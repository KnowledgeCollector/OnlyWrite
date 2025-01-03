import axios, {
  AxiosError,
  AxiosInstance,
  AxiosProgressEvent,
  AxiosResponse,
  FormData,
  InternalAxiosRequestConfig
} from '@ohos/axios';
import { PreferencesUtil, ToastUtil } from '@pura/harmony-utils';
import { JSON } from '@kit.ArkTS';
import fs from '@ohos.file.fs';
import { BaiduListlFile } from '../../../bean/BaiduListFile';
import { BaiduDetailFile } from '../../../bean/BaiduDetailFile';
import { hash } from '@kit.CoreFileKit';

// 单例模式的工具类
export class BaiduyunUtils {
  private static _singleton: BaiduyunUtils = new BaiduyunUtils();
  private dioToken: AxiosInstance | null = null;

  private constructor() {
    // 私有构造函数，禁止外部实例化
  }

  static getInstance(): BaiduyunUtils {
    return BaiduyunUtils._singleton;
  }

  private getDio(post: boolean): AxiosInstance {
    if (!this.dioToken) {
      this.dioToken = axios.create({
        baseURL: post ? "https://pan.baidu.com/rest/2.0/xpan/" : "",
        timeout: 600000, // 600 秒
        headers: {
          "User-Agent": "pan.baidu.com",
          "Content-Type": "application/x-www-form-urlencoded"
        }
      });
      // Add a request interceptor.
      axios.interceptors.request.use((config: InternalAxiosRequestConfig) => {
        // Do something about the request data.
        return config;
      }, (error: AxiosError) => {
        // Do something with the request error.
        return Promise.reject(error);
      });

      // Add a response interceptor.
      axios.interceptors.response.use((response: AxiosResponse) => {
        // Do something about the response data.
        return response;
      }, (error: AxiosError) => {
        // Do something with the response error.
        return Promise.reject(error);
      });
    }
    return this.dioToken
  }

  private async _get(url: string): Promise<object | undefined> {
    try {
      const response: AxiosResponse = await this.getDio(false).get(url);
      let code = 0
      if (response.data.errno) {
        code = response.data.errno
      }
      if (response.data.error_code) {
        code = response.data.error_code
      }
      if (code == 0) {
        return response.data
      } else {
        ToastUtil.showToast(url + " post fail：" + code)
        return undefined
      }
    } catch (error) {
      console.error('GET Error:', error);
      return undefined;
    }
  }


  private async _post(method: string, params: Record<string, string | number | object>): Promise<object | undefined> {
    try {
      let token = PreferencesUtil.getStringSync("baiduyun_token")
      let response: AxiosResponse = await this.getDio(true)
        .post<string, AxiosResponse<string>, Record<string, string | number | object>>(method + "&access_token=" +
          token, params)
      let code = 0
      if (response.data.errno) {
        code = response.data.errno
      }
      if (code == 0 || code == -8 || code == 31061) {
        return response.data
      } else {
        ToastUtil.showToast(method + " get fail：" + code)
        return undefined
      }
    } catch (error) {
      if (error.response?.status === 429) {
        let result: string = await new Promise((resolve, reject) => {
          setTimeout(() => resolve("延迟11000"), 11000);
        });
        return this._post(method, params);
      } else {
        console.info(JSON.stringify(error));
        return undefined
      }
    }
  }

  private baidupan_precreateFile(fileName: string, isFolder: number, size: number,
    blockList: string): Promise<object | undefined> {
    let map: Record<string, string | number | object> = {}
    let folder = PreferencesUtil.getStringSync("baiduyun_folder")
    map["path"] = "/apps/" + folder + "/" + fileName;
    map["size"] = size.toString();
    map["block_list"] = blockList;
    map["isdir"] = isFolder.toString();
    map["rtype"] = "3";
    map["autoinit"] = "1";
    return this._post("file?method=precreate", map)
  }

  private baidupan_createFile(fileName: string, size: number, uploadid: string,
    blockList: string): Promise<object | undefined> {
    let map: Record<string, string | number | object> = {}
    let folder = PreferencesUtil.getStringSync("baiduyun_folder")
    map["path"] = "/apps/" + folder + "/" + fileName;
    map["size"] = size.toString();
    map["uploadid"] = uploadid;
    map["block_list"] = blockList;
    map["isdir"] = "0";
    map["rtype"] = "3";
    return this._post("file?method=create", map)
  }

  async baidupan_createFolder(fileName: string): Promise<object | undefined> {
    let map: Record<string, string | number | object> = {}
    let folder = PreferencesUtil.getStringSync("baiduyun_folder")
    map["path"] = "/apps/" + folder + "/" + fileName;
    map["isdir"] = "1";
    map["rtype"] = "0";
    return this._post("file?method=create", map)
  }

  private baidupan_getUploadUrl(fileName: string, uploadId: string): Promise<object | undefined> {
    let token = PreferencesUtil.getStringSync("baiduyun_token")
    let folder = PreferencesUtil.getStringSync("baiduyun_folder")
    return this._get("https://d.pcs.baidu.com/rest/2.0/pcs/file?method=locateupload&appid=85359603&access_token=" + token + "&path=/apps/" + folder + "/" + folder + "&uploadid=" + uploadId + "&upload_version=2.0",)
  }


