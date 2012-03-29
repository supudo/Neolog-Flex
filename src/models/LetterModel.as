package models {
	
	[Bindable]
	public class LetterModel {
		
		import mx.collections.ArrayCollection;
		
		private static var _instance:LetterModel;
		public var items:ArrayCollection;
		
		public function LetterModel() {
		}
		
		public static function getInstance():LetterModel {
			if (_instance == null)
				_instance = new LetterModel();
			return _instance;
		}
	}
}