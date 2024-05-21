package funkin;

using StringTools;

class FunkinWrapper
{
  inline public static function callMethod(o:Dynamic, func:Function, args:Array<Dynamic>):Dynamic
    {
      return Reflect.callMethod(o, func, args);
    }
  inline public static function compare<T>(a:T, b:T):Int
    {
      return Reflect.compare(a, b);
    }
  inline public static function compareMethods(f1:Dynamic, f2:Dynamic):Bool
    {
      return Reflect.compareMethods(a, b);
    }
  inline public static function copy<T>(o:Null<T>):Null<T>
    {
      return Reflect.copy(o);
    }
  inline public static function getProperty(o:Dynamic, field:String):Dynamic
    {
      return Reflect.getProperty(o, field);
    }
public static function setProperty(o:Dynamic, field:String, value:Dynamic):Void
    {
      Reflect.setProperty(o, field, value);
    }
  inline public static function getOsName():String
    {
      return Sys.systemName();
    }
  inline public static function printToOutput(hi:String):String
    {
      return Sys.println(hi);
    }
  inline public static function isFunction(f:Dynamic):Bool
    {
      return Reflect.isFunction(f);
    }
  inline public static function fileExists(path:String):Bool
    {
      return Sys.FileSystem.exists(path);
    }
  inline public static function getClass<T>(o:T):Class<T>
    {
      return Type.getClass(o);
    }
  inline public static function getClassName(c:Class<Dynamic>):String
    {
      return Type.getClassName(c);
    }
  inline public static function getEnum(o:EnumValue):Enum<Dynamic>
    {
      return Type.getEnum(o);
    }
inline public static function getEnumName(e:Enum<Dynamic>):String
    {
      return Type.getEnumName(e);
    }
inline public static function resolveClass(name:String):Class<Dynamic>
    {
      return Type.resolveClass(name);
    }
  inline public static function resolveEnum(name:String):Enum<Dynamic>
    {
      return Type.resolveEnum(name);
    }
  inline public static function isObject(v:Dynamic):Bool
    {
      return Reflect.isObject(v);
    }
  inline public static function isEnumValue(v:Dynamic):Bool
    {
      return Reflect.isEnumValue(v);
    }
}
