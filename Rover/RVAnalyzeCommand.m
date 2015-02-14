//
//  RVAnalyzeCommand.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVAnalyzeCommand.h"

@implementation RVAnalyzeCommand

-(NSString *)description
{
    return [self descriptionWithConstant:self.constant];
}

-(NSString*)descriptionWithConstant:(NSInteger) constant
{
    if ([self.roverToolType isEqualToString:RV_CHEMCAM_ATTACHMENT_POINTS]) {
        return @"Use ChemCam";
    } else if ([self.roverToolType isEqualToString:RV_ROCK_GRINDER_ATTACHMENT_POINTS]) {
        return @"Use rock grinder";
    } else if ([self.roverToolType isEqualToString:RV_PANCAM_ATTACHMENT_POINTS]) {
        return @"Use PanCam";
    } else if ([self.roverToolType isEqualToString:RV_LASER_DRILL_ATTACHMENT_POINTS] ||
               [self.roverToolType isEqualToString:RV_MICROSCOPE_ATTACHMENT_POINTS]) {
        return @"Use laser drill";
    } else if ([self.roverToolType isEqualToString:RV_WEATHER_STATION_ATTACHMENT_POINTS]) {
        return @"Take temperature reading";
    } else {
        return @"Use Rover analysis tool";
    }
}

-(NSInteger)lengthOfChange
{
    return 0;
}

-(NSString *)changedString
{
    return @"";
}

-(id)copy
{
    RVAnalyzeCommand *copy = [[RVAnalyzeCommand alloc] init];
    copy.constant = self.constant;
    copy.oldConstant = self.oldConstant;
    copy.roverToolType = self.roverToolType;
    return copy;
}


-(void)undoCommand:(RVCommand*)cmd
{
    self.constant -= cmd.constant;
}

@end
