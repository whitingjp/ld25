package Src
{
  import mx.core.*;
  import mx.collections.*;
  import mx.containers.*;
  import flash.display.*;
  import flash.geom.*;
  import flash.events.*;
  import flash.text.*;
  import flash.utils.*;
  import flash.ui.Keyboard;
  import Src.FE.*;
  import Src.Entity.*;
  import Src.Gfx.*;
  import Src.Sound.*;
  import Src.Tiles.*;

  public class Game
  {    
    private var IS_FINAL:Boolean = false;

    public static var STATE_GAME:int = 0;
    public static var STATE_EDITING:int = 1;
    public static var STATE_FE:int = 2;
    
    public var stage:Stage;

    private var fps:Number=60;
    private var lastTime:int = 0;
    private var fpsText:TextField;

    private var updateTracker:Number = 0;
    private var physTime:Number;

    private var gameState:int = STATE_GAME;

    public var entityManager:EntityManager;
    public var input:Input;
    public var renderer:Renderer;
    public var soundManager:SoundManager;
    public var tileMap:TileMap;
    public var tileEditor:TileEditor;
    public var frontEnd:Frontend;

    /*
    [Embed(source="../level/test.lev", mimeType="application/octet-stream")]
    public static const TestLevelClass: Class;
    */

    public function Game()
    {
      entityManager = new EntityManager(this, 8);
      input = new Input(this);
      renderer = new Renderer();	  
      soundManager = new SoundManager();
      tileMap = new TileMap(this);      
      frontEnd = new Frontend(this);

      //tileMap.unpack(new TestLevelClass as ByteArray);
    }

    public function init(w:int, h:int, pixelSize:int, targetFps:int, stage:Stage):void
    {
      this.stage = stage;	  
    
      physTime = 1000.0/targetFps;
      renderer.init(w, h, pixelSize);
      soundManager.init();
      input.init();
      tileEditor = new TileEditor(tileMap);

      gameState = STATE_GAME;
      frontEnd.addScreen(new MainMenu());

      fpsText = new TextField();
      fpsText.textColor = 0xffffffff;
      fpsText.text = "352 fps";

      resetEntities();
    
      stage.addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    private function update():void
    {
      renderer.update();
      entityManager.update();
      if(State == STATE_FE)
        frontEnd.update();
      if(State == STATE_EDITING)
        tileEditor.update();
        
      if(input.keyPressedDictionary[Input.KEY_E])
      {
        if(State == STATE_GAME)
          State = STATE_EDITING;
        else
          State = STATE_GAME;
        resetEntities();
      }
        
      // Update input last, so mouse presses etc. will register first..
      // also note this mode of operation isn't perfect, sometimes input
      // will be lost!        
      input.update(); 
    }
    
    private function resetEntities():void
    {
      entityManager.reset();      
      if(State == STATE_GAME)
        tileMap.spawnEntities();
    }

    private function render():void
    {
      renderer.cls();
      
      //renderer.setCamera(camera);
      tileMap.render();
      entityManager.render();
      if(State == STATE_EDITING)
        tileEditor.renderWithCam();
      //renderer.setCamera();
      if(State == STATE_EDITING)
        tileEditor.renderWithoutCam(); 
      if(State == STATE_FE)
        frontEnd.render();

      /*
      if(!IS_FINAL)
        renderer.backBuffer.draw(fpsText);
      */
      
      renderer.flip();
    }

    public function enterFrame(event:Event):void
    {
      var thisTime:int = getTimer();
      updateTracker += thisTime-lastTime;
      lastTime = thisTime;
      
      fps = (fps*9 + 1000/(thisTime-lastTime))/10;
      /*
      if(fpsText)
        fpsText.text = "FPS: "+int(fps);*/

      while(updateTracker > 0)
      {
        update();
        updateTracker -= physTime;
      }

      if(renderer)
      {
        render();
      }
    }

    public function get State():int
    {
      return gameState;
    }

    public function set State(state:int):void
    {
      gameState = state;
    }
  }
}