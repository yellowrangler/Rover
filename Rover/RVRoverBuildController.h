//
//  RVRoverBuildController.h
//  Rover
//
//  Created by Sean Fitzgerald on 5/7/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVRoverBuildTool.h"
#import "RVAnimatedTextView.h"

@protocol RVRoverBuildControllerDelegate <NSObject>

-(void)communicationToolAttached;
-(void)analysisToolAttached;
-(void)locomotionToolAttached;

-(void)communicationToolUnattached;
-(void)analysisToolUnattached;
-(void)locomotionToolUnattached;

-(void)toolDisplaced:(RVRoverBuildTool*)tool;

-(void)roverFinished;
-(void)roverUnfinished;

@end

@interface RVRoverBuildController : NSObject

-(BOOL)snapTool:(RVRoverBuildTool*)tool;
-(RVRoverBuildTool*)toolForTouchLocation:(CGPoint)touch;
-(void)showMessage;
@property (nonatomic, weak) id<RVRoverBuildControllerDelegate>delegate;
@property (nonatomic, strong) NSString *planet;
@property (nonatomic, strong) RVAnimatedTextView *textView;
@property (nonatomic, strong) UITextView *weightTextView;
@property (nonatomic, strong) NSTimer *messageTimer;

@end
