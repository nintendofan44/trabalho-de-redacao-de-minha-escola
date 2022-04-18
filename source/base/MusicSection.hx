package base;

typedef SectionData = {
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var bpm:Float;
	var changeBPM:Bool;
}

/**
 * weird bullcrap
 * 
 * sorry for the swer
 */
class Section {
	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;

	public function new(lengthInSteps:Int = 16) {
		this.lengthInSteps = lengthInSteps;
	}
}
