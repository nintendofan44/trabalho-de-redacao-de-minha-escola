package states;

import interface_.CustomFadeTransition;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.util.FlxTimer;
import openfl.Lib;
import flixel.group.FlxSpriteGroup;
import flixel.FlxObject;
import flixel.util.FlxStringUtil;
import shaders.Ondas;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import shaders.ShaderEffect;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxSoundAsset;
import ajudas.AssetPaths;
import base.Conductor;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import states.MusicBeatState;
import ajudas.Utilidades;
import flixel.util.FlxCollision;
import objetos.SpriteDeFundo;
import flixel.effects.particles.FlxEmitter;

using StringTools;

class PlayState extends MusicBeatState {
	var close(get, null):Bool;

	var sound:FlxSoundAsset;

	var ceu:FlxSprite;
	var arvores:SpriteDeFundo;
	var flores:SpriteDeFundo;
	var grama:SpriteDeFundo;
	var gramaDesfoque:SpriteDeFundo;
	var sol:SpriteDeFundo;

	var creditos:SpriteDeFundo;

	var pasta:String = "";

	var estacao:String = "verao";
	var prefixo:String = "";

	var ondaDeCalor:Ondas;

	var oaoaoaoaoaoa:SpriteDeFundo;

	private var cameraPrincipal:FlxCamera;
	private var cameraPrincipal2:FlxCamera;
	private var cameraTransicao:FlxCamera;

	private var atualizarTempo:Bool = false;
	var porcentagemDaMusica:Float = 0;
	var tamanhoDaMusica:Float = 0;

	var dividir:Float = 400;

	public var spriteMap:Map<String, SpriteInstantania> = new Map<String, SpriteInstantania>();

	var shadersCameraPrincipal:Array<ShaderEffect> = [];
	var shadersCameraPrincipal2:Array<ShaderEffect> = [];

	var gameWidth:Int = 1280;
	var gameHeight:Int = 720;
	var zoom:Float = -1;

	var grupoPlanoDeFundo:FlxTypedGroup<FlxSprite>;
	var grupoParticulas:FlxTypedGroup<FlxEmitter>;
	var grupoPlanoDeFundo2:FlxTypedGroup<FlxSprite>;

	var mudandoEstacao:Bool = false;
	var ciclos:Int = 0; // Lord X !!!1!!1!1!11!1!1111!11!!!111

	var solL:Float = 0.0;
	var solA:Float = 0.0;

