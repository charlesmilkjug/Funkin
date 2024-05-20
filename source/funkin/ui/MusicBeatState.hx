package funkin.ui;

import funkin.modding.IScriptedClass.IEventHandler;
import funkin.ui.mainmenu.MainMenuState;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.audio.FunkinSound;
import flixel.util.FlxSort;
import funkin.modding.PolymodHandler;
import funkin.modding.events.ScriptEvent;
import funkin.modding.module.ModuleHandler;
import funkin.util.SortUtil;
import funkin.input.Controls;
#if mobile
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
import flixel.FlxCamera;
import funkin.mobile.ControlsHandler;
import funkin.mobile.FunkinHitbox;
import funkin.mobile.FunkinVirtualPad;
import funkin.util.TouchUtil;
#end

/**
 * MusicBeatState actually represents the core utility FlxState of the game.
 * It includes functionality for event handling, as well as maintaining BPM-based update events.
 */
class MusicBeatState extends FlxTransitionableState implements IEventHandler
{
  var controls(get, never):Controls;

  inline function get_controls():Controls
    return PlayerSettings.player1.controls;

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

  public function new()
  {
    super();

    initCallbacks();
  }

  function initCallbacks()
  {
    subStateOpened.add(onOpenSubStateComplete);
    subStateClosed.add(onCloseSubStateComplete);
  }

  #if mobile
  var hitbox:FunkinHitbox;
  var virtualPad:FunkinVirtualPad;

  var trackedInputsHitbox:Array<FlxActionInput> = [];
  var trackedInputsVirtualPad:Array<FlxActionInput> = [];

  public function addVirtualPad(dPad:FunkinDPadMode, action:FunkinActionMode, ?visible:Bool = true):Void
  {
    if (virtualPad != null)
    {
      removeVirtualPad();
    }

    virtualPad = new FunkinVirtualPad(dPad, action);

    ControlsHandler.setupVirtualPad(controls, virtualPad, dPad, action, trackedInputsVirtualPad);

    virtualPad.visible = visible;
    add(virtualPad);
  }

  public function addVirtualPadCamera(defaultDrawTarget:Bool = true):Void
  {
    if (virtualPad != null)
    {
      var camControls:FlxCamera = new FlxCamera();
      FlxG.cameras.add(camControls, defaultDrawTarget);
      camControls.bgColor.alpha = 0;
      virtualPad.cameras = [camControls];
    }
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
  }

  public function addHitbox(?visible:Bool = true):Void
  {
    if (hitbox != null)
    {
      removeHitbox();
    }

    hitbox = new FunkinHitbox(4, Std.int(FlxG.width / 4), FlxG.height, [0xC34B9A, 0x00FFFF, 0x12FB06, 0xF9393F]);

    ControlsHandler.setupHitbox(controls, hitbox, trackedInputsHitbox);

    hitbox.visible = visible;
    add(hitbox);
  }

  public function addHitboxCamera(DefaultDrawTarget:Bool = true):Void
  {
    if (hitbox != null)
    {
      var camControls:FlxCamera = new FlxCamera();
      FlxG.cameras.add(camControls, DefaultDrawTarget);
      camControls.bgColor.alpha = 0;
      hitbox.cameras = [camControls];
    }
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
  }
  #end

  override function create()
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

  function handleFunctionControls():Void
  {
    // Emergency exit button.
    if (FlxG.keys.justPressed.F4) FlxG.switchState(() -> new MainMenuState());

    // This can now be used in EVERY STATE YAY!
    if (FlxG.keys.justPressed.F5) debug_refreshModules();
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    dispatchEvent(new UpdateScriptEvent(elapsed));

    if (FlxG.keys.justPressed.ANY && isTouch) isTouch = false;
    if (TouchUtil.justPressed && !isTouch) isTouch = true;
  }

  function createWatermarkText()
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

  public function dispatchEvent(event:ScriptEvent)
  {
    ModuleHandler.callEvent(event);
  }

  function debug_refreshModules()
  {
    PolymodHandler.forceReloadAssets();

    this.destroy();

    // Create a new instance of the current state, so old data is cleared.
    FlxG.resetState();
  }

  public function stepHit():Bool
  {
    var event = new SongTimeScriptEvent(SONG_STEP_HIT, conductorInUse.currentBeat, conductorInUse.currentStep);

    dispatchEvent(event);

    if (event.eventCanceled) return false;

    return true;
  }

  public function beatHit():Bool
  {
    var event = new SongTimeScriptEvent(SONG_BEAT_HIT, conductorInUse.currentBeat, conductorInUse.currentStep);

    dispatchEvent(event);

    if (event.eventCanceled) return false;

    return true;
  }

  /**
   * Refreshes the state, by redoing the render order of all sprites.
   * It does this based on the `zIndex` of each prop.
   */
  public function refresh()
  {
    sort(SortUtil.byZIndex, FlxSort.ASCENDING);
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
