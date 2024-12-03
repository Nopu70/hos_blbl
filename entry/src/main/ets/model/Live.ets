
export interface AreaEntrance {
  id: number;
  pic: string;
  title: string;
  area_v2_id: number;
  area_v2_parent_id: number;
  tag_type: number;
  is_hot: number;
}

export interface LiveArea {
  id: number;
  parent_id: number;
  old_area_id: number;
  name: string;
  utime: string;
  act_id: number;
  pk_status: number;
  hot_status: number;
  lock_status: number;
  pic: string;
  complex_area_name: string;
  is_new: number;
  update_time: string;
  parent_name: string;
  area_type: number;
}

export interface Room {
  area_v2_id: number;
  area_v2_parent_id: number;
  area_v2_name: string;
  area_v2_parent_name: string;
  broadcast_type: number;
  cover: string;
  online: number;
  roomid: number;
  title: string;
  uname: string;
  face: string;
  uid: number;
  keyframe: string;
  is_auto_play: number;
  head_box_type: number;
  flag: number;
  session_id: string;
  group_id: number;
  special_id: number;
  is_nft: number;
  nft_dmark: string;
  is_ad: boolean;
  show_ad_icon: boolean;
  status: boolean;
  followers: number;
  watched_show: Watched;
}


export interface Watched {
  switch: boolean;
  num: number;
  text_small: string;
  text_large: string;
  icon: string;
  icon_location: number;
  icon_web: string;
}

export interface Module{
  module_info: ModuleInfo;
  list: Room[];
}

export interface ModuleInfo {
  id: number;
  link: string;
  pic: string;
  title: string;
  type: number;
  sort: number;
  count: number;
}

export interface LiveGridItem {
  value: Room | ModuleInfo;
  type: number;
}

export interface SecondAreaData {
  banner: SecondAreaBanner[];
  new_tags: SecondAreaTag[];
  list: Room[];
  count: number;
  has_more: boolean;
}

export interface SecondAreaBanner {
  id: number;
  title: string;
  location: string;
  position: number;
  pic: string;
  link: string;
  weight: number;
  room_id: number;
  up_id: number;
  parent_area_id: number
  area_id: number;
  live_status: number;
  av_id: number;
  is_ad: boolean;
  show_ad_icon: boolean
}

export interface SecondAreaTag {
  id: number;
  name: string;
  icon: string;
  sort_type: string;
  type: number;
  sort: number
}