import { relationalStore } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";
import { NoteBean } from "../../bean/NoteBean";
import { DbUtils } from "../../utils/DbUtils";
import { AppHelper } from "../../utils/AppHelper";

export class NoteDbManager {
  private static instance: NoteDbManager;

  public static getInstance() {
    if (!NoteDbManager.instance) {
      NoteDbManager.instance = new NoteDbManager();
    }
    return NoteDbManager.instance;
  }

  public insertNote(note: NoteBean): Promise<boolean> {
    return new Promise<boolean>((resolve, reject) => {
      DbUtils.getInstance().getDb()?.insert('page',
        {
          'pageId': note.pageId,
          'chapterId': note.chapterId,
          'title': note.title,
          'content': note.content,
          'createTime': note.createTime,
          'editTime': note.editTime,
          'isdelete': note.isdelete,
          'deleteTime': note.deleteTime,
          'orderNum': note.orderNum
        }, (err: BusinessError, rows: number) => {
          if (err) {
            reject(err)
            return;
          }
          resolve(true)
        })
    })
  }

  public updateNote(note: NoteBean): Promise<boolean> {
    return new Promise<boolean>((resolve, reject) => {
      let predicates = new relationalStore.RdbPredicates('page');
      predicates.equalTo('pageId', note.pageId)
      DbUtils.getInstance().getDb()?.update({
        'pageId': note.pageId,
        'chapterId': note.chapterId,
        'title': note.title,
        'content': note.content,
        'createTime': note.createTime,
        'editTime': note.editTime,
        'isdelete': note.isdelete,
        'deleteTime': note.deleteTime,
        'orderNum': note.orderNum,
      }, predicates, (err: BusinessError, rows: number) => {
        if (err) {
          reject(err)
          return;
        }
        resolve(true)
      })
    })
  }


  public getNoteById(pageId: number): Promise<Array<NoteBean>> {
    let predicates = new relationalStore.RdbPredicates('page');
    predicates.equalTo('pageId', pageId)
    return this.getNotes(predicates)
  }


  public getNoteByChapterId(chapterId: number): Promise<Array<NoteBean>> {
    let predicates = new relationalStore.RdbPredicates('page');
    predicates.equalTo('chapterId', chapterId)
    this.sortPredicates(predicates)
    return this.getNotes(predicates)
  }

  private getNotes(predicates: relationalStore.RdbPredicates): Promise<Array<NoteBean>> {
    return new Promise<Array<NoteBean>>((resolve, reject) => {
      DbUtils.getInstance().getDb()?.query(predicates,
        ['pageId', 'chapterId', 'title', 'content', 'createTime', 'editTime', 'isdelete', 'deleteTime', 'orderNum'],
        (err: BusinessError, resultSet) => {
          if (err) {
            reject(err)
            return;
          }
          resolve(this.parseNote(resultSet))
          resultSet.close();
        })
    })
  }


  public deleteNote(pageId: number) {
    return new Promise<boolean>((resolve, reject) => {
      let predicates = new relationalStore.RdbPredicates('page');
      predicates.equalTo('pageId', pageId)
      DbUtils.getInstance().getDb()?.delete(predicates, (err: BusinessError, rows: number) => {
        if (err) {
          reject(err)
          return;
        }
        resolve(true)
      })
    })
  }

  public deleteNoteByChapter(chapterId: number) {
    return new Promise<boolean>((resolve, reject) => {
      let predicates = new relationalStore.RdbPredicates('page');
      predicates.equalTo('chapterId', chapterId)
      DbUtils.getInstance().getDb()?.delete(predicates, (err: BusinessError, rows: number) => {
        if (err) {
          reject(err)
          return;
        }
        resolve(true)
      })
    })
  }

  private parseNote(resultSet: relationalStore.ResultSet): Array<NoteBean> {
    let list: Array<NoteBean> = [];
    // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
    while (resultSet.goToNextRow()) {
      const pageId = resultSet.getValue(resultSet.getColumnIndex('pageId')) as number;
      const chapterId = resultSet.getValue(resultSet.getColumnIndex('chapterId')) as number;
      const title = resultSet.getString(resultSet.getColumnIndex('title'));
      const content = resultSet.getString(resultSet.getColumnIndex('content'));
      const createTime = resultSet.getValue(resultSet.getColumnIndex('createTime')) as number;
      const editTime = resultSet.getValue(resultSet.getColumnIndex('editTime')) as number;
      const isPreview = resultSet.getValue(resultSet.getColumnIndex('isdelete')) as boolean;
      const deleteTime = resultSet.getValue(resultSet.getColumnIndex('deleteTime')) as number;
      const orderNum = resultSet.getValue(resultSet.getColumnIndex('orderNum')) as number;
      list.push(new NoteBean(pageId, chapterId, title, content, createTime, editTime, isPreview, deleteTime, orderNum))
    }
    return list
  }


  private sortPredicates(predicates: relationalStore.RdbPredicates) {
    switch (AppHelper.sortType) {
      case 0:
        predicates.orderByAsc('createTime')
        break
      case 1:
        predicates.orderByDesc('createTime')
        break
      case 2:
        predicates.orderByAsc('createTime')
        break
      case 3:
        predicates.orderByDesc('editTime')
        break
      case 4:
        predicates.orderByAsc('title')
        break
      case 5:
        predicates.orderByDesc('title')
        break
    }
  }
}