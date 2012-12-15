package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*
  import flash.ui.Keyboard;
  import flash.utils.Dictionary;
  import Src.Tiles.*;
  import Src.Gfx.*;

  public class DemonBunny extends Entity
  {
    public var collider:CCollider;
    public var platformer:CPlatformer;
    public var controller:CGrazeController;
    public var nullController:CController;
    public var sprite:CSprite;
    public var eatSprite:CSprite;
    public var eatTimer:Number = -1;

    public var captured:Entity = null;

    public function DemonBunny(collider:CCollider, controller:CGrazeController)
    {
      this.collider = collider;
      this.controller = controller;
      sprite = new CSprite(this, new SpriteDef(0,70,10,10,2,2));
      eatSprite = new CSprite(this, new SpriteDef(0,90,20,20,4,2));
      platformer = new CPlatformer(this, collider, sprite, controller);
      nullController = new CController();
      controller.platformer = platformer;
    }

    public override function update():void
    { 
      platformer.update();
      var e:Entity = game.entityManager.getColliding(collider);
      if(e != null && !(e is Witch) && !(e is DemonBunny))
      {
        platformer.controller = nullController;
        e.alive = false;
        captured = e;
        eatTimer = 1;
      }
      if(eatTimer >= 0)
      {
        collider.speed.x = 0;
        eatTimer -= 0.05;
        if(eatTimer < 0)
        {
          game.entityManager.push(new Bunny(collider.pos));
          alive = false;
        }
      }
    }    
    
    public override function render():void
    {
      if(eatTimer >= 0)
      {
        captured.render();
        eatSprite.frame.x = (1-eatTimer)*4;
        var renderPos:Point = collider.pos.clone();
        renderPos.y -= 10;
        if(platformer.isLeft)
        {
          eatSprite.frame.y = 1;
          renderPos.x -= 10;
        }
        else
        {
          eatSprite.frame.y = 0;
        }
        eatSprite.render(renderPos);
      } else
      {
        platformer.render(collider.pos);
      }
    }
  }
}