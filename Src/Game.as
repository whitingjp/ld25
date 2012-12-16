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

    private var gameState:int;

    public var entityManager:EntityManager;
    public var input:Input;
    public var renderer:Renderer;
    public var soundManager:SoundManager;
    public var tileMap:TileMap;
    public var tileEditor:TileEditor;
    public var frontEnd:Frontend;

    public var score:int=0;

    public var main:Main;

    public var gameOverTimer:Number;

    [Embed(source="../level/level.lev", mimeType="application/octet-stream")]
    public static const Level1Class: Class;

    public function Game()
    {
      entityManager = new EntityManager(this, 8);
      input = new Input(this);
      renderer = new Renderer();	  
      soundManager = new SoundManager();
      tileMap = new TileMap(this);      
      frontEnd = new Frontend(this);

      tileMap.unpack(new Level1Class as ByteArray);
      gameOverTimer = 0;
    }

    public function init(targetFps:int, stage:Stage, main:Main):void
    {
      this.main = main;
      this.stage = stage;	  
      State = STATE_GAME;
    
      physTime = 1000.0/targetFps;
      soundManager.init();
      input.init();
      tileEditor = new TileEditor(tileMap);

      frontEnd.addScreen(new MainMenu());

      resetEntities();
    
      stage.addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    private function update():void
    {
      renderer.update();

      if(State == STATE_FE)
      {
        frontEnd.update();
        input.update(); 
        return;
      }

      entityManager.update();

      if(State == STATE_EDITING)
        tileEditor.update();
        
      if(input.keyPressedDictionary[Input.KEY_E])
      {
        if(State == STATE_GAME)
          State = STATE_EDITING;
        else
          State = STATE_GAME;        
      }

      if(gameOverTimer > 0)
      {
        gameOverTimer -= 0.007;
        trace(gameOverTimer);
        if(gameOverTimer <= 0)
        {
          frontEnd.swapScreen(new ScoreBoard());
          State = STATE_FE;
        }
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
      
      if(State == STATE_FE)
      {
        frontEnd.render();
        renderer.flip();
        return;
      }

      //renderer.setCamera(camera);
      tileMap.render();
      entityManager.render();

      if(State == STATE_EDITING)
        tileEditor.renderWithCam();
      //renderer.setCamera();
      if(State == STATE_EDITING)
        tileEditor.renderWithoutCam(); 


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

    public function gameOverMan():void
    {
      gameOverTimer = 1;
    }

    public function showerGibs(pos:Point):void
    {
      var gibs:int = Math.random()*3+3;
      var bunnies:Boolean = Math.random() > 0.98;
      for(var i:int=0; i<5; i++)
      {
        if(bunnies)
          entityManager.push(new Bunny(pos));
        else
          entityManager.push(new Gibs(pos));
      }
    }

    public function set State(state:int):void
    {
      gameState = state;
      resetEntities();
      if(gameState != STATE_FE )
      {
        renderer.init( 320, 240, 2, 4);
        score = 0;
      }
      else
      {
        renderer.init( 40, 30, 16, 1);
      }
      main.reAddBuffer();
    }
  }
}