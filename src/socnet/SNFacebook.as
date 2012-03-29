package socnet {
	
	import com.adobe.serializers.json.JSONEncoder;
	import com.facebook.graph.FacebookMobile;
	
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	import views.WordDetailsView;
	import utilities.AppSettings;
	
	public class SNFacebook {

		private var _message:String = "";
		private var _stage:Stage;
		
		public var _view:WordDetailsView;
		
		public function SNFacebook(stage:Stage) {
			this._stage = stage;
		}
		
		public function PostToFacebook(msg:String):void {
			this._message = msg;
			FacebookMobile.init(AppSettings.getInstance().socFacebookAppID, initHandler);
		}

		public function IsLoggedIn():Boolean {
			///~ API issue : http://code.google.com/p/facebook-actionscript-api/issues/detail?id=297
			return true;
			/*
			var fbl:Boolean = false;
			if (FacebookMobile.getSession() != null) {
				var v2:Boolean = FacebookMobile.getSession().uid != null;
				var v3:Boolean = FacebookMobile.getSession().uid != "";
				fbl = v2 && v3;
			}
			return fbl;
			*/
		}
		
		public function Logout():void {
			FacebookMobile.logout();
		}
		
		protected function initHandler(result:Object, fail:Object):void {
			if (result) {
				AppSettings.getInstance().logThis(null, "initHandler, Already logged in.");
				this.postMessage();
			}
			else {
				AppSettings.getInstance().logThis(null, "initHandler, No logged in. Possible error - " + fail.message);
				var fbView:StageWebView = new StageWebView();
				fbView.viewPort = new Rectangle(10, 10, this._stage.width - 30, this._stage.height - 30);
				FacebookMobile.login(loginHandler, this._stage, ["publish_stream"], fbView);
			}
		}

		protected function loginHandler(success:Object, fail:Object):void {
			if (success) {
				if (success.uid != null && success.uid != "")
					AppSettings.getInstance().FacebookUID = success.uid;
				postMessage();
			}
			else if (fail != null && fail.error != null)
				AppSettings.getInstance().logThis(null, "Login error - " + fail.error.code + " - " + fail.error.message);
		}
		
		protected function postMessage():void {
			FacebookMobile.api("/me/feed", submitPostHandler, {message:this._message}, "POST");
		}
		
		protected function submitPostHandler(result:Object, fail:Object):void {
			AppSettings.getInstance().logThis(null, "FB result");
			this._view.postFacebookFinished(result, fail);
		}
	}
}