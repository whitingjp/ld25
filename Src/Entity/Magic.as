package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*
  import flash.ui.Keyboard;
  import flash.utils.Dictionary;
  import Src.Tiles.*;
  import Src.Gfx.*;

  public class Magic extends Entity
  {
    public var collider:CCollider;
    public var sprite:CSprite;
    public var timer:Number;

    public function Magic(pos:Point)
    {      
      sprite = new CSprite(this, new SpriteDef(0,170,10,10,6,1));
      
      collider = new CCollider(this);
      collider.rect = new Rectangle(1,1,3,3);
      collider.pos = pos.clone();
      collider.resolve = false;
      collider.tileResolve = false;
      collider.speed = new Point(0,0);
      collider.speed.x = Math.random()*4-2;
      collider.speed.y = Math.random()*2-1;
      timer = 1+Math.random();
    }

    public override function render():void
    {
      sprite.frame.x = (1-timer)*5;
      sprite.render(collider.pos);
    }

    public override function update():void
    {      
      collider.speed.x *= 0.9;
      collider.speed.y -= 0.15;
      timer -= 0.08;
      if(timer < 0)
        alive = false;
    }
  }
}