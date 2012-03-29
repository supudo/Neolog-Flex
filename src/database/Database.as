package database {

	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.Responder;
	
	import mx.formatters.DateFormatter;
	
	import utilities.AppSettings;
	
	public class Database extends EventDispatcher {

		private var dbFile:File;
		public var aConn:SQLConnection;		
		private var sqlStatementFactory:SQLStatementFactory;
		private var sqlStatement:SQLStatement;
		private var dbSchema:DatabaseSchema;
		private var dbResponder:DatabaseResponder;

		public function Database() {
		}

		public function getCreationDateOfDatabase():Date {
			var d:Date;
			if (this.dbFile && this.dbFile.exists)
				d = dbFile.creationDate;
			return d;
		}
		
		public function deleteDatabase():Boolean {
			var success:Boolean = false;
			if (this.dbFile) {
				if (this.aConn && this.aConn.connected)
					this.aConn.close(null);	

				var fs:FileStream = new FileStream();
				try {
					fs.open(this.dbFile,FileMode.UPDATE);
					while (fs.bytesAvailable)	
						fs.writeByte(Math.random() * Math.pow(2,32));
					AppSettings.getInstance().logThis(null, "Writing complete");
					fs.close();
					this.dbFile.deleteFile();
					AppSettings.getInstance().logThis(null, "Deletion complete");
					success = true;
				}
				catch (e:Error) {
					AppSettings.getInstance().logThis(null, e.name + ", " + e.message);
					fs.close();
				}				
			}
			return success;
		}
		
		/** ========================================================
		 * Create the asynchronous connection to the database, then create the tables
		 * 
		 * @param responder:DatabaseResponder Will dispatch result or error events when the tables are created. Dispatches an event with data TABLES_CREATED 
		 *  when all tables have been successfully created. 
		 **/
		public function init(responder:DatabaseResponder):void {
			var internalResponder:DatabaseResponder = new DatabaseResponder();
			internalResponder.addEventListener(DatabaseEvent.RESULT_EVENT, onResult);
			internalResponder.addEventListener(DatabaseEvent.ERROR_EVENT, onError);	
			this.dbSchema = new DatabaseSchema();	
			openConnection(internalResponder);	
			
			function onResult(de:DatabaseEvent):void {
				internalResponder.removeEventListener(DatabaseEvent.ERROR_EVENT, onError);
				internalResponder.removeEventListener(DatabaseEvent.RESULT_EVENT, onResult);				
				//createTables(responder);
				this.dbResponder = responder;
				createTables();
			}
			
			function onError(de:DatabaseEvent):void {
				internalResponder.removeEventListener(DatabaseEvent.ERROR_EVENT, onError);
				internalResponder.removeEventListener(DatabaseEvent.RESULT_EVENT, onResult);
			}
		}
		
		private function openConnection(responder:DatabaseResponder):void {
			this.dbFile = File.applicationStorageDirectory.resolvePath("neolog_0.1.db");

			this.aConn = new SQLConnection();
			
			this.aConn.addEventListener(SQLEvent.OPEN, onConnOpen);
			this.aConn.addEventListener(SQLErrorEvent.ERROR, onConnError);
			//this.aConn.openAsync(this.dbFile, SQLMode.CREATE);
			
			if (this.dbFile.exists)
				this.aConn.open(this.dbFile, SQLMode.UPDATE);
			else
				this.aConn.open(this.dbFile, SQLMode.CREATE);
			this.dbResponder = responder;	

			this.sqlStatementFactory = new SQLStatementFactory(this.aConn);	

			function onConnOpen(se:SQLEvent):void {
				AppSettings.getInstance().logThis(null, "SQL Connection successfully opened. Database:0001");
				aConn.removeEventListener(SQLEvent.OPEN, onConnOpen);
				aConn.removeEventListener(SQLErrorEvent.ERROR, onConnError);					
				sqlStatementFactory = new SQLStatementFactory(aConn);
				var de:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				responder.dispatchEvent(de);				
			}
			
			function onConnError(see:SQLErrorEvent):void {
				AppSettings.getInstance().logThis(null, "SQL Error while attempting to open database. Database:0002");
				aConn.removeEventListener(SQLEvent.OPEN, onConnOpen);
				aConn.removeEventListener(SQLErrorEvent.ERROR, onConnError);
				var de:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
				responder.dispatchEvent(de);
			}
		}
		
		/** ========================================================
		 * Database wipe
		 **/
		public function wipeDatabase():void {
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.DELETE_SETTINGS);
			sqlWrapper.statement.execute();
			sqlWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.DELETE_TEXTCONTENT);
			sqlWrapper.statement.execute();
			sqlWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.DELETE_CATEGORIES);
			sqlWrapper.statement.execute();
			sqlWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.DELETE_JOBOFFERS);
			sqlWrapper.statement.execute();
			AppSettings.getInstance().logThis(null, "Database wiped!");
		}
		
		/** ========================================================
		 * Table creates
		 **/
		public function createTables():void {
			createSettingsTable();
		}
		
		private function createSettingsTable():void {
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.CREATE_TABLE_SETTINGS);
			sqlWrapper.statement.execute();
			this.populateSettings();
		}
		
		private function populateSettings():void {
			this.addSettings("stStorePrivateData", "true", false);
			this.addSettings("stPDEmail", "", false);
			this.addSettings("stShowCategories", "true", false);
			this.addSettings("stOnlineSearch", "true", false);
			this.addSettings("stInAppEmail", "false", false);
			this.createTextContentTable();
		}

		private function createTextContentTable():void {
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.CREATE_TABLE_TEXTCONTENT);
			sqlWrapper.statement.execute();
			this.createCategoriesTable();
		}

		private function createCategoriesTable():void {
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.CREATE_TABLE_CATEGORIES);
			sqlWrapper.statement.execute();
			this.createJobOffersTable();
		}	

		private function createJobOffersTable():void {
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.CREATE_TABLE_JOBOFFERS);
			sqlWrapper.statement.execute();
			this.finishedCreatingTables();
		}
		private function finishedCreatingTables():void {
			var de:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
			de.data = this.dbSchema.TABLES_CREATED;
			if (this.dbResponder != null)
				this.dbResponder.dispatchEvent(de);
			this.dispatchEvent(new Event("dbConnInitiated", true));
		}
		
		/** ========================================================
		 * Settings
		 **/
		public function addSettings(sname:String, svalue:String, doUpdate:Boolean):void {
			if (sname != "" && svalue != "") {
				var exists:Boolean = this.hasSettings(sname);
				if (!exists || doUpdate) {
					AppSettings.getInstance().logThis(null, "addSettings (" + (exists ? "update" : "insert") + ") ... " + sname);
					var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(((exists) ? this.dbSchema.UPDATE_SETTINGS : this.dbSchema.INSERT_SETTINGS));
					sqlWrapper.statement.parameters[":sname"] = sname; 
					sqlWrapper.statement.parameters[":svalue"] =  svalue;
					sqlWrapper.statement.execute();
				}
			}
		}
		
		public function hasSettings(sname:String):Boolean {
			var alreadyExisting:Boolean = false;
			if (sname != "") {
				var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.GET_SETTINGS);
				sqlWrapper.statement.parameters[":sname"] = sname;
				sqlWrapper.statement.execute();
				sqlWrapper.result = sqlWrapper.statement.getResult(); 
				alreadyExisting = sqlWrapper.result.data != null && sqlWrapper.result.data.length > 0;
			}
			return alreadyExisting;
		}
		
		public function getSettings():Array {
			var items:Array = null;
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.GET_SETTINGS_ALL);
			sqlWrapper.statement.execute();
			sqlWrapper.result = sqlWrapper.statement.getResult();
			if (sqlWrapper.result != null && sqlWrapper.result.data != null)
				items = sqlWrapper.result.data;
			return items;
		}

		/** ========================================================
		 * Text Content
		 **/
		public function addTextContent(ent:Object):void {
			if (ent) {
				var exists:Boolean = this.hasTextContent(ent.id);
				AppSettings.getInstance().logThis(null, "addTextContent (" + (exists ? "update" : "insert") + ") ... " + ent.id);
				var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(((exists) ? this.dbSchema.UPDATE_TEXTCONTENT : this.dbSchema.INSERT_TEXTCONTENT));
				sqlWrapper.statement.parameters[":cid"] = ent.id; 
				sqlWrapper.statement.parameters[":title"] =  ent.title;
				sqlWrapper.statement.parameters[":content"] = ent.content;
				sqlWrapper.statement.execute();
			}
		}

		public function hasTextContent(cid:uint):Boolean {
			var alreadyExisting:Boolean = false;
			if (cid is Number) {
				var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.GET_TEXTCONTENT);
				sqlWrapper.statement.parameters[":cid"] = cid;
				sqlWrapper.statement.execute();
				sqlWrapper.result = sqlWrapper.statement.getResult(); 
				alreadyExisting = sqlWrapper.result.data != null && sqlWrapper.result.data.length > 0;
			}
			return alreadyExisting;
		}

		public function getTextContent(cid:uint):Object {
			var ent:Object = null;
			if (cid is Number) {
				var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.GET_TEXTCONTENT);
				sqlWrapper.statement.parameters[":cid"] = cid;
				sqlWrapper.statement.execute();
				sqlWrapper.result = sqlWrapper.statement.getResult();
				ent = sqlWrapper.result.data[0] as Object;
			}
			return ent;
		}
		
		/** ========================================================
		 * Categories
		 **/
		public function addCategory(ent:Object):void {
			if (ent) {
				var exists:Boolean = this.hasCategory(ent.id);
				AppSettings.getInstance().logThis(null, "addCategory (" + (exists ? "update" : "insert") + ") ... " + ent.id);
				var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(((exists) ? this.dbSchema.UPDATE_CATEGORIES : this.dbSchema.INSERT_CATEGORIES));
				sqlWrapper.statement.parameters[":cid"] = ent.id; 
				sqlWrapper.statement.parameters[":title"] =  ent.name;
				sqlWrapper.statement.parameters[":offerscount"] = ent.offerscount;
				sqlWrapper.statement.execute();
			}
		}
		
		public function hasCategory(cid:uint):Boolean {
			var alreadyExisting:Boolean = false;
			if (cid is Number) {
				var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.GET_CATEGORY);
				sqlWrapper.statement.parameters[":cid"] = cid;
				sqlWrapper.statement.execute();
				sqlWrapper.result = sqlWrapper.statement.getResult(); 
				alreadyExisting = sqlWrapper.result.data != null && sqlWrapper.result.data.length > 0;
			}
			return alreadyExisting;
		}
		
		public function getCategoriesAll():Array {
			var items:Array = null;
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.GET_CATEGORIES);
			sqlWrapper.statement.execute();
			sqlWrapper.result = sqlWrapper.statement.getResult();
			if (sqlWrapper.result != null && sqlWrapper.result.data != null)
				items = sqlWrapper.result.data;
			return items;
		}

		public function getCategories(humanYn:Boolean):Array {
			var items:Array = null;
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.GET_CATEGORIES_COUNT);
			sqlWrapper.statement.parameters[":humanyn"] = humanYn;
			sqlWrapper.statement.execute();
			sqlWrapper.result = sqlWrapper.statement.getResult();
			if (sqlWrapper.result != null && sqlWrapper.result.data != null)
				items = sqlWrapper.result.data;
			return items;
		}

		public function getCategory(cid:uint):void {
			if (this.dbResponder != null && cid is Number) {
				var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstance(this.dbResponder, this.dbSchema.GET_CATEGORY);
				sqlWrapper.statement.parameters[":cid"] = cid;
				sqlWrapper.statement.execute();
			}
		}
		
		/** ========================================================
		 * Job offers
		 **/
		public function addJobOffers(ent:Object):void {
			if (ent) {
				var exists:Boolean = this.hasJobOffer(ent.id);
				AppSettings.getInstance().logThis(null, "addJobOffers (" + (exists ? "update" : "insert") + ") ... " + ent.id);
				var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(((exists) ? this.dbSchema.UPDATE_JOBOFFERS : this.dbSchema.INSERT_JOBOFFERS));
				sqlWrapper.statement.parameters[":oid"] = ent.id; 
				sqlWrapper.statement.parameters[":cid"] =  ent.cid;
				sqlWrapper.statement.parameters[":title"] = ent.title;
				sqlWrapper.statement.parameters[":categorytitle"] = ent.category;
				sqlWrapper.statement.parameters[":email"] = ent.email;
				sqlWrapper.statement.parameters[":freelanceyn"] = ent.fyn == 1;
				sqlWrapper.statement.parameters[":humanyn"] = ent.hm == 1;
				sqlWrapper.statement.parameters[":negativism"] = ent.negativism;
				sqlWrapper.statement.parameters[":positivism"] = ent.positivism;
				var matches : Array = ent.date.match(/(\d\d\d\d)-(\d\d)-(\d\d)/);
				var publishDate:Date = new Date();
				publishDate.setUTCFullYear(int(matches[1]), int(matches[2]) - 1, int(matches[3]));
				sqlWrapper.statement.parameters[":publishdate"] = publishDate;
				sqlWrapper.statement.parameters[":publishdatestamp"] = ent.datestamp;
				if (!exists) {
					sqlWrapper.statement.parameters[":readyn"] = false;
					sqlWrapper.statement.parameters[":sentmessageyn"] = false;
				}
				sqlWrapper.statement.execute();
			}
		}
		
		public function hasJobOffer(oid:uint):Boolean {
			var alreadyExisting:Boolean = false;
			if (oid is Number) {
				var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.GET_JOBOFFERS_FOR_JOBOFFER_ID);
				sqlWrapper.statement.parameters[":oid"] = oid;
				sqlWrapper.statement.execute();
				sqlWrapper.result = sqlWrapper.statement.getResult(); 
				alreadyExisting = sqlWrapper.result.data != null && sqlWrapper.result.data.length > 0;
			}
			return alreadyExisting;
		}

		public function getJobOffers():Array {
			var items:Array = null;
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.GET_JOBOFFERS);
			sqlWrapper.statement.execute();
			sqlWrapper.result = sqlWrapper.statement.getResult();
			if (sqlWrapper.result != null && sqlWrapper.result.data != null)
				items = sqlWrapper.result.data;
			return items;
		}

		public function getJobOfferForCategory(args:Array):void {					
			if (this.dbResponder != null && args[0] is Number) {
				var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstance(this.dbResponder, this.dbSchema.GET_JOBOFFERS_FOR_JOBOFFER_ID);
				sqlWrapper.statement.parameters[":id"] = args[0];
				sqlWrapper.statement.execute();
			}
		}
		
		public function getJobOfferForHuman(humanYn:Boolean):Array {	
			var items:Array = null;
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.GET_JOBOFFERS_FOR_HUMAN);
			sqlWrapper.statement.parameters[":humanyn"] = humanYn;
			sqlWrapper.statement.execute();
			sqlWrapper.result = sqlWrapper.statement.getResult();
			if (sqlWrapper.result != null && sqlWrapper.result.data != null)
				items = sqlWrapper.result.data;
			return items;
		}
		
		public function getJobOffersComplex(humanYn:Boolean, categoryID:uint):Array {	
			var items:Array = null;
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.GET_JOBOFFERS_COMPLEX);
			sqlWrapper.statement.parameters[":humanyn"] = humanYn;
			sqlWrapper.statement.parameters[":cid"] = categoryID;
			sqlWrapper.statement.execute();
			sqlWrapper.result = sqlWrapper.statement.getResult();
			if (sqlWrapper.result != null && sqlWrapper.result.data != null)
				items = sqlWrapper.result.data;
			return items;
		}

		public function searchJobOffers(searchQuery:String, searchFreelance:int):Array {
			var items:Array = null;
			var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstanceRT(this.dbSchema.SEARCH_JOBOFFERS);
			sqlWrapper.statement.parameters[":freelanceyn"] = searchFreelance;
			sqlWrapper.statement.parameters[":searchq"] = "%" + searchQuery + "%";
			sqlWrapper.statement.execute();
			sqlWrapper.result = sqlWrapper.statement.getResult();
			if (sqlWrapper.result != null && sqlWrapper.result.data != null)
				items = sqlWrapper.result.data;
			return items;
		}
		
		/** ========================================================
		 * Gets the last inserted rowid, according to the function last_insert_rowid() in SQLite
		 * 		 
		 * @param args Array [responder:DatabaseRespodner]
		 **/
		public function getLastInsertRowId():void {
			if (this.dbResponder != null) {
				var sqlWrapper:SQLWrapper = this.sqlStatementFactory.newInstance(this.dbResponder, this.dbSchema.GET_LAST_INSERT_ROWID);				
				sqlWrapper.statement.execute();
			}
		}
	}
}