	private function get_close():Bool {
		return FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]);
	}

	public function new() {
		super();
	}

	public static var instance:PlayState;

	override public function create() {
		instance = this;
		pasta = "planoDeFundo";

		var stageWidth:Float = Lib.application.window.width;
		var stageHeight:Float = Lib.application.window.height;

		if (zoom == -1) {
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		cameraPrincipal = new FlxCamera();
		cameraPrincipal2 = new FlxCamera();
		cameraPrincipal2.bgColor.alpha = 0;
		cameraTransicao = new FlxCamera();
		cameraTransicao.bgColor.alpha = 0;

		FlxG.cameras.reset(cameraPrincipal);
		FlxG.cameras.setDefaultDrawTarget(cameraPrincipal, true);
		FlxG.cameras.add(cameraPrincipal2);
		FlxG.cameras.setDefaultDrawTarget(cameraPrincipal2, false);
		FlxG.cameras.add(cameraTransicao);
		FlxG.cameras.setDefaultDrawTarget(cameraTransicao, false);
		CustomFadeTransition.nextCamera = cameraTransicao;

		persistentUpdate = true;
		persistentDraw = true;

		Utilidades.mudarMusica(AssetPaths.music(estacao), false, true);

		grupoPlanoDeFundo = new FlxTypedGroup<FlxSprite>();
		grupoParticulas = new FlxTypedGroup<FlxEmitter>();
		grupoPlanoDeFundo2 = new FlxTypedGroup<FlxSprite>();

		ceu = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 166, 255));
		ceu.screenCenter();
		ceu.scrollFactor.set();
		grupoPlanoDeFundo.add(ceu);

		arvores = new SpriteDeFundo('$pasta/$estacao/arvores', 0, 0, 0, 0);
		arvores.screenCenter();
		grupoPlanoDeFundo.add(arvores);

		grama = new SpriteDeFundo('$pasta/$estacao/grama', 0, 0, 0, 0);
		grama.y = FlxG.height - grama.height + 17;
		grama.screenCenter(X);
		grama.x += 40;
		grama.scale.set(0.77, 0.67);
		grupoPlanoDeFundo.add(grama);

		gramaDesfoque = new SpriteDeFundo('$pasta/$estacao/grama com desfoque', 0, 0, 0, 0);
		gramaDesfoque.y = grama.y;
		gramaDesfoque.y += 6;
		gramaDesfoque.scale.set(0.87, 0.77);
		gramaDesfoque.screenCenter(X);
		grupoPlanoDeFundo.add(gramaDesfoque);

		sol = new SpriteDeFundo('$pasta/geral/sol', -200, -200, 0, 0);
		sol.angle = 270;
		solL = sol.width;
		solA = sol.height;
		grupoPlanoDeFundo.add(sol);

		if (estacao == "verao") {
			oaoaoaoaoaoa = new SpriteDeFundo('$pasta/$estacao/onda de calor', 0, 0, 0, 0);
			oaoaoaoaoaoa.screenCenter();
			oaoaoaoaoaoa.setGraphicSize(FlxG.width, FlxG.height);
			grupoPlanoDeFundo.add(oaoaoaoaoaoa);

			adicionarShadersDeCamera('principal2', ondaDeCalor = new Ondas());
			ondaDeCalor.waveAmplitude = 0.1;
			ondaDeCalor.waveFrequency = 1;
			ondaDeCalor.waveSpeed = 2;
			ondaDeCalor.effectType = HEAT_WAVE_HORIZONTAL;
		}

		for (i in 0...2) {
			grupoPlanoDeFundo.add(adicionarImagemComRetorno('passaro' + i, '$pasta/geral/passaro', 0, (FlxG.height / 4) + (10 + solA), true));
			momentoAmendoim('passaro' + i).scale.set(0.25, 0.25);
			momentoAmendoim('passaro' + i).updateHitbox();
			if (i > -1 && i > 0) {
				momentoAmendoim('passaro' + i).x += momentoAmendoim('passaro' + i).width * i + 10;
				momentoAmendoim('passaro' + i).y += momentoAmendoim('passaro' + i).height * i + 10;
			}
		}

		add(grupoPlanoDeFundo);
		add(grupoParticulas);
		add(grupoPlanoDeFundo2);

		FlxG.worldBounds.set(gameWidth / 2, gameHeight / 2, gameWidth, gameHeight);

		super.create();

		FlxTween.tween(sol, {
			x: (FlxG.width / dividir) + (solL + 5),
			y: (FlxG.height / dividir) + (solA + 5),
			angle: 0
		}, 1.5, {ease: FlxEase.cubeInOut});

		tamanhoDaMusica = FlxG.sound.music.length;
	}

	override public function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		ondaDeCalor.update(elapsed);

		if (!mudandoEstacao) {
			for (i in 0...2) {
				var valor:Bool = false;
				if (i > -1 && i < 1) // matemática complexa confia
					valor = true;
				else if (i > -1 && (i > 1 || i == 1))
					valor = false;

				var valor2:Int = valor ? 1 : 0;
				var multiplicador:Int = 35;
				momentoAmendoim('passaro' + i).x += (elapsed * multiplicador) * ((i + valor2) / 2);
			}

			for (i in 0...2) {
				/*var valor:Bool = false;
					if (i > -1 && i < 1)
						valor = true;
					else if (i > -1 && (i > 1 || i == 1))
						valor = false;

					var valor2:Int = valor ? 1 : 0; */

				if (momentoAmendoim('passaro' + i).x > FlxG.width + 50) {
					ciclos++;
					trace(ciclos);

					if (ciclos == 2)
						mudarEstacao('outono');
					if (ciclos == 4)
						mudarEstacao('inverno');
					if (ciclos == 6)
						mudarEstacao('primavera');
					/*if (ciclos == 8) {
						mudarEstacao('verao');
						ciclos = 0;
					}*/ // se eu um dia quiser fazer um loop
					if (ciclos == 8) {
						limparTudo(true);

						creditos = new SpriteDeFundo('$pasta/creditos', 0, 0, 0, 0);
						creditos.alpha = 0;
						creditos.screenCenter();
						creditos.cameras = [cameraPrincipal2];
						add(creditos);
						FlxTween.tween(creditos, {alpha: 1}, 1, {ease: FlxEase.smootherStepIn});
					}

					momentoAmendoim('passaro' + i).kill();
					momentoAmendoim('passaro' + i).foiAdicionada = false;
					grupoPlanoDeFundo2.add(adicionarImagemComRetorno('passaro' + i, '$pasta/geral/passaro', 0, (FlxG.height / 4) + (10 + solA), true));
					momentoAmendoim('passaro' + i).scale.set(0.25, 0.25);
					momentoAmendoim('passaro' + i).updateHitbox();
					if (i > -1 && i > 0) {
						momentoAmendoim('passaro' + i).x += momentoAmendoim('passaro' + i).width * i + 10;
						momentoAmendoim('passaro' + i).y += momentoAmendoim('passaro' + i).height * i + 10;
					}
				}
			}
		}

		if (atualizarTempo) {
			var tempoAtual:Float = Conductor.songPosition;
			if (tempoAtual < 0) tempoAtual = 0;
			porcentagemDaMusica = (tempoAtual / tamanhoDaMusica);

			var calculoMusica:Float = (tamanhoDaMusica - tempoAtual);

			var segundosTotais:Int = Math.floor(calculoMusica / 1000);
			if (segundosTotais < 0) segundosTotais = 0;

			// tempo.text = FlxStringUtil.formatTime(segundosTotais, false);
		}

		if (close) {
			FlxTween.tween(sol, {x: -200, y: -200, angle: 270}, 1.5, {ease: FlxEase.cubeInOut});
			new FlxTimer().start(0.95, function(tmr:FlxTimer) {
				MusicBeatState.switchState(new TitleScreen());
			});
		}
	}

	var lastBeatHit:Int = -1;

	override public function beatHit() {
		super.beatHit();

		if (lastBeatHit == curBeat) {
			return;
		}

		lastBeatHit = curBeat;
	}

	override public function stepHit() {
		super.stepHit();
	}

	public override function openSubState(SubState:FlxSubState):Void {
		#if FLX_MOUSE
		if (cursor != null && hideCursorOnSubstate && cursor.visible == true) {
			_cursorHidden = true;
			cursor.visible = false;
		}
		#end
		super.openSubState(SubState);
	}

	public function adicionarShadersDeCamera(cam:String, effect:ShaderEffect) {
		switch (cam.toLowerCase()) {
			case 'cameraprincipal' | 'principal':
				shadersCameraPrincipal.push(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in shadersCameraPrincipal) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				cameraPrincipal.setFilters(newCamEffects);
			case 'cameraprincipal2' | 'principal2':
				shadersCameraPrincipal2.push(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in shadersCameraPrincipal2) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				cameraPrincipal2.setFilters(newCamEffects);
			default:
				shadersCameraPrincipal.push(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in shadersCameraPrincipal) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				cameraPrincipal.setFilters(newCamEffects);
		}
	}

	public function removerShadersDeCamera(cam:String, effect:ShaderEffect) {
		switch (cam.toLowerCase()) {
			case 'cameraprincipal' | 'principal':
				shadersCameraPrincipal.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in shadersCameraPrincipal) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				cameraPrincipal.setFilters(newCamEffects);
			case 'cameraprincipal2' | 'principal2':
				shadersCameraPrincipal2.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in shadersCameraPrincipal2) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				cameraPrincipal2.setFilters(newCamEffects);
			default:
				shadersCameraPrincipal.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in shadersCameraPrincipal) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				cameraPrincipal.setFilters(newCamEffects);
		}
	}

	public function limparShadersDeCamera(cam:String) {
		switch (cam.toLowerCase()) {
			case 'cameraprincipal' | 'principal':
				shadersCameraPrincipal = [];
				var newCamEffects:Array<BitmapFilter> = [];
				cameraPrincipal.setFilters(newCamEffects);
			case 'cameraprincipal2' | 'principal2':
				shadersCameraPrincipal2 = [];
				var newCamEffects:Array<BitmapFilter> = [];
				cameraPrincipal2.setFilters(newCamEffects);
			default:
				shadersCameraPrincipal = [];
				var newCamEffects:Array<BitmapFilter> = [];
				cameraPrincipal.setFilters(newCamEffects);
		}
	}

	function adicionarImagem(tag:String, imagem:String, x:Float, y:Float, antialiasing:Bool) {
		tag = tag.replace('.', '');
		resetarTagDeSprite(tag);
		var dolly:SpriteInstantania = new SpriteInstantania(x, y, antialiasing);
		if (imagem != null && imagem.length > 0) {
			dolly.loadGraphic(AssetPaths.image(imagem));
		}
		dolly.antialiasing = antialiasing;
		PlayState.instance.spriteMap.set(tag, dolly);
		dolly.active = true;

		adicionar(tag);
	}

	function adicionarImagemComRetorno(tag:String, imagem:String, x:Float, y:Float, antialiasing:Bool):SpriteInstantania {
		tag = tag.replace('.', '');
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

	function adicionar(tag:String) {
		if (PlayState.instance.spriteMap.exists(tag)) {
			var pepsi:SpriteInstantania = PlayState.instance.spriteMap.get(tag);
			if (!pepsi.foiAdicionada) {
				PlayState.instance.add(pepsi);
				pepsi.foiAdicionada = true;
			}
		}
	}

	function remover(tag:String) {
		if (PlayState.instance.spriteMap.exists(tag)) {
			var pepsi:SpriteInstantania = PlayState.instance.spriteMap.get(tag);
			if (!pepsi.foiAdicionada) {
				pepsi.kill();
				pepsi.foiAdicionada = false;
			}
		}
	}

	function resetarTagDeSprite(tag:String) {
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

	function momentoAmendoim(name:String):SpriteInstantania {
		return PlayState.instance.spriteMap.exists(name) ? PlayState.instance.spriteMap.get(name) : Reflect.getProperty(PlayState.instance, name);
	}

	function mudarEstacao(estacao:String) {
		mudandoEstacao = true;

		var transicao:SpriteDeFundo = new SpriteDeFundo('$pasta/$estacao/transicao', 0, -1000);
		transicao.cameras = [cameraTransicao];
		transicao.screenCenter(X);
		add(transicao);
		FlxTween.tween(transicao, {y: 1000}, 3, {
			ease: FlxEase.expoInOut,
			onComplete: function(twn:FlxTween) {
				transicao.kill();
			}
		});

		this.estacao = estacao;
		limparTudo(false);

		ceu = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 166, 255));
		ceu.screenCenter();
		ceu.scrollFactor.set();
		grupoPlanoDeFundo.add(ceu);

		new FlxTimer().start(1.5, function(tmr:FlxTimer) {
			switch (estacao) {
				case "verao":
					limparShadersDeCamera('principal2');
					oaoaoaoaoaoa = new SpriteDeFundo('$pasta/$estacao/onda de calor', 0, 0, 0, 0);
					oaoaoaoaoaoa.screenCenter();
					oaoaoaoaoaoa.setGraphicSize(FlxG.width, FlxG.height);
					grupoPlanoDeFundo.add(oaoaoaoaoaoa);

					adicionarShadersDeCamera('principal2', ondaDeCalor = new Ondas());
					ondaDeCalor.waveAmplitude = 0.1;
					ondaDeCalor.waveFrequency = 1;
					ondaDeCalor.waveSpeed = 2;
					ondaDeCalor.effectType = HEAT_WAVE_HORIZONTAL;
				case "outono":
					{
						limparShadersDeCamera('principal2');
						var emissor:FlxEmitter = new FlxEmitter(0, 0);
						emissor.launchMode = FlxEmitterMode.SQUARE;
						emissor.velocity.set(-50, 150, 50, 750, -100, 0, 100, 100);
						emissor.scale.set(1, 1, 1, 1, 1, 1, 1, 1);
						emissor.drag.set(0, 0, 0, 0, 5, -5, 10, -10);
						emissor.width = 3500;
						emissor.alpha.set(1, 1, 0, 0);
						emissor.lifespan.set(3, 5);
						emissor.x = (FlxG.width - emissor.width) / 2;
						emissor.y = (FlxG.height - emissor.height) / 2;
						emissor.loadParticles(AssetPaths.image('$pasta/outono/folha2'), 500, 16, true);

						emissor.start(false, FlxG.random.float(0.1, 0.2), 100000);
						grupoParticulas.add(emissor);
					}
				case "inverno":
					{
						var emissor:FlxEmitter = new FlxEmitter(0, 0);
						emissor.launchMode = FlxEmitterMode.SQUARE;
						emissor.velocity.set(-50, 150, 50, 750, -100, 0, 100, 100);
						emissor.scale.set(1, 1, 1, 1, 1, 1, 1, 1);
						emissor.drag.set(0, 0, 0, 0, 5, -5, 10, -10);
						emissor.width = FlxG.width;
						emissor.height = FlxG.height;
						emissor.alpha.set(1, 1, 0, 0);
						emissor.lifespan.set(3, 5);
						emissor.x = (FlxG.width - emissor.width) / 2;
						emissor.y = (FlxG.height - emissor.height) / 2;
						emissor.loadParticles(AssetPaths.image('$pasta/inverno/neve'), 500, 16, true);

						emissor.start(false, FlxG.random.float(0.1, 0.2), 100000);
						grupoParticulas.add(emissor);
					}
			}

			arvores = new SpriteDeFundo('$pasta/$estacao/arvores', 0, 0, 0, 0);
			arvores.screenCenter();
			grupoPlanoDeFundo2.add(arvores);

			if (estacao == "primavera") {
				flores = new SpriteDeFundo('$pasta/primavera/flores', 0, 0, 0, 0);
				flores.screenCenter();
				grupoPlanoDeFundo2.add(flores);
			}

			grama = new SpriteDeFundo('$pasta/$estacao/grama', 0, 0, 0.1, 0);
			grama.y = FlxG.height - grama.height + 17;
			grama.screenCenter(X);
			grama.x += 40;
			grama.scale.set(0.77, 0.67);
			grupoPlanoDeFundo2.add(grama);

			gramaDesfoque = new SpriteDeFundo('$pasta/$estacao/grama com desfoque', 0, 0, 0.4, 0);
			gramaDesfoque.y = grama.y;
			gramaDesfoque.y += 6;
			gramaDesfoque.scale.set(0.87, 0.77);
			gramaDesfoque.screenCenter(X);
			grupoPlanoDeFundo2.add(gramaDesfoque);

			sol = new SpriteDeFundo('$pasta/geral/sol', (FlxG.width / dividir) + (solL + 5), (FlxG.height / dividir) + (solA + 5), 0, 0);
			sol.angle = 0;
			grupoPlanoDeFundo2.add(sol);

			for (i in 0...2) {
				grupoPlanoDeFundo2.add(adicionarImagemComRetorno('passaro' + i, '$pasta/geral/passaro', 0, (FlxG.height / 4) + (10 + solA), true));
				momentoAmendoim('passaro' + i).scale.set(0.25, 0.25);
				momentoAmendoim('passaro' + i).updateHitbox();
				if (i > -1 && i > 0) {
					momentoAmendoim('passaro' + i).x += momentoAmendoim('passaro' + i).width * i + 10;
					momentoAmendoim('passaro' + i).y += momentoAmendoim('passaro' + i).height * i + 10;
				}
			}
		});
		Utilidades.mudarMusica(AssetPaths.music(estacao), true, true);
		mudandoEstacao = false;
	}

	function limparTudo(creditos:Bool) {
		if (creditos) {
			grupoPlanoDeFundo.forEachAlive(function(sprite:FlxSprite) {
				FlxTween.tween(sprite, {alpha: 0}, 1, {ease: FlxEase.quartInOut});
			});
			grupoPlanoDeFundo2.forEachAlive(function(sprite:FlxSprite) {
				FlxTween.tween(sprite, {alpha: 0}, 1, {ease: FlxEase.quartInOut});
			});
			new FlxTimer().start(2, function(tmr:FlxTimer) {
				grupoPlanoDeFundo.clear();
				if (grupoParticulas.length > -1 && grupoParticulas.length > 0)
					grupoParticulas.clear();
				grupoPlanoDeFundo2.clear();
			});
			pasta = "creditos";
		} else {
			grupoPlanoDeFundo.clear();
			if (grupoParticulas.length > -1 && grupoParticulas.length > 0)
				grupoParticulas.clear();
			grupoPlanoDeFundo2.clear();
		}
	}
}
