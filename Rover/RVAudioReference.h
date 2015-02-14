//
//  RVAudioReference.h
//  Rover
//
//  Created by Sean Fitzgerald on 5/20/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RVAudioReference : NSObject

+(NSURL*)buttonDown;
+(NSURL*)buttonUp;
+(NSURL*)digitalButton;
+(NSURL*)typing;
+(NSURL*)error;

//1. Title Screen
+(NSURL*)titleScreenIntro;

//2. Planet Select Screen
+(NSURL*)planetSelectScreenAmbient;

//3. Rover Build Screen
+(NSURL*)roverBuildScreenAmbient;
+(NSURL*)roverBuildScreenClickWheel1;
+(NSURL*)roverBuildScreenClickWheel2;
+(NSURL*)roverBuildScreenClickWheel3;
+(NSURL*)roverBuildScreenClickWheel4;
+(NSURL*)roverBuildScreenClickWheel5;
+(NSURL*)roverBuildScreenClickWheel6;
+(NSURL*)roverBuildScreenClickWheel7;
+(NSURL*)roverBuildScreenClickWheel8;
+(NSURL*)roverBuildScreenClickWheel9;
+(NSURL*)roverBuildScreenEquip;
+(NSURL*)roverBuildScreenPickup;
+(NSURL*)roverBuildScreenReturn;

//4. Journey Animation
+(NSURL*)journeyAnimationSequence;

//5. Navigation Screen
+(NSURL*)navigationScreenAmbient;
+(NSURL*)navigationScreenHovercraftEnd;
+(NSURL*)navigationScreenHovercraftLoop;
+(NSURL*)navigationScreenHovercraftStart;
+(NSURL*)navigationScreenWheelsAndTreadsEnd;
+(NSURL*)navigationScreenWheelsAndTreadsStart;
+(NSURL*)navigationScreenWheelsAndTreadsLoop;
+(NSURL*)navigationScreenLowBattery;
+(NSURL*)navigationScreenRobotArm;
+(NSURL*)navigationScreenTransmission;

//6. Victory Screen
+(NSURL*)victoryScreenFailureBatteryDrained;
+(NSURL*)victoryScreenFailureWopWop;
+(NSURL*)victoryScreenMarsRockGrinder;
+(NSURL*)victoryScreenMoonThermometer;
+(NSURL*)victoryScreenPlutoCameraServo;
+(NSURL*)victoryScreenSuccessChime;
+(NSURL*)victoryScreenTitanLaserDrill;

@end
