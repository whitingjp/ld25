package Src.Gfx
{
  import mx.core.*;
  import mx.collections.*;
  import flash.display.*;
  import flash.geom.*
  import flash.text.*;

  public class Renderer
  {
    public var pixelSize:int;
    public var width:int;
    public var height:int;

    [Embed(source="../../graphics/spritesheet.png")]
    [Bindable]
    public var spriteSheetClass:Class;
    public var spriteSheetSrc:BitmapAsset;
    public var spriteSheet:BitmapData;

    // double buffer
    public var topBuffer:BitmapData;
    public var bottomBuffer:BitmapData;

    // colour to use to clear backbuffer with
    public var clearColor:uint = 0xfffcfdd9;
    public var bottomClearColor:uint = 0xffdffdce;
    
    // background
    public var bitmap:Bitmap;

    private var fadeSpeed:Number;
    private var fade:Number;
    private var fadeCol:uint;

    public function init(width:int, height:int, pixelSize:int):void
    {
      this.width = width;
      this.height = height;
      this.pixelSize = pixelSize;
    
      bitmap = new Bitmap(new BitmapData(width, height, false, 0xAAAAAA ) );
      bitmap.scaleX = bitmap.scaleY = pixelSize;
    
      spriteSheetSrc = new spriteSheetClass() as BitmapAsset;
      spriteSheet = spriteSheetSrc.bitmapData;

      topBuffer = new BitmapData(width, height/2, false);
      bottomBuffer = new BitmapData(width, height/2, false);

      fade = 0;
      fadeSpeed = 0.005;
      fadeCol = 0xff000000;
    }

    public function cls():void
    {
      drawRect(new Rectangle(0,0, width*2, height), clearColor);
    }

    public function flip():void
    {
      bitmap.bitmapData.fillRect( bitmap.bitmapData.rect, clearColor );
      bitmap.bitmapData.copyPixels(topBuffer, topBuffer.rect, new Point(0,0));
      swapColour(bottomBuffer, clearColor, bottomClearColor);
      bitmap.bitmapData.copyPixels(bottomBuffer, bottomBuffer.rect, new Point(0,height/2));
    
      // TODO handle fade again
    }

    public function drawSprite(spr:SpriteDef, x:int, y:int,
                                xFrame:int=0, yFrame:int=0):void
    {
      var rect:Rectangle = spr.getRect(xFrame, yFrame);
      topBuffer.copyPixels(spriteSheet, rect, new Point(x,y));
      bottomBuffer.copyPixels(spriteSheet, rect, new Point(x-width,y));
      if(x+rect.width > width*2)
        drawSprite(spr, x-width*2, y, xFrame, yFrame);
    }
    
    public function drawRect(rect:Rectangle, fillCol:uint):void
    {
      topBuffer.fillRect(rect, fillCol);
      rect.x -= width;
      bottomBuffer.fillRect(rect, fillCol);
    }

    public function drawHollowRect(rect:Rectangle, fillCol:uint):void
    {
      topBuffer.fillRect(new Rectangle(rect.x, rect.y, rect.width, 1), fillCol);
      topBuffer.fillRect(new Rectangle(rect.x+rect.width-1, rect.y, 1, rect.height), fillCol);
      topBuffer.fillRect(new Rectangle(rect.x, rect.y+rect.height-1, rect.width, 1), fillCol);
      topBuffer.fillRect(new Rectangle(rect.x, rect.y, 1, rect.height), fillCol);

      rect.x -= width;

      bottomBuffer.fillRect(new Rectangle(rect.x, rect.y, rect.width, 1), fillCol);
      bottomBuffer.fillRect(new Rectangle(rect.x+rect.width-1, rect.y, 1, rect.height), fillCol);
      bottomBuffer.fillRect(new Rectangle(rect.x, rect.y+rect.height-1, rect.width, 1), fillCol);
      bottomBuffer.fillRect(new Rectangle(rect.x, rect.y, 1, rect.height), fillCol);

    }

    public function drawSpriteText(str:String, x:int, y:int):void
    {
      // If I want to use this I'll have to draw a font!
      /*str = str.toUpperCase();
      var i:int;
      for(i=0; i<str.length; i++)
      {
        var sprite:String = "font_regular";
        var frame:int = -1;
        var charCode:Number = str.charCodeAt(i);

        if(charCode >= 65 && charCode <= 90) // A to Z
          frame = charCode-65;
        if(charCode >= 48 && charCode <= 57) // 0 to 9
          frame = charCode-48+26;
        if(charCode >= 33 && charCode <= 47) // ! to /
        {
          sprite = "font_special";
          frame = charCode-33;
        }
        if(charCode >= 58 && charCode <= 64) // : to @
        {
          sprite = "font_special";
          frame = charCode-58+15;
        }
        if(frame != -1)
          drawSprite(sprite, x, y, frame);
        x += 8;
      }*/
    }

    public function startFade(col:uint, speed:Number):void
    {
      if(speed > 0)
        fade = 1;
      else
        fade = -1;
      fadeSpeed = speed;
      fadeCol = col;
    }

    public function colourMap(src:Array, dest:Array):void
    {
      for(var i:int=0; i<src.length; i++)
      {
        swapColour(topBuffer, src[i], dest[i]);
        swapColour(bottomBuffer, src[i], dest[i]);
      }
    }

    public function swapColour(image:BitmapData, source:uint, dest:uint):void
    {
      image.threshold(image, image.rect, new Point(0,0), "==", source, dest);
    }

    public function update():void
    {
      if(fade > 0)
      {
        fade -= fadeSpeed;
        if(fade < 0)
          fade = 0;
      } else if(fade < 0)
      {
        fade -= fadeSpeed;
        if(fade > 0)
          fade = -0.001;
      }
    }
  }
}
