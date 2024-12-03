

@Observed
export class  Response<T>{
  code: number = -1;
  message: string = "0"
  ttl: number = 1;
  data: T | null = null;
  mid: number = -1;
}