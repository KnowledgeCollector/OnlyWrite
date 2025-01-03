export class PartInfo {
  etag: String = '';
  part_number: number = 0;
  part_size: number = 0;
  upload_url: string = '';
  content_type: string = '';

  constructor(etag: string, part_number: number, part_size: number, upload_url: string, content_type: string) {
    this.etag = etag
    this.part_number = part_number
    this.part_size = part_size
    this.upload_url = upload_url
    this.content_type = content_type
  }
}
