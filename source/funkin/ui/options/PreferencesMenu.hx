package funkin.ui.options;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.ui.AtlasText.AtlasFont;
import funkin.ui.options.OptionsState.Page;
import funkin.graphics.FunkinCamera;
import funkin.ui.TextMenuList.TextMenuItem;
import funkin.util.Constants;
import funkin.input.Controls;
import funkin.util.MathUtil;

class PreferencesMenu extends Page
{
  var textItems:TextMenuList;
  var preferenceItems:FlxTypedSpriteGroup<FlxSprite>;

  var menuCamera:FlxCamera;
  var camFollow:FlxObject;

  public function new()
  {
    super();

    menuCamera = new FunkinCamera('prefMenu');
    FlxG.cameras.add(menuCamera, false);
    menuCamera.bgColor = 0x0;
    camera = menuCamera;

    add(textItems = new TextMenuList());
    add(preferenceItems = new FlxTypedSpriteGroup<FlxSprite>());

    createPrefItems();

    camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
    if (textItems != null) camFollow.y = textItems.selectedItem.y;

    menuCamera.follow(camFollow, null, Constants.DEFAULT_CAMERA_FOLLOW_RATE_MENU);
    var margin = 160;
    menuCamera.deadzone.set(0, margin, menuCamera.width, 40);
    menuCamera.minScrollY = 0;

    textItems.onChange.add(function(selected) {
      camFollow.y = selected.y;
    });
  }

  /**
   * Create the menu items for each of the preferences.
   */
  function createPrefItems():Void
  {
    createPrefItemCheckbox('Naughtyness', 'Toggle displaying raunchy content', function(value:Bool):Void {
      Preferences.naughtyness = value;
    }, Preferences.naughtyness);
    createPrefItemCheckbox('Downscroll', 'Enable to make notes move downwards', function(value:Bool):Void {
      Preferences.downscroll = value;
    }, Preferences.downscroll);
    createPrefItemCheckbox('Ghost Tapping', 'Enable to let you spam notes', function(value:Bool):Void {
      Preferences.ghostTapping = value;
    }, Preferences.ghostTapping);
    #if !web
    createPrefItemCounter('Framerate', 'It\'s self explanatory', function(value:Int):Void {
      Preferences.framerate = value;
    }, Preferences.framerate, Constants.MIN_FRAMERATE, Constants.MAX_FRAMERATE);
    #end
    createPrefItemCheckbox('Flashing Lights', 'Disable to dampen flashing effects', function(value:Bool):Void {
      Preferences.flashingLights = value;
    }, Preferences.flashingLights);
    createPrefItemCheckbox('Camera Zooming on Beat', 'Disable to stop the camera bouncing to the song', function(value:Bool):Void {
      Preferences.zoomCamera = value;
    }, Preferences.zoomCamera);
    createPrefItemCheckbox('Debug Display', 'Enable to show FPS and other debug stats', function(value:Bool):Void {
      Preferences.debugDisplay = value;
    }, Preferences.debugDisplay);
    createPrefItemCheckbox('Auto Pause', 'Automatically pause the game when it loses focus', function(value:Bool):Void {
      Preferences.autoPause = value;
    }, Preferences.autoPause);
    createPrefItemSlider('Background dim', 'How dark is the dim behind gameplay', function(value:Float):Void {
      Preferences.gameplayBackgroundAlpha = value;
    }, Preferences.gameplayBackgroundAlpha, 0, 1, 0.1);
  }

  function createPrefItemCheckbox(prefName:String, prefDesc:String, onChange:Bool->Void, defaultValue:Bool):Void
  {
    var checkbox:CheckboxPreferenceItem = new CheckboxPreferenceItem(0, 120 * (textItems.length), defaultValue);

    textItems.createItem(120, (120 * textItems.length) + 30, prefName, AtlasFont.BOLD, function() {
      var value = !checkbox.currentValue;
      onChange(value);
      checkbox.currentValue = value;
    }, true);

    preferenceItems.add(checkbox);
  }

  function createPrefItemCounter(prefName:String, prefDesc:String, onChange:Int->Void, defaultValue:Int, minValue:Int, maxValue:Int, step:Int = 1):Void
  {
    final posY = 120 * items.length;
    final counter = new CounterPreferenceItem(20, posY + 55, defaultValue, minValue, maxValue, onChange);
    counter.ID = items.length;
    items.createItem(120, posY + 30, prefName, AtlasFont.BOLD);
    preferenceItems.add(counter);
  }

  function createPrefItemSlider(prefName:String, prefDesc:String, onChange:Float->Void, defaultValue:Float, minValue:Float, maxValue:Float,
      increment:Float):Void
  {
    var sliderItem:SliderMenuItem = new SliderMenuItem(20, (120 * preferenceItems.length) + 30, defaultValue, minValue, maxValue, increment, onChange);
    textItems.createItem(160, (120 * textItems.length) + 30, prefName, AtlasFont.BOLD, sliderItem.callbackPlaceholder, true);
    preferenceItems.add(sliderItem);
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    // Indent the selected item.
    // TODO: Only do this on menu change?
    textItems.forEach(function(daItem:TextMenuItem) {
      if (textItems.selectedItem == daItem) daItem.x = 150;
      else
        daItem.x = 120;
    });
  }
}

