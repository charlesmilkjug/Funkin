package funkin;

import funkin.save.Save;

/**
 * A core class which provides a store of user-configurable, globally relevant values.
 */
class Preferences
{
  /**
   * Whether some particularly fowl language is displayed.
   * @default `true`
   */
  public static var naughtyness(get, set):Bool;

  static function get_naughtyness():Bool
  {
    return Save?.instance?.options?.naughtyness;
  }

  static function set_naughtyness(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.naughtyness = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the strumline is at the bottom of the screen rather than the top.
   * @default `false`
   */
  public static var downscroll(get, set):Bool;

  static function get_downscroll():Bool
  {
    return Save?.instance?.options?.downscroll;
  }

  static function set_downscroll(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.downscroll = value;
    save.flush();
    return value;
  }

  /**
   * If true, the player will not receive the ghost miss penalty if there are no notes within the hit window.
   * This is the thing people have been begging for forever lolol.
   * @default `false`
   */
  public static var ghostTapping(get, set):Bool;

  static function get_ghostTapping():Bool
  {
    return Save?.instance?.options?.ghostTapping ?? false;
  }

  static function set_ghostTapping(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.ghostTapping = value;
    save.flush();
    return value;
  }

  /**
   * Framerate.
   * @default `60` on web targets, on native may vary.
   */
  public static var framerate(get, set):Int;

  static function get_framerate():Int
  {
    return Save?.instance?.options?.framerate ?? FlxG.updateFramerate;
  }

  static function set_framerate(value:Int):Int
  {
    #if web
    FlxG.log.warn("You can't set framerate on web targets!");
    return FlxG.updateFramerate;
    #else
    FlxG.updateFramerate = value;
    FlxG.drawFramerate = value;

    var save:Save = Save.instance;
    save.options.framerate = value;
    save.flush();
    return value;
    #end
  }

  /**
   * If disabled, flashing lights in the main menu and other areas will be less intense.
   * @default `true`
   */
  public static var flashingLights(get, set):Bool;

  static function get_flashingLights():Bool
  {
    return Save?.instance?.options?.flashingLights ?? true;
  }

  static function set_flashingLights(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.flashingLights = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the camera bump synchronizes to the beat.
   * @default `false`
   */
  public static var zoomCamera(get, set):Bool;

  static function get_zoomCamera():Bool
  {
    return Save?.instance?.options?.zoomCamera;
  }

  static function set_zoomCamera(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.zoomCamera = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the strumline gets centered.
   * Otherwise, move the strumline a bit to the 2nd half of the screen, in case of that focusing thing.
   * @default `false`
   */
  public static var centerStrums(get, set):Bool;

  static function get_centerStrums():Bool
  {
    return Save?.instance?.options?.centerStrums ?? false;
  }

  static function set_centerStrums(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.centerStrums = value;
    save.flush();
    return value;
  }

  /**
   * Adds song position bar.
   * @default `false`
   */
  public static var songPositionBar(get, set):Bool;

  static function get_songPositionBar():Bool
  {
    return Save?.instance?.options?.songPositionBar ?? false;
  }

  static function set_songPositionBar(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.songPositionBar = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, an FPS and memory counter will be displayed even if this is not a debug build.
   * @default `true`
   */
  public static var debugDisplay(get, set):Bool;

  static function get_debugDisplay():Bool
  {
    return Save?.instance?.options?.debugDisplay ?? true;
  }

  static function set_debugDisplay(value:Bool):Bool
  {
    var save = Save.instance;
    if (value != save.options.debugDisplay)
    {
      toggleDebugDisplay(value);
    }

    save.options.debugDisplay = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the game will automatically pause when tabbing out.
   * @default `true`
   */
  public static var autoPause(get, set):Bool;

  static function get_autoPause():Bool
  {
    return Save?.instance?.options?.autoPause ?? true;
  }

  static function set_autoPause(value:Bool):Bool
  {
    var save:Save = Save.instance;
    if (value != save.options.autoPause) FlxG.autoPause = value;

    save.options.autoPause = value;
    save.flush();
    return value;
  }

  /**
   * Changes default health bar colors to characters dominant color from health icon.
   * @default `false`
   */
  public static var coloredHealthBar(get, set):Bool;

  static function get_coloredHealthBar():Bool
  {
    return Save?.instance?.options?.coloredHealthBar ?? false;
  }

  static function set_coloredHealthBar(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.coloredHealthBar = value;
    save.flush();
    return value;
  }

  /**
   * Loads the user's preferences from the save data and apply them.
   */
  public static function init():Void
  {
    // Apply the autoPause setting (enables automatic pausing on focus lost).
    FlxG.autoPause = Preferences.autoPause;
    // Apply the debugDisplay setting (enables the FPS and RAM display).
    toggleDebugDisplay(Preferences.debugDisplay);
  }

  static function toggleDebugDisplay(show:Bool):Void
  {
    if (show) #if mobile
      FlxG.game.addChild(Main.statisticMonitor);
    #else
      FlxG.stage.addChild(Main.statisticMonitor);
    #end
    else
      #if mobile
      FlxG.game.addChild(Main.statisticMonitor);
      #else
      FlxG.stageremoveChild(Main.statisticMonitor);
      #end
  }

  /**
   * How dark the black screen behind gameplay should be.
   *
   * 0 = fully transparent. 1 = opaque.
   * @default `0`
   */
  public static var gameplayBackgroundAlpha(get, set):Float;

  static function get_gameplayBackgroundAlpha():Float
  {
    return Save?.instance?.options?.gameplayBackgroundAlpha ?? 0;
  }

  static function set_gameplayBackgroundAlpha(value:Float):Float
  {
    var save:Save = Save.instance;
    save.options.gameplayBackgroundAlpha = value;
    save.flush();
    return value;
  }
}
