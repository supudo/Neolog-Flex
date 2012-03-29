package database {
	import flash.events.Event;

	public class DatabaseEvent extends Event {

		public static const ERROR_EVENT:String   = "dbErrorEvent";
		public static const RESULT_EVENT:String  = "dbResultEvent";
		
		public var data:*;
		
		public function DatabaseEvent(type:String) {
			super(type);
		}
	}
}