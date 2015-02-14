//
//  RVCommandLineupController.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVCommandLineupViewTwo.h"

@protocol RVCommandLineupDelegate <NSObject>

-(BOOL)canCompleteCommands:(NSMutableArray*)commandLineup;
-(void)executeComands:(NSMutableArray*)commandLineup;
-(void)layOutPathForCommands:(NSMutableArray*)commandLineup;

@end

@interface RVCommandLineupController : NSObject

//all the commands return a BOOL that describes whether or not they can complete the action
-(BOOL)moveForward;
-(BOOL)turnRight;
-(BOOL)turnLeft;
-(BOOL)turnAround;
-(BOOL)action;
-(BOOL)analyze;
-(void)undo;
-(void)execute;

@property (nonatomic, weak) id<RVCommandLineupDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *commandLineup;
@property (nonatomic, weak) RVCommandLineupViewTwo *view;
@property (nonatomic, strong) NSString *roverToolType;

@end
