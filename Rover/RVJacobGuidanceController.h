//
//  RVJacobGuidanceController.h
//  Rover
//
//  Created by Sean Fitzgerald on 5/10/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVRoverBuildToolChest.h"
#import "RVRoverBuildController.h"
#import "RVRoverBuildTool.h"

@protocol RVJacobGuidanceDelegate

-(void)writeMessage:(NSString*)message;

@end

@interface RVJacobGuidanceController : NSObject

@property (nonatomic, weak) id<RVJacobGuidanceDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger currentWeight;
@property (nonatomic, strong) NSString * planet;
@property (nonatomic, strong) RVRoverBuildController* buildController;

@property (nonatomic, assign, readonly) BOOL locomotionSystemCompleted;
@property (nonatomic, assign, readonly) BOOL analysisSystemCompleted;
@property (nonatomic, assign, readonly) BOOL communicationSystemCompleted;
@property (nonatomic, assign) BOOL isIntroduction;
@property (nonatomic, assign, readonly) BOOL roverIsFinished;

-(void)nextMessage;
-(void)nextGeneralMessage;

-(void)newTool:(RVRoverBuildTool *)tool;
-(void)removeTool:(RVRoverBuildTool *)tool;

@end
