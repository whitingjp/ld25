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

  public class TileEditor
  {
    private var tileMap:TileMap;
    private var pallete:TileMap;
    private var index:int;
    private var selected:Tile;
    private var inPallete:Boolean = false;
    private var game:Game;
    private var fileReference:FileReference;
    
    public function TileEditor(tileMap:TileMap)
    {
      this.tileMap = tileMap;
      
      game = tileMap.game;
      selected = new Tile();            
      pallete = new TileMap(game); 
      pallete.reset(20, 20); // These 20's are just guesses
      var x:int=0;
      for(var i:int=0; i<Tile.T_MAX; i++)
        x = fillOutPallete(i, x, 0);      
    }
  
    private function fillOutPallete(t:int, x:int, y:int):int
    {
      var sprite:SpriteDef = pallete.sprites[t];
      for(var i:int=0; i<sprite.xFrames; i++)
      {
        for(var j:int=0; j<sprite.yFrames; j++)
        {
          var tile:Tile = new Tile();
          tile.t = t;
          tile.xFrame = i;
          tile.yFrame = j;
          pallete.setTile(x+i, y+j, tile);
        }
      }
      return x+sprite.xFrames;
    }

    public function getOffsetMouse():Point
    {
      var mousePos:Point = game.input.mousePos.clone();
      if(mousePos.y > game.renderer.height/2)
      {
        mousePos.y -= game.renderer.height/2;
        mousePos.x += game.renderer.width;
      }
      return mousePos;
    }
    
    public function update():void
    {
      inPallete = game.input.keyDownDictionary[Input.KEY_SPACE];

      var mousePos:Point = getOffsetMouse();
      index = tileMap.getIndexFromPos(mousePos);
      if(game.input.mouseHeld && !inPallete)
      {        
        tileMap.setTileByIndex(index, selected);
      }
      if(game.input.keyDownDictionary[Input.KEY_CONTROL])
      {
        if(inPallete) selected = pallete.getTileAtPos(mousePos);
        else selected = tileMap.getTileAtPos(mousePos);
      }
      if(!inPallete)
      {
        var p:Point = tileMap.getXY(index);
        tileMap.autoTile(p.x, p.y);
        tileMap.autoTile(p.x, p.y-1);
        tileMap.autoTile(p.x+1, p.y);
        tileMap.autoTile(p.x, p.y+1);
        tileMap.autoTile(p.x-1, p.y);        
      }
      
      if(game.input.keyPressedDictionary[Input.KEY_C])
        saveToFile("level.lev");
      if(game.input.keyPressedDictionary[Input.KEY_L])
        loadFromFile();      
    }
    
    public function renderWithCam():void
    {
      var xy:Point = tileMap.getXY(index);
      var rect:Rectangle = new Rectangle(
        xy.x*TileMap.tileWidth, xy.y*TileMap.tileHeight,
        TileMap.tileWidth, TileMap.tileHeight);
      game.renderer.drawHollowRect(rect, 0xfff847);
    }
    
    public function renderWithoutCam():void
    {
      if(inPallete)
      {
        game.renderer.cls();
        pallete.render();
      }

      var spr:SpriteDef = tileMap.sprites[selected.t];
      game.renderer.drawSprite(spr, 0, game.renderer.height-TileMap.tileHeight,
                               selected.xFrame, selected.yFrame);
      var rect:Rectangle = new Rectangle(
        0, game.renderer.height-TileMap.tileHeight,
        TileMap.tileWidth, TileMap.tileHeight);
      game.renderer.drawHollowRect(rect, 0xf09bf7);
    }
    
    public function saveToFile(fileName:String):void    
    {
      var byteArray:ByteArray = new ByteArray();
      tileMap.pack(byteArray);
        
      fileReference = new FileReference()
      fileReference.save(byteArray, fileName);
    }
    
    public function loadFromFile():void
    {    
      fileReference = new FileReference();
      fileReference.addEventListener(Event.SELECT,onFileSelect);
      fileReference.addEventListener(Event.COMPLETE,onFileComplete);
      fileReference.browse();
    } 
    
    private function onFileSelect(event:Event):void
    {
      fileReference.load();
    }  
    
    private function onFileComplete(event:Event):void
    {
      var byteArray:ByteArray = fileReference.data;

      tileMap.unpack(byteArray);
    }    
  }
}