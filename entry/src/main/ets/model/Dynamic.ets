
export interface Dynamic {
  id_str: string;
  type: string;
  visible: boolean;

  modules: Modules;
}

export interface Modules {
  module_author: ModuleAuthor;
  module_dynamic: ModuleDynamic;
  module_stat: ModuleStat;
}

export interface ModuleAuthor {
  mid: number;
  name: string;
  following: boolean;
  face: string;

  pub_time: string;
  pub_action: string;
  type: string;
}

export interface ModuleDynamic {
  desc: Desc;
  major: Major;
}

export interface Desc {
  text: string;
  rich_text_nodes: RichTextNode[]
}

export interface RichTextNode {
  orig_text: string;
  text: string;
  type: string;
  emoji: Emoji;
}

export interface Emoji {
  icon_url: string;
  size: number;
  text: string;
  type: number;
}

export interface Major {
  archive: Archive;
  draw: Draw;
}

export interface Archive {
  aid: number;
  bvid: string;
  cover: string;
  title: string;
  duration_text: string;
  type: number;
  stat: ArchiveStat;
}

export interface ArchiveStat {
  danmaku: string;
  play: string;
}

export interface Draw {
  id: number;
  type: string;
  items: DrawItem[];
}

export interface DrawItem {
  height: number;
  width: number;
  size: number;
  src: string;
}

export interface ModuleStat {
  comment: Stat;
  forward: Stat;
  like: Stat;
}

export interface Stat {
  count: number;
  forbidden: boolean;
  status: boolean;
}