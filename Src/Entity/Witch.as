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

    public var spellTimer:Number;

    public function Witch(pos:Point)
    {
      var sprite:CSprite = new CSprite(this, new SpriteDef(0,50,10,10,2,2));
      controller = new CPlayerController(this);
      collider = new CCollider(this);
      collider.rect = new Rectangle(0,0,10,9);
      platformer = new CPlatformer(this, collider, sprite, controller);      
      reset();
      collider.pos = pos;
      spellTimer = 0;
    }

    public function reset():void
    {
      collider.pos = new Point(0,0);
      collider.speed = new Point(0,0);
    }

    public override function doSpell():Boolean
    {
      // well that was silly
      alive = false;
      game.entityManager.push(new Newt(collider, controller, false));
      return true;
    }
    public override function update():void
    {
      platformer.update();
      if(controller.doAction && spellTimer <= 0)
      {
        trace(spellTimer);
        spellTimer = 1;
        trace(spellTimer);
        var pos:Point = collider.pos.clone();
        pos.x += platformer.isLeft ? -6: 10;
        pos.y += 4;
        var spell:Spell = new Spell(pos, platformer.isLeft);        

        game.entityManager.push(spell);
      }
      if(spellTimer > 0)
        spellTimer -= 0.05;     
      var paintRect:Rectangle = collider.worldRect.clone();
      paintRect.inflate(5,5);
      game.tileMap.paintRect(paintRect, 1);
    }    
    
    public override function render():void
    {
      platformer.render(collider.pos);
    }
  }
}