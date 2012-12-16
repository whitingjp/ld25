package Src.Sound
{
  import mx.core.*;
  import mx.collections.*;
  import flash.media.*;
  import flash.events.*;

  public class SoundManager
  {
    public static var SOUND_ENABLED:Boolean = true;
    public static var MUSIC_ENABLED:Boolean = false;

    [Embed(source="../../sound/test.mp3")]
    [Bindable]
    private var mp3Music:Class;
    private var musicSounds:Object;
    private var channel:SoundChannel;
    private var currentTrack:String;

    private var sounds:Object;

    public function SoundManager()
    {
      sounds = new Object()
      musicSounds = new Object();
    }
    
    private function addSynth(name:String, settings:String):void
    {
      var synth:SfxrSynth = new SfxrSynth();
      synth.setSettingsString(settings);
      synth.cacheMutations(5);
      sounds[name] = synth;
    }

    public function init():void
    {
      addSynth("makeBlock", "3,,0.0919,,0.1412,0.4383,,-0.5999,,,,,,,,,,,1,,,,,0.5");
      addSynth("removeBlock", "3,,0.1817,0.5092,0.25,0.0579,,0.0961,-0.36,,,-0.2151,0.7966,,,0.5187,,,1,,,,,0.5");
      addSynth("fireWand", "0,,0.09,,0.28,0.2823,,0.1,0.24,0.18,0.46,,,0.3748,,,,,1,,,0.1,,0.5");
      addSynth("convert", "0,,0.2538,,0.2092,0.3161,,0.3556,,,,,,0.5629,,0.5773,,,1,,,,,0.5");
      addSynth("slash", "3,0.13,0.2008,0.38,0.26,0.36,,-0.36,-0.16,,,0.4928,0.8177,,,,-0.0289,-0.2355,1,,,,,0.5");
      addSynth("eat", "3,0.17,0.37,0.46,0.32,0.1023,,0.06,-0.0799,,,,,,,,,,1,,,,,0.5");
      addSynth("deNewt", "0,,0.0945,0.517,0.112,0.5453,,,,,,,,,,,,,1,,,,,0.5");
      addSynth("witchJump", "0,,0.1139,,0.1113,0.467,,0.2301,,,,,,0.0583,,,,,0.9832,,,0.0878,,0.5");
      addSynth("bunnyJump","0,,0.0885,,0.0914,0.79,,0.2301,,,,,,0.0583,,,,,0.9832,,,0.0878,,0.1");
      addSynth("heroJump","0,,0.09,,0.28,0.19,,0.1599,,,,,,0.0583,,,,,0.9832,,,0.0878,,0.5");
      addSynth("newtJump","0,,0.0885,,0.0914,0.91,,-0.3199,,,,,,0.0583,,,,,0.9832,,,0.0878,,0.5");
      addSynth("demonBunnyJump","0,,0.0885,,0.0914,0.17,,0.2301,,,,,,0.0583,,,,,0.9832,,,0.0878,,0.5");
      addSynth("breakingHouse","3,,0.1206,0.3694,0.3845,0.0812,,,,,,0.7511,0.7979,,,,,,1,,,,,0.5");
      //addSynth("","");
      

      // Do music
      musicSounds['test'] = new mp3Music() as SoundAsset;
      playMusic('test');
    }

    public function playSound(sound:String):void
    {
      if(!SOUND_ENABLED)
        return;
        
      if(!sounds.hasOwnProperty(sound))
      {
        trace("Sound '"+sound+"' not found!");
        return;
      }      

      sounds[sound].playCachedMutation();
    }

    public function playMusic(track:String):void
    {
      currentTrack = track;
      if(!MUSIC_ENABLED)
        return;
        
      if(!musicSounds.hasOwnProperty(track))
      {
        trace("Music '"+track+"' not found!");
        return;      
      }

      stopMusic();
      channel = musicSounds[currentTrack].play();
      setVol(0.1);
      channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
    }

    public function stopMusic():void
    {
      if(channel)
        channel.stop();
    }

    public function setVol(vol:Number):void
    {
      if(channel)
      {
        var transform:SoundTransform = channel.soundTransform;
        transform.volume = vol;
        channel.soundTransform = transform;
      }
    }

    private function soundCompleteHandler(event:Event):void
    {
      playMusic(currentTrack);
    }
  }
}