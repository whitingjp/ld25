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
      sprite = new CSprite(this, new SpriteDef(90,40,5,5,2,1));    
      collider = new CCollider(this);
      collider.rect = new Rectangle(1,1,3,3);
      collider.pos = pos;
      collider.resolve = false;
      collider.tileResolve = false;
      collider.speed.x = isLeft ? -1.5 : 1.5;
      animTimer = 0;
      lifeTimer = 1;
    }

    public override function update():void
    {
      animTimer += 0.05;
      lifeTimer -= 0.001;
      if(game.tileMap.getColAtRect(collider.worldRect) == CCollider.COL_SOLID)
      {
        alive = false;
        game.makeMagic(collider.pos.clone());
        var worldRect:Rectangle = collider.worldRect;
        var centre:Point=new Point((worldRect.left+worldRect.right)/2, (worldRect.top+worldRect.bottom)/2);
        var offCentre:Point = centre.clone();
        offCentre.x += collider.speed.x * 6;
        var tileIndex:int = game.tileMap.getIndexFromPos(offCentre);
        var xy:Point = game.tileMap.getXY(tileIndex);
        var tile:Tile = game.tileMap.getTileFromIndex(tileIndex);
        if(game.tileMap.getTileGroup(game.tileMap.getTileAtPos(offCentre)) == 1)
        {                    
          tileIndex = game.tileMap.getIndexFromPos(centre);
          xy = game.tileMap.getXY(tileIndex);
          tile = game.tileMap.getTileFromIndex(tileIndex);

          tile.t = Tile.T_WALL;
          tile.xFrame = 4;
          game.soundManager.playSound("makeBlock");
        } else
        {
          tile.t = Tile.T_NONE;
          tile.xFrame = 0;
          tile.yFrame = 0;
          game.soundManager.playSound("removeBlock");
        }
        game.tileMap.autoTileSet(xy.x, xy.y);
        return;
      }
      if(lifeTimer < 0)
      {
        alive = false;
        return;
      }
      var colliding:Array = game.entityManager.getColliding(collider.worldRect);
      for(var i:int=0; i<colliding.length; i++)
      {
        if(!colliding[i].alive || !alive)
          continue;
        if(colliding[i].doSpell())
        {
          alive = false;
          game.makeMagic(collider.pos.clone());
        }
      }      
    }
    
    public override function render():void
    {
      sprite.frame.x = animTimer * 2;
      sprite.render(collider.pos);
    }
  }
}