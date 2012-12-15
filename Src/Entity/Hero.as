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

    public function Hero(pos:Point)
    {
      var sprite:CSprite = new CSprite(this, new SpriteDef(20,50,10,10,2,2));      
      collider = new CCollider(this);
      collider.rect = new Rectangle(0,0,10,9);
      controller = new CHeroController(this, collider);
      platformer = new CPlatformer(this, collider, sprite, controller);      
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
      // she turned me into a newt
      alive = false;
      game.entityManager.push(new Newt(collider, controller, true));
      return true;
    }


    public override function update():void
    {
      platformer.update();
      if(controller.doAction)
      {
        var pos:Point = collider.pos.clone();
        pos.x += platformer.isLeft ? -3 : 7;
        pos.y += 4;
        var spell:Spell = new Spell(pos, platformer.isLeft);

        game.entityManager.push(spell);
      }
      var paintRect:Rectangle = collider.worldRect.clone();
      paintRect.inflate(5,5);
      game.tileMap.paintRect(paintRect, 0);
    }    
    
    public override function render():void
    {
      platformer.render(collider.pos);
    }
  }
}