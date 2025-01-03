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
import { PartInfo } from '../../../bean/PartInfo';
import fs from '@ohos.file.fs';
import { AliyunFile } from '../../../bean/AliyunFile';
import { AliyunFileList } from '../../../bean/AliyunFileList';

// 单例模式的工具类
export class AliyunUtils {
  private static _singleton: AliyunUtils = new AliyunUtils();
  private dioToken: AxiosInstance | null = null;

  private constructor() {
    // 私有构造函数，禁止外部实例化
  }

  static getInstance(): AliyunUtils {
    return AliyunUtils._singleton;
  }

  private getDio(): AxiosInstance {
    if (!this.dioToken) {
      this.dioToken = axios.create({
        baseURL: 'https://openapi.alipan.com',
        timeout: 600000, // 600 秒
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

  private async _post(url: string, needToken: boolean,
    params: Record<string, string | number | object>): Promise<object | string | undefined> {
    if (needToken) {
      //需要权限
      let lastTime: number = PreferencesUtil.getNumberSync("aliyunpan_token_time");
      let expires_in = PreferencesUtil.getNumberSync("aliyunpan_expires_in");
      if (lastTime != null && expires_in != null && (Date.now() - lastTime) / 1000 > expires_in) {
        //过期刷新token
        let token = await this.aliyunpan_refreshToken();
        if (token) {
          //保存token
          PreferencesUtil.putSync("aliyunpan_token", token['access_token']);
          PreferencesUtil.putSync("aliyunpan_refreshtoken", token['refresh_token']);
          PreferencesUtil.putSync("aliyunpan_expires_in", token['expires_in']);
          PreferencesUtil.putSync("aliyunpan_token_time", Date.now());
          this.getDio().defaults.headers.common['Authorization'] =
            "Bearer " + PreferencesUtil.getStringSync("aliyunpan_token");
          return this._basePost(url, params);
        } else {
          ToastUtil.showToast("当前授权已过期，请重新授权")
          return undefined
        }
      } else {
        //未过期
        this.getDio().defaults.headers.common['Authorization'] =
          "Bearer " + PreferencesUtil.getStringSync("aliyunpan_token");
        return this._basePost(url, params);
      }
    } else {
      return this._basePost(url, params);
    }
  }

  private async _basePost(url: string,
    params: Record<string, string | number | object>): Promise<object | string | undefined> {
    try {
      let response: AxiosResponse =
        await this.getDio().post<string, AxiosResponse<string>, Record<string, string | number | object>>(url, params)
      return response.data
    } catch (error) {
      if (error.response?.status === 429) {
        let result: string = await new Promise((resolve, reject) => {
          setTimeout(() => resolve("延迟11000"), 11000);
        });
        return this._basePost(url, params);
      } else {
        console.info(JSON.stringify(error));
        return undefined
      }
    }
  }

  private async _get(url: string): Promise<object | string | undefined> {
    try {
      const response: AxiosResponse = await this.getDio().get(url);
      return response.data;
    } catch (error) {
      console.error('GET Error:', error);
      return undefined;
    }
  }


  public aliyunpan_getToken(code: string): Promise<object | string | undefined> {
    let map: Record<string, string | number | object> = {}
    map["client_id"] = "13e96672b3f54e71b137df5839ec9f75";
    map["client_secret"] = "167c70c6d38e4c8abde36ef887217b21";
    map["code"] = code;
    map["grant_type"] = "authorization_code";
    return this._post("/oauth/access_token", false, map);
  }

  public aliyunpan_refreshToken(): Promise<object | string | undefined> {
    let map: Record<string, string | number | object> = {}
    map["client_id"] = "13e96672b3f54e71b137df5839ec9f75";
    map["client_secret"] = "167c70c6d38e4c8abde36ef887217b21";
    map["grant_type"] = "refresh_token";
    map["refresh_token"] = PreferencesUtil.getStringSync("aliyunpan_refreshtoken");
    return this._post("/oauth/access_token", false, map);
  }

  public aliyunpan_getDriveInfo(): Promise<object | string | undefined> {
    let map: Record<string, string | number | object> = {}
    return this._post("/adrive/v1.0/user/getDriveInfo", true, map);
  }

  public aliyunpan_getSpaceInfo(): Promise<object | string | undefined> {
    let map: Record<string, string | number | object> = {}
    return this._post("/adrive/v1.0/user/getSpaceInfo", true, map);
  }

  public aliyunpan_createFile(name: String, type: String,
    parent_file_id: String): Promise<object | string | undefined> {
    let map: Record<string, string | number | object> = {}
    map["drive_id"] = PreferencesUtil.getStringSync("aliyunpan_driveid");
    map["parent_file_id"] = parent_file_id;
    map["name"] = name;
    map["type"] = type;
    map["check_name_mode"] = "refuse";
    return this._post("/adrive/v1.0/openFile/create", true, map);
  }

  public aliyunpan_initPath(listener: Function) {
    this.aliyunpan_createFile("只是写作", "folder", "root").then((data) => {
      if (data) {
        let aliyunpan_folder = PreferencesUtil.getStringSync("aliyunpan_folder");
        if (aliyunpan_folder != null) {
          if (aliyunpan_folder.includes("/")) {
            let folders: Array<String> = aliyunpan_folder.split("/");
            this.aliyunpan_createFile(folders[1], "folder", data['file_id']).then((file) => {
              if (file) {
                PreferencesUtil.putSync("aliyunpan_app_fileid", file['file_id']);
                listener(true);
                this.initHtmlPath();
              } else {
                listener(false)
              }
            })
          } else {
            PreferencesUtil.putSync("aliyunpan_app_fileid", data['file_id']);
            listener(true);
            this.initHtmlPath();
          }
        } else {
          listener(false);
        }
      } else {
        listener(false)
      }
    })
  }

  public initHtmlPath() {
    //离线网页文件夹
    let fileId: string = PreferencesUtil.getStringSync("aliyunpan_app_fileid");
    if (fileId && fileId.length > 0) {
      this.aliyunpan_createFile("html", "folder", fileId).then((folder) => {
        if (folder) {
          PreferencesUtil.putSync("aliyunpan_html_fileid", folder['file_id']);
        }
      });
    }
  }

  public aliyunpan_uploadFile(fileId: string, fileName: string, path: string, listener: Function) {
    //判断文件大小，大于100M则分段上传
    this.aliyunpan_createFile(fileName, "file", fileId).then((createFile) => {
      if (createFile) {
        if (createFile['part_info_list'] && createFile['upload_id']) {
          this._uploadFile(path, fileName, createFile['part_info_list'][0], (ok: boolean) => {
            if (ok) {
              this._aliyunpan_uploadComplete(createFile['file_id'], createFile['upload_id']).then((value) => {
                if (value != null) {
                  listener(true);
                } else {
                  listener(false);
                }
              });
            } else {
              listener(false);
            }
          });
        } else {
          listener(false);
        }
      } else {
        listener(false);
      }
    });
  }

  private _uploadFile(filePath: string, fileName: string, partInfo: PartInfo, listener: Function) {
    let file2 = fs.openSync(filePath, 0o2);
    let stat = fs.lstatSync(filePath);
    let buf2 = new ArrayBuffer(stat.size);
    fs.readSync(file2.fd, buf2);
    fs.fsyncSync(file2.fd);
    fs.closeSync(file2.fd);
    // 发送请求
    axios.put(partInfo.upload_url, buf2, {
      context: getContext(this),
      timeout: 6000000,
      headers: {
        'Content-Length': stat.size.toString(),
        'Content-Type': ''
      },
      onUploadProgress: (progressEvent: AxiosProgressEvent): void => {
        console.info(progressEvent && progressEvent.loaded && progressEvent.total ?
          Math.ceil(progressEvent.loaded / progressEvent.total * 100) + '%' : '0%');
      },
    }).then((res: AxiosResponse) => {
      console.info("result" + JSON.stringify(res.data));
      listener(true);
    }).catch((error: AxiosError) => {
      console.error("error:" + JSON.stringify(error));
      listener(false);
    })
  }

  public _aliyunpan_uploadComplete(file_id: string, upload_id: string) {
    let map: Record<string, string | number | object> = {}
    map["drive_id"] = PreferencesUtil.getStringSync("aliyunpan_driveid");
    map["file_id"] = file_id;
    map["upload_id"] = upload_id;
    return this._post("/adrive/v1.0/openFile/complete", true, map);
  }

  public aliyunpan_getFileList(marker: string, parent_file_id: string,
    category: string): Promise<object | string | undefined> {
    let map: Record<string, string | number | object> = {}
    map["drive_id"] = PreferencesUtil.getStringSync("aliyunpan_driveid");
    map["parent_file_id"] = parent_file_id;
    map["marker"] = marker;
    map["limit"] = 100;
    map["order_by"] = "created_at";
    map["order_direction"] = "DESC";
    map["category"] = category;
    map["type"] = "all"; //video|doc|audio|zip|others|image
    return this._post("/adrive/v1.0/openFile/list", true, map);
  }

  private _aliyunpan_getDownloadUrl(file_id: string): Promise<object | string | undefined> {
    let map: Record<string, string | number | object> = {}
    map["drive_id"] = PreferencesUtil.getStringSync("aliyunpan_driveid");
    map["file_id"] = file_id;
    map["order_by"] = "created_at";
    return this._post("/adrive/v1.0/openFile/getDownloadUrl", true, map);
  }

  //下载网络文件
  private _aliyunpan_downloadFile(url: string, desPath: string, listener: Function) {
    try {
      fs.accessSync(desPath);
      fs.unlinkSync(desPath);
    } catch (err) {
    }
    axios({
      url: url,
      method: 'get',
      // context: getContext(this),
      filePath: desPath,
      onDownloadProgress: (progressEvent: AxiosProgressEvent): void => {
        console.info("progress: " + progressEvent.loaded.toString() + "A" + progressEvent.total?.toString())
      }
    }).then((res: AxiosResponse) => {
      listener(true)
      console.info("result: " + JSON.stringify(res.data));
    }).catch((error: AxiosError) => {
      listener(false);
      console.error("error:" + JSON.stringify(error));
      if (error.toString().includes("403")) {
        ToastUtil.showToast("请求太频繁请稍后再试!")
      } else {
        ToastUtil.showToast("aliyunpan_downloadFile fail：" + JSON.stringify(error))
      }
    })
  }

  public getAllAliyunFiles(marker: string, isHtml: boolean, files: Array<AliyunFile>, listener: Function) {
    let fileId: string = PreferencesUtil.getStringSync(isHtml ? "aliyunpan_html_fileid" : "aliyunpan_app_fileid");
    if (fileId != null) {
      this.aliyunpan_getFileList(marker, fileId, "zip,others").then((value) => {
        if (value) {
          let aliyunFileList: AliyunFileList = JSON.parse(JSON.stringify(value)) as AliyunFileList;
          aliyunFileList.items.forEach((item) => {
            files.push(item);
          })
          if (aliyunFileList.next_marker && aliyunFileList.next_marker.length > 0) {
            this.getAllAliyunFiles(marker, isHtml, files, listener);
          } else {
            listener(files);
          }
        } else {
          listener(files);
        }
      }
      )
    }
  }

  public getAllCloudFiles(marker: string, fileId: string, files: Array<AliyunFile>, listener: Function) {
    this.aliyunpan_getFileList(marker, fileId, "video,doc,audio,zip,others,image").then((value) => {
      if (value) {
        let aliyunFileList: AliyunFileList = JSON.parse(JSON.stringify(value)) as AliyunFileList
        files.forEach((item) => {
          files.push(item);
        })
        if (aliyunFileList.next_marker && aliyunFileList.next_marker.length > 0) {
          this.getAllCloudFiles(marker, fileId, files, listener);
        } else {
          listener(files);
        }
      } else {
        listener(files);
      }
    }
    );
  }

  public downLoadAliyun(file_id: string, path: string, listener: Function) {
    this._aliyunpan_getDownloadUrl(file_id).then((value) => {
      if (value) {
        let downLoadUrl: string = value["url"];
        this._aliyunpan_downloadFile(downLoadUrl, path, listener);
      }
    }
    );
  }

  public aliyunpan_deleteFile(file_id: string):
    Promise<object | string | undefined> {
    let map: Record<string, string | number | object> = {}
    map["drive_id"] = PreferencesUtil.getStringSync("aliyunpan_driveid");
    map["file_id"] = file_id;
    return this._post("/adrive/v1.0/openFile/delete", true, map);
  }
}
