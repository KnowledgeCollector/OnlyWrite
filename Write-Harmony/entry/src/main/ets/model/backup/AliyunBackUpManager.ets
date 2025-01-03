import { Context } from "@kit.AbilityKit";
import { DbUtils } from "../../utils/DbUtils";
import { PreferencesUtil, ToastUtil } from "@pura/harmony-utils";
import { AppHelper } from "../../utils/AppHelper";
import { AliyunUtils } from "../cloud/aliyun/AliyunUtils";
import { AliyunFile } from "../../bean/AliyunFile";

export class AliyunBackUpManager {
  private static instance: AliyunBackUpManager;

  public static getInstance() {
    if (!AliyunBackUpManager.instance) {
      AliyunBackUpManager.instance = new AliyunBackUpManager();
    }
    return AliyunBackUpManager.instance;
  }


  //备份到阿里云
  backupCloud(dbPath: string, dbFileName: string) {
    try {
      AliyunUtils.getInstance()
        .aliyunpan_uploadFile(PreferencesUtil.getStringSync("aliyunpan_app_fileid"), dbFileName, dbPath,
          (ok: boolean) => {
            if (ok) {
              ToastUtil.showToast($r('app.string.cloud_backup_ok'))
            }
          })
    } catch (errData) {
      console.log('Backup fail:' + JSON.stringify(errData))
    }
  }


  private restoredbFiles: Array<AliyunFile> = []

  getCloud(listener: Function) {
    try {
      this.restoredbFiles = []
      AliyunUtils.getInstance().getAllAliyunFiles("", false, [], (files: Array<AliyunFile>) => {
        if (files.length > 0) {
          files.forEach((item) => {
            if (item.name.endsWith(".zip")) {
              this.restoredbFiles.push(item)
            }
          })
          listener(this.restoredbFiles)
        }
      })
    } catch (errData) {
      ToastUtil.showToast(JSON.stringify(errData))
      console.log('Backup fail:' + JSON.stringify(errData))
    }
  }

  restoreCloud(index: number, listener: Function) {
    let file = this.restoredbFiles[index]
    let dbPath = AppHelper.dbFolder + file.name
    AliyunUtils.getInstance().downLoadAliyun(file.file_id, dbPath, async (ok: boolean) => {
      if (ok) {
        DbUtils.getInstance().restore(file.name)
        setTimeout(() => {
          listener()
        }, 500)
      }
    }
    )
  }
}