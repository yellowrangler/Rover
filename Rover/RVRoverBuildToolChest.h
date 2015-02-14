//
//  RVRoverBuildToolChest.h
//  Rover
//
//  Created by Sean Fitzgerald on 5/7/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RVRoverBuildTool.h"

@interface RVRoverBuildToolChest : UIView

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, strong) NSMutableArray *tools;
@property (nonatomic, strong) NSMutableArray *toolsThatFitHere;
@property (nonatomic, assign) CGFloat scrollViewAnchorOffset;

-(RVRoverBuildTool*)toolForTouchLocation:(CGPoint)touch;
-(void)storeTool:(RVRoverBuildTool*)tool;

@end
