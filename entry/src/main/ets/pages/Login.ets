import { webview } from "@kit.ArkWeb"
import { BusinessError } from "@kit.BasicServicesKit";
import { Cookies } from "../model/Cookies";

@Builder
export function entryBuilder() {
  Login();
}

class JSProxy{
  onBack(): void {
    AppStorage.get<NavPathStack>("nav_stack")?.pop(true);
  }
}

@Component
struct Login{

  @Consume("nav_stack") navStack: NavPathStack;

  @State loginSucceed: boolean = false;

  controller: webview.WebviewController = new webview.WebviewController();
  handler: webview.WebSchemeHandler = new webview.WebSchemeHandler();
  jsProxy: JSProxy = new JSProxy()


  build() {
    NavDestination() {
      Web({
        src: "https://passport.bilibili.com/h5-app/passport/login",
        controller: this.controller,
      }).visibility(!this.loginSucceed ? Visibility.Visible : Visibility.Hidden)
        .onControllerAttached(() => {
        try {
          this.handler.onRequestStart((request, _) => {
            console.log(`webview_request__${request.getRequestUrl()}`)
            if (request.getRequestUrl().includes("m.bilibili.com")) {
              this.loginSucceed = true;
              webview.WebCookieManager.saveCookieAsync().then(() => {
                return webview.WebCookieManager.fetchCookie("api.bilibili.com");
              }).then((cookies) => {
                AppStorage.setOrCreate("cookies", new Cookies(cookies));
                this.navStack.pop(1, true);
              }).catch(() => {
                this.navStack.pop(0, true);
              })
              return true;
            }
            return false;
          })
          this.controller.setWebSchemeHandler("https", this.handler);
          this.controller.registerJavaScriptProxy(this.jsProxy, "JSProxy",
            [], ["onBack"])
          this.controller.refresh();
        }catch (error) {
          console.log(`webview_request_err__${(error as BusinessError).message}`);
        }
      }).onPageEnd(() => {
        let js:string ="javascript:document.getElementsByClassName('v-navbar__back')[0].addEventListener('click', function(){ JSProxy.onBack(); })";
        this.controller.runJavaScript(js).then((result) => {
          console.log(`inject_js_result__ ${result}`)
        }).catch((error:BusinessError) => {
          console.log(`inject_js_err2__ ${error.message}`)
        })
      }).javaScriptAccess(true).domStorageAccess(true)
    }.hideTitleBar(true)
  }
}