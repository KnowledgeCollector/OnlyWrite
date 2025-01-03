import { AliyunFile } from "./AliyunFile";

export class AliyunFileList {
  next_marker: string = ''; //	string	必填
  items: Array<AliyunFile> = []; //array	必填
}