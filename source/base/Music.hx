package base;

import base.MusicSection.SectionData;

using StringTools;

typedef MusicData = {
	var song:String;
	var things:Array<SectionData>;
	var bpm:Float;
}

class Music {
	public var song:String;
	public var things:Array<SectionData>;
	public var bpm:Float;

	public function new(song, things, bpm) {
		this.song = song;
		this.things = things;
		this.bpm = bpm;
	}
}
