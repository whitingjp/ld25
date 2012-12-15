package Src.Entity
{
  import flash.geom.*;
  import Src.*;
  import Src.Tiles.*;
  import Src.Entity.*;
  public class CHeroController extends CController
  {
    private var e:Entity;
    private var aimingLeft:Boolean;
    public var platformer:CPlatformer;
    private var collider:CCollider;
    public function CHeroController(e:Entity, collider:CCollider)
    {
      this.e = e;
      this.collider = collider;
      aimingLeft = Math.random() > 0.5;
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
      if((getCollisionAt(2*o,0) & CCollider.COL_SOLID))
        return false;
      return true;
    }

    public override function get goUp():Boolean
    {
      var o:int = aimingLeft ? -1 : 1;
      if((getCollisionAt(2*o,0) & CCollider.COL_SOLID))
        return true;
      return false;
    }

    public override function get goRight():Boolean { return goSideways(false); }
    public override function get goDown():Boolean { return false; }
    public override function get goLeft():Boolean { return goSideways(true); }
    public override function get doAction():Boolean { return false; }

    public override function update():void
    {
    }
  }
}