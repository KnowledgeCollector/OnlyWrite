import { relationalStore } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";
import { DbUtils } from "../../utils/DbUtils";
import { ChapterBean } from "../../bean/ChapterBean";

export class ChapterDbManager {
  private static instance: ChapterDbManager;

  public static getInstance() {
    if (!ChapterDbManager.instance) {
      ChapterDbManager.instance = new ChapterDbManager();
    }
    return ChapterDbManager.instance;
  }

  public insertChapter(type: ChapterBean) {
    return new Promise<boolean>((resolve, reject) => {
      DbUtils.getInstance().getDb()?.insert('chapter', {
        'id': type.id,
        'chapterName': type.chapterName,
        'orderNum': type.orderNum,
        'bookId': type.bookId,
      }, (err: BusinessError, rowId: number) => {
        if (err) {
          reject(err)
          return;
        }
        resolve(true)
      })
    })
  }

  public updateChapter(type: ChapterBean) {
    return new Promise<boolean>((resolve, reject) => {
      let predicates = new relationalStore.RdbPredicates('chapter'); // 创建表'EMPLOYEE'的predicates
      predicates.equalTo('id', type.id);
      DbUtils.getInstance().getDb()?.update({
        'id': type.id,
        'chapterName': type.chapterName,
        'orderNum': type.orderNum,
        'bookId': type.bookId,
      }, predicates, (err: BusinessError, rows: number) => {
        if (err) {
          reject(err)
          return;
        }
        resolve(true)
      })
    })
  }

  public deleteChapter(typeId: number) {
    return new Promise<boolean>((resolve, reject) => {
      let predicates = new relationalStore.RdbPredicates('chapter');
      predicates.equalTo('id', typeId);
      DbUtils.getInstance().getDb()?.delete(predicates, (err: BusinessError, rows: number) => {
        if (err) {
          reject(err)
          return;
        }
        resolve(true)
      })
    })
  }


  public getAllChapters(): Promise<Array<ChapterBean>> {
    let predicates = new relationalStore.RdbPredicates('chapter');
    return this.getChapters(predicates)
  }

  public getChaptersByBookId(bookId: number): Promise<Array<ChapterBean>> {
    let predicates = new relationalStore.RdbPredicates('chapter');
    predicates.equalTo('bookId', bookId)
    predicates.orderByAsc('orderNum')
    return this.getChapters(predicates)
  }

  public getChapterById(id: number): Promise<Array<ChapterBean>> {
    let predicates = new relationalStore.RdbPredicates('chapter');
    predicates.equalTo('id', id)
    return this.getChapters(predicates)
  }

  private getChapters(predicates: relationalStore.RdbPredicates): Promise<Array<ChapterBean>> {
    return new Promise<Array<ChapterBean>>((resolve, reject) => {
      DbUtils.getInstance().getDb()?.query(predicates,
        ['id', 'chapterName', 'orderNum', 'bookId'], (err: BusinessError, resultSet) => {
          if (err) {
            reject(err)
            return;
          }
          resolve(this.parseBean(resultSet))
          resultSet.close();
        })
    })
  }

  private parseBean(resultSet: relationalStore.ResultSet): Array<ChapterBean> {
    let list: Array<ChapterBean> = [];
    // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
    while (resultSet.goToNextRow()) {
      const id = resultSet.getValue(resultSet.getColumnIndex('id')) as number;
      const orderNum = resultSet.getValue(resultSet.getColumnIndex('orderNum')) as number;
      const chapterName = resultSet.getString(resultSet.getColumnIndex('chapterName'));
      const bookId = resultSet.getValue(resultSet.getColumnIndex('bookId')) as number;
      list.push(new ChapterBean(id, chapterName, orderNum, bookId))
    }
    return list
  }
}