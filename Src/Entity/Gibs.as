package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*
  import flash.ui.Keyboard;
  import flash.utils.Dictionary;
  import Src.Tiles.*;
  import Src.Gfx.*;

  public class Gibs extends Entity
  {
    public var collider:CCollider;
    public var sprite:CSprite;
    public var timer:Number;

    public function Gibs(pos:Point)
    {      
      sprite = new CSprite(this, new SpriteDef(0,180,5,5,10,1));
      sprite.frame.x = Math.random()*10;
      collider = new CCollider(this);
      collider.rect = new Rectangle(1,1,3,3);
      collider.pos = pos.clone();
      collider.resolve = false;
      collider.speed = new Point(0,0);
      collider.speed.x = Math.random()*4-2;
      collider.speed.y = -Math.random()*3;
      timer = 1+Math.random();
    }

    public override function render():void
    {
      sprite.render(collider.pos);
    }

    public override function update():void
    {      
      collider.speed.x *= 0.9;
      collider.speed.y += 0.2;
      if(collider.speed.y > 2)
        collider.speed.y = 2;
      timer -= 0.005;
      if(timer < 0)
        alive = false;
    }
  }
}