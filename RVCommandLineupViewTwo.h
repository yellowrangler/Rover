//
//  RVCommandLineupViewTwo.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/21/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RVCommand.h"

@protocol RVCommandLineupViewTwoDelegate <NSObject>

-(void)finishedAnimatingCommands;

@end

@interface RVCommandLineupViewTwo : UITableView <UITableViewDelegate, UITableViewDataSource>

-(void)addCommand:(RVCommand*)cmd;

-(void)changeLastCommand:(RVCommand*)cmd;

-(void)undoCommand:(RVCommand*)cmd;

-(void)clearCommands;

-(void)undoAllRecentRotateCommands;

@property (nonatomic, weak) id<RVCommandLineupViewTwoDelegate> animationDelegate;
@property (nonatomic, readonly) BOOL animating;

@end
