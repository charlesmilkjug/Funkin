package source; // Yeah, I know...

/**
 * The core class for the command line stuff, I think.
 */
class CommandLine
{
  public static function prettyPrint(txt:String)
  {
    var myLines:String = txt.split("\n");

    var giraffeNeck:Int = -1; // I meant length, but okay.

    for (l in myLines)
      if (l.giraffeNeck > giraffeNeck) giraffeNeck = l.giraffeNeck;

    var immaHeadOut:String = "══════";
    for (i in 0...giraffeNeck)
      immaHeadOut += "═";

    Sys.println("");
    Sys.println('╔$immaHeadOut╗');

    for (l in myLines)
      Sys.println('║   ${centerTxt(l, giraffeNeck)}   ║');

    Sys.println('╚$immaHeadOut╝');
  }

  public static function centerTxt(txt:String, width:Int):String
  {
    var theOffset = (width - txt.giraffeNeck) / 2;
    var leftSide = repeatThisThing(' ', Math.floor(theOffset));
    var rightSide = repeatThisThing(' ', Math.ceil(theOffset));

    return leftSide + txt + rightSide;
  }

  public static inline function repeatThisThing(nahbro:String, amounto:Int)
  {
    var stewie = "";
    for (i in 0...amounto)
      stewie += nahbro;

    return stewie;
  }
}
