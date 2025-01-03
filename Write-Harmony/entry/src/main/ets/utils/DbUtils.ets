import { relationalStore } from "@kit.ArkData";

export class DbUtils {
  private static instance: DbUtils;
  private static STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'startnow.db',
    securityLevel: relationalStore.SecurityLevel.S3, // 数据库安全级别
    encrypt: false,
  };
  private static dbStore: relationalStore.RdbStore | undefined = undefined

  public static getInstance() {
    if (!DbUtils.instance) {
      DbUtils.instance = new DbUtils();
    }
    return DbUtils.instance;
  }

  public async initDb(context: Context) {
    if (DbUtils.dbStore === undefined) {
      DbUtils.dbStore = await relationalStore.getRdbStore(context, DbUtils.STORE_CONFIG)
    }
  }

  public getDb(): relationalStore.RdbStore | undefined {
    return DbUtils.dbStore
  }

  public backup(fileName: string) {
    return DbUtils.dbStore?.backup(fileName)
  }

  public restore(fileName: string) {
    return DbUtils.dbStore?.restore(fileName)
  }
}