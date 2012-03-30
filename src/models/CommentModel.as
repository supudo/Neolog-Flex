package models {
	
	[Bindable]
	public class CommentModel {
		
		import mx.collections.ArrayCollection;
		
		private static var _instance:CommentModel;
		public var items:ArrayCollection;
		
		public function CommentModel() {
		}
		
		public static function getInstance():CommentModel {
			if (_instance == null)
				_instance = new CommentModel();
			return _instance;
		}
	}
}