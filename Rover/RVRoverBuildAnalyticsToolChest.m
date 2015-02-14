//
//  RVRoverBuildAnalyticsToolChest.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/8/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVRoverBuildAnalyticsToolChest.h"
#import "Constants_Layout.h"
#import "Constants_Images.h"
#import "RVUtilities.h"
#import "Constants_Build_Graphics.h"

@implementation RVRoverBuildAnalyticsToolChest

//initialization methods
-(id)init
{
    self = [super init];
    if (self) {
        [self customInitialization];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInitialization];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInitialization];
    }
    return self;
}

//helper methods
-(void)customInitialization
{
    self.scrollViewAnchorOffset = rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SHADOWS).origin.x - rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_SCROLLBAR_VIEW).origin.x;
    CGRect shadowsRect = rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SHADOWS);
    self.frame = CGRectMake(shadowsRect.origin.x - self.scrollViewAnchorOffset,
                            shadowsRect.origin.y,
                            shadowsRect.size.width,
                            shadowsRect.size.height);
    self.originalFrame = self.frame;
    //the shadows
    UIImageView *shadows = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_SHADOWS]];
    shadows.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SHADOWS),
                                    rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SHADOWS).origin);
    [self addSubview:shadows];
    
    //and then the six tools
        // chemcam
        // laser drill
        // microscope
        // rock grinder
        // spectrometer
        // weather station

    RVRoverBuildTool *chemcam = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_CHEMCAM]];
    chemcam.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_CHEMCAM),
                                    rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SHADOWS).origin);
    chemcam.toolType = RV_ANALYSIS_TYPE_TOOL;
    chemcam.chestAttachmentPoint = chemcam.frame.origin;
    chemcam.attachmentType = RV_CHEMCAM_ATTACHMENT_POINTS;
    chemcam.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ATTACHMENT_POINT_CHEMCAM);
    
    RVRoverBuildTool *laserDrill = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_LASER_DRILL]];
    laserDrill.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_LASER_DRILL),
                                    rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SHADOWS).origin);
    laserDrill.toolType = RV_ANALYSIS_TYPE_TOOL;
    laserDrill.chestAttachmentPoint = laserDrill.frame.origin;
    laserDrill.attachmentType = RV_LASER_DRILL_ATTACHMENT_POINTS;
    laserDrill.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ATTACHMENT_POINT_LASER_DRILL);
    
    RVRoverBuildTool *microscope = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_MICROSCOPE]];
    microscope.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_MICROSCOPE),
                                    rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SHADOWS).origin);
    microscope.toolType = RV_ANALYSIS_TYPE_TOOL;
    microscope.chestAttachmentPoint = microscope.frame.origin;
    microscope.attachmentType = RV_MICROSCOPE_ATTACHMENT_POINTS;
    microscope.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ATTACHMENT_POINT_MICROSCOPE);
    
    RVRoverBuildTool *rockGrinder = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ROCK_GRINDER]];
    rockGrinder.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_ROCK_GRINDER),
                                        rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SHADOWS).origin);
    rockGrinder.toolType = RV_ANALYSIS_TYPE_TOOL;
    rockGrinder.chestAttachmentPoint = rockGrinder.frame.origin;
    rockGrinder.attachmentType = RV_ROCK_GRINDER_ATTACHMENT_POINTS;
    rockGrinder.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ATTACHMENT_POINT_ROCK_GRINDER);
    
    RVRoverBuildTool *spectrometer = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_SPECTROMETER]];
    spectrometer.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SPECTROMETER),
                                        rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SHADOWS).origin);
    spectrometer.toolType = RV_ANALYSIS_TYPE_TOOL;
    spectrometer.chestAttachmentPoint = spectrometer.frame.origin;
    spectrometer.attachmentType = RV_SPECTROMETER_ATTACHMENT_POINTS;
    spectrometer.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ATTACHMENT_POINT_SPECTROMETER);
    
    RVRoverBuildTool *weatherStation = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_WEATHER_STATION]];
    weatherStation.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_WEATHER_STATION),
                                        rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SHADOWS).origin);
    weatherStation.toolType = RV_ANALYSIS_TYPE_TOOL;
    weatherStation.chestAttachmentPoint = weatherStation.frame.origin;
    weatherStation.attachmentType = RV_WEATHER_STATION_ATTACHMENT_POINTS;
    weatherStation.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ATTACHMENT_POINT_WEATHER_STATION);
    
    RVRoverBuildTool *pancam = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_PANCAM]];
    pancam.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ANCHOR_PANCAM),
                                   rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ANCHOR_SHADOWS).origin);
    pancam.toolType = RV_ANALYSIS_TYPE_TOOL;
    pancam.chestAttachmentPoint = pancam.frame.origin;
    pancam.attachmentType = RV_PANCAM_ATTACHMENT_POINTS;
    pancam.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ATTACHMENT_POINT_PANCAM);
    
    self.tools = [@[chemcam, laserDrill, microscope, rockGrinder, spectrometer, weatherStation, pancam] mutableCopy];
    self.toolsThatFitHere = [self.tools copy];
    
    for (UIView *view in self.tools) {
        [self addSubview:view];
    }
}


@end
