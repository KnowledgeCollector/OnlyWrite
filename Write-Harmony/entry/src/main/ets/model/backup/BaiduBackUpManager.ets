import { Context } from "@kit.AbilityKit";
import { DbUtils } from "../../utils/DbUtils";
import { ToastUtil } from "@pura/harmony-utils";
import { AppHelper } from "../../utils/AppHelper";
import { BaiduyunUtils } from "../cloud/baiduyun/BaiduyunUtils";
import { BaiduListlFile } from "../../bean/BaiduListFile";

export class BaiduBackUpManager {
  private static instance: BaiduBackUpManager;

  public static getInstance() {
    if (!BaiduBackUpManager.instance) {
      BaiduBackUpManager.instance = new BaiduBackUpManager();
    }
    return BaiduBackUpManager.instance;
  }


  //备份到云
  backupCloud(dbPath: string, dbFileName: string) {
    try {
      BaiduyunUtils.getInstance().baidupan_uploadFile(dbFileName, dbPath, (ok: boolean) => {
        if (ok) {
          ToastUtil.showToast($r('app.string.cloud_backup_ok'))
        }
      })
    } catch (errData) {
      console.log('Backup fail:' + JSON.stringify(errData))
    }
  }


  private restoredbFiles: Array<BaiduListlFile> = []

  getCloud(listener: Function) {
    try {
      this.restoredbFiles = []
      BaiduyunUtils.getInstance().baidupan_getFileList("", 0, (files: Array<BaiduListlFile>) => {
        if (files.length > 0) {
          files.forEach((item) => {
            if (item.server_filename.endsWith(".zip")) {
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
    let dbPath = AppHelper.dbFolder + file.server_filename
    BaiduyunUtils.getInstance().baidupan_downloadFile(JSON.stringify([file.fs_id]), dbPath, async (ok: boolean) => {
      if (ok) {
        DbUtils.getInstance().restore(file.server_filename)
        setTimeout(() => {
          listener()
        }, 500)
      }
    }
    )
  }
}