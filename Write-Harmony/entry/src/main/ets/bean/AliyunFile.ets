//读取文件列表
export class AliyunFile {
  drive_id: string = ''; //	string	必填
  file_id: string = ''; //	string	必填
  parent_file_id: string = ''; //	string	必填
  name: string = ''; //	string	必填
  file_extension: string = ''; //	string	必填
  category: string = ''; //	string	必填
  type: string = ''; //	string	必填
  url: string = ''; //图片预览图地址、小于 5MB 文件的下载地址。超过5MB 请使用 /getDownloadUrl string 选填
  created_at: string = ''; //string 必填	格式："yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
}