//
//  RVRoverBuildLocomotionToolChest.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/8/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVRoverBuildLocomotionToolChest.h"
#import "Constants_Layout.h"
#import "Constants_Images.h"
#import "RVUtilities.h"
#import "Constants_Build_Graphics.h"

@implementation RVRoverBuildLocomotionToolChest

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
    self.scrollViewAnchorOffset = rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ANCHOR_SHADOWS).origin.x - rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_SCROLLBAR_VIEW).origin.x;
    CGRect shadowsRect = rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ANCHOR_SHADOWS);
    self.frame = CGRectMake(shadowsRect.origin.x - self.scrollViewAnchorOffset,
                            shadowsRect.origin.y,
                            shadowsRect.size.width,
                            shadowsRect.size.height);
    self.originalFrame = self.frame;
    //the shadows
    UIImageView *shadows = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_SHADOWS]];
    shadows.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ANCHOR_SHADOWS),
                                    rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ANCHOR_SHADOWS).origin);
    [self addSubview:shadows];
    
    //and then the three tools
    RVRoverBuildTool *wheels = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_WHEELS]];
    wheels.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ANCHOR_WHEELS),
                                   rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ANCHOR_SHADOWS).origin);
    wheels.toolType = RV_LOCOMOTION_TYPE_TOOL;
    wheels.chestAttachmentPoint = wheels.frame.origin;
    wheels.attachmentType = RV_WHEELS_ATTACHMENT_POINTS;
    wheels.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ATTACHMENT_POINT_WHEELS);
    
    RVRoverBuildTool *treads = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_TREADS]];
    treads.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ANCHOR_TREADS),
                                   rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ANCHOR_SHADOWS).origin);
    treads.toolType = RV_LOCOMOTION_TYPE_TOOL;
    treads.chestAttachmentPoint = treads.frame.origin;
    treads.attachmentType = RV_TREADS_ATTACHMENT_POINTS;
    treads.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ATTACHMENT_POINT_TREADS);
    
    RVRoverBuildTool *hovercraft = [[RVRoverBuildTool alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_HOVERCRAFT]];
    hovercraft.frame = frameFromOrigin(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ANCHOR_HOVERCRAFT),
                                       rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ANCHOR_SHADOWS).origin);
    hovercraft.toolType = RV_LOCOMOTION_TYPE_TOOL;
    hovercraft.chestAttachmentPoint = hovercraft.frame.origin;
    hovercraft.attachmentType = RV_HOVERCRAFT_ATTACHMENT_POINTS;
    hovercraft.attachmentPoint = pointHalf((CGPoint)RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ATTACHMENT_POINT_HOVERCRAFT);
    
    self.tools = [@[wheels, treads, hovercraft] mutableCopy];
    self.toolsThatFitHere = [self.tools copy];
    
    for (UIView *view in self.tools) {
        [self addSubview:view];
    }
}

@end
