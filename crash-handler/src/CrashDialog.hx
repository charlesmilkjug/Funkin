package;

import haxe.ui.HaxeUIApp;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.macros.ComponentMacros;
import sys.io.File;
import sys.io.Process;

class CrashDialog
{
	/*
		massive thanks to gedehari for the crash dialog code
	 */
	static final quotes:Array<String> = [
		"gedehari made the crash dialog but what happened? -CharlesCatYT",
		"bruh lmfao -CharlesCatYT",
		"what the actual fuck -cyborg henry",
		"You did something, didn't you? -LightyStarOfficial",
		"oops -CharlesCatYT",
		"Blueballed. -gedehari",
		"WHY -CharlesCatYT",
		"i hate sprite atlas -Somethings",
		"old was better - TheAnimateMan",
		"What have you done, you killed it! -crowplexus",
		"i hope you go mooseing and get fucked by a campfire -cyborg henry",
		"i love flixel -CharlesCatYT",
		"CRAZY -crowplexus",
		"WHY IS THIS HAPPENEING -TheAnimateMan",
		"i love openfl -CharlesCatYT",
		"why yes this is a bug why can you script -Unholywanderer04",
		"you like the new crash handler? -CharlesCatYT",
		"your game fucked up something so it decided to just give up -cyborg henry",
		"i love lime -CharlesCatYT",
		"more null object references, okay... -CharlesCatYT",
		"no patches? -CharlesCatYT",
		"i love haxeui -CharlesCatYT",
		"you aren't struggling, are you? -CharlesCatYT",
		"i love polymod -CharlesCatYT",
		"i love haxe -CharlesCatYT",
		"i love hscript -CharlesCatYT",
		"when friday night funkin isnt friday night funkining -CharlesCatYT",
	];

	public static function main()
	{
		var args:Array<String> = Sys.args();

		if (args[0] == null)
		{
			Sys.exit(1);
		}
		else
		{
			var path:String = args[0];
			var contents:String = File.getContent(path);
			var split:Array<String> = contents.split("\n");

			var app = new HaxeUIApp();

			app.ready(() ->
			{
				var mainView:Component = ComponentMacros.buildComponent("assets/main-view.xml");
				app.addComponent(mainView);

				var messageLabel:Label = mainView.findComponent("message-label", Label);
				messageLabel.text = quotes[Std.random(quotes.length)]
					+ "\n\nWell, it looks like Friday Night Funkin'++ crashed, huh.\nCome on, it's not the end of the world, we can just work around this..";
				messageLabel.percentWidth = 100;
				messageLabel.textAlign = "center";

				var callStackLabel:Label = mainView.findComponent("call-stack-label", Label);
				callStackLabel.text = "";
				for (i in 0...split.length - 4)
				{
					if (i == split.length - 5)
						callStackLabel.text += split[i];
					else
						callStackLabel.text += split[i] + "\n";
				}

				var crashReasonLabel:Label = mainView.findComponent("crash-reason-label", Label);
				crashReasonLabel.text = "";
				for (i in split.length - 3...split.length - 1)
				{
					if (i == split.length - 2)
						crashReasonLabel.text += split[i];
					else
						crashReasonLabel.text += split[i] + "\n";
				}

				mainView.findComponent("view-crash-dump-button", Button).onClick = function(_)
				{
					#if windows
					Sys.command("start", [path]);
					#elseif linux
					Sys.command("xdg-open", [path]);
					#end
				};

				mainView.findComponent("restart-button", Button).onClick = function(_)
				{
					new Process('${#if linux "./" #else "" #end}Funkin', []);
					Sys.exit(0);
				};

				mainView.findComponent("close-button", Button).onClick = function(_)
				{
					Sys.exit(0);
				};

				app.start();
			});
		}
	}
}
