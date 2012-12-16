package Src.FE
{
  import mx.core.*;
  import mx.collections.*;
  import Src.*;
  import Src.Gfx.*;

  public class MainMenu extends Screen
  {
    public var screen:int;
    public var animTimer:Number;
    public var story:SpriteDef; 
    public var delay:Number;   

    public function MainMenu()
    {
      screen = 0;
      animTimer = 0;
      story = new SpriteDef(120,0,40,30,1,5)
      delay = 1;
    }

    public override function update():void
    {
      animTimer += 0.02;
      if(delay > 0) delay -= 0.1;
      while(animTimer > 1) animTimer--;
      if(game.input.actKey(false))
      {
        screen++;
        delay = 1;
        if(screen > 2)
        {
          game.State = Game.STATE_GAME;
        }
      }
    }

    public override function render():void
    {
      var frame:int = animTimer * 2 + screen*2;
      if(screen == 2)
        frame = 4; 
      game.renderer.drawSprite(story, 0, 0, 0, frame);
    }
  }
}