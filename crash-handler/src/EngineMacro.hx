package;

import haxe.macro.Expr;

class EngineMacro
{
	public static macro function getEngineVersion():ExprOf<String>
	{
		return macro $v{"0.3.2"}
	}
}
