package socnet {
	
	import com.swfjunkie.tweetr.Tweetr;
	import com.swfjunkie.tweetr.events.TweetEvent;
	import com.swfjunkie.tweetr.oauth.OAuth;
	import com.swfjunkie.tweetr.oauth.events.OAuthEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.ui.Keyboard;
	
	import views.WordDetailsView;
	import utilities.AppSettings;

	public class SNTwitter {
		
		public var _view:WordDetailsView;
		
		private var _message:String = "";
		private var _stage:Stage;
		
		private var tweetr:Tweetr;
		private var tweetId:Number;
		private var twWebView:StageWebView;
		private var twOAuth:OAuth;

		public function SNTwitter(stage:Stage) {
			this._stage = stage;
			this.tweetr = new Tweetr();
			if (this._stage != null)
				this._stage.addEventListener(KeyboardEvent.KEY_DOWN, this.handleKeyEvent);
		}
		
		public function PostToTwitter(msg:String):void {
			this._message = msg;

			this.tweetr.addEventListener(TweetEvent.COMPLETE, this.handleTweetEvent);
			this.tweetr.addEventListener(TweetEvent.FAILED, this.handleTweetEvent);
			this.tweetr.addEventListener(TweetEvent.STATUS, this.handleTweetEvent);
			
			this.twOAuth = new OAuth();
			this.twOAuth.addEventListener(OAuthEvent.COMPLETE, this.handleOAuthEvent);
			this.twOAuth.addEventListener(OAuthEvent.ERROR, this.handleOAuthEvent);
			
			this.twOAuth.consumerKey = AppSettings.getInstance().TwitterConsumerKey;
			this.twOAuth.consumerSecret = AppSettings.getInstance().TwitterConsumerSecret;
			this.twOAuth.callbackURL = AppSettings.getInstance().TwitterCallbackURI;
			this.twOAuth.pinlessAuth = true;

			if (AppSettings.getInstance().TwitterOAuthToken != "" && AppSettings.getInstance().TwitterOAuthTokenSecret != "") {
				this.twOAuth.oauthToken = AppSettings.getInstance().TwitterOAuthToken;
				this.twOAuth.oauthTokenSecret = AppSettings.getInstance().TwitterOAuthTokenSecret;
				this.tweetr.oAuth = this.twOAuth;
				this.tweetr.updateStatus(this._message);
			}
			else
				this.TWLogin();
		}
		
		public function IsLoggedIn():Boolean {
			return AppSettings.getInstance().TwitterOAuthToken != "" && AppSettings.getInstance().TwitterOAuthTokenSecret != "";
		}
		
		public function Logout():void {
			if (AppSettings.getInstance().TwitterOAuthToken != "" && AppSettings.getInstance().TwitterOAuthTokenSecret != "") {
				this.twOAuth = new OAuth();
				this.twOAuth.oauthToken = AppSettings.getInstance().TwitterOAuthToken;
				this.twOAuth.oauthTokenSecret = AppSettings.getInstance().TwitterOAuthTokenSecret;
				this.tweetr.oAuth = this.twOAuth;
				this.tweetr.endSession();
				AppSettings.getInstance().TwitterOAuthToken = "";
				AppSettings.getInstance().TwitterOAuthTokenSecret = "";
			}
		}

		private function TWLogin():void {
			AppSettings.getInstance().logThis(this._view, "[Twitter] Adding StageWebView Instance ..");
			this.twWebView = new StageWebView();
			this.twWebView.stage = this._stage;
			this.twWebView.assignFocus();
			this.twWebView.viewPort = new Rectangle(10, 10, this._stage.stageWidth - 10, this._stage.stageHeight - 10);
			this.twWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, this.wvLocationChanged);

			this.twOAuth.stageWebView = this.twWebView;
			AppSettings.getInstance().logThis(this._view, "[Twitter] Calling OAuth Authentication");
			this.twOAuth.getAuthorizationRequest();
		}

		private function handleTweetEvent(event:TweetEvent):void {
			if (event.type == TweetEvent.COMPLETE)
				this._view.postTwitterFinished({result:true}, null);
			else if (event.type == TweetEvent.FAILED) {
				this._view.postTwitterFinished(null, {code:999});
				AppSettings.getInstance().logThis(this._view, "[Twitter] Error posting! - " + event.info);
			}
			else
				AppSettings.getInstance().logThis(this._view, "[Twitter] Status ...");
		}

		private function handleOAuthEvent(event:OAuthEvent):void {
			if (event.type == OAuthEvent.COMPLETE) {
				AppSettings.getInstance().logThis(this._view, "[Twitter] You have successfully authenticated!");
				this.twWebView.dispose();
				this.twWebView = null;
				this.tweetr.oAuth = this.twOAuth;
				AppSettings.getInstance().TwitterOAuthToken = this.twOAuth.oauthToken;
				AppSettings.getInstance().TwitterOAuthTokenSecret = this.twOAuth.oauthTokenSecret;
				AppSettings.getInstance().logThis(this._view, "[Twitter] Posting now...");
				this.tweetr.updateStatus(this._message);
			}
			else
				AppSettings.getInstance().logThis(this._view, "[Twitter] handleOAuthEvent Error: " + event.text);
		}

		private function handleKeyEvent(event:KeyboardEvent):void {
			event.preventDefault();
			event.stopImmediatePropagation();
			if (event.keyCode == Keyboard.BACK) {
				if (this.twWebView) {
					AppSettings.getInstance().logThis(this._view, "[Twitter] User Aborting OAuth Authorization!");
					this.twWebView.dispose();
					this.twWebView = null;
				}
				else {
					AppSettings.getInstance().logThis(this._view, "[Twitter] Closing app!");
					NativeApplication.nativeApplication.exit();
				}
			}
		}

		private function wvLocationChanged(event:LocationChangeEvent):void {
			AppSettings.getInstance().logThis(this._view, "[Twitter] Location changed - " + event.location);
			if (event.location.indexOf(AppSettings.getInstance().TwitterCallbackURI + "?denied=") >= 0) {
				AppSettings.getInstance().logThis(this._view, "[Twitter] Twitter canceled!");

				event.preventDefault();
				event.stopImmediatePropagation();
				if (this.twWebView) {
					this.twWebView.dispose();
					this.twWebView = null;
				}
			}
		}
	}
}