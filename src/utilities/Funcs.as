package utilities {
	import mx.resources.ResourceManager;

	[ResourceBundle("resources")]
	public class Funcs {

		public function Funcs() {
		}
		
		public function getFullDate(dt:Date, today:Date, withYear:Boolean):String {
			var d:String = "";
			d += dt.date + " ";
			d += ResourceManager.getInstance().getString('resources','monthsLong_' + dt.month) + " ";
			if (withYear || dt.fullYear != today.fullYear)
				d += dt.fullYear;
			if (dt.date == today.date && dt.month == today.month && dt.fullYear == today.fullYear)
				d = ResourceManager.getInstance().getString('resources','date_Now');
			return d;
		}
		
		public function getPrintDate(dt:Date):String {
			var d:String = "";
			d += dt.date + " ";
			d += ResourceManager.getInstance().getString('resources','monthsLong_' + dt.month) + " ";
			d += dt.fullYear;
			return d;
		}
		
		public function emailIsValid(email:String):Boolean {
			var validEmail:Boolean = false;
			if (email != "" && email.indexOf("@") > 0 && email.indexOf(".") > 0)
				validEmail = true;
			return validEmail;
		}

	}

}