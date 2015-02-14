//
//  NSMutableArray+RVCommand.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "NSMutableArray+RVCommand.h"
#import "RVMoveCommand.h"
#import "RVRotateCommand.h"
#import "RVActionCommand.h"
#import "RVAnalyzeCommand.h"

@implementation NSMutableArray (RVCommand)

-(RVCommand*)lastCommand
{
    return self.lastObject;
}

-(instancetype)commandLineupWithCommand:(RVCommand*)cmd
{
    NSMutableArray * lineup = [self mutableCopy];
    [lineup addObject:cmd];
    return lineup;
}

-(RVCommand*)popCommand
{
    RVCommand *returnCommand = self.lastCommand;
    [self removeLastObject];
    return returnCommand;
}

-(void)removeCommand:(RVCommand *)cmd
{
    RVCommand *topCmd = (RVCommand*)self.lastCommand;
    if (topCmd.constant == cmd.constant) {
        [self removeLastObject];
    } else {
        [topCmd undoCommand:cmd];
    }
}

-(BOOL)commandCausesRemoval:(RVCommand*)command
{
    RVCommand *topCmd = (RVCommand*)self.lastCommand;
    if (topCmd.constant == command.constant) {
        return YES;
    } else {
        return NO;
    }
}

-(void)removeAllRecentRotateBuffers
{
    for (int i = self.count - 1; i >= 0; i--) {
        if ([self[i] isKindOfClass:[RVRotateCommand class]]) {
            [self removeLastObject];
        } else {
            break;
        }
    }
}

-(NSInteger)countCommands
{
    NSInteger commandCount = 0;
    for (RVCommand *command in self) {
        if ([command isKindOfClass:[RVRotateCommand class]]) {
            commandCount++;
        } else if([command isKindOfClass:[RVMoveCommand class]]) {
            commandCount += command.constant;
        } else {
            commandCount++;
        }
    }
    return commandCount;
}

@end
