package;

import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import sys.io.File;
import lime.app.Application;
import sys.io.Process;
import haxe.io.Path;
import sys.FileSystem;
import openfl.system.System;
import flixel.system.FlxAssets;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextField;
import flixel.util.FlxColor;
import flixel.FlxG;
import states.PlayState;
import states.TitleScreen;
import interface_.FPS_Mem;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.Bitmap;
import openfl.Assets;

class FlxGameMod extends FlxGame
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleScreen; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	public static var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public function new() {
		var stageWidth:Float = Lib.application.window.width;
		var stageHeight:Float = Lib.application.window.height;

		if (zoom == -1) {
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleScreen;
		#end

		super(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
	}
}

class Main extends Sprite {
	var counter:FPS_Mem;
	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void {

		addChild(new FlxGameMod());

		#if !mobile
		counter = new FPS_Mem(10, 3, 0xFFFFFF);
		addChild(counter);
		#end

		FlxG.autoPause = false;

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	}

	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = "./crash/" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		var crashDialoguePath:String = "CrashDialog";

		#if windows
		crashDialoguePath += ".exe";
		#end

		if (FileSystem.exists("./" + crashDialoguePath))
		{
			Sys.println("Found crash dialog: " + crashDialoguePath);

			#if linux
			crashDialoguePath = "./" + crashDialoguePath;
			#end
			new Process(crashDialoguePath, [path]);
		}
		else
		{
			// I had to do this or the stupid CI won't build :distress:
			Sys.println("No crash dialog found! Making a simple alert instead...");
			Application.current.window.alert(errMsg, "Error!");
		}

		Sys.exit(1);
	}
}
