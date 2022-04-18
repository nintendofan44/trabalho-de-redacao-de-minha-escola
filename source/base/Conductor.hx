package base;

import base.Music.MusicData;

typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor {
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float = 0;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public function new() {
	}

	public static function getBPMChange(time:Float) {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (time >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange;
	}

	public static function getCrochet(time:Float) {
		var lastChange = getBPMChange(time);
		return ((60 / lastChange.bpm) * 1000);
	}

	public static function mapBPMChanges(song:MusicData) {
		bpmChangeMap = [
			{
				stepTime: 0,
				songTime: 0,
				bpm: song.bpm
			}
		];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.things.length) {
			if (song.things[i].changeBPM && song.things[i].bpm != curBPM) {
				curBPM = song.things[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.things[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
	}

	public static function changeBPM(newBpm:Float) {
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}
