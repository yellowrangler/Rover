//
//  RVMapView.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RVMapLocation.h"
#import "Constants_Layout.h"
#import "Constants_UIUX.h"

@protocol RVMapViewAnimationDelegate <NSObject>

-(void)roverFinishedMoving;
-(void)roverTookOneStep;
-(void)updateCompassRoseAngle:(double)angle;

@end

@interface RVMapView : UIScrollView

@property (nonatomic, strong) NSString *mapName;
@property (nonatomic, strong) UIImage *mapImage;
@property (nonatomic, strong) UIImage *roverImage;
@property (nonatomic, strong) RVMapLocation *roverStartPosition;
@property (nonatomic, readonly) RVMapLocation *roverPosition;
@property (nonatomic, weak) id<RVMapViewAnimationDelegate> animationDelegate;

@property (nonatomic, strong) NSURL *toolAudioURL;
@property (nonatomic, strong) NSURL *transportStartAudioURL;
@property (nonatomic, strong) NSURL *transportStopAudioURL;
@property (nonatomic, strong) NSURL *transportLoopAudioURL;

@property (nonatomic, strong) UIImageView *mapImageView;
@property (nonatomic, strong) UIImageView *roverImageView;

-(void)modifiedScrollRectToViewableWithoutAnimation;
-(void)calibrateCompass;
-(void)roverMoveForward;
-(void)roverRotateRight;
-(void)roverRotateLeft;
-(void)roverTurnAround;
-(void)roverUseTool;
-(void)roverAnalyze;

-(void)resetRover;

-(void)pathMoveForward:(BOOL)final;
-(void)pathRotateRight:(BOOL)final;
-(void)pathRotateLeft:(BOOL)final;
-(void)pathTurnAround:(BOOL)final;
-(void)pathUseTool;
-(void)pathAnalyze;
-(void)setPath;

-(void)resetPath;

-(void)addObjective:(RVMapLocation*)location;
-(void)addObjectiveCommand:(RVMapLocation*)location;
-(void)removeObjective;
-(void)showRocks:(NSArray*)rocks;

@end
