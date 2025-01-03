import { relationalStore } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";
import { DbUtils } from "../../utils/DbUtils";
import { BookBean } from "../../bean/BookBean";

export class BookDbManager {
  private static instance: BookDbManager;

  public static getInstance() {
    if (!BookDbManager.instance) {
      BookDbManager.instance = new BookDbManager();
    }
    return BookDbManager.instance;
  }

  public insertBook(book: BookBean) {
    return new Promise<boolean>((resolve, reject) => {
      DbUtils.getInstance().getDb()?.insert('book', {
        'id': book.id,
        'bookName': book.bookName,
        'orderNum': book.orderNum,
        'parentBookId': book.parentBookId
      }, (err: BusinessError, rowId: number) => {
        if (err) {
          reject(err)
          return;
        }
        resolve(true)
      })
    })
  }

  public updateBook(book: BookBean) {
    return new Promise<boolean>((resolve, reject) => {
      let predicates = new relationalStore.RdbPredicates('book');
      predicates.equalTo('id', book.id);
      DbUtils.getInstance().getDb()?.update({
        'id': book.id,
        'bookName': book.bookName,
        'orderNum': book.orderNum,
        'parentBookId': book.parentBookId
      }, predicates, (err: BusinessError, rows: number) => {
        if (err) {
          reject(err)
          return;
        }
        resolve(true)
      })
    })
  }

  public deleteBook(id: number) {
    return new Promise<boolean>((resolve, reject) => {
      let predicates = new relationalStore.RdbPredicates('book');
      predicates.equalTo('id', id);
      DbUtils.getInstance().getDb()?.delete(predicates, (err: BusinessError, rows: number) => {
        if (err) {
          reject(err)
          return;
        }
        resolve(true)
      })
    })
  }

  public getBookById(bookId: number): Promise<Array<BookBean>> {
    let predicates = new relationalStore.RdbPredicates('book');
    predicates.equalTo('id', bookId)
    return this.getBooks(predicates)
  }

  public getAllBooks(): Promise<Array<BookBean>> {
    let predicates = new relationalStore.RdbPredicates('book');
    predicates.orderByAsc('orderNum')
    return this.getBooks(predicates)
  }

  private getBooks(predicates: relationalStore.RdbPredicates): Promise<Array<BookBean>> {
    return new Promise<Array<BookBean>>((resolve, reject) => {
      DbUtils.getInstance().getDb()?.query(predicates, ['id', 'bookName', 'orderNum', 'parentBookId'], (err: BusinessError, resultSet) => {
          if (err) {
            reject(err)
            return;
          }
          resolve(this.parseBean(resultSet))
          resultSet.close();
        })
    })
  }

  private parseBean(resultSet: relationalStore.ResultSet): Array<BookBean> {
    let list: Array<BookBean> = [];
    while (resultSet.goToNextRow()) {
      const id = resultSet.getValue(resultSet.getColumnIndex('id')) as number;
      const orderNum = resultSet.getValue(resultSet.getColumnIndex('orderNum')) as number;
      const parentBookId = resultSet.getValue(resultSet.getColumnIndex('parentBookId')) as number;
      const bookName = resultSet.getString(resultSet.getColumnIndex('bookName'));
      list.push(new BookBean(id, bookName, orderNum, parentBookId))
    }
    return list
  }
}