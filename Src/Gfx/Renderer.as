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
    public var buffers:Array;
    public var numBuffers:int = 4;

    // colour to use to clear backbuffer with
    public var clearColor:uint = 0xfffcfdd9;
    public var clearColors:Array;
    
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

      buffers = new Array();
      for(var i:int = 0; i<numBuffers; i++)
        buffers.push(new BitmapData(width, height/numBuffers, false));

      clearColors = new Array();
      clearColors.push(0xfffcfdd9);
      clearColors.push(0xffdffdce);
      clearColors.push(0xfffcfdd9);
      clearColors.push(0xffdffdce);

      fade = 0;
      fadeSpeed = 0.005;
      fadeCol = 0xff000000;
    }

    public function cls():void
    {
      drawRect(new Rectangle(0,0, width*numBuffers, height), 0xff000000);
    }

    public function flip():void
    {
      bitmap.bitmapData.fillRect( bitmap.bitmapData.rect, 0xff000000 );
      for(var i:int = 0; i<numBuffers; i++)
      {
        var h:int = (height/numBuffers)*i;
        swapColour(buffers[i], 0xff000000, clearColors[i]);
        bitmap.bitmapData.copyPixels(buffers[i], buffers[i].rect, new Point(0,h));
        //swapColour(buffers[i], clearColor, clearColors[i]);        
      }
    
      // TODO handle fade again
    }

    public function drawSprite(spr:SpriteDef, x:int, y:int,
                                xFrame:int=0, yFrame:int=0):void
    {
      var rect:Rectangle = spr.getRect(xFrame, yFrame);

      for(var i:int = 0; i<numBuffers; i++)
        buffers[i].copyPixels(spriteSheet, rect, new Point(x-width*i,y));
      if(x+rect.width > width*numBuffers)
        drawSprite(spr, x-width*numBuffers, y, xFrame, yFrame);
    }
    
    public function drawRect(rect:Rectangle, fillCol:uint):void
    {
      for(var i:int = 0; i<numBuffers; i++)
      {
        buffers[i].fillRect(rect, fillCol);
        rect.x -= width;
      }
    }

    public function drawHollowRect(rect:Rectangle, fillCol:uint):void
    {
      for(var i:int = 0; i<numBuffers; i++)
      {
        buffers[i].fillRect(new Rectangle(rect.x, rect.y, rect.width, 1), fillCol);
        buffers[i].fillRect(new Rectangle(rect.x+rect.width-1, rect.y, 1, rect.height), fillCol);
        buffers[i].fillRect(new Rectangle(rect.x, rect.y+rect.height-1, rect.width, 1), fillCol);
        buffers[i].fillRect(new Rectangle(rect.x, rect.y, 1, rect.height), fillCol);
        rect.x -= width;
      }
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
        for(var j:int=0; j<numBuffers; j++)
        {
          swapColour(buffers[i], src[i], dest[i]);
        }
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
