package funkin.play.components;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxDirection;
import funkin.graphics.FunkinSprite;
import funkin.play.PlayState;
import funkin.util.TimerUtil;
import funkin.util.SortUtil;
import flixel.util.FlxSort;

class PopUpStuff extends FlxTypedGroup<FunkinSprite>
{
  public var offsets:Array<Int> = [0, 0];

  override public function new()
  {
    super();
    this.ID = 0;
  }

  public function displayRating(?daRating:String)
  {
    var perfStart:Float = TimerUtil.start();

    if (daRating == null) daRating = "good";

    var ratingPath:String = daRating;

    if (PlayState.instance.currentStageId.startsWith('school')) ratingPath = 'weeb/pixelUI/$ratingPath-pixel';

    var rating:FunkinSprite = recycle(FunkinSprite);
    rating.loadTexture(ratingPath);
    rating.scrollFactor.set(0.2, 0.2);

    rating.zIndex = 1000;
    rating.x = (FlxG.width * 0.474) + offsets[0];
    // rating.x -= FlxG.camera.scroll.x * 0.2;
    rating.y = (FlxG.camera.height * 0.45 - 60) + offsets[1];
    rating.acceleration.y = 550;
    rating.velocity.y = -FlxG.random.int(140, 175);
    rating.velocity.x = -FlxG.random.int(0, 10);
    rating.ID = this.ID++;

    add(rating);

    if (PlayState.instance.currentStageId.startsWith('school'))
    {
      rating.setGraphicSize(rating.width * Constants.PIXEL_ART_SCALE * 0.7);
      rating.antialiasing = false;
    }
    else
    {
      rating.setGraphicSize(rating.width * 0.65);
      rating.antialiasing = true;
    }
    rating.updateHitbox();

    rating.x -= rating.width / 2;
    rating.y -= rating.height / 2;

    FlxTween.tween(rating, {alpha: 0}, 0.2,
      {
        onComplete: function(tween:FlxTween) {
          // remove(rating, true);
          rating.kill(); // destroy
          rating.alpha = 1.0;
        },
        startDelay: Conductor.instance.beatLengthMs * 0.001
      });

    refresh();
    // trace('displayRating took: ${TimerUtil.seconds(perfStart)}');
  }

  public function displayCombo(?combo:Int):Int
  {
    var perfStart:Float = TimerUtil.start();

    if (combo == null) combo = 0;

    var pixelShitPart1:String = "";
    var pixelShitPart2:String = '';

    if (PlayState.instance.currentStageId.startsWith('school'))
    {
      pixelShitPart1 = 'weeb/pixelUI/';
      pixelShitPart2 = '-pixel';
    }
    var comboSpr:FunkinSprite = FunkinSprite.create(pixelShitPart1 + 'combo' + pixelShitPart2);
    comboSpr.y = (FlxG.camera.height * 0.44) + offsets[1];
    comboSpr.x = (FlxG.width * 0.507) + offsets[0];
    comboSpr.x -= FlxG.camera.scroll.x * 0.2;

    comboSpr.acceleration.y = 600;
    comboSpr.velocity.y -= 150;
    comboSpr.velocity.x += FlxG.random.int(1, 10);

    add(comboSpr);

    if (PlayState.instance.currentStageId.startsWith('school'))
    {
      comboSpr.setGraphicSize(Std.int(comboSpr.width * Constants.PIXEL_ART_SCALE * 0.7));
      comboSpr.antialiasing = false;
    }
    else
    {
      comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
      comboSpr.antialiasing = true;
    }
    comboSpr.updateHitbox();

    FlxTween.tween(comboSpr, {alpha: 0}, 0.2,
      {
        onComplete: function(tween:FlxTween) {
          remove(comboSpr, true);
          comboSpr.destroy();
        },
        startDelay: Conductor.instance.beatLengthMs * 0.001
      });

    var seperatedScore:Array<Int> = [];
    var tempCombo:Int = combo;

    while (tempCombo != 0)
    {
      seperatedScore.push(tempCombo % 10);
      tempCombo = Std.int(tempCombo / 10);
    }
    while (seperatedScore.length < 3)
      seperatedScore.push(0);

    // seperatedScore.reverse();

    var daLoop:Int = 1;
    for (i in seperatedScore)
    {
      var numScore:FunkinSprite = recycle(FunkinSprite);
      numScore.loadTexture(pixelShitPart1 + 'num' + i + pixelShitPart2);

      if (PlayState.instance.currentStageId.startsWith('school'))
      {
        numScore.setGraphicSize(numScore.width * Constants.PIXEL_ART_SCALE * 0.7);
        numScore.antialiasing = false;
      }
      else
      {
        numScore.setGraphicSize(numScore.width * 0.45);
        numScore.antialiasing = true;
      }
      numScore.updateHitbox();

      // comboSpr.x
      numScore.x = numX - (36 * daLoop) - 65; //- 90;
      numScore.y = numY; // comboSpr.y
      numScore.acceleration.y = FlxG.random.int(250, 300);
      numScore.velocity.y = -FlxG.random.int(130, 150);
      numScore.velocity.x = FlxG.random.float(-5, 5);
      numScore.ID = this.ID++;

      add(numScore);

      FlxTween.tween(numScore, {alpha: 0}, 0.2,
        {
          onComplete: function(tween:FlxTween) {
            // remove(numScore, true);
            numScore.kill(); // destroy
            numScore.alpha = 1.0;
          },
          startDelay: Conductor.instance.beatLengthMs * 0.002
        });

      daLoop++;
    }

    refresh();
    // trace('displayCombo took: ${TimerUtil.seconds(perfStart)}');

    return combo;
  }

  inline public function refresh():Void
  {
    sort(SortUtil.byID, FlxSort.ASCENDING);
  }
}
