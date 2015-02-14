//
//  RVCommandLineupView.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVAnimatedTextView.h"
#import "RVCommand.h"

@protocol RVCommandLineupViewDelegate <NSObject>

-(void)finishedTyping;

@end

@interface RVCommandLineupView : UITableView

-(void)addCommand:(RVCommand*)cmd;

-(void)changeLastCommand:(RVCommand*)cmd;

-(void)undoCommand:(RVCommand*)cmd;

-(void)clearCommands;

-(void)undoAllRecentRotateCommands;

@property (nonatomic, weak) id<RVCommandLineupViewDelegate> animationDelegate;
@property (nonatomic, readonly) BOOL typing;

@end