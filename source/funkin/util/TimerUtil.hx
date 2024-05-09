package funkin.util;

import flixel.util.FlxTimer;
import funkin.util.tools.FloatTools;
import haxe.Timer;

class TimerUtil
{
  /**
   * Store the current time.
   */
  public static function start():Float
  {
    return Timer.stamp();
  }

  /**
   * Return the elapsed time.
   */
  static function took(start:Float, ?end:Float):Float
  {
    var endOrNow:Float = end != null ? end : Timer.stamp();
    return endOrNow - start;
  }

  /**
   * Return the elapsed time in seconds as a string.
   * @param start The start time.
   * @param end The end time.
   * @param precision The number of decimal places to round to.
   * @return The elapsed time in seconds as a string.
   */
  public static function seconds(start:Float, ?end:Float, ?precision = 2):String
  {
    var seconds:Float = FloatTools.round(took(start, end), precision);
    return '${seconds} seconds';
  }

  /**
   * Return the elapsed time in milliseconds as a string.
   * @param start The start time.
   * @param end The end time.
   * @return The elapsed time in milliseconds as a string.
   */
  public static function ms(start:Float, ?end:Float):String
  {
    var seconds:Float = took(start, end);
    return '${seconds * 1000} ms';
  }
}

typedef SequenceEvent =
{
  time: Float,
  callback: ()->Void
};

class Sequence
{
  /**
   * Create a new timer sequence.
   * @param events A list of function callbacks along with their corresponding call times, in seconds.
   * @param mult Optional multiplier for callback times. Great for frame-based or music-based timing.
   * @param start Whether or not to immediately start the sequence.
   */
  public function new(events:Array<SequenceEvent>, mult:Float = 1, start:Bool = true)
  {
    for (event in events)
    {
      timers.push(new FlxTimer().start(
        event.time * mult,
        function(timer:FlxTimer)
        {
          event.callback();
          timers.remove(timer);
        }
      ));
    }

    running = start;
  }

  /**
   * The list of uncompleted timers.
   */
  private final timers:Array<FlxTimer> = [];

  /**
   * Controls whether the timers in this sequence are active or not.
   */
  public var running(get, set):Bool;
  private var _running:Bool = true;

  @:noCompletion public function get_running():Bool
  {
    return completed ? false : _running;
  }

  @:noCompletion public function set_running(v:Bool):Bool
  {
    for (timer in timers)
    {
      timer.active = v;
    }

    return _running = v;
  }

  /**
   * Whether all timers in this sequence have completed or not.
   */
  public var completed(get, never);
  
  @:noCompletion public function get_completed():Bool
  {
    return timers.length == 0;
  }

  /**
   * Clean up and destroy this sequence.
   */
  public function destroy():Void
  {
    for (timer in timers)
    {
      timer.cancel();
      timer.destroy();
    }

    while (!completed)
    {
      timers.pop();
    }
  }
}
