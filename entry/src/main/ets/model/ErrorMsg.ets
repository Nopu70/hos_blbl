export class ErrorMsg{
  type: number = 0;
  message: string = "";

  constructor(message: string = "", type: number = 0) {
    this.message = message;
    this.type = type;
  }
}