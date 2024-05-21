package funkin.ui;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSubState;
import flixel.text.FlxText;
import funkin.ui.mainmenu.MainMenuState;
import flixel.util.FlxColor;
import funkin.audio.FunkinSound;
import funkin.modding.events.ScriptEvent;
import funkin.modding.IScriptedClass.IEventHandler;
import funkin.modding.module.ModuleHandler;
import funkin.modding.PolymodHandler;
import funkin.util.SortUtil;
import flixel.util.FlxSort;
import funkin.input.Controls;
import funkin.util.TouchUtil;
#if mobile
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
import flixel.FlxCamera;
import funkin.mobile.FunkinHitbox;
import funkin.mobile.FunkinVirtualPad;
import funkin.mobile.PreciseInputHandler;
#end

/**
 * MusicBeatSubState reincorporates the functionality of MusicBeatState into an FlxSubState.
 */
class MusicBeatSubState extends FlxSubState implements IEventHandler
{
  public var leftWatermarkText:FlxText = null;
  public var rightWatermarkText:FlxText = null;

  public var conductorInUse(get, set):Conductor;

  public static var isTouch:Bool = FlxG.onMobile ? true : false;

  var _conductorInUse:Null<Conductor>;

  function get_conductorInUse():Conductor
  {
    if (_conductorInUse == null) return Conductor.instance;
    return _conductorInUse;
  }

  function set_conductorInUse(value:Conductor):Conductor
  {
    return _conductorInUse = value;
  }

  public function new(bgColor:FlxColor = FlxColor.TRANSPARENT)
  {
    super();
    this.bgColor = bgColor;
  }

  var controls(get, never):Controls;

  inline function get_controls():Controls
    return PlayerSettings.player1.controls;

  #if mobile
  public var hitbox:FunkinHitbox;
  public var virtualPad:FunkinVirtualPad;

  public var vpadCam:FlxCamera;
  public var hitboxCam:FlxCamera;

  var trackedInputsHitbox:Array<FlxActionInput> = [];
  var trackedInputsVirtualPad:Array<FlxActionInput> = [];

  public function addVirtualPad(direction:FunkinDirectionalMode, action:FunkinActionMode, ?visible:Bool = true):Void
  {
    if (virtualPad != null)
    {
      removeVirtualPad();
    }
    virtualPad = new FunkinVirtualPad(direction, action);
    ControlsHandler.setupVirtualPad(controls, virtualPad, direction, action, trackedInputsVirtualPad);
    virtualPad.visible = visible;
    add(virtualPad);
  }

  public function addVirtualPadCamera(defaultDrawTarget:Bool = false):Void
  {
    if (virtualPad == null || vpadCam != null) return;

    vpadCam = new FlxCamera();
    FlxG.cameras.add(vpadCam, defaultDrawTarget);
    vpadCam.bgColor.alpha = 0;
    virtualPad.cameras = [vpadCam];
  }

  public function removeVirtualPad():Void
  {
    if (trackedInputsVirtualPad != null && trackedInputsVirtualPad.length > 0)
    {
      ControlsHandler.removeCachedInput(controls, trackedInputsVirtualPad);
    }
    if (virtualPad != null)
    {
      remove(virtualPad);
    }

    if (vpadCam != null)
    {
      FlxG.cameras.remove(vpadCam, false);
      vpadCam = FlxDestroyUtil.destroy(vpadCam);
    }
  }

  public function addHitbox(?visible:Bool = true, ?initInput:Bool = true):Void
  {
    if (hitbox != null)
    {
      removeHitbox();
    }
    hitbox = new FunkinHitbox(4, Std.int(FlxG.width / 4), FlxG.height, [0xC34B9A, 0x00FFFF, 0x12FB06, 0xF9393F]);
    ControlsHandler.setupHitbox(controls, hitbox, trackedInputsHitbox);
    hitbox.visible = visible;
    add(hitbox);

    if (initInput) PreciseInputHandler.initializeHitbox(hitbox);
  }

  public function addHitboxCamera(DefaultDrawTarget:Bool = false):Void
  {
    if (hitbox == null || hitboxCam != null) return;
    hitboxCam = new FlxCamera();
    FlxG.cameras.add(hitboxCam, DefaultDrawTarget);
    hitboxCam.bgColor.alpha = 0;
    hitbox.cameras = [hitboxCam];
  }

  public function removeHitbox():Void
  {
    if (trackedInputsHitbox != null && trackedInputsHitbox.length > 0)
    {
      ControlsHandler.removeCachedInput(controls, trackedInputsHitbox);
    }
    if (hitbox != null)
    {
      remove(hitbox);
    }

    if (hitboxCam != null)
    {
      FlxG.cameras.remove(hitboxCam, false);
      hitboxCam = FlxDestroyUtil.destroy(hitboxCam);
    }
  }
  #end

  override function create():Void
  {
    super.create();
    createWatermarkText();
    Conductor.beatHit.add(this.beatHit);
    Conductor.stepHit.add(this.stepHit);
  }

