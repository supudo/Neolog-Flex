package utilities {
	import database.Database;
	import database.DatabaseResponder;
	
	import spark.components.View;

	public class AppSettings {
		static private var _instance:AppSettings;

		public function AppSettings(enforcer:SingletonEnforcer) {
		}
		
		public static function getInstance():AppSettings {
			if (AppSettings._instance == null)
				AppSettings._instance = new AppSettings(new SingletonEnforcer())
			return AppSettings._instance;
		}

		public var dbHelper:Database;
		public var webServicesURL:String = "http://www.neolog.bg/service_json.php";
		public var stStorePrivateData:Boolean = true;
		public var stPDEmail:String = "";
		public var socFacebookAppID:String = "";
		public var socFacebookAppURL:String = "";
		public var FacebookUID:String = "";
		public var TwitterConsumerKey:String = "";
		public var TwitterConsumerSecret:String = "";
		public var AppCallbackURI:String = "http://www.neolog.bg/";
		public var TwitterCallbackURI:String = AppCallbackURI;
		public var TwitterOAuthToken:String = "";
		public var TwitterOAuthTokenSecret:String = "";
		public var CurrentNestID:uint = 0;
		public var CurrentLetter:String = "";
		public var Letters:Array = new Array("А", "Б", "В", "Г", "Д", "Е", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ъ", "Ю", "Я", "Други..."); 
		
		public function logThis(ctrl:View, ... args):void {
			var output:String = "";
			for (var i:uint = 0; i<args.length; i++) {
				output += " " + args[i];
			}
			trace("_______[Neolog-DEBUG] " + ((ctrl == null) ? "XXX" : ctrl.name) + " // " + output);
		}
		
		public function loadAppSettings():void {
			if (this.dbHelper == null) {
				this.dbHelper = new Database();
				this.dbHelper.init(new DatabaseResponder());
			}

			var setts:Array = this.dbHelper.getSettings();
			for (var i:uint; i<setts.length; i++) {
				switch(setts[i].sname) {
					case "stStorePrivateData": {
						AppSettings.getInstance().stStorePrivateData = setts[i].svalue == "true";
						break;
					}
					case "stPDEmail": {
						AppSettings.getInstance().stPDEmail = setts[i].svalue;
						break;
					}
					default: {
						break;
					}
				}
			}
		}
		
		public function saveAppSettings():void {
			if (this.dbHelper == null) {
				this.dbHelper = new Database();
				this.dbHelper.init(new DatabaseResponder());
			}
			
			this.dbHelper.addSettings("stStorePrivateData", AppSettings.getInstance().stStorePrivateData.toString(), true);
			this.dbHelper.addSettings("stPDEmail", AppSettings.getInstance().stPDEmail, true);
		}
	}
}

class SingletonEnforcer{};