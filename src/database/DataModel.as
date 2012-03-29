package database {

	import database.Database;
	
	public class DataModel {

		public static var inst:DataModel;		
		public var db:Database; 		
		
		public function DataModel() {			
		}
		
		public static function getInstance():DataModel {
			if (!inst)
				inst = new DataModel();
			return inst;
		}
	}
}