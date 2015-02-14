//
//  RVJacobGuidanceController.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/10/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVJacobGuidanceController.h"
#import "Constants_Build_Graphics.h"

@interface RVJacobGuidanceController()

@property (nonatomic, assign) BOOL highGain;
@property (nonatomic, assign) BOOL lowGain;
@property (nonatomic, assign) BOOL panCam;
@property (nonatomic, assign) BOOL spectrometer;
@property (nonatomic, assign) BOOL weatherStation;
@property (nonatomic, assign) BOOL chemCam;
@property (nonatomic, assign) BOOL rockGrinder;
@property (nonatomic, assign) BOOL microscope;
@property (nonatomic, assign) BOOL laserDrill;
@property (nonatomic, assign) BOOL hovercraft;
@property (nonatomic, assign) BOOL wheels;
@property (nonatomic, assign) BOOL treads;
@property (nonatomic, strong) NSString *lastTool;

@property (nonatomic, assign, readonly) NSInteger baseWeight;
@property (nonatomic, assign, readonly) NSInteger maxWeight;
@property (nonatomic, assign, readonly) BOOL roverIsOverWeight;

@property (nonatomic, strong) NSString *currentMessage;
@property (nonatomic, assign) BOOL isGeneralResponse;

@end

@implementation RVJacobGuidanceController

-(id)init
{
    self = [super init];
    if (self) {
        self.isIntroduction = YES;
    }
    return self;
}

//accessor methods
-(void)setCurrentMessage:(NSString *)currentMessage
{
    //set the instance variable
    _currentMessage = currentMessage;
    
    [self.delegate writeMessage:_currentMessage];
}

-(BOOL)roverIsFinished
{
    BOOL finished = NO;
    if ([self.planet isEqualToString:@"moon"]) {
        finished = self.highGain && self.wheels && self.weatherStation;
    } else if ([self.planet isEqualToString:@"mars"]) {
        finished = self.highGain && (self.treads || self.wheels) && (self.rockGrinder || self.chemCam || self.microscope || self.spectrometer);
    } else if ([self.planet isEqualToString:@"titan"]) {
        finished = self.highGain && self.hovercraft && self.laserDrill && self.microscope;
    } else if ([self.planet isEqualToString:@"pluto"]) {
        finished = self.highGain && self.treads && self.panCam;
    }
    return finished && !self.roverIsOverWeight;
}

-(BOOL)communicationSystemCompleted
{
    BOOL finished = NO;
    if ([self.planet isEqualToString:@"moon"]) {
        finished = self.highGain;
    } else if ([self.planet isEqualToString:@"mars"]) {
        finished = self.highGain;
    } else if ([self.planet isEqualToString:@"titan"]) {
        finished = self.highGain;
    } else if ([self.planet isEqualToString:@"pluto"]) {
        finished = self.highGain;
    }
    return finished;
}

-(BOOL)analysisSystemCompleted
{
    BOOL finished = NO;
    if ([self.planet isEqualToString:@"moon"]) {
        finished = self.weatherStation;
    } else if ([self.planet isEqualToString:@"mars"]) {
        finished = (self.rockGrinder || self.chemCam || self.microscope || self.spectrometer);
    } else if ([self.planet isEqualToString:@"titan"]) {
        finished = self.laserDrill && self.microscope;
    } else if ([self.planet isEqualToString:@"pluto"]) {
        finished = self.panCam;
    }
    return finished;
}

-(BOOL)locomotionSystemCompleted
{
    BOOL finished = NO;
    if ([self.planet isEqualToString:@"moon"]) {
        finished = self.wheels;
    } else if ([self.planet isEqualToString:@"mars"]) {
        finished = (self.treads || self.wheels);
    } else if ([self.planet isEqualToString:@"titan"]) {
        finished = self.hovercraft;
    } else if ([self.planet isEqualToString:@"pluto"]) {
        finished = self.treads;
    }
    return finished;
}

-(NSInteger)baseWeight
{
    return 105;
}

-(NSInteger)maxWeight
{
    return 185;
}

-(NSInteger)currentWeight
{
    NSInteger weight =self.baseWeight +
    (self.highGain?10:0) +
    (self.lowGain?5:0) +
    (self.panCam?15:0) +
    (self.spectrometer?10:0) +
    (self.weatherStation?25:0) +
    (self.chemCam?10:0) +
    (self.rockGrinder?10:0) +
    (self.microscope?25:0) +
    (self.laserDrill?15:0) +
    (self.hovercraft?20:0) +
    (self.treads?40:0) +
    (self.wheels?30:0);
    
    return weight;
}

-(BOOL)roverIsOverWeight
{
    return self.currentWeight > self.maxWeight;
}

//public functions
-(void)nextGeneralMessage
{
    self.isGeneralResponse = YES;
    [self nextMessage];
}

