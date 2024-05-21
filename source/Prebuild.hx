package source; // Yeah, I know...

import sys.io.Process;
import sys.io.File;

/**
 * A script which executes before the game is built.
 */
class Prebuild extends CommandLine
{
  static inline final BUILD_TIME_FILE:String = '.build_time';

  static function main():Void
  {
    saveBuildTime();

    CommandLine.prettyPrint('Building Funkin\'++.'); // Check if your Haxe version is outdated.

    var theProcess:Process = new Process('haxe --version');
    theProcess.exitCode(true);
    var haxer = theProcess.stdout.readLine();
    if (haxer != "4.3.4")
    {
      var curHaxe = [for (augh in haxer.split(".")) Std.parseInt(augh)];
      var dudeWanted = [4, 3, 4];
      for (bro in 0...dudeWanted.length)
      {
        if (curHaxe[bro] < dudeWanted[bro])
        {
          CommandLine.prettyPrint("!! WARNING !!");
          Sys.println("Your current Haxe version is outdated.");
          Sys.println('You\'re using ${haxer}, while the required version is 4.3.4.');
          Sys.println('The engine has no guarantee of compiling with your current version of Haxe.');
          Sys.println('So, we recommend upgrading to 4.3.4.');
          break;
        }
      }
    }

    CommandLine.prettyPrint('This might take a while, just be patient.');
  }

  static function saveBuildTime():Void
  {
    var fo:sys.io.FileOutput = File.write(BUILD_TIME_FILE);
    var now:Float = Sys.time();
    fo.writeDouble(now);
    fo.close();
  }
}
