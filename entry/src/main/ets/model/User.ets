export interface  User {
  isLogin: boolean;
  mid: number;
  face: string;
  money: number;
  uname: string;
  stat: Stat;
  level: Resource;
}

export interface Stat{
  following: number;
  follower: number;
  dynamic_count: number;
}