-(void)newTool:(RVRoverBuildTool *)tool
{
    if ([tool.attachmentType isEqualToString:RV_HGANTENNA_ATTACHMENT_POINTS]) {
        self.highGain = YES;
    } else if ([tool.attachmentType isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS]){
        self.lowGain = YES;
    } else if ([tool.attachmentType isEqualToString:RV_PANCAM_ATTACHMENT_POINTS]){
        self.panCam = YES;
    } else if ([tool.attachmentType isEqualToString:RV_SPECTROMETER_ATTACHMENT_POINTS]){
        self.spectrometer = YES;
    } else if ([tool.attachmentType isEqualToString:RV_WEATHER_STATION_ATTACHMENT_POINTS]){
        self.weatherStation = YES;
    } else if ([tool.attachmentType isEqualToString:RV_CHEMCAM_ATTACHMENT_POINTS]){
        self.chemCam = YES;
    } else if ([tool.attachmentType isEqualToString:RV_ROCK_GRINDER_ATTACHMENT_POINTS]){
        self.rockGrinder = YES;
    } else if ([tool.attachmentType isEqualToString:RV_MICROSCOPE_ATTACHMENT_POINTS]){
        self.microscope = YES;
    } else if ([tool.attachmentType isEqualToString:RV_LASER_DRILL_ATTACHMENT_POINTS]){
        self.laserDrill = YES;
    } else if ([tool.attachmentType isEqualToString:RV_HOVERCRAFT_ATTACHMENT_POINTS]){
        self.hovercraft = YES;
    } else if ([tool.attachmentType isEqualToString:RV_TREADS_ATTACHMENT_POINTS]){
        self.treads = YES;
    } else if ([tool.attachmentType isEqualToString:RV_WHEELS_ATTACHMENT_POINTS]){
        self.wheels = YES;
    }
    self.lastTool = tool.attachmentType;
    self.isIntroduction = NO;
    [self nextMessage];
}

-(void)removeTool:(RVRoverBuildTool *)tool
{
    if ([tool.attachmentType isEqualToString:RV_HGANTENNA_ATTACHMENT_POINTS]) {
        self.highGain = NO;
    } else if ([tool.attachmentType isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS]){
        self.lowGain = NO;
    } else if ([tool.attachmentType isEqualToString:RV_PANCAM_ATTACHMENT_POINTS]){
        self.panCam = NO;
    } else if ([tool.attachmentType isEqualToString:RV_SPECTROMETER_ATTACHMENT_POINTS]){
        self.spectrometer = NO;
    } else if ([tool.attachmentType isEqualToString:RV_WEATHER_STATION_ATTACHMENT_POINTS]){
        self.weatherStation = NO;
    } else if ([tool.attachmentType isEqualToString:RV_CHEMCAM_ATTACHMENT_POINTS]){
        self.chemCam = NO;
    } else if ([tool.attachmentType isEqualToString:RV_ROCK_GRINDER_ATTACHMENT_POINTS]){
        self.rockGrinder = NO;
    } else if ([tool.attachmentType isEqualToString:RV_MICROSCOPE_ATTACHMENT_POINTS]){
        self.microscope = NO;
    } else if ([tool.attachmentType isEqualToString:RV_LASER_DRILL_ATTACHMENT_POINTS]){
        self.laserDrill = NO;
    } else if ([tool.attachmentType isEqualToString:RV_HOVERCRAFT_ATTACHMENT_POINTS]){
        self.hovercraft = NO;
    } else if ([tool.attachmentType isEqualToString:RV_TREADS_ATTACHMENT_POINTS]){
        self.treads = NO;
    } else if ([tool.attachmentType isEqualToString:RV_WHEELS_ATTACHMENT_POINTS]){
        self.wheels = NO;
    }
}

