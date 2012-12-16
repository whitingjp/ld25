package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*
  import flash.ui.Keyboard;
  import flash.utils.Dictionary;
  import Src.Tiles.*;
  import Src.Gfx.*;

  public class Newt extends Entity
  {
    public var collider:CCollider;
    public var platformer:CPlatformer;
    public var controller:CController;
    public var timer:Number;
    public var good:Boolean;

    public function Newt(collider:CCollider, controller:CController, good:Boolean)
    {
      var sprite:CSprite;
      this.good = good;
      if(good)
        sprite = new CSprite(this, new SpriteDef(60,70,10,10,2,2));
      else
        sprite = new CSprite(this, new SpriteDef(40,70,10,10,2,2));
      this.collider = collider;
      collider.rect = new Rectangle(0,5,10,4);
      this.controller = controller;
      platformer = new CPlatformer(this, collider, sprite, controller, "newtJump");
      platformer.runSpeed = 0;
      timer = 1;
    }

    public override function doSpell():Boolean
    {
      // thank god for that
      returnToTrueForm();
      return true;
    }

    private function returnToTrueForm():void
    {
        if(good)
        {
          game.entityManager.push(new Hero(collider.pos));
          game.score--;
        }
        else
          game.entityManager.push(new Witch(collider.pos));
        alive = false;
        game.soundManager.playSound("deNewt");
    }

    public override function update():void
    {
      platformer.update();
      timer -= 0.005;
      if(timer < 0)
        returnToTrueForm();
    }    
    
    public override function render():void
    {
      platformer.render(collider.pos);
    }
  }
}