  async baidupan_uploadFile(fileName: string, path: string, listener: Function) {
    //判断文件大小，大于100M则分段上传
    let token = PreferencesUtil.getStringSync("baiduyun_token")
    let folder = PreferencesUtil.getStringSync("baiduyun_folder")
    let stat = fs.lstatSync(path);
    let blockList: Array<string> = [];
    let md5 = await hash.hash(path, "md5")
    blockList.push(md5);
    this.baidupan_precreateFile(fileName, 0, stat.size, JSON.stringify(blockList)).then((createFile) => {
      if (createFile) {
        this.baidupan_getUploadUrl(fileName, createFile["uploadid"]).then((value) => {
          if (value != null && value["error_code"] == 0) {
            let uploadRootUrl: string = value["servers"][0]["server"];
            let cloudPath = "/apps/" + folder + "/" + fileName;
            let uploadUrl =
              uploadRootUrl + "/rest/2.0/pcs/file?method=upload&access_token=" + token + "&path=" + cloudPath +
                "&ondup=overwrite";
            this.baidupan_upLoadSingleFile(uploadUrl, fileName, path, listener);
          }
        });
      }
    });
  }

  //上传小文件
  private baidupan_upLoadSingleFile(url: string, fileName: string, path: string, listener: Function,) {
    let formData = new FormData()
    formData.append("file", path, { filename: fileName });
    axios.post<string, AxiosResponse<string>, FormData>(url, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      context: getContext(this),
      onUploadProgress: (progressEvent: AxiosProgressEvent): void => {
        console.info(progressEvent && progressEvent.loaded && progressEvent.total ?
          Math.ceil(progressEvent.loaded / progressEvent.total * 100) + '%' : '0%');
      },
    }).then((response: AxiosResponse) => {
      let code = 0
      if (response.data.error_code) {
        code = response.data.error_code
      }
      if (code == 0) {
        listener(true);
      } else {
        listener(false)
        ToastUtil.showToast("upload " + fileName + " fail")
      }
    }).catch((err: AxiosError) => {
      console.error("error:" + JSON.stringify(err));
      ToastUtil.showToast("upload " + fileName + " fail：" + JSON.stringify(err))
      listener(false);
    })
  }

  /////////////////////////////////////////////上传文件结束////////////////////////////////////////

  /////////////////////////////////////////////获取文件列表开始////////////////////////////////////////

  //path必须以/开头或者为空
  baidupan_getFileList(path: String, start: number, listener: Function) {
    let token = PreferencesUtil.getStringSync("baiduyun_token")
    let folder = PreferencesUtil.getStringSync("baiduyun_folder")
    this._get("https://pan.baidu.com/rest/2.0/xpan/file?method=list&dir=/apps/" + folder + path + "&access_token=" + token + "&order=time&desc=1&start=" + start).then((value) => {
      if (value && value["list"]) {
        let list: Array<BaiduListlFile> = JSON.parse(JSON.stringify(value["list"])) as Array<BaiduListlFile>
        let files: Array<BaiduListlFile> = []
        list.forEach((item) => {
          if (item.isdir == 0) {
            files.push(item)
          }
        })
        listener(files)
      } else {
        ToastUtil.showToast("baidupan_getFileList fail")
      }
    }
    )
  }

  /////////////////////////////////////////////获取文件列表结束////////////////////////////////////////

  /////////////////////////////////////////////下载文件开始////////////////////////////////////////
  private baidupan_getFileDetail(fsids: string, listener: Function) {
    let token = PreferencesUtil.getStringSync("baiduyun_token")
    this._get("https://pan.baidu.com/rest/2.0/xpan/multimedia?method=filemetas&access_token=" + token + "&dlink=1&fsids=" + fsids).then((value) => {
      if (value&&value["list"]) {
        let list: Array<BaiduDetailFile> = JSON.parse(JSON.stringify(value["list"])) as Array<BaiduDetailFile>
        listener(list)
      } else {
        ToastUtil.showToast("baidupan_getFileDetail fail")
      }
    })
  }

  //下载网络文件
  baidupan_downloadFile(fsids: string, desPath: string, listener: Function) {
    try {
      fs.accessSync(desPath);
      fs.unlinkSync(desPath);
    } catch (err) {
    }
    let token = PreferencesUtil.getStringSync("baiduyun_token")
    this.baidupan_getFileDetail(fsids, (files: Array<BaiduDetailFile>) => {
      if (files.length > 0) {
        axios({
          // context: getContext(this),
          method: 'get',
          url: files[0].dlink + "&access_token=" + token,
          filePath: desPath,
          headers: {
            "User-Agent": "pan.baidu.com"
          },
          onDownloadProgress: (progressEvent: AxiosProgressEvent): void => {
            console.info("progress: " + progressEvent.loaded.toString() + "A" + progressEvent.total?.toString())
          }
        }).then((res: AxiosResponse) => {
          listener(true)
          console.info("result: " + JSON.stringify(res.data));
        }).catch((error: AxiosError) => {
          listener(false)
          console.error("error:" + JSON.stringify(error));
          ToastUtil.showToast("baidupan_downloadFile fail：" + JSON.stringify(error))
        })
      }
    })
  }

  /////////////////////////////////////////////下载文件结束////////////////////////////////////////
  /////////////////////////////////////////////删除文件开始////////////////////////////////////////

  baidupan_deleteFile(fsids: string): Promise<object | undefined> {
    let map: Record<string, string | number | object> = {}
    map["opera"] = "delete";
    map["async"] = "0";
    map["filelist"] = fsids;
    return this._post(
      "file?method=filemanager&opera=delete", map
    )
  }

  /////////////////////////////////////////////删除文件结束////////////////////////////////////////
}
