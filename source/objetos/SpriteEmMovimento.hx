package objetos;

import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxTileFrames;
import flixel.FlxG;
import ajudas.Utilidades;
import flixel.math.FlxMath;
import ajudas.AssetPaths;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class SpriteEmMovimento extends FlxSprite {
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Float = 0;
	public var targetX:Float = 0;
	public var yMult:Float = 120;
	public var scrollType:String = "";

	public function new() {
		super();
	}

	override function update(elapsed:Float) {
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		var scaledX = FlxMath.remapToRange(targetX, 0, 1, 0, 1.3);
		var lerpVal:Float = Utilidades.bound(elapsed * 9.6, 0, 1);

		switch (scrollType) {
			case "Classic":
				y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48), lerpVal);
				if (forceX != Math.NEGATIVE_INFINITY) {
					x = forceX;
				}
				else {
					x = FlxMath.lerp(x, (targetY * 20) + 90, lerpVal);
				}

			case "Vertical":
				y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.5), lerpVal);
				x = FlxMath.lerp(x, (targetY * 0) + 308, lerpVal);
				x += targetX / (openfl.Lib.current.stage.frameRate / 60);

			case "Horizontal":
				screenCenter(Y);
				x = FlxMath.lerp(x, (scaledX * 200) + (FlxG.width * 0.5), lerpVal);
				x -= 12.5;

			case "C-Shape":
				y = FlxMath.lerp(y, (scaledY * 65) + (FlxG.height * 0.39), lerpVal);

				x = FlxMath.lerp(x, Math.exp(scaledY * 0.8) * 70 + (FlxG.width * 0.1), lerpVal);
				if (scaledY < 0)
					x = FlxMath.lerp(x, Math.exp(scaledY * -0.8) * 70 + (FlxG.width * 0.1), lerpVal);

				if (x > FlxG.width + 30)
					x = FlxG.width + 30;
			case "D-Shape":
				y = FlxMath.lerp(y, (scaledY * 90) + (FlxG.height * 0.45), lerpVal);

				x = FlxMath.lerp(x, Math.exp(scaledY * 0.8) * -70 + (FlxG.width * 0.35), lerpVal);
				if (scaledY < 0)
					x = FlxMath.lerp(x, Math.exp(scaledY * -0.8) * -70 + (FlxG.width * 0.35), lerpVal);

				if (x < -900)
					x = -900;
			case "Center":
				screenCenter(X);

				y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.30);
				// x = FlxMath.lerp(x, (targetY * 20) + 90, 0.30);
		}

		super.update(elapsed);
	}

	// huh
	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):SpriteEmMovimento
	{
		var graph:FlxGraphic = FlxG.bitmap.add(Graphic, Unique, Key);
		if (graph == null)
			return this;

		if (Width == 0)
		{
			Width = Animated ? graph.height : graph.width;
			Width = (Width > graph.width) ? graph.width : Width;
		}

		if (Height == 0)
		{
			Height = Animated ? Width : graph.height;
			Height = (Height > graph.height) ? graph.height : Height;
		}

		if (Animated)
			frames = FlxTileFrames.fromGraphic(graph, FlxPoint.get(Width, Height));
		else
			frames = graph.imageFrame;

		return this;
	}
}
