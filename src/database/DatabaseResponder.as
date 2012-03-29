package database {

	import flash.events.EventDispatcher;

	public class DatabaseResponder extends EventDispatcher {
		[Event(name="dbErrorEvent",  type="database.DatabaseEvent")]
		[Event(name="dbResultEvent", type="database.DatabaseEvent")]
		
		public function DatabaseResponder() {
		}
	}
}