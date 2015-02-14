//
//  RVRoverBuildToolChest.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/7/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVRoverBuildToolChest.h"
#import "RVUtilities.h"
#import "Constants_Layout.h"

@interface RVRoverBuildToolChest ()

@property (nonatomic, assign) CGPoint toolChestWindowCenter;

@property (nonatomic, strong) NSMutableDictionary *attachmentPoints;


@end

@implementation RVRoverBuildToolChest

-(RVRoverBuildTool*)toolForTouchLocation:(CGPoint)touch
{
    RVRoverBuildTool *tappedTool = nil;
    for (RVRoverBuildTool *tool in self.tools) {
        if (CGRectContainsPoint(tool.frame, touch)) {
            [self.tools removeObject:tool];
            tappedTool = tool;
            break;
        }
    }
    return tappedTool;
}

-(void)storeTool:(RVRoverBuildTool*)tool
{
    if ([self.toolsThatFitHere containsObject:tool]) {
        //check if the tool can attach to any of the points.
        [tool animateToCenterPoint:self.toolChestWindowCenter
                      andThenPoint:tool.chestAttachmentPoint
                            onView:self];
//        [self.tools addObject:tool];
    }
}

-(CGPoint)toolChestWindowCenter
{
    return CGPointMake(CGRectGetMidX(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TOOL_WINDOW_VIEW)),
                       CGRectGetMidY(rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TOOL_WINDOW_VIEW)));
}

@end
