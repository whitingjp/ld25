package {
	import flash.display.Sprite;
	import flash.events.Event;
	
	import Src.Game;
	
	public class Main extends Sprite {
		private var game:Game;
	
		public function Main()
		{
			game = new Game();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		public function reAddBuffer() : void
		{
			while(numChildren != 0) removeChildAt(0);
			addChild(game.renderer.bitmap);
		}
		
		private function onAddedToStage( pEvent : Event ) : void
		{
			game.init(60, stage, this);
			reAddBuffer();
		}
	}
}