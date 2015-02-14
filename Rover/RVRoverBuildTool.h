//
//  RVRoverBuildTool.h
//  Rover
//
//  Created by Sean Fitzgerald on 5/7/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RVRoverBuildTool : UIImageView

@property (nonatomic, strong) NSString * toolType;
@property (nonatomic, assign) CGPoint attachmentPoint;
@property (nonatomic, strong) NSString * attachmentType;
@property (nonatomic, assign) CGPoint chestAttachmentPoint;

-(void)animateToPoint:(CGPoint)point;
-(void)animateToAttachmentPoint:(CGPoint)point;
-(void)animateToCenterPoint:(CGPoint)point andThenPoint:(CGPoint)point2 onView:(UIView*)view;

@end
