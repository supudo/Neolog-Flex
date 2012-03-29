package utilities {
	import com.adobe.fiber.services.wrapper.HTTPServiceWrapper;
	import com.adobe.serializers.json.JSONEncoder;
	
	import database.DataModel;
	import database.Database;
	import database.DatabaseEvent;
	import database.DatabaseResponder;
	
	import events.DataEvent;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import utilities.AppSettings;
	
	import views.LoadingView;

	public class Synchronization extends com.adobe.fiber.services.wrapper.HTTPServiceWrapper {
		
		public var doFullSync:Boolean;
		
		private var httpService:HTTPService = new HTTPService();
		public var dbHelper:Database = new Database();
		private var dbResponder:DatabaseResponder = new DatabaseResponder();
		
		private var SERVICE_NESTS:String = "?action=GetNests";
		private var SERVICE_TEXTCONTENT:String = "?action=GetContent";
		private var SERVICE_WORDSFORNEST:String = "?action=FetchWordsForNest&wd=2";
		private var SERVICE_WORDSFORLETTER:String = "?action=FetchWordsForLetter&wd=2";
		private var SERVICE_WORDCOMMENTS:String = "?action=FetchWordComments&wd=2";
		private var SERVICE_SENDWORD:String = "?action=SendWord";
		private var SERVICE_SENDCOMMENT:String = "?action=SendComment";
		private var SERVICE_SEARCH:String = "?action=Search&wd=2";
		
		private var SERVICE_ID_NESTS:uint = 1;
		private var SERVICE_ID_TEXTCONTENT:uint = 2;
		private var SERVICE_ID_WORDSFORNEST:uint = 3;
		private var SERVICE_ID_WORDSFORLETTER:uint = 4;
		private var SERVICE_ID_WORDCOMMENTS:uint = 5;
		private var SERVICE_ID_SENDWORD:uint = 6;
		private var SERVICE_ID_SENDCOMMENT:uint = 7;
		private var SERVICE_ID_SEARCH:uint = 8;
		
		private var ServiceID:uint = 0;
		
		private var loadingView:LoadingView;
		
		public function Synchronization(caller:LoadingView) {
			this.loadingView = caller;
			this.httpService.contentType = "application/json";
			this.httpService.resultFormat = HTTPService.RESULT_FORMAT_TEXT;
			this.dbHelper = new Database();
		}
		
		public function StartSync():void {
			this.dbHelper.addEventListener("dbConnInitiated", dbConnectionInitiated);
			this.dbHelper.init(this.dbResponder);
		}
		
		public function dbConnectionInitiated(event:Event):void {
			this.removeEventListener("dbConnInitiated", dbConnectionInitiated);
			if (this.doFullSync)
				this.dbHelper.wipeDatabase();
			AppSettings.getInstance().dbHelper = this.dbHelper;
			this.StartSyncWithService(this.SERVICE_TEXTCONTENT);
		}
		
		public function StartSyncWithService(serviceName:String):void {
			try {
				AppSettings.getInstance().logThis(null, "Synchronizing ... " + serviceName);
				if (serviceName == this.SERVICE_TEXTCONTENT)
					this.syncTextContent();
				else if (serviceName == this.SERVICE_NESTS)
					this.syncNests();
			}
			catch (e:Error) {
				AppSettings.getInstance().logThis(this, "Synchronizing error - " + e.message);
			}
		}
		
		private function syncCompleted():void {
			this.loadingView.syncCompleted();
		}
		
		/**
		 * Sync'ers
		 **/
		private function syncTextContent():void {
			AppSettings.getInstance().logThis(null, "Calling syncTextContent...");
			this.ServiceID = this.SERVICE_ID_TEXTCONTENT;
			this.httpService.url = AppSettings.getInstance().webServicesURL + this.SERVICE_TEXTCONTENT;
			this.httpService.addEventListener(ResultEvent.RESULT, serviceResult);
			this.httpService.addEventListener(FaultEvent.FAULT, serviceError);
			var token:AsyncToken = this.httpService.send();
			token.addResponder(new mx.rpc.Responder(onJSONResult, onJSONFault));
		}
		
		private function syncNests():void {
			AppSettings.getInstance().logThis(null, "Calling syncNests...");
			this.ServiceID = this.SERVICE_ID_NESTS;
			this.httpService.url = AppSettings.getInstance().webServicesURL + this.SERVICE_NESTS;
			this.httpService.addEventListener(ResultEvent.RESULT, serviceResult);
			this.httpService.addEventListener(FaultEvent.FAULT, serviceError);
			var token:AsyncToken = this.httpService.send();
			token.addResponder(new mx.rpc.Responder(onJSONResult, onJSONFault));
		}
		
		/**
		 * Service events
		 **/
		private function serviceResult(event:ResultEvent):void {
			AppSettings.getInstance().logThis(null, "Service OK - " + (event.result as String));
		}
		
		private function serviceError(event:FaultEvent):void {
			AppSettings.getInstance().logThis(null, "Service error:");
			AppSettings.getInstance().logThis(null, "     - Code:" + event.fault.faultCode);
			AppSettings.getInstance().logThis(null, "     - Description:" + event.fault.faultString);
			AppSettings.getInstance().logThis(null, "     - Detail:" + event.fault.faultString);
		}
		
		/**
		 * JSON events
		 **/
		private function onJSONResult(event:ResultEvent):void {
			var jsonResponse:String = (event.message.body as String);
			AppSettings.getInstance().logThis(null, "Got response from " + this.ServiceID + " = " + jsonResponse);
			switch (this.ServiceID) {
				case this.SERVICE_ID_TEXTCONTENT: {
					this.handleTextContent(jsonResponse);
					break;
				}
				case this.SERVICE_ID_NESTS: {
					this.handleNests(jsonResponse);
					break;
				}
				case this.SERVICE_ID_SENDWORD: {
					this.handleSendWord(jsonResponse);
					break;
				}
				case this.SERVICE_ID_SEARCH: {
					this.handleSearch(jsonResponse);
					break;
				}
				default: {
					break;
				}
			}
		}
		
		private function onJSONFault(event:FaultEvent):void {
			AppSettings.getInstance().logThis(null, "JSON error:");
			AppSettings.getInstance().logThis(null, "     - Code:" + event.fault.faultCode);
			AppSettings.getInstance().logThis(null, "     - Description:" + event.fault.faultString);
			AppSettings.getInstance().logThis(null, "     - Detail:" + event.fault.faultString);
		}
		
		/**
		 * Handlers
		 **/
		private function handleTextContent(jsonResponse:String):void {
			var entities:Object = JSON.parse(jsonResponse);
			for (var i:uint=0; i<entities.GetContent.length; i++) {
				var ent:Object = entities.GetContent[i];
				var cid:uint = ent.id;
				this.dbHelper.addTextContent(ent);
			}
			this.syncNests();
		}
		
		private function handleNests(jsonResponse:String):void {
			var entities:Object = JSON.parse(jsonResponse);
			for (var i:uint=0; i<entities.GetNests.length; i++) {
				var ent:Object = entities.GetNests[i];
				var cid:uint = ent.id;
				this.dbHelper.addNest(ent);
			}
			this.syncCompleted();
		}
		
		private function handleSendWord(jsonResponse:String):void {
			var returnObject:Object = new Object();
			var response:Object = JSON.parse(jsonResponse);
			if (response != null && response.SendWord != null) {
				if (response.SendWord.result == "true")
					returnObject.postResponse = "true";
				else
					returnObject.postResponse = response.SendWord.result;
			}
			this.dispatchEvent(new DataEvent("sendWordFinished", true, false, returnObject));
		}
		
		private function handleSearch(jsonResponse:String):void {
			var entities:Object = JSON.parse(jsonResponse);
			if (entities != null && entities.Search != null) {
				for (var i:uint=0; i<entities.Search.length; i++) {
					var ent:Object = entities.Search[i];
					var cid:uint = ent.wid;
					this.dbHelper.addWord(ent);
				}
			}
			this.dispatchEvent(new Event("searchFinished", true));
		}
		
		/**
		 * Publics
		 **/
		public function sendWord(obj:Object):void {
			if (obj != null) {
				AppSettings.getInstance().logThis(null, "obj...");
				this.ServiceID = this.SERVICE_ID_SENDWORD;
				this.httpService.url = AppSettings.getInstance().webServicesURL + this.SERVICE_SENDWORD;
				this.httpService.addEventListener(ResultEvent.RESULT, serviceResult);
				this.httpService.addEventListener(FaultEvent.FAULT, serviceError);
				this.httpService.method = "POST";
				this.httpService.useProxy = false;
				this.httpService.contentType = HTTPService.CONTENT_TYPE_FORM;
				this.httpService.showBusyCursor = true;
				var token:AsyncToken = this.httpService.send({jsonobj:JSON.stringify(obj)});
				token.addResponder(new mx.rpc.Responder(onJSONResult, onJSONFault));
			}
		}
		public function startSearch(searchQuery:String):void {
			AppSettings.getInstance().logThis(null, "startSearch : searchQuery = '" + searchQuery + "'");
			this.ServiceID = this.SERVICE_ID_SEARCH;
			this.httpService.url = AppSettings.getInstance().webServicesURL + this.SERVICE_SEARCH + "&q=" + searchQuery;
			this.httpService.addEventListener(ResultEvent.RESULT, serviceResult);
			this.httpService.addEventListener(FaultEvent.FAULT, serviceError);
			var token:AsyncToken = this.httpService.send();
			token.addResponder(new mx.rpc.Responder(onJSONResult, onJSONFault));
		}

	}

}