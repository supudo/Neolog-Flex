package models {
	
	[Bindable]
	public class NestModel {
		
		import mx.collections.ArrayCollection;
		
		private static var _instance:NestModel;
		public var items:ArrayCollection;
		
		public function NestModel() {
		}
		
		public static function getInstance():NestModel {
			if (_instance == null)
				_instance = new NestModel();
			return _instance;
		}
	}
}