package events
{
	import flash.events.Event;
	
	public class DataEvent extends Event {
		
		public static var DATA_LOADED:String = "dataLoaded";
		private var _data:Object;
		
		public function DataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null) {
			super(type, bubbles, cancelable);
			this._data = data;
		}
		
		override public function clone():Event {
			return new DataEvent(type, bubbles, cancelable, data);
		}
		
		public function get data():Object {
			return _data;
		}
		
	}
}