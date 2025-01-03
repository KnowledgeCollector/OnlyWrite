import { LoadingDialog, router } from "@kit.ArkUI";
import { NoteUtils } from "../../utils/NoteUtils";
import { fileUri, picker } from '@kit.CoreFileKit';
import { common, Context } from "@kit.AbilityKit";
import { DbUtils } from "../../utils/DbUtils";
import { EmitterUtil, FileUtil, PreferencesUtil, ToastUtil } from "@pura/harmony-utils";
import { AppHelper } from "../../utils/AppHelper";
import { zlib } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs'
import { AliyunBackUpManager } from "./AliyunBackUpManager";
import { Constants } from "../../utils/Constants";
import { BaiduBackUpManager } from "./BaiduBackUpManager";

export class BackUpManager {
  private static instance: BackUpManager;

  public static getInstance() {
    if (!BackUpManager.instance) {
      BackUpManager.instance = new BackUpManager();
    }
    return BackUpManager.instance;
  }


  //本地备份
  backupLocal(context: Context) {
    try {
      let time = NoteUtils.getBackUpTime(Date.now())
      const documentSaveOptions = new picker.DocumentSaveOptions();
      // 配置保存的模式为DOWNLOAD，若配置了DOWNLOAD模式，此时配置的其他documentSaveOptions参数将不会生效。
      //1.获取Download目录权限
      documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
      const documentViewPicker = new picker.DocumentViewPicker(context);
      documentViewPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
        //2.备份数据库
        let dbName = time + ".zip"
        DbUtils.getInstance().backup(dbName)?.then(async () => {
          //备份到云端
          this.backupCloud(dbName)

          //备份到本地
          //Download中创建backup文件夹
          let uriString = new fileUri.FileUri(documentSaveResult[0])
          if (!FileUtil.accessSync(uriString.path + "/backup/")) {
            FileUtil.mkdirSync(uriString.path + "/backup/")
          }
          //删除重名备份文件
          let outSidePath = uriString.path + "/backup/" + dbName
          if (fs.accessSync(outSidePath)) {
            fs.unlink(outSidePath)
          }
          //将沙箱中备份的数据库复制到Download中
          FileUtil.copyFile(AppHelper.dbFolder + dbName, outSidePath).then(() => {
            ToastUtil.showToast($r('app.string.backup_ok'))
          })
        })
      })
    } catch (errData) {
      console.log('Backup fail:' + JSON.stringify(errData))
    }
  }

  //本地恢复
  restoreLocal(context: Context, listener: Function) {
    try {
      //1.获取Download目录授权
      const documentSaveOptions = new picker.DocumentSaveOptions();
      // 配置保存的模式为DOWNLOAD，若配置了DOWNLOAD模式，此时配置的其他documentSaveOptions参数将不会生效。
      documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
      const documentViewPicker = new picker.DocumentViewPicker(context);
      documentViewPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
        let uriString = new fileUri.FileUri(documentSaveResult[0])
        //创建backup文件夹
        let backUpFolder = uriString.path + "/backup/"
        if (!FileUtil.accessSync(backUpFolder)) {
          FileUtil.mkdirSync(backUpFolder)
        }
        uriString = new fileUri.FileUri(backUpFolder)
        //2.读取Download目录文件列表
        const documentSelectOptions = new picker.DocumentSelectOptions();
        // 选择文档的最大数目（可选）
        documentSelectOptions.maxSelectNumber = 1;
        // 指定选择的文件或者目录路径（可选）
        documentSelectOptions.defaultFilePathUri = uriString.getFullDirectoryUri();
        // 选择文件的后缀类型['后缀类型描述|后缀类型']（可选） 若选择项存在多个后缀名，则每一个后缀名之间用英文逗号进行分隔（可选），后缀类型名不能超过100,选择所有文件：'所有文件(*.*)|.*';
        documentSelectOptions.fileSuffixFilters = ['文档|.zip'];
        //选择是否对指定文件或目录授权，true为授权，当为true时，defaultFilePathUri为必选参数，拉起文管授权界面；false为非授权，拉起常规文管界面（可选）
        documentSelectOptions.authMode = true;
        documentViewPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
          documentSelectResult.forEach(async (uri) => {
            //将选择的备份文件复制到沙箱
            let fromFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
            let fileName = fromFile.name.substring(0, fromFile.name.lastIndexOf("."))
            let toFilePath = AppHelper.dbFolder + fileName + ".db"
            let backFile = fs.openSync(toFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
            fs.copyFileSync(fromFile.fd, backFile.fd);
            fs.closeSync(fromFile);
            fs.closeSync(backFile);
            //恢复数据库
            DbUtils.getInstance().restore(fileName + ".db")?.then(async () => {
              setTimeout(() => {
                listener()
              }, 200)
            })
          })
        })
      })
    } catch (errData) {
      console.log('Backup fail:' + JSON.stringify(errData))
    }
  }

  //备份到云
  backupCloud(dbName: string) {
    if (PreferencesUtil.getBooleanSync("aliyunpan_backup")) {
      AliyunBackUpManager.getInstance().backupCloud(AppHelper.dbFolder + dbName, dbName)
    } else if (PreferencesUtil.getBooleanSync("baiduyun_backup")) {
      BaiduBackUpManager.getInstance().backupCloud(AppHelper.dbFolder + dbName, dbName)
    }
  }

  //获取云备份文件
  getCloud(listener: Function) {
    if (PreferencesUtil.getBooleanSync("aliyunpan_backup")) {
      AliyunBackUpManager.getInstance().getCloud(listener)
    } else if (PreferencesUtil.getBooleanSync("baiduyun_backup")) {
      BaiduBackUpManager.getInstance().getCloud(listener)
    } else {
      ToastUtil.showToast($r('app.string.open_cloud'))
    }
  }

  //恢复云备份文件
  restoreCloud(index: number, listener: Function) {
    if (PreferencesUtil.getBooleanSync("aliyunpan_backup")) {
      AliyunBackUpManager.getInstance().restoreCloud(index, listener)
    } else if (PreferencesUtil.getBooleanSync("baiduyun_backup")) {
      BaiduBackUpManager.getInstance().restoreCloud(index, listener)
    }
  }
}