package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*
  import flash.ui.Keyboard;
  import flash.utils.Dictionary;
  import Src.Tiles.*;
  import Src.Gfx.*;

  public class Spell extends Entity
  {
    public var collider:CCollider;
    public var sprite:CSprite;
    public var animTimer:Number;
    public var lifeTimer:Number;

    public function Spell(pos:Point, isLeft:Boolean)
    {
      sprite = new CSprite(this, new SpriteDef(40,50,5,5,2,1));    
      collider = new CCollider(this);
      collider.rect = new Rectangle(1,1,3,3);
      collider.pos = pos;
      collider.resolve = false;
      collider.speed.x = isLeft ? -1 : 1;
      animTimer = 0;
      lifeTimer = 1;
    }

    public override function update():void
    {
      animTimer += 0.05;
      lifeTimer -= 0.001;
      if(game.tileMap.getColAtRect(collider.worldRect) == CCollider.COL_SOLID)
        alive = false;
      if(lifeTimer < 0)
        alive = false;
      var colliding:Entity = game.entityManager.getColliding(collider);
      if(colliding != null)
      {
        if(colliding.doSpell())
          alive = false;
      }
    }    
    
    public override function render():void
    {
      sprite.frame.x = animTimer * 2;
      sprite.render(collider.pos);
    }
  }
}