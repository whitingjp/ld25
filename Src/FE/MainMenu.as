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
    public var hitTimer:Number;

    public function MainMenu()
    {
      screen = -1;
      animTimer = 0;
      story = new SpriteDef(120,0,40,30,1,10)
      delay = 1;
      hitTimer = 0;
    }

    public override function update():void
    {
      animTimer += 0.02;
      if(delay > 0) delay -= 0.01;
      while(animTimer > 1) animTimer--;
      if(delay <= 0 && game.input.actKey(false))
      {
        screen++;
        delay = 1;
        if(screen > 4)
        {
          game.State = Game.STATE_GAME;
        }
      }

      if(hitTimer > 0)
        hitTimer -= 0.015;
      if(hitTimer <= 0 && screen > -1)
      {
        if(screen < 4)
        {
          game.soundManager.playSound("breakingHouse");
        } else
        {
           game.soundManager.playSound("convert");
        }
        hitTimer = 1+Math.random()*0.1;
      }

    }

    public override function render():void
    { 
      var renderScreen:int = screen;
      if(renderScreen < 0) renderScreen = 0;
      var frame:int = animTimer * 2 + renderScreen*2;
      var shake:Number = Math.random()*(hitTimer*3);
      if(screen >= 4) shake = 0;
      game.renderer.drawSprite(story, shake, 0, 0, frame);
    }
  }
}