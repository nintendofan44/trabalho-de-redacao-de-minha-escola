package states;

import ajudas.Org;
import ajudas.Org.TextoInstantanio;
import ajudas.Org.SpriteInstantania;
import objetos.FlxTextConectado;
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
	public var textMap:Map<String, TextoInstantanio> = new Map<String, TextoInstantanio>();

	var shadersCameraPrincipal:Array<ShaderEffect> = [];
	var shadersCameraPrincipal2:Array<ShaderEffect> = [];

	var gameWidth:Int = 1280;
	var gameHeight:Int = 720;
	var zoom:Float = -1;

	var descricoes:Array<String> = [
		'O verão caracteriza-se por elevadas temperaturas. \nSuas principais características são as elevadas temperaturas e o aumento dos índices pluviométricos.',
		'No outono, os ventos aumentam e ficam mais fortes gradativamente. \nComo o outono antecede o inverno, é comum também haver quedas de temperaturas constantes. \nSe há queda nas temperaturas, também há a diminuição da umidade do ar. \nGeadas e neve podem ser também comuns nessa estação do ano.',
		'O inverno caracteriza-se pelo seu frio extremo. Além disso, é bastante comum a presença de geadas e nevascas. \nQuando a temperatura das nuvens está abaixo de 0 Celsius (32 Fahrenheit), o vapor de água se condensa, \ndando origens a cristais de gelo, que caem em forma de neve.',
		'A primavera caracteriza-se por apresentar dias com temperaturas amenas, \nalém disso, em algumas regiões, também ocorre a floração de diversas plantas. \nA primavera inicia-se logo após o inverno e encerra-se dando início ao verão.',
	];

	var grupoPlanoDeFundo:FlxTypedGroup<FlxSprite>;
	var grupoParticulas:FlxTypedGroup<FlxEmitter>;
	var grupoPlanoDeFundo2:FlxTypedGroup<FlxSprite>;
	var grupoTexto:FlxTypedGroup<TextoInstantanio>;

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
		grupoTexto = new FlxTypedGroup<TextoInstantanio>();

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
			grupoPlanoDeFundo2.add(Org.adicionarImagemComRetorno('passaro' + i, '$pasta/geral/passaro', 0, (FlxG.height / 4) + (10 + solA), true));
			Org.editarSprite('passaro' + i).scale.set(0.25, 0.25);
			Org.editarSprite('passaro' + i).updateHitbox();
			if (i > -1 && i > 0) {
				Org.editarSprite('passaro' + i).x += Org.editarSprite('passaro' + i).width * i + 10;
				Org.editarSprite('passaro' + i).y += Org.editarSprite('passaro' + i).height * i + 10;
			}
		}

		grupoTexto.add(Org.adicionarPalavrasComRetorno('descrição', 0, 0, FlxG.width, descricoes[0], 16));
		Org.editarTexto('descrição').setFormat(AssetPaths.font("Days.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		Org.editarTexto('descrição').updateHitbox();
		Org.editarTexto('descrição').screenCenter();
		Org.editarTexto('descrição').y += Org.editarTexto('descrição').height * 4;

		add(grupoPlanoDeFundo);
		add(grupoParticulas);
		add(grupoPlanoDeFundo2);
		add(grupoTexto);

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

				if (FlxG.keys.pressed.ENTER)
					multiplicador = 200;
				else
					multiplicador = 35;

				Org.editarSprite('passaro' + i).x += (elapsed * multiplicador) * ((i + valor2) / 2);
			}

			for (i in 0...2) {
				/*var valor:Bool = false;
					if (i > -1 && i < 1)
						valor = true;
					else if (i > -1 && (i > 1 || i == 1))
						valor = false;

					var valor2:Int = valor ? 1 : 0; */

				if (Org.editarSprite('passaro' + i).x > FlxG.width + 50) {
					ciclos++;
					trace(ciclos);

					if (ciclos == 2)
						mudarEstacao('outono', 1);
					if (ciclos == 4)
						mudarEstacao('inverno', 2);
					if (ciclos == 6)
						mudarEstacao('primavera', 3);
					/*if (ciclos == 8) {
						mudarEstacao('verao', 0);
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

					Org.editarSprite('passaro' + i).kill();
					Org.editarSprite('passaro' + i).foiAdicionada = false;
					grupoPlanoDeFundo2.add(Org.adicionarImagemComRetorno('passaro' + i, '$pasta/geral/passaro', 0, (FlxG.height / 4) + (10 + solA), true));
					Org.editarSprite('passaro' + i).alpha = 0;
					Org.editarSprite('passaro' + i).scale.set(0.25, 0.25);
					Org.editarSprite('passaro' + i).updateHitbox();
					if (i > -1 && i > 0) {
						Org.editarSprite('passaro' + i).x += Org.editarSprite('passaro' + i).width * i + 10;
						Org.editarSprite('passaro' + i).y += Org.editarSprite('passaro' + i).height * i + 10;
						FlxTween.tween(Org.editarSprite('passaro' + i), {alpha: 1}, 1, {ease: FlxEase.quartInOut});
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
			if (ciclos != 8) {
				FlxTween.tween(sol, {x: -200, y: -200, angle: 270}, 1.5, {ease: FlxEase.cubeInOut});
				new FlxTimer().start(0.95, function(tmr:FlxTimer) {
					//FlxTween.tween(FlxG.camera, {zoom: 3, angle: 179}, 1.1, {ease: FlxEase.expoInOut});
					MusicBeatState.switchState(new TitleScreen());
				});
			} else {
				//FlxTween.tween(FlxG.camera, {zoom: 3, angle: 179}, 1.1, {ease: FlxEase.expoInOut});
				MusicBeatState.switchState(new TitleScreen());
			}
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

	function mudarEstacao(estacao:String, estacaoNum:Int) {
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
				grupoPlanoDeFundo2.add(Org.adicionarImagemComRetorno('passaro' + i, '$pasta/geral/passaro', 0, (FlxG.height / 4) + (10 + solA), true));
				Org.editarSprite('passaro' + i).scale.set(0.25, 0.25);
				Org.editarSprite('passaro' + i).updateHitbox();
				if (i > -1 && i > 0) {
					Org.editarSprite('passaro' + i).x += Org.editarSprite('passaro' + i).width * i + 10;
					Org.editarSprite('passaro' + i).y += Org.editarSprite('passaro' + i).height * i + 10;
				}
			}
		});
		new FlxTimer().start(3, function(tmr:FlxTimer) {
			grupoTexto.add(Org.adicionarPalavrasComRetorno('descrição', 0, 0, FlxG.width, descricoes[estacaoNum], 16));
			Org.editarTexto('descrição').setFormat(AssetPaths.font("Days.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			Org.editarTexto('descrição').updateHitbox();
			Org.editarTexto('descrição').screenCenter();
			Org.editarTexto('descrição').y += Org.editarTexto('descrição').height;
			grupoTexto.forEachAlive(function(texto:FlxTextConectado) {
				if (texto != null/* && texto.alpha == 0*/)
					FlxTween.tween(texto, {alpha: 1}, 1, {ease: FlxEase.quartInOut});
			});
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
			grupoTexto.forEachAlive(function(texto:FlxTextConectado) {
				FlxTween.tween(texto, {alpha: 0}, 1, {ease: FlxEase.quartInOut});
			});
			new FlxTimer().start(2, function(tmr:FlxTimer) {
				grupoPlanoDeFundo.clear();
				if (grupoParticulas.length > -1 && grupoParticulas.length > 0)
					grupoParticulas.clear();
				grupoPlanoDeFundo2.clear();
				grupoTexto.clear();
			});
			pasta = "creditos";
		} else {
			grupoTexto.forEachAlive(function(texto:FlxTextConectado) {
				FlxTween.tween(texto, {alpha: 0}, 1, {ease: FlxEase.quartInOut});
			});
			grupoPlanoDeFundo.clear();
			if (grupoParticulas.length > -1 && grupoParticulas.length > 0)
				grupoParticulas.clear();
			grupoPlanoDeFundo2.clear();
			new FlxTimer().start(2, function(tmr:FlxTimer) {
				grupoTexto.clear();
			});
		}
	}
}
