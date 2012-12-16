package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*
  import flash.ui.Keyboard;
  import flash.utils.Dictionary;
  import Src.Tiles.*;
  import Src.Gfx.*;

  public class Bunny extends Entity
  {
    public var collider:CCollider;
    public var platformer:CPlatformer;
    public var controller:CGrazeController;
    public var sprite:CSprite;
    public var darkSprite:CSprite;

    public function Bunny(pos:Point)
    {
      sprite = new CSprite(this, new SpriteDef(20,70,10,10,2,2));
      collider = new CCollider(this);
      collider.rect = new Rectangle(0,0,10,9);
      controller = new CGrazeController(this, collider);
      platformer = new CPlatformer(this, collider, sprite, controller, "bunnyJump");
      controller.platformer = platformer;
      reset();
      collider.pos = pos;
    }

    public function reset():void
    {
      collider.pos = new Point(0,0);
      collider.speed = new Point(0,0);
    }

    public override function doSpell():Boolean
    {
      // demon bunny
      alive = false;
      var demon:DemonBunny = new DemonBunny(collider, controller);
      demon.platformer.isLeft = platformer.isLeft;
      game.entityManager.push(demon);

      game.soundManager.playSound("convert");
      return true;
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