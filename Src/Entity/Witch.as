package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*
  import flash.ui.Keyboard;
  import flash.utils.Dictionary;
  import Src.Tiles.*;
  import Src.Gfx.*;

  public class Witch extends Entity
  {
    public var collider:CCollider;
    public var platformer:CPlatformer;
    public var controller:CController;

    public function Witch(pos:Point)
    {
      var sprite:CSprite = new CSprite(this, new SpriteDef(0,50,10,10,2,2));
      controller = new CPlayerController(this);
      collider = new CCollider(this);
      collider.rect = new Rectangle(0,0,10,9);
      platformer = new CPlatformer(this, collider, sprite, controller);      
      reset();
      collider.pos = pos;
    }

    public function reset():void
    {
      collider.pos = new Point(0,0);
      collider.speed = new Point(0,0);
    }

    public override function update():void
    {
      platformer.update();
    }    
    
    public override function render():void
    {
      platformer.render(collider.pos);
    }
  }
}