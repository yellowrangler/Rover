//
//  RVRoverBuildCommunicationToolChest.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/8/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVRoverBuildCommunicationToolChest.h"
#import "Constants_Layout.h"
#import "Constants_Images.h"
#import "RVUtilities.h"
#import "Constants_Build_Graphics.h"

@implementation RVRoverBuildCommunicationToolChest

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
    self.scrollViewAnchorOffset = rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ANCHOR_SHADOWS).origin.x - rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_SCROLLBAR_VIEW).origin.x;
    CGRect shadowsRect = rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ANCHOR_SHADOWS);
    self.frame = CGRectMake(shadowsRect.origin.x - self.scrollViewAnchorOffset,
                            shadowsRect.origin.y,
                            shadowsRect.size.width,
                            shadowsRect.size.height);
    self.originalFrame = self.frame;
    //the shadows
    UIImageView *shadows = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_SHADOWS]];
    shadows.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ANCHOR_SHADOWS),
                                    rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ANCHOR_SHADOWS).origin);
    [self addSubview:shadows];
    
    //and then the three tools
    RVRoverBuildTool *hgAntenna = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_HGANTENNA]];
    hgAntenna.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ANCHOR_HGANTENNA),
                                      rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ANCHOR_SHADOWS).origin);
    hgAntenna.toolType = RV_COMMUNICATION_TYPE_TOOL;
    hgAntenna.chestAttachmentPoint = hgAntenna.frame.origin;
    hgAntenna.attachmentType = RV_HGANTENNA_ATTACHMENT_POINTS;
    hgAntenna.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ATTACHMENT_POINT_HGANTENNA);

    RVRoverBuildTool *lgAntenna = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_LGANTENNA]];
    lgAntenna.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ANCHOR_LGANTENNA),
                                   rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ANCHOR_SHADOWS).origin);
    lgAntenna.toolType = RV_COMMUNICATION_TYPE_TOOL;
    lgAntenna.chestAttachmentPoint = lgAntenna.frame.origin;
    lgAntenna.attachmentType = RV_LGANTENNA_ATTACHMENT_POINTS;
    lgAntenna.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ATTACHMENT_POINT_LGANTENNA);
    
    self.tools = [@[hgAntenna, lgAntenna] mutableCopy];
    self.toolsThatFitHere = [self.tools copy];
    
    for (UIView *view in self.tools) {
        [self addSubview:view];
    }
}

@end
