package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*
  import flash.ui.Keyboard;
  import flash.utils.Dictionary;
  import Src.Tiles.*;
  import Src.Gfx.*;

  public class Hero extends Entity
  {
    public var collider:CCollider;
    public var platformer:CPlatformer;
    public var controller:CController;

    public var heroController:CController;
    public var nullController:CController;

    public var slashTimer:Number = -1;

    public var captured:Entity = null;

    public var windUp:int;

    public function Hero(pos:Point)
    {
      var sprite:CSprite = new CSprite(this, new SpriteDef(20,50,10,10,7,2));
      collider = new CCollider(this);
      collider.rect = new Rectangle(0,0,10,9);
      heroController = new CHeroController(this, collider);
      nullController = new CController();
      controller = heroController;
      platformer = new CPlatformer(this, collider, sprite, controller, "heroJump");      
      reset();
      collider.pos = pos;
      windUp=0;
    }

    public function reset():void
    {
      collider.pos = new Point(0,0);
      collider.speed = new Point(0,0);
    }

    public override function doSpell():Boolean
    {
      // she turned me into a newt
      alive = false;
      game.entityManager.push(new Newt(collider, controller, true));
      game.soundManager.playSound("convert");
      return true;
    }


    public override function update():void
    {
      if(!alive)
        return;
      platformer.update();
      var paintRect:Rectangle = collider.worldRect.clone();
      paintRect.inflate(5,5);
      game.tileMap.paintRect(paintRect, 0);

      if(slashTimer >= 0)
      {
        collider.speed.x = 0;
        slashTimer -= 0.05;
        if(slashTimer < 0)
        {
          platformer.controller = heroController;
          captured = null;
        }
        return;
      }

      var worldRect:Rectangle = collider.worldRect;
      worldRect.offset(platformer.isLeft ? -4 : 4, 0);
      var colliding:Array = game.entityManager.getColliding(worldRect);
      for(var i:int=0; i<colliding.length; i++)
      {
        if(!colliding[i].alive)
          continue;
        if(colliding[i] is Bunny || colliding[i] is Spell || colliding[i] is Hero)
          continue;
        if(windUp == 0)
        {
          windUp+=5;
          break;
        }
        platformer.controller = nullController;
        colliding[i].alive = false;
        captured = colliding[i];
        slashTimer = 1;
        game.soundManager.playSound("slash");
      }
      if(windUp > 0) windUp--;
    }    
    
    public override function render():void
    {
      if(slashTimer >= 0)
      {
        captured.render();
        platformer.sprite.frame.x = (1-slashTimer)*7;
        var renderPos:Point = collider.pos.clone();
        platformer.sprite.render(renderPos);
      } else
      {
        platformer.render(collider.pos);
      }
    }
  }
}