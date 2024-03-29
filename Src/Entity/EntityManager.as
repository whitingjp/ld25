package Src.Entity
{
  import mx.core.*;
  import mx.collections.*;
  import Src.*;
  import Src.Tiles.*;
  import flash.geom.*;

  public class EntityManager
  {
    private var entities:Array;
    private var subMoves:int;
    public var game:Game;

    public var pushArray:Array;

    public var targetBunnies:int = 10;
    public var targetHeroes:Number = 1;
    public var spawnTimer:Number = 0;

    public function EntityManager(game:Game, subMoves:int)
    {      
      this.game = game;
      this.subMoves = subMoves;
      reset();
    }
    
    public function reset():void
    {
      entities = new Array();
      pushArray = new Array();
    }

    public function push(entity:Entity):void
    {
      entity.setManager(this);
      pushArray.push(entity);
    }

    public function update():void
    {
      var i:int;
      for(i=0; i<entities.length; i++)
        entities[i].update();
      clearCollided();
      doWrap();
      // x
      move(true);
      tileResolve(true);
      // y
      move(false);
      tileResolve(false);
      resolve();
      for(i=0; i<entities.length; i++)
      {
        if(!entities[i].alive)
        {
          if(entities[i] is Hero)
            game.score++;
          if(entities[i] is Witch)
            game.gameOverMan()
        }
      }
      entities = entities.filter(isAlive);
      while(pushArray.length > 0)
        entities.push(pushArray.pop());

      
      if(spawnTimer > 0)
        spawnTimer -= 0.002;
      if(spawnTimer <= 0)
      {
        
        var bunnyCount:int = 0;
        var heroCount:int = 0;
        for(i=0; i<entities.length; i++)
        {
          if(entities[i] is Bunny || entities[i] is DemonBunny)
            bunnyCount++;          
          if(entities[i] is Hero)
            heroCount++;
        }
        var levelWidth:int = game.tileMap.width*TileMap.tileWidth;
        var pos:Point;
        while(bunnyCount < targetBunnies)
        { 
          pos = new Point(Math.random()*levelWidth, -10);
          push(new Bunny(pos));
          bunnyCount++;
        }
        if(heroCount == 0)
        {
          targetHeroes += 1;
          while(heroCount < targetHeroes)
          {
            pos = new Point(Math.random()*(levelWidth/8)+levelWidth/8, -10);
            push(new Hero(pos));
            heroCount++;
          }
        }
        
        spawnTimer = 1;
      }
      
    }

    public function render():void
    {
      for(var i:int=0; i<entities.length; i++)
        entities[i].render();
    }

    private function isAlive(element:*, index:int, arr:Array):Boolean
    {
      return element.alive;
    }

    private function doWrap():void
    {
      for(var i:int = 0; i < entities.length; i++)
      {
        if(entities[i].hasOwnProperty("collider"))
        {
          var mapWidth:int = game.tileMap.width * TileMap.tileWidth;
          if(entities[i].collider.pos.x < 0)
            entities[i].collider.pos.x += mapWidth;
          if(entities[i].collider.pos.x >= mapWidth)
            entities[i].collider.pos.x -= mapWidth;
        }
      }
    }

    private function clearCollided():void
    {
      for(var i:int = 0; i < entities.length; i++)
        if(entities[i].hasOwnProperty("collider"))
          entities[i].collider.collided = 0;
    }

    private function move(isX:Boolean):void
    {
      for(var i:int = 0; i < entities.length; i++)
      {
        if(!entities[i].hasOwnProperty("collider"))
          continue;
        if(isX)
          entities[i].collider.pos.x += entities[i].collider.speed.x;
        else
          entities[i].collider.pos.y += entities[i].collider.speed.y;
      }
    }

    public function getColliding(rect:Rectangle):Array
    {
      var a:Array = new Array();
      var i:int;
      for(i = 0; i < entities.length; i++)
      {        
        if(!entities[i].hasOwnProperty("collider"))
          continue;
        if(!entities[i].collider.resolve)
          continue;
        var wi:Rectangle = entities[i].collider.worldRect;
        if(!wi.intersects(rect))
          continue;
        a.push(entities[i]);
      }
      return a;
    }

    private function resolve():Boolean
    {
      var i:int;
      var j:int;
      var anyOverlaps:Boolean = false;
      for(i = 0; i < entities.length; i++)
      {
        for(j = i + 1; j < entities.length; j++)
        {
          if(!entities[i].hasOwnProperty("collider") || !entities[j].hasOwnProperty("collider"))
            continue;
          if(!entities[i].collider.resolve || !entities[j].collider.resolve)
            continue;
          var wi:Rectangle = entities[i].collider.worldRect;
          var wj:Rectangle = entities[j].collider.worldRect;
          if(!wi.intersects(wj))
            continue;
          anyOverlaps = true;
          var minmove:Point = minMove(wi, wj);
          if(Math.abs(minmove.x) < Math.abs(minmove.y))
            minmove.x = 0;
          else
            minmove.y = 0;
          minmove.x /= 2;
          minmove.y /= 2;
          //if(minmove.y < 0) entities[i].collider.collided |= 1;
          //if(minmove.x > 0) entities[i].collider.collided |= 2;
          //if(minmove.y > 0) entities[i].collider.collided |= 4;
          //if(minmove.x < 0) entities[i].collider.collided |= 8;
          entities[i].collider.pos = entities[i].collider.pos.subtract(minmove)
          entities[j].collider.pos = entities[j].collider.pos.add(minmove)
        }
      }
      return anyOverlaps;
    }

    private function tileResolve(isX:Boolean):void
    {
      var i:int
      var size:Point = new Point(TileMap.tileWidth, TileMap.tileHeight);
      for(i = 0; i < entities.length; i++)
      {
        if(!entities[i].hasOwnProperty("collider"))
          continue;
        var worldrect:Rectangle = entities[i].collider.worldRect;
        var bound:Rectangle = worldrect.clone();
        bound.left = int(bound.left / size.x);
        bound.top = int(bound.top / size.y);
        bound.right = int(bound.right / size.x);
        bound.bottom = int(bound.bottom / size.y);
        var x:int;
        var y:int;
        for(x = bound.right; x >= bound.left; x--) {
          for(y = bound.bottom; y >= bound.top; y--) {
            var tile:Tile = game.tileMap.getTile(x, y);
            if(tile.t != Tile.T_WALL)
              continue;
            var tileRect:Rectangle = new Rectangle(x*size.x, y*size.y-1, size.x, size.y);
            if(!worldrect.intersects(tileRect))
              continue;
            if(!entities[i].collider.tileResolve)
              continue;              
            var minmove:Point = minMove(tileRect, worldrect);
            if(isX == false)
              minmove.x = 0;
            else
              minmove.y = 0;
            if(minmove.y < 0) entities[i].collider.collided |= 1;
            if(minmove.x > 0) entities[i].collider.collided |= 2;
            if(minmove.y > 0) entities[i].collider.collided |= 4;
            if(minmove.x < 0) entities[i].collider.collided |= 8;
            entities[i].collider.pos = entities[i].collider.pos.add(minmove);
            worldrect = entities[i].collider.worldRect;
          }
        }
      }
    }

    private function minMove(wi:Rectangle, wj:Rectangle):Point
    {
      var imid:Point = wi.topLeft.add(wi.bottomRight)
      imid.x /= 2;
      imid.y /= 2;
      var jmid:Point = wj.topLeft.add(wj.bottomRight)
      jmid.x /= 2;
      jmid.y /= 2;
      var diff:Point = imid.subtract(jmid)
      if(diff.x == 0 && diff.y == 0)
        diff.x = 1;
      var iSize:Point = wi.intersection(wj).size;
      var xmove:Number = iSize.x / diff.x;
      var ymove:Number = iSize.y / diff.y;
      var minmove:Number;
      if(Math.abs(xmove) < Math.abs(ymove))
      {
        minmove = xmove;
        if(imid.x > jmid.x)
          minmove = -minmove;
      } else {
        minmove = ymove;
        if(imid.y > jmid.y)
          minmove = -minmove;
      }
      if(Math.abs(minmove) < 0.001)
      {
        if (minmove < 0)
          minmove = -0.001;
        else
          minmove = 0.001;
      }
      diff.x *= minmove;
      diff.y *= minmove;
      return diff;
    }
  }
}