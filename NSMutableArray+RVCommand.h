//
//  NSMutableArray+RVCommand.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVCommand.h"

@interface NSMutableArray (RVCommand)

-(instancetype)commandLineupWithCommand:(RVCommand*)cmd;
-(RVCommand*)popCommand;
-(void)removeCommand:(RVCommand *)cmd;
-(void)removeAllRecentRotateBuffers;
-(BOOL)commandCausesRemoval:(RVCommand*)command;
-(NSInteger)countCommands;

@property (nonatomic, readonly) RVCommand *lastCommand;

@end