-(void)nextMessage
{
    /*
     {//MISSION REQUIREMENTS
     moon = body + highGain + wheels + weatherStation;
     mars = body + highGain + (treads or wheels) + (rockGrinder or chemCam or microscope or spectrometer);
     titan = body + highGain + hovercraft + laserDrill + microscope;
     pluto = body + highGain + treads + panCam;
     all = currentWeight <= maxWeight;
     }
     */
    
    if ([self.planet isEqualToString:@"moon"])
    {//MOON
        if (self.isIntroduction &&
            !self.isGeneralResponse)
        {//AT SCREEN START
            //These should start displaying when the screen is loaded.
            //After each one types out, it should stay long enough to read (maybe 2 seconds?), and then the next one should start typing out.
            //The user can interrupt this at any time by clicking on a tool button or by selecting a tool.
            NSString *message1 = @"Hi, engineer! Jacob here, and I'm going to help you build your rover for your Moon mission!";
            NSString *message2 = @"Look through the tools, and drag the ones you need for your mission onto your rover body.";
            NSString *message3 = @"Tools only fit in certain places, so match up the shape of the tool base and rover port.";
            NSString *message4 = @"If your rover weighs more than 185kg, it will be too heavy to launch!";
            NSString *message5 = @"Ready to build? Let's get started!";
            if ([self.currentMessage isEqualToString:message1]) {
                self.currentMessage = message2;
            } else if ([self.currentMessage isEqualToString:message2]) {
                self.currentMessage = message3;
            } else if ([self.currentMessage isEqualToString:message3]) {
                self.currentMessage = message4;
            } else if ([self.currentMessage isEqualToString:message4]) {
                self.currentMessage = message5;
                //stop the introductions after displaying the last one
                self.isIntroduction = NO;
            } else if ([self.currentMessage isEqualToString:message5]) {
                self.currentMessage = message1;
            } else {
                self.currentMessage = message1;
            }
        } else
            if (!self.isGeneralResponse){//RESPONSIVE
                if (!self.roverIsOverWeight){
                    if ([self.lastTool isEqualToString:RV_HGANTENNA_ATTACHMENT_POINTS]){self.currentMessage = @"Great! Now you will be able to send instructions to your rover.";}
                    else if ([self.lastTool isEqualToString:RV_WHEELS_ATTACHMENT_POINTS]){self.currentMessage = @"Excellent! Those wheels will work well on the Moon's rocky and dusty surface.";}
                    else if ([self.lastTool isEqualToString:RV_WEATHER_STATION_ATTACHMENT_POINTS]){self.currentMessage = @"Fantastic! Now your rover will be able to take temperature readings!";}
                    else if ([self.lastTool isEqualToString:RV_PANCAM_ATTACHMENT_POINTS] ||
                             [self.lastTool isEqualToString:RV_ROCK_GRINDER_ATTACHMENT_POINTS] ||
                             [self.lastTool isEqualToString:RV_SPECTROMETER_ATTACHMENT_POINTS] ||
                             [self.lastTool isEqualToString:RV_CHEMCAM_ATTACHMENT_POINTS] ||
                             [self.lastTool isEqualToString:RV_MICROSCOPE_ATTACHMENT_POINTS] ||
                             [self.lastTool isEqualToString:RV_LASER_DRILL_ATTACHMENT_POINTS] /*"tool is panCam, spectrometer, chemCam, rockGrinder, microscope, or laserDrill"*/){
                        self.currentMessage = @"That tool doesn’t help with your primary mission, but bring it along if you want!";
                    }
                    else if ([self.lastTool isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS] &&
                             self.highGain){self.currentMessage = @"That tool doesn’t help with your primary mission, but bring it along if you want!";}
                    else if ([self.lastTool isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS] &&
                             !self.highGain){self.currentMessage = @"That’s a backup tool. You still need the high gain antenna to send the rover instructions!";}
                    else if ([self.lastTool isEqualToString:RV_TREADS_ATTACHMENT_POINTS]){self.currentMessage = @"Those treads won't work very well on the Moon. Try a different locomotion tool!";}
                    else if ([self.lastTool isEqualToString:RV_HOVERCRAFT_ATTACHMENT_POINTS]){self.currentMessage = @"The hovercraft won't work very well on the Moon. Try a different locomotion tool!";}
                } else
                    if (self.roverIsOverWeight){
                        if ([self.lastTool isEqualToString:RV_HGANTENNA_ATTACHMENT_POINTS] ||
                            [self.lastTool isEqualToString:RV_WHEELS_ATTACHMENT_POINTS] ||
                            [self.lastTool isEqualToString:RV_WEATHER_STATION_ATTACHMENT_POINTS]){
                            self.currentMessage = @"You need that tool, but your rover is over the 185kg weight limit! Better take something off.";
                            //OR, depending on how easy this would be: MAYBE IN FUTURE VERSIONS
                            //                        "You need that tool, but your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
                        }
                        else if ([self.lastTool isEqualToString:RV_PANCAM_ATTACHMENT_POINTS] ||
                                 [self.lastTool isEqualToString:RV_ROCK_GRINDER_ATTACHMENT_POINTS] ||
                                 [self.lastTool isEqualToString:RV_SPECTROMETER_ATTACHMENT_POINTS] ||
                                 [self.lastTool isEqualToString:RV_CHEMCAM_ATTACHMENT_POINTS] ||
                                 [self.lastTool isEqualToString:RV_MICROSCOPE_ATTACHMENT_POINTS] ||
                                 [self.lastTool isEqualToString:RV_LASER_DRILL_ATTACHMENT_POINTS] /*"tool is panCam, spectrometer, chemCam, rockGrinder, microscope, or laserDrill"*/){
                            self.currentMessage = @"It would be nice to have that tool, but your rover is over the 185kg weight limit!";
                            //OR
                            //                        "It would be nice to have that tool, but now your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
                        }
                        else if ([self.lastTool isEqualToString:RV_TREADS_ATTACHMENT_POINTS]){self.currentMessage = @"Those treads won't work very well on the Moon. Try a different locomotion tool!";}
                        else if ([self.lastTool isEqualToString:RV_HOVERCRAFT_ATTACHMENT_POINTS]){self.currentMessage = @"The hovercraft won't work very well on the Moon. Try a different locomotion tool!";}
                    }
            } else
            {//GENERAL
                if (self.roverIsFinished){
                    self.currentMessage = @"Those are all the tools your rover needs to complete its Moon mission! Ready to launch?";
                } else
                    if (!self.weatherStation &&
                        !self.wheels &&
                        !self.highGain){
                        self.currentMessage = @"Your rover still needs tools for communication, analysis, and locomotion.";
                        //                    "Your rover isn't ready for launch. What tools does it need?"
                    } else
                        if (!self.wheels){
                            self.currentMessage = @"Your rover still needs a locomotion tool.";
                            //                    "How will your rover move around on the rocky and dusty surface of the Moon?"
                        } else
                            if (!self.highGain){
                                self.currentMessage = @"Your rover still needs a communication tool.";
                                //                    "Make sure to include the tool that will allow you to send instructions to your rover!"
                            } else
                                if (!self.weatherStation){
                                    self.currentMessage = @"Your rover still needs an analysis tool.";
                                    //                    "What tool will let your rover to take the temperature on the Moon?"
                                } else
                                {
                                    NSString *mission1 = @"Remember, your mission is to take temperature readings from the dark side of the moon.";
                                    NSString *mission2 = @"The Moon is 240,000 miles from earth!";
                                    NSString *mission3 = @"Because there is no wind on the Moon, footprints and tracks last for years and years!";
                                    if ([self.currentMessage isEqualToString:mission1]) {
                                        self.currentMessage = mission2;
                                    } else if ([self.currentMessage isEqualToString:mission2]) {
                                        self.currentMessage = mission3;
                                    } else if ([self.currentMessage isEqualToString:mission3]) {
                                        self.currentMessage = mission1;
                                    } else {
                                        self.currentMessage = mission1;
                                    }
                                }
                self.isGeneralResponse = NO;
            }
    } else if ([self.planet isEqualToString:@"mars"])
    {//MARS
        if (self.isIntroduction &&
            !self.isGeneralResponse)
        {//AT SCREEN START
            //These should start displaying when the screen is loaded.
            //After each one types out, it should stay long enough to read (maybe 2 seconds?), and then the next one should start typing out.
            //The user can interrupt this at any time by clicking on a tool button or by selecting a tool.
            NSString *message1 = @"Hi, engineer! Jacob here, and I'm going to help you build your rover for your Moon mission!";
            NSString *message2 = @"Look through the tools, and drag the ones you need for your mission onto your rover body.";
            NSString *message3 = @"Tools only fit in certain places, so match up the shape of the tool base and rover port.";
            NSString *message4 = @"If your rover weighs more than 185kg, it will be too heavy to launch!";
            NSString *message5 = @"Ready to build? Let's get started!";
            if ([self.currentMessage isEqualToString:message1]) {
                self.currentMessage = message2;
            } else if ([self.currentMessage isEqualToString:message2]) {
                self.currentMessage = message3;
            } else if ([self.currentMessage isEqualToString:message3]) {
                self.currentMessage = message4;
            } else if ([self.currentMessage isEqualToString:message4]) {
                self.currentMessage = message5;
                //stop the introductions after displaying the last one
                self.isIntroduction = NO;
            } else if ([self.currentMessage isEqualToString:message5]) {
                self.currentMessage = message1;
            } else {
                self.currentMessage = message1;
            }
        } else if (!self.isGeneralResponse){//RESPONSIVE
            if (!self.roverIsOverWeight){
                //tool is necessary
                if ([self.lastTool isEqualToString:RV_HGANTENNA_ATTACHMENT_POINTS]){self.currentMessage = @"Great! Now you will be able to send instructions to your rover.";}
                else if ([self.lastTool isEqualToString:RV_WHEELS_ATTACHMENT_POINTS]){self.currentMessage = @"Excellent! Those wheels will work well on the rocky and dusty surface of Mars.";}
                else if ([self.lastTool isEqualToString:RV_TREADS_ATTACHMENT_POINTS]){self.currentMessage = @"Nice! Those treads will work well on the rocky and dusty surface of Mars.";}
                else if ([self.lastTool isEqualToString:RV_ROCK_GRINDER_ATTACHMENT_POINTS]){self.currentMessage = @"Good choice! With the rock grinder, your rover will be able to check for liquid water on Mars!";}
                else if ([self.lastTool isEqualToString:RV_CHEMCAM_ATTACHMENT_POINTS]){self.currentMessage = @"Wonderful! The ChemCam will let your rover detect tiny fossils of ancient life!";}
                else if ([self.lastTool isEqualToString:RV_MICROSCOPE_ATTACHMENT_POINTS]){self.currentMessage = @"Fantastic! The microscope will let your rover detect tiny fossils of ancient life!";}
                else if ([self.lastTool isEqualToString:RV_SPECTROMETER_ATTACHMENT_POINTS]){self.currentMessage = @"Sweet! The spectrometer will let your rover detect tiny fossils of ancient life!";}
                //tool is not necessary
                else if ([self.lastTool isEqualToString:RV_PANCAM_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_WEATHER_STATION_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_LASER_DRILL_ATTACHMENT_POINTS] /*"tool is panCam, weather station, or laserDrill"*/){
                    self.currentMessage = @"That tool doesn’t help with your primary mission, but bring it along if you want!";
                }
                else if ([self.lastTool isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS] &&
                         self.highGain){self.currentMessage = @"That tool doesn’t help with your primary mission, but bring it along if you want!";}
                else if ([self.lastTool isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS] &&
                         !self.highGain){self.currentMessage = @"That’s a backup tool. You still need the high gain antenna to send the rover instructions!";}
                else if ([self.lastTool isEqualToString:RV_HOVERCRAFT_ATTACHMENT_POINTS]){self.currentMessage = @"The hovercraft won't work very well on Mars. Try a different locomotion tool!";}
            }
            else if (self.roverIsOverWeight){
                //rover is overweight
                if ([self.lastTool isEqualToString:RV_HGANTENNA_ATTACHMENT_POINTS] ||
                    [self.lastTool isEqualToString:RV_WHEELS_ATTACHMENT_POINTS] ||
                    [self.lastTool isEqualToString:RV_TREADS_ATTACHMENT_POINTS] ||
                    [self.lastTool isEqualToString:RV_CHEMCAM_ATTACHMENT_POINTS] ||
                    [self.lastTool isEqualToString:RV_ROCK_GRINDER_ATTACHMENT_POINTS]){
                    self.currentMessage = @"You need that tool, but your rover is over the 185kg weight limit! Better take something off.";
                    //OR, depending on how easy this would be: MAYBE IN FUTURE VERSIONS
                    //                        "You need that tool, but your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
                }
                else if ([self.lastTool isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_PANCAM_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_WEATHER_STATION_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_LASER_DRILL_ATTACHMENT_POINTS] /*"tool is lowGain or panCam or weatherStation or laserDrill"*/){
                    self.currentMessage = @"It would be nice to have that tool, but your rover is over the 185kg weight limit!";
                    //OR
                    //                        "It would be nice to have that tool, but now your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
                }
                else if ([self.lastTool isEqualToString:RV_HOVERCRAFT_ATTACHMENT_POINTS]){self.currentMessage = @"The hovercraft won't work very well on Mars. Try a different locomotion tool!";}
            }
        } else
        {//GENERAL
            if (self.roverIsFinished){
                self.currentMessage = @"Those are all the tools your rover needs to complete its Mars mission! Ready to launch?";
            } else if (!self.highGain &&
                       (!self.wheels || !self.treads) &&
                       (!self.chemCam || !self.microscope || !self.spectrometer) &&
                       !self.rockGrinder){
                self.currentMessage = @"Your rover still needs tools for communication, analysis, and locomotion.";
                //                    "Your rover isn't ready for launch. What tools does it need?"
            } else if (!self.wheels || !self.treads){
                self.currentMessage = @"Your rover still needs a locomotion tool.";
                //                     "How will your rover move around on the dusty and rocky surface of Mars?"
            } else if (!self.highGain){
                self.currentMessage = @"Your rover still needs a communication tool.";
                //                    "Make sure to include the tool that will allow you to send instructions to your rover!"
            } else if (!self.rockGrinder){
                self.currentMessage = @"Your rover still needs an analysis tool.";
                //                     "How will your rover detect evidence of liquid water?"
            } else if (!self.chemCam || !self.microscope || self.spectrometer){
                self.currentMessage = @"Your rover still needs an analysis tool.";
                //                     "What does your rover need to look for tiny fossils?"
            } else
            {
                NSString *mission1 = @"Your mission: examine rocks for traces of liquid water and look for ancient fossils.";
                NSString *mission2 = @"It may be possible for humans to go to Mars within the next ten years!";
                NSString *mission3 = @"'The Martian Chronicles' by Ray Bradbury is one of my favorite science fiction books!";
                NSString *mission4 = @"It can take a radio message up to 20 minutes to travel from Mars back to Earth!";
                NSString *mission5 = @"Mars is about 200 million miles away from Earth!";
                if ([self.currentMessage isEqualToString:mission1]) {
                    self.currentMessage = mission2;
                } else if ([self.currentMessage isEqualToString:mission2]) {
                    self.currentMessage = mission3;
                } else if ([self.currentMessage isEqualToString:mission3]) {
                    self.currentMessage = mission4;
                } else if ([self.currentMessage isEqualToString:mission4]) {
                    self.currentMessage = mission5;
                } else if ([self.currentMessage isEqualToString:mission5]) {
                    self.currentMessage = mission1;
                } else {
                    self.currentMessage = mission1;
                }
            }
            self.isGeneralResponse = NO;
        }
    } else if ([self.planet isEqualToString:@"titan"])
    {//TITAN
        if (self.isIntroduction &&
            !self.isGeneralResponse)
        {//AT SCREEN START
            //These should start displaying when the screen is loaded.
            //After each one types out, it should stay long enough to read (maybe 2 seconds?), and then the next one should start typing out.
            //The user can interrupt this at any time by clicking on a tool button or by selecting a tool.
            NSString *message1 = @"Hi, engineer! Jacob here, and I'm going to help you build your rover for your Moon mission!";
            NSString *message2 = @"Look through the tools, and drag the ones you need for your mission onto your rover body.";
            NSString *message3 = @"Tools only fit in certain places, so match up the shape of the tool base and rover port.";
            NSString *message4 = @"If your rover weighs more than 185kg, it will be too heavy to launch!";
            NSString *message5 = @"Ready to build? Let's get started!";
            if ([self.currentMessage isEqualToString:message1]) {
                self.currentMessage = message2;
            } else if ([self.currentMessage isEqualToString:message2]) {
                self.currentMessage = message3;
            } else if ([self.currentMessage isEqualToString:message3]) {
                self.currentMessage = message4;
            } else if ([self.currentMessage isEqualToString:message4]) {
                self.currentMessage = message5;
                //stop the introductions after displaying the last one
                self.isIntroduction = NO;
            } else if ([self.currentMessage isEqualToString:message5]) {
                self.currentMessage = message1;
            } else {
                self.currentMessage = message1;
            }
        }
        else if (!self.isGeneralResponse){//RESPONSIVE
            if (!self.roverIsOverWeight){
                if ([self.lastTool isEqualToString:RV_HGANTENNA_ATTACHMENT_POINTS]){self.currentMessage = @"Great! Now you will be able to send instructions to your rover.";}
                else if ([self.lastTool isEqualToString:RV_HOVERCRAFT_ATTACHMENT_POINTS]){self.currentMessage = @"Excellent! The hovercraft will let your rover move around on Titan's icy surface.";}
                else if ([self.lastTool isEqualToString:RV_LASER_DRILL_ATTACHMENT_POINTS]){self.currentMessage = @"Awesome! This will allow your rover to drill through the thick ice on Titan.";}
                else if ([self.lastTool isEqualToString:RV_MICROSCOPE_ATTACHMENT_POINTS]){self.currentMessage = @"Nice! With the microscope, your rover might be able to detect evidence of life!";}
                else if ([self.lastTool isEqualToString:RV_ROCK_GRINDER_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_PANCAM_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_CHEMCAM_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_WEATHER_STATION_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_SPECTROMETER_ATTACHMENT_POINTS] /*"tool is rockGrinder, panCam, chemCam, weatherStation, or spectrometer"*/){
                    self.currentMessage = @"That tool doesn’t help with your primary mission, but bring it along if you want!";
                }
                else if ([self.lastTool isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS] &&
                         self.highGain){self.currentMessage = @"That tool doesn’t help with your primary mission, but bring it along if you want!";}
                else if ([self.lastTool isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS] &&
                         !self.highGain){self.currentMessage = @"That’s a backup tool. You still need the high gain antenna to send the rover instructions!";}
                else if ([self.lastTool isEqualToString:RV_WHEELS_ATTACHMENT_POINTS]){self.currentMessage = @"Wheels won't work very well on Titan's icy surface. Try a different locomotion tool!";}
                else if ([self.lastTool isEqualToString:RV_TREADS_ATTACHMENT_POINTS]){self.currentMessage = @"Treads won't work very well on Titan's icy surface. Try a different locomotion tool!";}
            }
            else if (self.roverIsOverWeight){
                if ([self.lastTool isEqualToString:RV_HGANTENNA_ATTACHMENT_POINTS] ||
                    [self.lastTool isEqualToString:RV_HOVERCRAFT_ATTACHMENT_POINTS] ||
                    [self.lastTool isEqualToString:RV_LASER_DRILL_ATTACHMENT_POINTS] ||
                    [self.lastTool isEqualToString:RV_MICROSCOPE_ATTACHMENT_POINTS]){ //highGain OR hovercraft OR laserDrill OR microscope
                    self.currentMessage = @"You need that tool, but your rover is over the 185kg weight limit! Better take something off.";
                    //OR, depending on how easy this would be: MAYBE IN FUTURE VERSIONS
                    //                        "You need that tool, but your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
                }
                else if ([self.lastTool isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_ROCK_GRINDER_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_PANCAM_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_CHEMCAM_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_WEATHER_STATION_ATTACHMENT_POINTS] ||
                         [self.lastTool isEqualToString:RV_SPECTROMETER_ATTACHMENT_POINTS] /*"tool is lowGain or rockGrinder or panCam or chemCam or weatherStation or spectrometer"*/){
                    self.currentMessage = @"It would be nice to have that tool, but your rover is over the 185kg weight limit!";
                    //OR
                    //                        "It would be nice to have that tool, but now your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
                }
                else if ([self.lastTool isEqualToString:RV_WHEELS_ATTACHMENT_POINTS]){self.currentMessage = @"Wheels won't work very well on Titan's icy surface. Try a different locomotion tool!";}
                else if ([self.lastTool isEqualToString:RV_TREADS_ATTACHMENT_POINTS]){self.currentMessage = @"Treads won't work very well on Titan's icy surface. Try a different locomotion tool!";}
            }
        } else
        {//GENERAL
            if (self.roverIsFinished){
                self.currentMessage = @"Those are all the tools your rover needs to complete its mission on Titan! Ready to launch?";
            }
            else if (!self.hovercraft &&
                     !self.laserDrill &&
                     !self.microscope &&
                     !self.highGain){
                self.currentMessage = @"Your rover still needs tools for communication, analysis, and locomotion.";
                //                    "Your rover isn't ready for launch. What tools does it need?"
            }
            else if (!self.hovercraft){
                self.currentMessage = @"Your rover still needs a locomotion tool.";
                //                    "How will your rover move around on the icy surface of Titan?"
            }
            else if (!self.highGain){
                self.currentMessage = @"Your rover still needs a communication tool.";
                //                    "Make sure to include the tool that will allow you to send instructions to your rover!"
            }
            else if (!self.laserDrill){
                self.currentMessage = @"Your rover still needs an analysis tool.";
                //                    "How will your rover get to the soil underneath the thick ice on Titan?"
            }
            else if (!self.microscope){
                self.currentMessage = @"Your rover still needs an analysis tool.";
                //                    "How can you analyze the soil under the ice for evidence of life?"
            }
            else
            {
                NSString *mission1 = @"Remember, your mission is to study the soil underneath the ice for evidence of life.";
                NSString *mission2 = @"It takes about 10 times longer to travel to Titan than to travel to the Sun!";
                NSString *mission3 = @"A year on Titan is almost 44 Earth-years long!";
                NSString *mission4 = @"Titan is so cold, water on its surface is as hard as rock.";
                if ([self.currentMessage isEqualToString:mission1]) {
                    self.currentMessage = mission2;
                } else if ([self.currentMessage isEqualToString:mission2]) {
                    self.currentMessage = mission3;
                } else if ([self.currentMessage isEqualToString:mission3]) {
                    self.currentMessage = mission4;
                } else if ([self.currentMessage isEqualToString:mission4]) {
                    self.currentMessage = mission1;
                } else {
                    self.currentMessage = mission1;
                }
            }
            self.isGeneralResponse = NO;
        }
    } else if ([self.planet isEqualToString:@"pluto"])
    {//PLUTO
        if (self.isIntroduction &&
            !self.isGeneralResponse)
        {//AT SCREEN START
            //These should start displaying when the screen is loaded.
            //After each one types out, it should stay long enough to read (maybe 2 seconds?), and then the next one should start typing out.
            //The user can interrupt this at any time by clicking on a tool button or by selecting a tool.
            NSString *message1 = @"Hi, engineer! Jacob here, and I'm going to help you build your rover for your Moon mission!";
            NSString *message2 = @"Look through the tools, and drag the ones you need for your mission onto your rover body.";
            NSString *message3 = @"Tools only fit in certain places, so match up the shape of the tool base and rover port.";
            NSString *message4 = @"If your rover weighs more than 185kg, it will be too heavy to launch!";
            NSString *message5 = @"Ready to build? Let's get started!";
            if ([self.currentMessage isEqualToString:message1]) {
                self.currentMessage = message2;
            } else if ([self.currentMessage isEqualToString:message2]) {
                self.currentMessage = message3;
            } else if ([self.currentMessage isEqualToString:message3]) {
                self.currentMessage = message4;
            } else if ([self.currentMessage isEqualToString:message4]) {
                self.currentMessage = message5;
                //stop the introductions after displaying the last one
                self.isIntroduction = NO;
            } else if ([self.currentMessage isEqualToString:message5]) {
                self.currentMessage = message1;
            } else {
                self.currentMessage = message1;
            }
        } else
            if (!self.isGeneralResponse){//RESPONSIVE
                if (!self.roverIsOverWeight){
                    if ([self.lastTool isEqualToString:RV_HGANTENNA_ATTACHMENT_POINTS]){self.currentMessage = @"Great! Now you will be able to send instructions to your rover.";}
                    else if ([self.lastTool isEqualToString:RV_TREADS_ATTACHMENT_POINTS]){self.currentMessage = @"Excellent! The treads will let your rover move around on Pluto's icy and rocky surface.";}
                    else if ([self.lastTool isEqualToString:RV_PANCAM_ATTACHMENT_POINTS]){self.currentMessage = @"Awesome! The PanCam will let your rover take pictures of Pluto's unexplored surface!";}
                    else if ([self.lastTool isEqualToString:RV_ROCK_GRINDER_ATTACHMENT_POINTS] ||
                             [self.lastTool isEqualToString:RV_CHEMCAM_ATTACHMENT_POINTS] ||
                             [self.lastTool isEqualToString:RV_WEATHER_STATION_ATTACHMENT_POINTS] ||
                             [self.lastTool isEqualToString:RV_SPECTROMETER_ATTACHMENT_POINTS] ||
                             [self.lastTool isEqualToString:RV_LASER_DRILL_ATTACHMENT_POINTS] /*"tool is rockGrinder, chemCam, weatherStation, spectrometer, or laserDrill"*/){
                        self.currentMessage = @"That tool doesn’t help with your primary mission, but bring it along if you want!";
                    }
                    else if ([self.lastTool isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS] &&
                             self.highGain){self.currentMessage = @"That tool doesn’t help with your primary mission, but bring it along if you want!";}
                    else if ([self.lastTool isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS] &&
                             !self.highGain){self.currentMessage = @"That’s a backup tool. You still need the high gain antenna to send the rover instructions!";}
                    else if ([self.lastTool isEqualToString:RV_WHEELS_ATTACHMENT_POINTS]){self.currentMessage = @"Wheels won't work very well on Pluto's surface. Try a different locomotion tool!";}
                    else if ([self.lastTool isEqualToString:RV_HOVERCRAFT_ATTACHMENT_POINTS]){self.currentMessage = @"The hovercraft won't work very well on Pluto. Try a different locomotion tool!";}
                } else
                    if (self.roverIsOverWeight){
                        if ([self.lastTool isEqualToString:RV_HGANTENNA_ATTACHMENT_POINTS] ||
                            [self.lastTool isEqualToString:RV_TREADS_ATTACHMENT_POINTS] ||
                            [self.lastTool isEqualToString:RV_PANCAM_ATTACHMENT_POINTS]){
                            self.currentMessage = @"You need that tool, but your rover is over the 185kg weight limit! Better take something off.";
                            //OR, depending on how easy this would be: MAYBE IN FUTURE VERSIONS
                            //                        "You need that tool, but your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
                        }
                        else if ([self.lastTool isEqualToString:RV_LGANTENNA_ATTACHMENT_POINTS] ||
                                 [self.lastTool isEqualToString:RV_ROCK_GRINDER_ATTACHMENT_POINTS] ||
                                 [self.lastTool isEqualToString:RV_PANCAM_ATTACHMENT_POINTS] ||
                                 [self.lastTool isEqualToString:RV_CHEMCAM_ATTACHMENT_POINTS] ||
                                 [self.lastTool isEqualToString:RV_WEATHER_STATION_ATTACHMENT_POINTS] ||
                                 [self.lastTool isEqualToString:RV_SPECTROMETER_ATTACHMENT_POINTS] ||
                                 [self.lastTool isEqualToString:RV_LASER_DRILL_ATTACHMENT_POINTS] /*"tool is lowGain or rockGrinder or panCam or chemCam or weatherStation or spectrometer or laserDrill"*/){
                            self.currentMessage = @"It would be nice to have that tool, but your rover is over the 185kg weight limit!";
                            //OR
                            //                        "It would be nice to have that tool, but now your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
                        }
                        else if ([self.lastTool isEqualToString:RV_WHEELS_ATTACHMENT_POINTS]){self.currentMessage = @"Wheels won't work very well on Pluto's surface. Try a different locomotion tool!";}
                        else if ([self.lastTool isEqualToString:RV_HOVERCRAFT_ATTACHMENT_POINTS]){self.currentMessage = @"The hovercraft won't work very well on Pluto. Try a different locomotion tool!";}
                    }
            } else if (self.roverIsFinished){
                self.currentMessage = @"Those are all the tools your rover needs to complete its mission on Pluto! Ready to launch?";
            } else if (!self.panCam &&
                       !self.treads &&
                       !self.highGain){
                self.currentMessage = @"Your rover still needs tools for communication, analysis, and locomotion.";
                //                    "Your rover isn't ready for launch. What tools does it need?"
            } else if (!self.treads){
                self.currentMessage = @"Your rover still needs a locomotion tool.";
                //                    "Pluto's surface is rocky and icy. What would be the best locomotion tool for that?"
            } else if (!self.highGain){
                self.currentMessage = @"Your rover still needs a communication tool.";
                //                    "Make sure to include the tool that will allow you to send instructions to your rover!"
            } else if (!self.panCam){
                self.currentMessage = @"Your rover still needs an analysis tool.";
                //                    "What can your rover use to take a picture of Pluto's surface?"
            } else
            {
                NSString *mission1 = @"Remember, your mission is to take a picture of Pluto’s surface!";
                NSString *mission2 = @"Pluto is about 3 BILLION miles away from Earth!";
                NSString *mission3 = @"Pluto has 5 moons that we know about. Two were discovered in the past 5 years!";
                NSString *mission4 = @"I have two dogs, and their names are Pluto and Rover. What a coincidence!";
                NSString *mission5 = @"Tools only fit in certain places, so match up the shape of the tool base and rover port.";
                if ([self.currentMessage isEqualToString:mission1]) {
                    self.currentMessage = mission2;
                } else if ([self.currentMessage isEqualToString:mission2]) {
                    self.currentMessage = mission3;
                } else if ([self.currentMessage isEqualToString:mission3]) {
                    self.currentMessage = mission4;
                } else if ([self.currentMessage isEqualToString:mission4]) {
                    self.currentMessage = mission5;
                } else if ([self.currentMessage isEqualToString:mission5]) {
                    self.currentMessage = mission1;
                } else {
                    self.currentMessage = mission1;
                }
            }
        self.isGeneralResponse = NO;
    }
}

@end