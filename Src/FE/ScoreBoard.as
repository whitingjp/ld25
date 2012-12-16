package Src.FE
{
  import mx.core.*;
  import mx.collections.*;
  import Src.*;
  import Src.Gfx.*;

  public class ScoreBoard extends Screen
  {
    public var scoreBoard:SpriteDef;
    public var numbers:SpriteDef;
    public var delay:Number;

    public function ScoreBoard()
    {
      scoreBoard = new SpriteDef(0,140,40,30);
      numbers = new SpriteDef(0,130,5,5,10);
      delay = 1;
    }

    public override function update():void
    {      
      if(delay > 0) delay -= 0.015;
      if(delay <= 0 && game.input.actKey(false))
        game.State = Game.STATE_GAME;
    }

    public override function render():void
    { 
      game.renderer.drawSprite(scoreBoard, 0, 0);
      var tens:int = game.score/10;
      var units:int = game.score-tens*10;
      game.renderer.drawSprite(numbers, 21, 12, tens);
      game.renderer.drawSprite(numbers, 26, 12, units);
    }
  }
}