package Src.Tiles
{
  import mx.core.*;
  import mx.collections.*;
  import flash.geom.*
  import flash.net.*;
  import flash.events.*;
  import flash.utils.*;
  import Src.*;
  import Src.Entity.*;
  import Src.Gfx.*;

  public class TileMap
  {  
    private static const OBJ_WITCH:int=1;
    private static const OBJ_HERO:int=2;
    private static const OBJ_BUNNY:int=3;
  
    public static var tileWidth:int=10;
    public static var tileHeight:int=10;
    
    private static var tileSpr:String="walls";
    private static var decorationSpr:String="decoration";
    private static var objSpr:String="objects";    
    
    public static const magic:int=0xface;
    public static const version:int=1;    
    
    public var width:int;
    public var height:int;
    public var tiles:Array;
    public var sprites:Array;
    
    public var game:Game;

    private var filledTile:Tile;
    
    public function TileMap(game:Game)
    {
      reset(32*4,6);
      this.game = game;
      filledTile = new Tile();
      filledTile.t = Tile.T_WALL;
    }
    
    public function reset(width:int, height:int):void
    {
      this.width = width;
      this.height = height;
      
      sprites = new Array();
      sprites[Tile.T_NONE] = new SpriteDef(80,0,10,10,4,3);
      sprites[Tile.T_WALL] = new SpriteDef(0,0,10,10,8,4);
      sprites[Tile.T_ENTITY] = new SpriteDef(0,40,10,10,4,1);
      
      tiles = new Array();
      for(var i:int=0; i<width*height; i++)
          tiles.push(new Tile());

      getTile(0,3).t = Tile.T_WALL;
    }
    
    public function spawnEntities():void
    {
      for(var i:int=0; i<tiles.length; i++)
      {
        var y:int = i/width;
        var x:int = i-(y*width);
        var p:Point = new Point(x*tileWidth, y*tileHeight);
        if(tiles[i].t == Tile.T_ENTITY)
        switch(tiles[i].xFrame)
        {
          case OBJ_WITCH:
            game.entityManager.push(new Witch(p));
            break;
          case OBJ_HERO:
            game.entityManager.push(new Hero(p));
            break;   
          case OBJ_BUNNY:
            game.entityManager.push(new Bunny(p));
            break;
        }
      }
    }

    public function render():void
    {
      for(var i:int=0; i<tiles.length; i++)
      {
        var y:int = i/width;
        var x:int = i-(y*width);
        var tile:Tile = getTile(x,y);
        if(tile.t == Tile.T_ENTITY && game.State != Game.STATE_EDITING)
          continue;
        var spr:SpriteDef = sprites[tile.t];  
        game.renderer.drawSprite(spr, x*tileWidth, y*tileHeight, tile.xFrame, tile.yFrame);
      }
    }
    
    public function getIndex(x:int, y:int):int
    {
      while(x < 0) x += width;
      while(x >= width) x -= width;
      if(y < 0) return -1;
      if(y >= height) return -1;
      return x+y*width;
    }
    
    public function getIndexFromPos(p:Point):int
    {
      var iTileX:int = p.x / tileWidth;
      var iTileY:int = p.y / tileHeight;
      return getIndex(iTileX, iTileY);
    }
    
    public function getTileFromIndex(i:int):Tile
    {
      return tiles[i];
    }    
        
    public function getTile(x:int, y:int):Tile
    {
      var i:int = getIndex(x, y);
      if(i == -1)
        return filledTile;
      else
        return getTileFromIndex(getIndex(x,y));
    }
    
    public function getTileAtPos(p:Point):Tile
    {
      var i:int = getIndexFromPos(p);
      if(i == -1)
        return filledTile;
      else
        return getTileFromIndex(i);
    }

    public function getXY(i:int):Point
    {
      var y:int = i/width;
      var x:int = i-(y*width);
      return new Point(x,y);
    }
    
    public function setTileByIndex(i:int, tile:Tile):void
    {
      tiles[i] = tile.clone();
    }
    
    public function setTile(x:int, y:int, tile:Tile):void
    {
      setTileByIndex(getIndex(x,y), tile);
    }
    
    public function getColAtPos(p:Point):int
    {
      switch(getTileAtPos(p).t)
      {
        case Tile.T_WALL: return CCollider.COL_SOLID;
      }
      return CCollider.COL_NONE;
    }

    public function getColAtRect(r:Rectangle):int
    {
      var col:int = CCollider.COL_NONE;
      var p:Point = new Point(0,0);
      for(p.x=r.left; p.x<=r.right; p.x+=tileWidth/2)      
        for(p.y=r.top; p.y<=r.bottom; p.y+=tileHeight/2)
          col = col | getColAtPos(p);
      p.x = r.right; p.y = r.bottom;
      col = col | getColAtPos(p);
      return col;
    }

    public function pack(byteArray:ByteArray):void
    {
      byteArray.writeInt(magic);
      byteArray.writeInt(version); 
      byteArray.writeInt(width);
      byteArray.writeInt(height);
      for(var i:int=0; i<tiles.length; i++)
        tiles[i].addToByteArray(byteArray);
      byteArray.compress();
    }

    public function unpack(byteArray:ByteArray):void
    {
      byteArray.uncompress();
           
      if(magic != byteArray.readInt())
      {
        trace("Not a game level file!");
        return;
      }
      if(TileMap.version != byteArray.readInt())
      {
        trace("Wrong level version!");
        return;
      }
      var w:int = byteArray.readInt();
      var h:int = byteArray.readInt();
      reset(w, h);
      for(var i:int=0; i<tiles.length; i++)
        tiles[i].readFromByteArray(byteArray);
    }

    
    public function getTileGroup(t:Tile):int
    {
      return int(t.xFrame/4)+int(t.yFrame/4)*16;
    }
    
    public function autoTile(x:int, y:int):void
    {
      var t:Tile = getTile(x, y);
      if(t.t != Tile.T_WALL)
        return;
      var group:int = getTileGroup(t);
      var flags:int = 0;

      var checkTile:Tile;
      checkTile = getTile(x,y-1);
      if(checkTile.t == t.t) flags |= 1;
      checkTile = getTile(x+1,y);
      if(checkTile.t == t.t) flags |= 2;
      checkTile = getTile(x,y+1);
      if(checkTile.t == t.t) flags |= 4;
      checkTile = getTile(x-1,y);
      if(checkTile.t == t.t) flags |= 8;
      
      var allWall:Boolean = false;
      switch(flags)
      {
        case  0: t.xFrame = 3; t.yFrame = 3; break;
        case  1: t.xFrame = 3; t.yFrame = 2; break;
        case  2: t.xFrame = 0; t.yFrame = 3; break;
        case  3: t.xFrame = 0; t.yFrame = 2; break;
        case  4: t.xFrame = 3; t.yFrame = 0; break;
        case  5: t.xFrame = 3; t.yFrame = 1; break;
        case  6: t.xFrame = 0; t.yFrame = 0; break;
        case  7: t.xFrame = 0; t.yFrame = 1; break;
        case  8: t.xFrame = 2; t.yFrame = 3; break;
        case  9: t.xFrame = 2; t.yFrame = 2; break;
        case 10: t.xFrame = 1; t.yFrame = 3; break;
        case 11: t.xFrame = 1; t.yFrame = 2; break;
        case 12: t.xFrame = 2; t.yFrame = 0; break;
        case 13: t.xFrame = 2; t.yFrame = 1; break;
        case 14: t.xFrame = 1; t.yFrame = 0; break;
        case 15: allWall = true; break;
      }
      if(allWall)
      {
        // is it center or inner corner?
        flags = 0;
        checkTile = getTile(x+1,y-1);
        if(checkTile.t == t.t) flags |= 1;
        checkTile = getTile(x+1,y+1);
        if(checkTile.t == t.t) flags |= 2;
        checkTile = getTile(x-1,y+1);
        if(checkTile.t == t.t) flags |= 4;
        checkTile = getTile(x-1,y-1);
        if(checkTile.t == t.t) flags |= 8;
        switch(flags)
        {
          default: t.xFrame = 1; t.yFrame = 1; break;
          /*
          case 3:  t.xFrame = 5; t.yFrame = 3; break;
          case 6:  t.xFrame = 4; t.yFrame = 2; break;
          case 7:  t.xFrame = 5; t.yFrame = 1; break;
          case 9:  t.xFrame = 4; t.yFrame = 3; break;
          case 11: t.xFrame = 5; t.yFrame = 0; break;
          case 12: t.xFrame = 5; t.yFrame = 2; break;
          case 13: t.xFrame = 4; t.yFrame = 0; break;
          case 14: t.xFrame = 4; t.yFrame = 1; break;
          */
        }
      }
      t.yFrame += (group/16)*4;
      t.xFrame += (group-int(group/16)*16)*4;
    }

    public function autoTileSet(x:int, y:int):void
    {
      autoTile(x, y);
      autoTile(x, y-1);
      autoTile(x+1, y);
      autoTile(x, y+1);
      autoTile(x-1, y);
    }


    public function paintGroup(x:int, y:int, group:int):void
    {
      var t:Tile = getTile(x, y);
      if(t.t != Tile.T_WALL)
        return;
      var tg:int = getTileGroup(t);
      if(tg == group)
        return;
      t.xFrame = group*4;
      autoTile(x, y);
    }

    public function paintRect(rect:Rectangle, group:int):void
    {
      for(var i:int=rect.left/tileWidth; i<rect.right/tileWidth; i++)
      {
        for(var j:int=rect.top/tileHeight; j<rect.bottom/tileHeight; j++)
        {
          paintGroup(i,j,group);
        }
      }
    }
  }

}