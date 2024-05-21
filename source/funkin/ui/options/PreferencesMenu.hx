package funkin.ui.options;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
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
  inline static final DESC_BG_OFFSET_X = 15.0;
  inline static final DESC_BG_OFFSET_Y = 15.0;
  static var DESC_TEXT_WIDTH:Null<Float>;

  var items:TextMenuList;
  var preferenceItems:FlxTypedSpriteGroup<FlxSprite>;
  var preferenceDesc:Array<String> = [];

  var menuCamera:FlxCamera;
  var camFollow:FlxObject;

  var descText:FlxText;
  var descTextBG:FlxSprite;

  public function new()
  {
    super();

    if (DESC_TEXT_WIDTH == null) DESC_TEXT_WIDTH = FlxG.width * 0.8;

    menuCamera = new FunkinCamera('prefMenu');
    FlxG.cameras.add(menuCamera, false);
    menuCamera.bgColor = 0x0;
    camera = menuCamera;

    add(textItems = new TextMenuList());
    add(preferenceItems = new FlxTypedSpriteGroup<FlxSprite>());

    descTextBG = new FlxSprite().makeGraphic(1, 1, 0x80000000);
    descTextBG.scrollFactor.set();
    descTextBG.antialiasing = false;
    descTextBG.active = false;

    descText = new FlxText(0, 0, 0, "No description", 26);
    descText.scrollFactor.set();
    descText.font = Paths.font("vcr.ttf");
    descText.alignment = CENTER;
    descText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
    // descText.antialiasing = false;

    descTextBG.x = descText.x - DESC_BG_OFFSET_X;
    descTextBG.scale.x = descText.width + DESC_BG_OFFSET_X * 2;
    descTextBG.updateHitbox();

    add(descTextBG);
    add(descText);

    createPrefItems();

    camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
    camFollow.y = items.selectedItem.y;
    add(camFollow);

    menuCamera.follow(camFollow, null, Constants.DEFAULT_CAMERA_FOLLOW_RATE_MENU);
    menuCamera.deadzone.set(0, 280, menuCamera.width, 40);
    menuCamera.minScrollY = -30;

    var prevIndex = 0;
    var prevItem = items.selectedItem;
    items.onChange.add(function(selected) {
      camFollow.y = selected.y;

      prevItem.x = 120;
      selected.x = 150;

      var counterItem = preferenceItems.members[prevIndex];
      if (Std.isOfType(counterItem, CounterPreferenceItem)) counterItem.active = false;
      counterItem = preferenceItems.members[items.selectedIndex];
      if (Std.isOfType(counterItem, CounterPreferenceItem)) counterItem.active = true;

      final newDesc = preferenceDesc[items.selectedIndex];
      final showDesc = (newDesc != null && newDesc.length != 0);
      descText.visible = descTextBG.visible = showDesc;
      if (showDesc)
      {
        descText.text = newDesc;
        descText.fieldWidth = descText.width > DESC_TEXT_WIDTH ? DESC_TEXT_WIDTH : 0;
        descText.screenCenter(X).y = FlxG.height * 0.85 - descText.height * 0.5;

        descTextBG.x = descText.x - DESC_BG_OFFSET_X;
        descTextBG.y = descText.y - DESC_BG_OFFSET_Y;
        descTextBG.scale.set(descText.width + DESC_BG_OFFSET_X * 2, descText.height + DESC_BG_OFFSET_Y * 2);
        descTextBG.updateHitbox();
      }

      prevIndex = items.selectedIndex;
      prevItem = selected;
    });
    items.selectItem(items.selectedIndex);
  }

  /**
   * Create the menu items for each of the preferences.
   */
  function createPrefItems():Void
  {
    createPrefItemCheckbox('Naughtyness', 'Toggle displaying raunchy content especially in Week 7', function(value:Bool):Void {
      Preferences.naughtyness = value;
    }, Preferences.naughtyness);
    createPrefItemCheckbox('Downscroll', 'Enable to make notes move downwards', function(value:Bool):Void {
      Preferences.downscroll = value;
    }, Preferences.downscroll);
    createPrefItemCheckbox('Show Judgements', 'Self explanatory', function(value:Bool):Void {
      Preferences.comboHUD = value;
    }, Preferences.comboHUD);
    createPrefItemCheckbox('Ghost Tapping', 'Enable to let you spam notes', function(value:Bool):Void {
      Preferences.ghostTapping = value;
    }, Preferences.ghostTapping);
    #if !web
    createPrefItemCounter('Framerate', 'Self explanatory', function(value:Int):Void {
      Preferences.framerate = value;
    }, Preferences.framerate, Constants.MIN_FRAMERATE, Constants.MAX_FRAMERATE);
    #end
    createPrefItemCheckbox('Flashing Lights', 'Disable to dampen flashing effects', function(value:Bool):Void {
      Preferences.flashingLights = value;
    }, Preferences.flashingLights);
    createPrefItemCheckbox('Camera Zooming on Beat', 'Disable to stop the camera bouncing to the song', function(value:Bool):Void {
      Preferences.zoomCamera = value;
    }, Preferences.zoomCamera);
    createPrefItemCheckbox('Song Position Bar', 'Enable to display the song position', function(value:Bool):Void {
      Preferences.songPositionBar = value;
    }, Preferences.songPositionBar);
    createPrefItemCheckbox('Stats Counter', 'Enable to show a FPS and RAM counter', function(value:Bool):Void {
      Preferences.debugDisplay = value;
    }, Preferences.debugDisplay);
    createPrefItemCheckbox('Colored Health Bar', 'Enable to make the health bar use colors based on icons', function(value:Bool):Void {
      Preferences.coloredHealthBar = value;
    }, Preferences.coloredHealthBar);
    createPrefItemCheckbox('Centered Strumline', 'Enable to center the strums', function(value:Bool):Void {
      Preferences.centerStrums = value;
    }, Preferences.centerStrums);
    createPrefItemCheckbox('Auto Pause', 'Automatically pause the game when it loses focus', function(value:Bool):Void {
      Preferences.autoPause = value;
    }, Preferences.autoPause);
    createPrefItemSlider('Lane Underlay', 'Set the opacity of the note underlay', function(value:Float):Void {
      Preferences.gameplayBackgroundAlpha = value;
    }, Preferences.gameplayBackgroundAlpha, 0, 1, 0.1);
  }

  function createPrefItemCheckbox(prefName:String, prefDesc:String, onChange:Bool->Void, defaultValue:Bool):Void
  {
    var checkbox:CheckboxPreferenceItem = new CheckboxPreferenceItem(0, 120 * (textItems.length), defaultValue);

    textItems.createItem(120, posY + 30, prefName, AtlasFont.BOLD, () -> onChange(checkbox.currentValue = !checkbox.currentValue), true);

    preferenceItems.add(checkbox);
    preferenceDesc.push(prefDesc);
  }

  function createPrefItemCounter(prefName:String, prefDesc:String, onChange:Int->Void, defaultValue:Int, minValue:Int, maxValue:Int, step:Int = 1):Void
  {
    final posY = 120 * textItems.length;
    final counter = new CounterPreferenceItem(16, posY + 52, defaultValue, minValue, maxValue, onChange);
    counter.ID = textItems.length;
    counter.active = false;

    textItems.createItem(120, posY + 30, prefName, AtlasFont.BOLD, null, true);

    preferenceItems.add(counter);
    preferenceDesc.push(prefDesc);
  }

  function createPrefItemSlider(prefName:String, prefDesc:String, onChange:Float->Void, defaultValue:Float, minValue:Float, maxValue:Float,
      increment:Float):Void
  {
    var sliderItem:SliderMenuItem = new SliderMenuItem(20, (120 * preferenceItems.length) + 30, defaultValue, minValue, maxValue, increment, onChange);
    textItems.createItem(160, (120 * textItems.length) + 30, prefName, AtlasFont.BOLD, sliderItem.callbackPlaceholder, true);
    preferenceItems.add(sliderItem);
  }
  /* override function update(elapsed:Float)
    {
      super.update(elapsed);

      // Indent the selected item.
      // TODO: Only do this on menu change?
      textItems.forEach(function(daItem:TextMenuItem) {
        if (textItems.selectedItem == daItem) daItem.x = 150;
        else
          daItem.x = 120;
      });
  }*/
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
    super(x, y, 0, "", 42);
    this.font = Paths.font("vcr.ttf");
    this.alignment = RIGHT;
    this.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
    // this.antialiasing = false;

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
