import { Upper } from "./Upper";


@Observed
export class BVideo{
  aid: number = -1;
  bvid: string = "";
  cid: number = -1;
  pic: string | null = null;
  pic_4_3: string | null = null;
  title: string | null = null;
  owner: Upper | null = null;
  pubdate: number = 0;
  duration: number = 0;
  stat: Stat | null = null;
  dimension: Dimension = new Dimension();
  first_frame: string | null = null;
  short_link_v2: string | null = null; //短url
  pub_location: string | null = null; //地址
  rcmd_reason: RcmdReason | null = null; //地址
  index: number = 0;
}

export class Stat{
  aid: number = 0;
  view: number = 0;
  danmaku: number = 0;
  reply: number = 0;
  favorite: number = 0;
  coin: number = 0;
  share: number = 0;
  now_rank: number = 0;
  his_rank: number = 0;
  like: number = 0;
  dislike: number = 0;
  vt: number = 0;
  vv: number = 0
}

export class Dimension{
  width: number = 1920;
  height: number = 1080;
  rotate: number = 0;
}

export class RcmdReason{
  content: string = "";
  corner_mark: number = 0;
}