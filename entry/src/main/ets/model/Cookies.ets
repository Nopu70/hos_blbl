import { isEmpty } from "../utils/TextUtil"

export class Cookies {
  cookies: string = "";
  cookiesMap: Map<string, string> = new Map();

  constructor(cookies: string) {
    this.cookies = cookies;
    if (isEmpty(cookies)) {
      return
    }
    let cookieArray = cookies.split(";");
    cookieArray.forEach((v) => {
      let cookiePair = v.trim().split("=");
      if (cookiePair.length === 2) {
        this.cookiesMap.set(cookiePair[0], cookiePair[1]);
      }
    })
  }

  setCookie(key: string, value: string) {
    this.cookies += `; ${key}=${value}`;
    this.cookiesMap.set(key, value);
  }

  getCookie(key: string): string | undefined {
    return this.cookiesMap.get(key);
  }
}