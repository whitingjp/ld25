package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*
  import flash.ui.Keyboard;
  import flash.utils.Dictionary;
  import Src.Tiles.*;
  import Src.Gfx.*;

  public class CSprite
  {
    private var e:Entity;
    public var def:SpriteDef;
    public var frame:Point;
    
    public function CSprite(e:Entity, def:SpriteDef)
    {
      this.e = e;
      this.def = def;
      this.frame = new Point(0,0);
    }
    
    public function render(pos:Point):void
    {
      e.game.renderer.drawSprite(def, pos.x+0.25, pos.y+0.25, frame.x, frame.y);
    }
  }
}