package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*
  import flash.ui.Keyboard;
  import flash.utils.Dictionary;
  import Src.Tiles.*;

  public class CPlatformer
  {
    private var collider:CCollider;
    public var sprite:CSprite;
    private var controller:CController;
    private var e:Entity;
    public var isLeft:Boolean;
    public var anim:Number;
    public var runSpeed:Number;

    public function CPlatformer(e:Entity, collider:CCollider, sprite:CSprite, controller:CController)
    {
      this.e = e;
      this.collider = collider;
      this.sprite = sprite;
      this.controller = controller;
      this.anim = 0;
      this.runSpeed = 1;
      reset();
    }

    public function reset():void
    {
      isLeft = false;
    }

    public function updateRun():void
    {
      if(controller.goLeft)
      {
        collider.speed.x -= 0.3;
        if(collider.speed.x < -runSpeed)
          collider.speed.x = -runSpeed;
      }
      if(controller.goRight)
      {
        collider.speed.x += 0.3;
        if(collider.speed.x > runSpeed)
          collider.speed.x = runSpeed;
      }
      if(!controller.goLeft && !controller.goRight)
        collider.speed.x /= 1.7;
      else
      {
        anim = anim + 0.05;
        while(anim > 1) anim--;
      }

      if(controller.goLeft && ! controller.goRight)
        isLeft = true;
      if(controller.goRight && ! controller.goLeft)
        isLeft = false;
    }

    public function updateJump():void
    {
      var canJump:Boolean = (collider.collided & 1) > 0;
      if(canJump)
      {
        collider.speed.y = 1-0.3;
        if(controller.goUp)
          collider.speed.y = -3;
      }
      collider.speed.y += 0.3;
      if(collider.speed.y > 3)
        collider.speed.y = 3;
    }

    public function update():void
    {
      controller.update(); 
      updateRun();
      updateJump();      
    }
 
    public function render(pos:Point=null):void
    {
      if(pos == null)
        pos = collider.pos;
      sprite.frame.x = anim*sprite.def.xFrames;
      if(isLeft)
        sprite.frame.y = 1;
      else
        sprite.frame.y = 0;        
      sprite.render(pos);
    }
  }
}