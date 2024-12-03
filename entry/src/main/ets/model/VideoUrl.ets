
export class VideoUrl {
  quality: number = 0;
  format: string | null = null;
  timelength: number = 0;
  accept_format: string | null = null;
  durl: Durl[] | null = null;
  support_formats: Format[] | null = null;
}

export class Durl{
  order: number = 0;
  length: number = 0;
  size: number = 0;
  url: string | null = null;
  backup_url: string[] | null = null;
}

export class Format{
  quality: number = 0;
  format: string | null = null;
  new_description: string | null = null;
  display_desc: string | null = null;
  superscript: string | null = null;
}