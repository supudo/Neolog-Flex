package events
{
	import flash.events.Event;
	import spark.components.View;
	
	public class ViewEvent extends Event {
		
		public function ViewEvent(type:String, argResult:View, bubbles:Boolean=false, cancelable:Boolean=false) {
			this._result = argResult;
			super(type, bubbles, cancelable);
		}
		
		public function get result():View {
			return this._result;
		}
		
		override public function clone():Event {
			return new ViewEvent(type, result, bubbles, cancelable);
		}
		
		public static const ViewViewed:String = "ViewEvent.ViewViewed";
		//public static const SearchJobsView:String = "SearchJobsView";
		//public static const SearchPeopleView:String = "SearchPeopleView";

		private var _result:View;
		
	}
}