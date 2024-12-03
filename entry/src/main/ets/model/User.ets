
@Observed
export class User {
  isLogin: boolean = false;
  mid: number = 0;
  face: string | null = null;
  money: number = 0;
  uname: string | null = null;
  stat: Stat | null = null;
  level: Resource = $r('app.media.user_level_0')
}

@Observed
export class Stat{
  following: number = 0;
  follower: number = 0;
  dynamic_count: number = 0;
}