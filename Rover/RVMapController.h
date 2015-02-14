//
//  RVMapController.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVAnimatedTextView.h"
#import "RVCommandLineupController.h"
#import "RVMapView.h"

@protocol RVMapControllerAnimationDelegate <NSObject>

-(void)roverFinishedMoving:(NSInteger)numberOfSteps;
-(void)roverTookOneStep;
-(void)updateCompassRoseAngle:(double)angle;

@end

@protocol RVMapControllerRoverDelegate <NSObject>

-(void)roverFinishedObjectiveNumber:(NSInteger)objectiveNumber;

@end

@interface RVMapController : RVAnimatedTextView<RVCommandLineupDelegate,RVMapViewAnimationDelegate>

@property (nonatomic, strong) RVMapView *view;
@property (nonatomic, strong) NSString *mapName;
@property (nonatomic, strong) NSString *roverName;
@property (nonatomic, assign) NSInteger objectiveNumber;
@property (nonatomic, assign) BOOL canDriveOnWater;
@property (nonatomic, assign) id<RVMapControllerAnimationDelegate> roverAnimationDelegate;
@property (nonatomic, assign) id<RVMapControllerRoverDelegate> roverDelegate;

@end
