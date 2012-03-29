package models {
	
	[Bindable]
	public class WordModel {
		
		import mx.collections.ArrayCollection;
		
		private static var _instance:WordModel;
		public var items:ArrayCollection;
		
		public function WordModel() {
		}
		
		public static function getInstance():WordModel {
			if (_instance == null)
				_instance = new WordModel();
			return _instance;
		}
	}
}