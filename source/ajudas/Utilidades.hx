package ajudas;

import flixel.system.FlxAssets.FlxSoundAsset;
import base.Conductor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton.FlxTypedButton;
import states.PlayState;
import openfl.system.System;
import flixel.text.FlxText;
import flixel.FlxG;
import openfl.utils.Assets;
import flixel.FlxSprite;

using StringTools;

class Utilidades
{
	inline public static function nextPower(k:Int) { // not sure what this is for
		var n = 1;
		while (n < k)
			n *= 2;
		return Std.int(n);
	}

	inline public static function bound(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	inline public static function currentMem():Float
	{
		return (System.totalMemory / 1024) / 1000;
	}

	inline public static function divide(f1:Float, f2:Float):Float
	{
		return if (f2 == 0 || f1 == 0) 0 else f1 / f2;
	}

	public static function precacheSound(sound:String, ?library:String = null):Void
	{
		if (!Assets.cache.hasSound(AssetPaths.sound(sound, library)))
		{
			FlxG.sound.cache(AssetPaths.sound(sound, library));
		}
	}

	public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	/**
	 * [Função usada para mudar a música que está tocando atualmente]
	 * @param nome Nome da música
	 * @param fade Mude para true se você quiser que a musica tenha uma transição
	 * @param mudarBPM Mude para true se você quiser mudar o bpm
	 * @param bpm Valor do bpm (em float)
	 */
	inline public static function mudarMusica(nome:FlxSoundAsset, fadeOut:Bool = false, fadeIn:Bool = false, mudarBPM:Bool = false, bpm:Float = 100) {
		var volume = 1;
		if ((fadeOut && !fadeIn) || (fadeOut && fadeIn) || (!fadeOut && !fadeIn))
			volume = 1;
		else if (!fadeOut && fadeIn)
			volume = 0;

		if (fadeOut) FlxG.sound.music.fadeOut(1, 0);
		if (FlxG.sound.music != null) FlxG.sound.music.stop();
		FlxG.sound.playMusic(nome, volume);
		if (fadeIn) FlxG.sound.music.fadeIn(1, 0, 1);
		if (mudarBPM) Conductor.changeBPM(bpm);
	}

	inline public static function floorDecimal(value:Float, decimals:Int):Float {
		if (decimals < 1) {
			return Math.floor(value);
		}

		var tempMult:Float = 1;
		for (i in 0...decimals) {
			tempMult *= 10;
		}
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}
}

class SpriteInstantania extends FlxSprite
{
	public var foiAdicionada:Bool = false;
	//public var isInFront:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, _antialiasing:Bool)
	{
		super(x, y);
		antialiasing = _antialiasing;
	}
}
