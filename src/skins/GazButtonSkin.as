package skins {
	
	import spark.skins.mobile.ButtonSkin;

	public class GazButtonSkin extends ButtonSkin {
		
		[Bindable]
		[Embed(source="../assets/images/gaz.png")]
		private var boomImage:Class;

		public function GazButtonSkin() {
			super();
			width = 280;
			height = 37;
		}
		
		override protected function getBorderClassForCurrentState():Class {
			labelDisplay.setStyle("color", 0xFFFFFF);
			return boomImage;
		}
		
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void {
		}
	}
}