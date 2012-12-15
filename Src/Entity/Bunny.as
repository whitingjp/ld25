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
    var rabbitSprite:CSprite;
    var darkSprite:CSprite;

    public function Bunny(pos:Point)
    {
      rabbitSprite = new CSprite(this, new SpriteDef(20,70,10,10,2,2));
      darkSprite = new CSprite(this, new SpriteDef(0,70,10,10,2,2));
      collider = new CCollider(this);
      collider.rect = new Rectangle(0,0,10,9);
      controller = new CGrazeController(this, collider);
      platformer = new CPlatformer(this, collider, rabbitSprite, controller);
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
      if(platformer.sprite == darkSprite)
        return false;
      
      platformer.sprite = darkSprite;
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