//
//  RVIndiaGuindanceSystem.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/10/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVIndiaGuindanceSystem.h"

#define RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_0 (@"Before India's Introduction")
#define RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_1 (@"Before India's Introduction text 2")
#define RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_2 (@"Before India's Introduction text 3")
#define RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_3 (@"Before India's Introduction text 4")

@interface RVIndiaGuindanceSystem()

@property (nonatomic, strong) NSString *state;
@property (nonatomic, assign) NSInteger messageNumber;

@end

@implementation RVIndiaGuindanceSystem

-(id)init
{
    self = [super init];
    if (self) {
        self.state = RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_0;
    }
    return self;
}

-(void)nextMessage
{
    if (!self.selectedPlanet) {
        if ([self.state isEqualToString:RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_0]) {
            [self.delegate writeMessage:@"Hello, engineer! I'm India, and this is the destination selection screen!"];
            self.state = RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_1;
        } else if ([self.state isEqualToString:RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_1]) {
            [self.delegate writeMessage:@"From here you can choose where to send the rover you're going to build."];
            self.state = RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_2;
        } else if ([self.state isEqualToString:RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_2]) {
            [self.delegate writeMessage:@"Each place has a different mission for your rover to complete!"];
            self.state = RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_3;
        } else if ([self.state isEqualToString:RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_3]) {
            [self.delegate writeMessage:@"Ready to start? Touch a celestial body to see its mission!"];
            self.state = @"NO STATE"; //RV_INDIA_GUIDEANCE_STATE_INTRODUCTION_0;
        }
    } else {
        if ([self.selectedPlanet isEqualToString:@"moon"]) {
            if (self.messageNumber == 0) {
                [self.delegate writeMessage:@"Because of the dust on the moon, treads aren't a good choice for locomotion."];
            } else if (self.messageNumber == 1) {
                [self.delegate writeMessage:@"Hovercrafts need flat surfaces to work well, and the Moon doesn't have many of those."];
            } else if (self.messageNumber == 2) {
                [self.delegate writeMessage:@"The weather station tool allows your rover to take the temperature."];
            } else if (self.messageNumber == 3) {
                [self.delegate writeMessage:@"Your rover needs the high gain antenna in order to get the instructions you send."];
            } else if (self.messageNumber == 4) {
                [self.delegate writeMessage:@"Humans were last on the Moon in 1972. The last rover to go to the Moon landed in 2013!"];
            } else if (self.messageNumber == 5) {
                [self.delegate writeMessage:@"The moon spins as it rotates around the Earth, so we can't see the dark side!"];
                self.messageNumber = -1;
            }
        } else if ([self.selectedPlanet isEqualToString:@"mars"]) {
            if (self.messageNumber == 0) {
                [self.delegate writeMessage:@"Wheels or treads will work well for your rover on Mars."];
            } else if (self.messageNumber == 1) {
                [self.delegate writeMessage:@"Your rover needs the high gain antenna in order to get the instructions you send."];
            } else if (self.messageNumber == 2) {
                [self.delegate writeMessage:@"Whatever other analysis tools you choose, you will still need the rock grinder to get started."];
            } else if (self.messageNumber == 3) {
                [self.delegate writeMessage:@"The ChemCam might help you complete this mission."];
            } else if (self.messageNumber == 4) {
                [self.delegate writeMessage:@"The spectrometer and the rock grinder are a good tool pair for this mission." ];
            } else if (self.messageNumber == 5) {
                [self.delegate writeMessage:@"Your rover will need some sort of scope to detect tiny fossils." ];
            } else if (self.messageNumber == 5) {
                [self.delegate writeMessage:@"There have been four successful robotically operated Mars rovers. Let's make it five!"];
                self.messageNumber = -1;
            }
        } else if ([self.selectedPlanet isEqualToString:@"titan"]) {
            if (self.messageNumber == 0) {
                [self.delegate writeMessage:@"There is liquid and ice on Titan's surface, so don't try putting wheels on your rover!"];
            } else if (self.messageNumber == 1) {
                [self.delegate writeMessage:@"Your rover needs the high gain antenna in order to get the instructions you send."];
            } else if (self.messageNumber == 2) {
                [self.delegate writeMessage:@"Your rover will need some sort of laser to drill through the ice on the surface."];
            } else if (self.messageNumber == 3) {
                [self.delegate writeMessage:@"To study the soil, you'll need something that magnifies microscopic particles."];
            } else if (self.messageNumber == 4) {
                [self.delegate writeMessage:@"From Titan, Earth looks like a tiny blue dot."];
            } else if (self.messageNumber == 5) {
                [self.delegate writeMessage:@"A spacecraft landed on Titan in 2005 and sent back pictures!"];
                self.messageNumber = -1;
            }
        } else if ([self.selectedPlanet isEqualToString:@"pluto"]) {
            if (self.messageNumber == 0) {
                [self.delegate writeMessage:@"The landscape on Pluto will be tricky to navigate. Wheels wouldn't work at all!"];
            } else if (self.messageNumber == 1) {
                [self.delegate writeMessage:@"Your rover needs the high gain antenna in order to get the instructions you send."];
            } else if (self.messageNumber == 2) {
                [self.delegate writeMessage:@"Only one analysis tool can take pictures, but how many other tools can you fit?"];
            } else if (self.messageNumber == 3) {
                [self.delegate writeMessage:@"No human spacecraft has ever been on Pluto ... yet!"];
            } else if (self.messageNumber == 4) {
                [self.delegate writeMessage:@"Pluto is smaller than the Moon, but we know much less about it!"];
                self.messageNumber = -1;
            }
        }
        self.messageNumber++;
    }
}

-(void)setSelectedPlanet:(NSString *)selectedPlanet
{
    self.messageNumber = 0;
    _selectedPlanet = selectedPlanet;
}

@end
