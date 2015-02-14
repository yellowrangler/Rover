//
//  RVRoverBuildTool.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/7/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVRoverBuildTool.h"
#import "RVRoverBuildToolChest.h"
#import "Constants_Layout.h"
#import "Constants_UIUX.h"
#import "RVUtilities.h"

@interface RVRoverBuildTool ()

@end

@implementation RVRoverBuildTool

-(void)animateToPoint:(CGPoint)point
{
    [UIView animateWithDuration:RV_UIUX_ROVER_BUILD_SCREEN_ANIMATE_SNAP_TIME
                     animations:^(void){
                         self.frame = CGRectMake(point.x,
                                                 point.y,
                                                 self.frame.size.width,
                                                 self.frame.size.height);
                     }];
}

-(void)animateToAttachmentPoint:(CGPoint)point
{
    [self animateToPoint:CGPointMake(point.x - self.attachmentPoint.x,
                                     point.y - self.attachmentPoint.y)];
}

-(void)animateToCenterPoint:(CGPoint)point andThenPoint:(CGPoint)point2 onView:(RVRoverBuildToolChest*)view
{
    [UIView animateWithDuration:RV_UIUX_ROVER_BUILD_SCREEN_ANIMATE_SNAP_TIME
                     animations:^(void){
                         self.center = point;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         CGPoint originDifference = pointFromOrigin(CGPointZero, view.frame.origin);
                         self.center = CGPointMake(self.center.x + originDifference.x,
                                                   self.center.y + originDifference.y);
                         [view addSubview:self];
                         [UIView animateWithDuration:RV_UIUX_ROVER_BUILD_SCREEN_ANIMATE_SNAP_TIME
                                          animations:^(void){
                                              self.frame = CGRectMake(point2.x,
                                                                      point2.y,
                                                                      self.frame.size.width,
                                                                      self.frame.size.height);
                                          } completion:^(BOOL finished){
                                              [view.tools addObject:self];
                                          }];
//                         [self animateToPoint:point2];
                     }];
}


@end
