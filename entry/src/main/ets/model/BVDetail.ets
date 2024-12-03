import { BVideo } from "./BVideo";

@Observed
export class BVDetail{
  View?: BVideo;
  Card?: Card;
  Tags?: Tag[];
  Related?: BVideo[];
}

export class Card {
  following: boolean = false;
  archive_count: number = 0;
  article_count: number = 0;
  follower: number = 0;
  like_num: number = 0;
}

export class Tag{
  tag_id: number = 0;
  tag_name?: string;
  music_id?: string;
  tag_type?: string;
  jump_url?: string;
}