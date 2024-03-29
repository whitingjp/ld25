package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*;
  import Src.*;

  public class Entity
  {
    public var alive:Boolean;
    private var manager:EntityManager;

    public function Entity()
    {
      alive = true;
    }

    public function setManager(manager:EntityManager):void
    {
      this.manager = manager;
    }
    
    public function get game():Game
    {
      return manager.game;
    }

    public function isAlive():Boolean { return alive; }  

    public function update():void {}
    public function render():void {}

    public function doSpell():Boolean { return false; }
  }
}