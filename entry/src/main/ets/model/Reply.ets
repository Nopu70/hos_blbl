export interface  Reply{
  rpid: number;
  oid: number;
  type: number;
  mid: number;
  root: number;
  parent: number;
  dialog: number;
  count: number;
  rcount: number;
  state: number;
  fansgrade: number;
  attr: number;
  ctime: number;
  like: number;
  action: number;
  member: Member;
  content: Content;
  replies: Reply[];
  reply_control: ReplyControl;
}

export interface Member{
  mid: string;
  sex: string;
  sign: string;
  uname: string;
  avatar: string;
  level_info: LevelInfo;
  vip: Vip;
}

export interface LevelInfo{
  current_level: number;
  current_min: number;
  current_exp: number;
  next_exp: number;
}

export interface Content {
  message: string;
  members: Member[];
  emote: Record<string, Emote>;
  jump_url: Record<string, Object>;
  max_line: number;
  pictures: Picture[];
}

export interface Emote {
  id: number;
  package_id: number;
  state: number;
  type: number;
  attr: number;
  text: string;
  url: string;
  mtime: number;
  jump_title: string;
}

export interface ReplyControl {
  is_up_top: boolean;
  max_line: number;
  time_desc: string;
  location: string;
}

export interface Picture {
  img_src: string;
  img_width: number;
  img_height: number;
  img_size: number;
  top_right_icon: string;
  play_gif_thumbnail: boolean;
}

export interface Vip {
  vipType: number;
  vipDueDate: number;
  accessStatus: number;
  vipStatus: number;
  themeType: 0,
  nickname_color: string;
}