/**
 * An interactable checkbox sprite, representing a `Bool` preference.
 *
 */
class CheckboxPreferenceItem extends FlxSprite
{
  public var currentValue(default, set):Bool;

  public function new(x:Float, y:Float, defaultValue:Bool = false)
  {
    super(x, y);

    frames = Paths.getSparrowAtlas('checkboxThingie');
    animation.addByPrefix('static', 'Check Box unselected', 24, false);
    animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

    setGraphicSize(width * 0.7);
    updateHitbox();

    this.currentValue = defaultValue;
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    switch (animation.curAnim.name)
    {
      case 'static':
        offset.set();
      case 'checked':
        offset.set(17, 70);
    }
  }

  function set_currentValue(value:Bool):Bool
  {
    if (value)
    {
      animation.play('checked', true);
    }
    else
    {
      animation.play('static');
    }

    return currentValue = value;
  }
}

class CounterPreferenceItem extends FlxText
{
  inline static final MAX_HOLD_TIME = 0.6;
  inline static final HOLD_SPEED = 50.0;

  public var currentValue(default, set):Int;
  public var onChange:Int->Void;

  var minValue:Int;
  var maxValue:Int;
  var step:Int;

  var holdTimer:Float = 0.0;
  var holdValue:Float = 0.0;

  public function new(x:Float, y:Float, defaultValue:Int = 0, minValue:Int = 0, maxValue:Int = 1, onChange:Int->Void, step:Int = 1)
  {
    super(x, y, 0, null, 42);
    this.font = "VCR OSD Mono";
    this.alignment = RIGHT;
    this.setBorderStyle(OUTLINE, flixel.util.FlxColor.BLACK, 1.5);

    this.step = step;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.onChange = onChange;
    this.currentValue = defaultValue;
  }

  // TODO: better code lmao
  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    final controls = PlayerSettings.player1.controls;
    final UI_LEFT = controls.UI_LEFT;
    final UI_RIGHT = controls.UI_RIGHT;
    final UI_LEFT_P = controls.UI_LEFT_P;
    final UI_RIGHT_P = controls.UI_RIGHT_P;

    if (UI_LEFT || UI_RIGHT)
    {
      if (UI_LEFT_P || UI_RIGHT_P)
      {
        currentValue += UI_LEFT_P ? -step : step;
        holdValue = currentValue;
      }

      holdTimer += elapsed;
      if (holdTimer >= MAX_HOLD_TIME)
      {
        holdValue = FlxMath.bound(holdValue + step * HOLD_SPEED * (UI_LEFT ? -elapsed : elapsed), minValue, maxValue);
        currentValue = Math.floor(holdValue);
      }
    }
    else
    {
      holdTimer = 0.0;
    }
  }

  function set_currentValue(value:Int):Int
  {
    value = MathUtil.boundInt(value, minValue, maxValue);
    if (currentValue != value)
    {
      this.text = '$value';
      currentValue = value;
      if (onChange != null) onChange(value);
    }
    return value;
  }
}

/**
 * A wrapper for a `TextMenuItem` which can be interacted with to increase the inner `Float` value.
 */
class SliderMenuItem extends TextMenuItem
{
  var curValue:Float;
  var minValue:Float;
  var maxValue:Float;
  var increment:Float;
  var onChange:Float->Void;

  // holy args

  /**
   * Creates a new number menu item.
   * @param x X pos
   * @param y Y pos
   * @param defaultValue Item default text
   * @param minValue Item minimum number
   * @param maxValue Item maximum number
   * @param increment Item increment per key press
   * @param onChange Callback fired when item value changed
   */
  public function new(x:Float = 0.0, y:Float = 0.0, defaultValue:Float = 0.0, minValue:Float = 0.0, maxValue:Float = 1.0, increment:Float = 0.1,
      onChange:Float->Void)
  {
    super(x, y, Std.string(defaultValue), AtlasFont.DEFAULT, callbackPlaceholder);

    this.fireInstantly = true;
    this.select();
    this.curValue = defaultValue;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.increment = increment;
    this.onChange = onChange;
  }

  /**
   * Called whenever this item is interacted with (ENTER key).
   */
  public function callbackPlaceholder():Void
  {
    trace("floatSlider text interacted with");
    if (curValue + increment > maxValue)
    {
      curValue = Math.round(minValue * 100) / 100;
    }
    else
    {
      curValue = Math.round((curValue + increment) * 100) / 100;
    }
    trace(Std.string(curValue));
    super.setItem(Std.string(curValue), callbackPlaceholder);
    onChange(curValue);
  }
}
