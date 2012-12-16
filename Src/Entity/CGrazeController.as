package Src.Entity
{
  import flash.geom.*;
  import Src.*;
  import Src.Tiles.*;
  import Src.Entity.*;
  public class CGrazeController extends CController
  {
    private var e:Entity;
    public var aimingLeft:Boolean;
    public var platformer:CPlatformer;
    private var collider:CCollider;
    public var flipChance:Number = 0.01;
    public var disregardGravityTimer:Number = 0;
    public function CGrazeController(e:Entity, collider:CCollider)
    {
      this.e = e;
      this.collider = collider;
      disregardGravityTimer = 0;
    }

    private function getCollisionAt(x:int, y:int):int
    {
      var rect:Rectangle = collider.worldRect;
      rect.inflate(-1,-1);
      rect.offset(x, y);
      return e.game.tileMap.getColAtRect(rect);
    }

    private function goSideways(isLeft:Boolean):Boolean
    {
      var o:int = isLeft ? -1 : 1;
      if(isLeft != aimingLeft)
        return false;
      if(!(getCollisionAt(8*o,8) & CCollider.COL_SOLID) && !(disregardGravityTimer > 0))
          return false;
      if((getCollisionAt(2*o,0) & CCollider.COL_SOLID))
        return false;
      return true;
    }

    public override function get goUp():Boolean { return Math.random() > 0.99; }
    public override function get goRight():Boolean { return goSideways(false); }
    public override function get goDown():Boolean { return false; }
    public override function get goLeft():Boolean { return goSideways(true); }
    public override function get doAction():Boolean { return false; }

    public override function update():void
    {
      if(disregardGravityTimer > 0)
        disregardGravityTimer -= 0.01;
      if(Math.random() > 0.997)
        disregardGravityTimer = 1;
      if(Math.random() > 1-flipChance)
        this.aimingLeft = Math.random() > 0.5;
    }
  }
}