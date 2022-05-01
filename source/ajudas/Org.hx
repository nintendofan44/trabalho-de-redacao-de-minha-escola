package ajudas;

import states.PlayState;
import flixel.FlxSprite;
import objetos.FlxTextConectado;

using StringTools;

class Org {
    // caractere para substituir - substituto
    public static var caracteresParaSubstituir:Array<Dynamic> = [
		[".", ""],
		["&", ""],
		["ç", "c"],
        ["ã", "a"],
        ["õ", "o"],
        ["ñ", "n"],
        ["á", "a"],
        ["é", "e"],
        ["í", "i"],
        ["ó", "o"],
        ["ú", "u"],
	];

    inline public static function adicionarImagem(tag:String, imagem:String, x:Float, y:Float, antialiasing:Bool) {
        verificarCaracteres(caracteresParaSubstituir, tag);
		resetarTagDeSprite(tag);
		var dolly:SpriteInstantania = new SpriteInstantania(x, y, antialiasing);
		if (imagem != null && imagem.length > 0) {
			dolly.loadGraphic(AssetPaths.image(imagem));
		}
		dolly.antialiasing = antialiasing;
		PlayState.instance.spriteMap.set(tag, dolly);
		dolly.active = true;

		adicionarSprite(tag);
	}

	inline public static function adicionarImagemComRetorno(tag:String, imagem:String, x:Float, y:Float, antialiasing:Bool):SpriteInstantania {
        verificarCaracteres(caracteresParaSubstituir, tag);
		resetarTagDeSprite(tag);
		var dolly:SpriteInstantania = new SpriteInstantania(x, y, antialiasing);
		if (imagem != null && imagem.length > 0) {
			dolly.loadGraphic(AssetPaths.image(imagem));
		}
		dolly.antialiasing = antialiasing;
		PlayState.instance.spriteMap.set(tag, dolly);
		dolly.active = true;

		return dolly;
	}

    inline public static function adicionarPalavras(tag:String, X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
        verificarCaracteres(caracteresParaSubstituir, tag);
		resetarTagDeTexto(tag);
		var dolly:TextoInstantanio = new TextoInstantanio(X, Y, FieldWidth, Text, Size, EmbeddedFont);
		dolly.antialiasing = true;
		PlayState.instance.textMap.set(tag, dolly);
		dolly.active = true;

		adicionarTexto(tag);
	}

	inline public static function adicionarPalavrasComRetorno(tag:String, X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true):TextoInstantanio {
        verificarCaracteres(caracteresParaSubstituir, tag);
		resetarTagDeTexto(tag);
		var dolly:TextoInstantanio = new TextoInstantanio(X, Y, FieldWidth, Text, Size, EmbeddedFont);
		dolly.antialiasing = true;
		PlayState.instance.textMap.set(tag, dolly);
		dolly.active = true;

		return dolly;
	}

    inline public static function adicionarSprite(tag:String) {
		if (PlayState.instance.spriteMap.exists(tag)) {
			var pepsi:SpriteInstantania = PlayState.instance.spriteMap.get(tag);
			if (!pepsi.foiAdicionada) {
				PlayState.instance.add(pepsi);
				pepsi.foiAdicionada = true;
			}
		}
	}

	inline public static function removerSprite(tag:String) {
		if (PlayState.instance.spriteMap.exists(tag)) {
			var pepsi:SpriteInstantania = PlayState.instance.spriteMap.get(tag);
			if (!pepsi.foiAdicionada) {
				pepsi.kill();
				pepsi.foiAdicionada = false;
			}
		}
	}

	inline public static function adicionarTexto(tag:String) {
		if (PlayState.instance.textMap.exists(tag)) {
			var pepsi:TextoInstantanio = PlayState.instance.textMap.get(tag);
			if (!pepsi.foiAdicionado) {
				PlayState.instance.add(pepsi);
				pepsi.foiAdicionado = true;
			}
		}
	}

	inline public static function removerTexto(tag:String) {
		if (PlayState.instance.textMap.exists(tag)) {
			var pepsi:TextoInstantanio = PlayState.instance.textMap.get(tag);
			if (!pepsi.foiAdicionado) {
				pepsi.kill();
				pepsi.foiAdicionado = false;
			}
		}
	}

	inline public static function resetarTagDeSprite(tag:String) {
		if (!PlayState.instance.spriteMap.exists(tag)) {
			return;
		}

		var interessante:SpriteInstantania = PlayState.instance.spriteMap.get(tag);
		interessante.kill();
		if (interessante.foiAdicionada) {
			PlayState.instance.remove(interessante, true);
		}
		interessante.destroy();
		PlayState.instance.spriteMap.remove(tag);
	}

	inline public static function resetarTagDeTexto(tag:String) {
		if (!PlayState.instance.textMap.exists(tag)) {
			return;
		}

		var interessante:TextoInstantanio = PlayState.instance.textMap.get(tag);
		interessante.kill();
		if (interessante.foiAdicionado) {
			PlayState.instance.remove(interessante, true);
		}
		interessante.destroy();
		PlayState.instance.textMap.remove(tag);
	}

	inline public static function editarSprite(name:String):SpriteInstantania {
		return PlayState.instance.spriteMap.exists(name) ? PlayState.instance.spriteMap.get(name) : Reflect.getProperty(PlayState.instance, name);
	}

	inline public static function editarTexto(name:String):FlxTextConectado {
		return PlayState.instance.textMap.exists(name) ? PlayState.instance.textMap.get(name) : Reflect.getProperty(PlayState.instance, name);
	}

    inline public static function verificarCaracteres(array:Array<Dynamic>, texto:String) { // intelijegue
        for (i in 0...array.length) {
            if (texto.contains(array[i][0]))
                texto = texto.replace(array[i][0], array[i][1]);
        }
    }
}

class SpriteInstantania extends FlxSprite
{
	public var foiAdicionada:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, _antialiasing:Bool)
	{
		super(x, y);
		antialiasing = _antialiasing;
	}
}

class TextoInstantanio extends FlxTextConectado
{
	public var foiAdicionado:Bool = false;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}
}
