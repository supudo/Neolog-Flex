package skins {
	
	import mx.resources.ResourceManager;
	import spark.skins.mobile.ToggleSwitchSkin;
	
	[ResourceBundle("resources")]
	public class ToggleYesNo extends ToggleSwitchSkin {

		public function ToggleYesNo() {
			super();
			selectedLabel = ResourceManager.getInstance().getString('resources','yes');
			unselectedLabel = ResourceManager.getInstance().getString('resources','no');
		}
	}
}