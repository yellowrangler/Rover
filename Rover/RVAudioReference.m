//
//  RVAudioReference.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/20/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVAudioReference.h"

@implementation RVAudioReference

//0. Generic
+(NSURL*)buttonDown
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_physical-button-down" ofType:@"wav"]];
}

+(NSURL*)buttonUp
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_physical-button-up" ofType:@"wav"]];
}

+(NSURL*)digitalButton
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_digital-button" ofType:@"wav"]];
}

+(NSURL*)typing
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_digital-typing" ofType:@"wav"]];
}

+(NSURL*)error
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_error" ofType:@"wav"]];
}

//1. Title Screen
+(NSURL*)titleScreenIntro
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"mus_intro" ofType:@"wav"]];
}

//2. Planet Select Screen
+(NSURL*)planetSelectScreenAmbient
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"amb_outerspace" ofType:@"wav"]];
}

//3. Rover Build Screen
+(NSURL*)roverBuildScreenAmbient
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"amb_workshop" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenClickWheel1
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_clickwheel-1" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenClickWheel2
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_clickwheel-2" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenClickWheel3
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_clickwheel-3" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenClickWheel4
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_clickwheel-4" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenClickWheel5
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_clickwheel-5" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenClickWheel6
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_clickwheel-6" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenClickWheel7
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_clickwheel-7" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenClickWheel8
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_clickwheel-8" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenClickWheel9
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_clickwheel-9" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenEquip
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_tool-drag_equip" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenPickup
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_tool-drag_pickup" ofType:@"wav"]];
}

+(NSURL*)roverBuildScreenReturn
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_tool-drag_return" ofType:@"wav"]];
}

//4. Journey Animation
+(NSURL*)journeyAnimationSequence
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"mix_journey-animation" ofType:@"wav"]];
}

//5. Navigation Screen
+(NSURL*)navigationScreenAmbient
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"amb_control-room" ofType:@"wav"]];
}

+(NSURL*)navigationScreenHovercraftEnd
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_hovercraft_end" ofType:@"wav"]];
}

+(NSURL*)navigationScreenHovercraftLoop
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_hovercraft_loop" ofType:@"wav"]];
}

+(NSURL*)navigationScreenHovercraftStart
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_hovercraft_start" ofType:@"wav"]];
}

+(NSURL*)navigationScreenWheelsAndTreadsEnd
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_wheels-and-treads_end" ofType:@"wav"]];
}

+(NSURL*)navigationScreenWheelsAndTreadsStart
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_wheels-and-treads_start" ofType:@"wav"]];
}

+(NSURL*)navigationScreenWheelsAndTreadsLoop
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_wheels-and-treads_loop" ofType:@"wav"]];
}

+(NSURL*)navigationScreenLowBattery
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_low-battery" ofType:@"wav"]];
}

+(NSURL*)navigationScreenRobotArm
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_robot-arm" ofType:@"wav"]];
}

+(NSURL*)navigationScreenTransmission
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_transmission" ofType:@"wav"]];
}

//6. Victory Screen
+(NSURL*)victoryScreenFailureBatteryDrained
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_failure_battery-drained" ofType:@"wav"]];
}

+(NSURL*)victoryScreenFailureWopWop
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_failure_wopwop" ofType:@"wav"]];
}

+(NSURL*)victoryScreenMarsRockGrinder
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_mars_rock-grinder" ofType:@"wav"]];
}

+(NSURL*)victoryScreenMoonThermometer
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_moon_thermometer" ofType:@"wav"]];
}

+(NSURL*)victoryScreenPlutoCameraServo
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_pluto_camera-servo" ofType:@"wav"]];
}

+(NSURL*)victoryScreenSuccessChime
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_success_chime" ofType:@"wav"]];
}

+(NSURL*)victoryScreenTitanLaserDrill
{
	return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sfx_titan_laser-drill" ofType:@"wav"]];
}

@end
