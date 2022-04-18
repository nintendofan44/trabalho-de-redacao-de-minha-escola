package states;

import flixel.FlxObject;
import lime.system.System;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import ajudas.Utilidades;
import flixel.math.FlxMath;
import ajudas.AssetPaths;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxSoundAsset;
import base.Conductor;

class TitleScreen extends MusicBeatState {
    public static var state:String = "started";
    public static var gameName:String = "Estações do ano";

    var curSelected:Int = 0;
    var scroll:Float = 0;
    public static var moved:Bool = false;

    var bg:FlxSprite;
    var title:FlxText;
    var titleShadow:FlxText;
    var titleOuterShadow:FlxText;
    var titleSize:Int = 80;

    private var titleArray:Array<FlxText> = [];
    private var buttonArray:Array<String> = ['playButton', 'exit'];
    private var buttonArray2:Array<FlxSprite> = [];

	var musicaParaCachear:Array<Dynamic> = [
		["verao", "semLib"],
		["outono", "semLib"],
		["inverno", "semLib"],
		["primavera", "semLib"],
		["menu", "semLib"]
	];

	var camFollowPos:FlxObject;
    var enableCamScroll:Bool = false;

	override public function create()
	{
        if (buttonArray.length > 2)
            enableCamScroll = true;

        trace(state);

		for (i in 0...musicaParaCachear.length) { // me mata
			if (musicaParaCachear[i][1] == "noLib")
				FlxG.sound.cache(AssetPaths.music(musicaParaCachear[i][0]));
			else
				FlxG.sound.cache(AssetPaths.music(musicaParaCachear[i][0], musicaParaCachear[i][1]));
		}

        //Utilidades.mudarMusica(AssetPaths.music('menu'), false, false, true, 151.0);

        bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 166, 255));
		bg.screenCenter();
        bg.scrollFactor.set();
		add(bg);

        if (enableCamScroll) {
            camFollowPos = new FlxObject(0, 0, 1, 1);
            add(camFollowPos);
    
            camFollowPos.setPosition(bg.getGraphicMidpoint().x, scroll * 30);
        }

        titleShadow = new FlxText(0, 0, FlxG.width, gameName, titleSize);
		titleShadow.setFormat(AssetPaths.font("Days.ttf"), titleSize, FlxColor.fromRGB(0, 0, 0), CENTER, FlxTextBorderStyle.NONE);

        title = new FlxText(0, 0, FlxG.width, gameName, titleSize);
		title.setFormat(AssetPaths.font("Days.ttf"), titleSize, FlxColor.fromRGB(255, 255, 255), CENTER, FlxTextBorderStyle.NONE);
		title.screenCenter();
        title.y -= 190;

        titleOuterShadow = new FlxText(0, 0, FlxG.width, gameName, titleSize);
		titleOuterShadow.setFormat(AssetPaths.font("Days.ttf"), titleSize, FlxColor.fromRGB(58, 58, 58), CENTER, FlxTextBorderStyle.NONE);

        for (i in 0...buttonArray.length) {
			var button:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			button.ID = i;
			button.frames = AssetPaths.getSparrowAtlas('menu/' + buttonArray[i]);
			button.animation.addByPrefix('idle', buttonArray[i] + 'Idle', 24, true);
			button.animation.addByPrefix('hover', buttonArray[i] + 'Hover', 24, true);
			button.animation.play('idle');
			button.antialiasing = true;
			button.updateHitbox();
			button.screenCenter(X);
            add(button);
            var scr:Float = buttonArray.length * 0.135;
			if (buttonArray.length < 1) scr = 0;
			button.scrollFactor.set(0, scr);
            button.antialiasing = true;
            buttonArray2.push(button);
            if (enableCamScroll) {
                FlxTween.tween(button, {y: (titleOuterShadow.height + 120) + (i * 200)}, 1 + (i * 0.25), {
                    ease: FlxEase.expoInOut,
                    onComplete: function(flxTween:FlxTween) {
                        moved = true;
                    }
                });
            } else {
                FlxTween.tween(button, {y: (titleOuterShadow.height + 220) + (i * 200)}, 1 + (i * 0.25), {
                    ease: FlxEase.expoInOut,
                    onComplete: function(flxTween:FlxTween) {
                        moved = true;
                    }
                });
            }
		}

        add(titleShadow);
        titleArray.push(titleShadow);
        add(title);
        titleArray.push(title);
        add(titleOuterShadow);
        titleArray.push(titleOuterShadow);

        titleShadow.scrollFactor.set();
        title.scrollFactor.set();
        titleOuterShadow.scrollFactor.set();

        titleShadow.setPosition(title.x - 5, title.y);
        titleOuterShadow.setPosition(title.x + 1, title.y);

        if (enableCamScroll)
            FlxG.camera.follow(camFollowPos, null, 1);

        changeItem();

		super.create();
	}

    var canClick:Bool = true;
	var isUsingMouse:Bool = false;

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        if (enableCamScroll) {
            if (scroll < 0)
                scroll = 0;
    
            if (FlxG.mouse.wheel > 0) {
                scroll += FlxG.mouse.wheel * 30;
                camFollowPos.setPosition(bg.getGraphicMidpoint().x, scroll);
            }
    
            if (FlxG.mouse.wheel < 0) {
                scroll += FlxG.mouse.wheel * 30;
                camFollowPos.setPosition(bg.getGraphicMidpoint().x, scroll);
            }
    
            //trace(scroll);   
        }

		super.update(elapsed);

        for (i in 0...buttonArray2.length) {
			if (isUsingMouse)
			{
				if(!FlxG.mouse.overlaps(buttonArray2[i]))
					buttonArray2[i].animation.play('idle');
			}

            buttonArray2[i].centerOffsets();
            buttonArray2[i].centerOrigin();

            var multX:Float = FlxMath.lerp(1, buttonArray2[i].scale.x, Utilidades.bound(1 - (elapsed * 9), 0, 1));
            var multY:Float = FlxMath.lerp(1, buttonArray2[i].scale.y, Utilidades.bound(1 - (elapsed * 9), 0, 1));
            buttonArray2[i].scale.set(multX, multY);
            buttonArray2[i].updateHitbox();
	
			if (FlxG.mouse.overlaps(buttonArray2[i]))
			{
				if (canClick)
				{
					curSelected = buttonArray2[i].ID;
					isUsingMouse = true;
					buttonArray2[i].animation.play('hover');

                    if (i == curSelected) {
                        var multX:Float = FlxMath.lerp(1.1, buttonArray2[i].scale.x, Utilidades.bound(1.1 - (elapsed * 9), 0, 1.1));
                        var multY:Float = FlxMath.lerp(1.1, buttonArray2[i].scale.y, Utilidades.bound(1.1 - (elapsed * 9), 0, 1.1));
                        buttonArray2[i].scale.set(multX, multY);
                        buttonArray2[i].updateHitbox();
                    }
				}
					
				if(FlxG.mouse.pressed && canClick)
				{
					selectButton();
				}
			}
	
			buttonArray2[i].updateHitbox();
        }

        for (i in 0...titleArray.length) {
            var multX:Float = FlxMath.lerp(1, titleArray[i].scale.x, Utilidades.bound(1 - (elapsed * 9), 0, 1));
            var multY:Float = FlxMath.lerp(1, titleArray[i].scale.y, Utilidades.bound(1 - (elapsed * 9), 0, 1));
		    titleArray[i].scale.set(multX, multY);
		    titleArray[i].updateHitbox();
        }
	}

    var lastBeatHit:Int = -1;

	override public function beatHit() {
		super.beatHit();

		if (lastBeatHit == curBeat) {
			return;
		}

        /*if (curBeat % 1 == 0) {
            for (i in 0...titleArray.length) {
                titleArray[i].scale.set(1.05, 1.05);
                titleArray[i].updateHitbox();
            }
        }*/

		lastBeatHit = curBeat;
	}

	override public function stepHit() {
		super.stepHit();
	}

    var selected:Bool = false;

    function selectButton()
	{
		selected = true;
		
		canClick = false;

        for (i in 0...buttonArray2.length) {
			if (curSelected == buttonArray2[i].ID)
			{
                goToState();
			}
		}
	}
	
	function goToState()
	{
		var stateToGo:String = buttonArray[curSelected];

		switch (stateToGo)
		{
			case 'playButton':
				MusicBeatState.switchState(new PlayState());
            case 'exit':
				Sys.exit(0);
		}		
	}

    function changeItem(huh:Int = 0)
	{
        if (moved) {
            curSelected += huh;

            if (curSelected >= buttonArray2.length)
                curSelected = 0;
            if (curSelected < 0)
                curSelected = buttonArray2.length - 1;
        }

        for (i in 0...buttonArray2.length) {
			buttonArray2[i].animation.play('idle');

			if (buttonArray2[i].ID == curSelected && moved)
			{
				buttonArray2[i].animation.play('hover');
			}

			buttonArray2[i].updateHitbox();
		}
	}
}