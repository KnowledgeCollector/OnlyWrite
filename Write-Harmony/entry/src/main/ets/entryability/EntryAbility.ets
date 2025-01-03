import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import fs, { ReadOptions } from '@ohos.file.fs'
import { DbUtils } from '../utils/DbUtils';
import { AppUtil } from '@pura/harmony-utils/src/main/ets/utils/AppUtil';
import { PreferencesUtil } from '@pura/harmony-utils';
import { AppHelper } from '../utils/AppHelper';
import { KeyboardAvoidMode } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    //数据库路径
    AppHelper.dbFolder = this.context.getApplicationContext().databaseDir + '/entry/rdb/'
    AppHelper.dbFilePath = AppHelper.dbFolder + "startnow.db"
    //数据库初始化
    await this.initDb()
    //工具类初始化
    AppUtil.init(this.context);
    //首选项初始化
    PreferencesUtil.init("zsk")
    windowStage.loadContent('pages/edit/EditPage', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  async initDb() {
    try {
      if (!fs.accessSync(AppHelper.dbFolder)) {
        fs.mkdirSync(AppHelper.dbFolder, true);
        this.context.resourceManager.getRawFd('startnow.db', async (error, file) => {
          if (error != null) {
            console.log(`哈哈：Get AppDataBase failed, error code: ${error.code}, message: ${error.message}.`);
          } else {
            let dbPath = AppHelper.dbFilePath
            let cacheFile = fs.openSync(dbPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
            // 读取缓冲区大小
            let bufferSize = 30000
            let buffer = new ArrayBuffer(bufferSize); //创建buffer缓冲区
            // 要copy的文件的offset和length
            let currentOffset = file.offset;
            let lengthNeedToReed = file.length;
            let readOption: ReadOptions = {
              offset: currentOffset, //期望读取文件的位置。可选，默认从当前位置开始读
              length: bufferSize //每次期望读取数据的长度。可选，默认缓冲区长度
            }
            // 后面len会一直减，直到没有
            while (true) {
              // 读取buffer容量的内容
              let readLength = fs.readSync(file.fd, buffer, readOption);
              // 写入buffer容量的内容
              fs.writeSync(cacheFile.fd, buffer, {
                length: readLength
              }) //写到cacheFile里
              // 判断后续内容 修改读文件的参数
              // buffer没读满代表文件读完了
              if (readLength < bufferSize) {
                break;
              }
              if (readOption.offset) {
                readOption.offset += readLength;
              }
            }
            fs.close(cacheFile);
            await DbUtils.getInstance().initDb(this.context)
          }
        });
      } else {
        console.error('哈哈：AppDataBase exist');
        await DbUtils.getInstance().initDb(this.context)
      }
    } catch (error) {
      console.error(`哈哈哈：Init AppDataBase failed, error code: ${error.code}, message: ${error.message}.`)
    }
  }
}