  public override function destroy():Void
  {
    #if mobile
    if (trackedInputsHitbox != null && trackedInputsHitbox.length > 0)
    {
      ControlsHandler.removeCachedInput(controls, trackedInputsHitbox);
    }

    if (trackedInputsVirtualPad != null && trackedInputsVirtualPad.length > 0)
    {
      ControlsHandler.removeCachedInput(controls, trackedInputsVirtualPad);
    }
    #end

    super.destroy();

    #if mobile
    if (virtualPad != null)
    {
      virtualPad = FlxDestroyUtil.destroy(virtualPad);
    }

    if (hitbox != null)
    {
      hitbox = FlxDestroyUtil.destroy(hitbox);
    }
    #end

    Conductor.beatHit.remove(this.beatHit);
    Conductor.stepHit.remove(this.stepHit);
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    // Emergency exit button, just in case.
    if (FlxG.keys.justPressed.F4) FlxG.switchState(() -> new MainMenuState());

    // This can now be used in EVERY STATE, YAY! :D
    if (FlxG.keys.justPressed.F5) debug_refreshModules();

    // Display Conductor info in the watch window.
    FlxG.watch.addQuick("musicTime", FlxG.sound.music?.time ?? 0.0);
    Conductor.watchQuick(conductorInUse);

    if (FlxG.keys.justPressed.ANY && isTouch) isTouch = false;
    if (funkin.util.TouchUtil.justPressed && !isTouch) isTouch = true;

    dispatchEvent(new UpdateScriptEvent(elapsed));
  }

  function debug_refreshModules()
  {
    PolymodHandler.forceReloadAssets();

    // Restart the current state, so old data is cleared.
    FlxG.resetState();
  }

  /**
   * Refreshes the state, by redoing the render order of all sprites.
   * It does this based on the `zIndex` of each prop.
   */
  public function refresh()
  {
    sort(SortUtil.byZIndex, FlxSort.ASCENDING);
  }

  /**
   * Called when a step is hit in the current song.
   * Continues outside of PlayState, for things like animations in menus.
   * @return Whether the event should continue (not canceled).
   */
  public function stepHit():Bool
  {
    var event:ScriptEvent = new SongTimeScriptEvent(SONG_STEP_HIT, conductorInUse.currentBeat, conductorInUse.currentStep);

    dispatchEvent(event);

    if (event.eventCanceled) return false;

    return true;
  }

  /**
   * Called when a beat is hit in the current song.
   * Continues outside of PlayState, for things like animations in menus.
   * @return Whether the event should continue (not canceled).
   */
  public function beatHit():Bool
  {
    var event:ScriptEvent = new SongTimeScriptEvent(SONG_BEAT_HIT, conductorInUse.currentBeat, conductorInUse.currentStep);

    dispatchEvent(event);

    if (event.eventCanceled) return false;

    return true;
  }

  public function dispatchEvent(event:ScriptEvent)
  {
    ModuleHandler.callEvent(event);
  }

  function createWatermarkText():Void
  {
    // Both have an xPos of 0, but a width equal to the full screen.
    // The rightWatermarkText is right aligned, which puts the text in the correct spot.
    leftWatermarkText = new FlxText(0, FlxG.height - 18, FlxG.width, '', 12);
    rightWatermarkText = new FlxText(0, FlxG.height - 18, FlxG.width, '', 12);

    // 100,000 should be good enough.
    leftWatermarkText.zIndex = 100000;
    rightWatermarkText.zIndex = 100000;
    leftWatermarkText.scrollFactor.set(0, 0);
    rightWatermarkText.scrollFactor.set(0, 0);
    leftWatermarkText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    rightWatermarkText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

    add(leftWatermarkText);
    add(rightWatermarkText);
  }

  /**
   * Close this substate and replace it with a different one.
   */
  public function switchSubState(substate:FlxSubState):Void
  {
    this.close();
    this._parentState.openSubState(substate);
  }

  override function startOutro(onComplete:() -> Void):Void
  {
    var event = new StateChangeScriptEvent(STATE_CHANGE_BEGIN, null, true);

    dispatchEvent(event);

    if (event.eventCanceled)
    {
      return;
    }
    else
    {
      FunkinSound.stopAllAudio();

      onComplete();
    }
  }

  public override function openSubState(targetSubState:FlxSubState):Void
  {
    var event = new SubStateScriptEvent(SUBSTATE_OPEN_BEGIN, targetSubState, true);

    dispatchEvent(event);

    if (event.eventCanceled) return;

    super.openSubState(targetSubState);
  }

  function onOpenSubStateComplete(targetState:FlxSubState):Void
  {
    dispatchEvent(new SubStateScriptEvent(SUBSTATE_OPEN_END, targetState, true));
  }

  public override function closeSubState():Void
  {
    var event = new SubStateScriptEvent(SUBSTATE_CLOSE_BEGIN, this.subState, true);

    dispatchEvent(event);

    if (event.eventCanceled) return;

    super.closeSubState();
  }

  function onCloseSubStateComplete(targetState:FlxSubState):Void
  {
    dispatchEvent(new SubStateScriptEvent(SUBSTATE_CLOSE_END, targetState, true));
  }
}
