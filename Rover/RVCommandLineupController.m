//
//  RVCommandLineupController.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVCommandLineupController.h"
#import "RVRotateCommand.h"
#import "RVActionCommand.h"
#import "RVMoveCommand.h"
#import "RVAnalyzeCommand.h"
#import "NSMutableArray+RVCommand.h"
#import "RVAudioReference.h"
@import AVFoundation;

@interface RVCommandLineupController ()<RVCommandLineupViewTwoDelegate>

@property (nonatomic, assign) BOOL futureExecute;
@property (nonatomic, strong) NSMutableArray *commandLineupBackBuffer;

@property (nonatomic, strong) AVAudioPlayer * errorAudioPlayer;

@end

@implementation RVCommandLineupController

-(id)init
{
    self = [super init];
    if (self) {
        self.errorAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference error] error:nil];
        [self.errorAudioPlayer prepareToPlay];
    }
    return self; 
}

//all the commands return a BOOL that describes whether or not they can complete the action
-(BOOL)moveForward;
{
    if ([self.delegate canCompleteCommands:[self.commandLineup commandLineupWithCommand:[[RVMoveCommand alloc] init]]]) {
        [self.commandLineupBackBuffer addObject:[[RVMoveCommand alloc] init]];
        if ([self.commandLineup.lastCommand isKindOfClass:[RVMoveCommand class]]) {
            [self.commandLineup.lastCommand incrementConstant];
            [self.view changeLastCommand:self.commandLineup.lastCommand];
        } else {
            RVMoveCommand *cmd = [[RVMoveCommand alloc] init];
            [self.commandLineup addObject:cmd];
            [self.view addCommand:self.commandLineup.lastCommand];
        }
        [self.delegate layOutPathForCommands:self.commandLineup];
        return YES;
    } else {
        [self.errorAudioPlayer setCurrentTime:0.0];
        [self.errorAudioPlayer play];
    }
    return NO;
}

-(BOOL)turnRight
{
    if ([self.delegate canCompleteCommands:[self.commandLineup commandLineupWithCommand:[[RVRotateCommand alloc] initRight]]]) {
        if ([self.commandLineup.lastCommand isKindOfClass:[RVRotateCommand class]]) {
            [self.commandLineup.lastCommand decrementConstant];
            if (self.commandLineup.lastCommand.constant == 0) {
                [self.commandLineup.lastCommand incrementConstant];
                [self.view undoCommand:self.commandLineup.lastCommand];
                [self.view undoAllRecentRotateCommands];
                [self.commandLineupBackBuffer removeAllRecentRotateBuffers];
                [self.commandLineup removeCommand:self.commandLineup.lastCommand];
            } else {
                [self.commandLineupBackBuffer addObject:[[RVRotateCommand alloc] initRight]];
                [self.view changeLastCommand:self.commandLineup.lastCommand];
            }
        } else {
            [self.commandLineupBackBuffer addObject:[[RVRotateCommand alloc] initRight]];
            RVRotateCommand *cmd = [[RVRotateCommand alloc] initRight];
            [self.commandLineup addObject:cmd];
            [self.view addCommand:self.commandLineup.lastCommand];
        }
        [self.delegate layOutPathForCommands:self.commandLineup];
        return YES;
    } else {
        [self.errorAudioPlayer setCurrentTime:0.0];
        [self.errorAudioPlayer play];
    }
    return NO;
}

-(BOOL)turnLeft
{
    if ([self.delegate canCompleteCommands:[self.commandLineup commandLineupWithCommand:[[RVRotateCommand alloc] initLeft]]]) {
        if ([self.commandLineup.lastCommand isKindOfClass:[RVRotateCommand class]]) {
            [self.commandLineup.lastCommand incrementConstant];
            if (self.commandLineup.lastCommand.constant == 0) {
                [self.commandLineup.lastCommand decrementConstant];
                [self.view undoCommand:self.commandLineup.lastCommand];
                [self.view undoAllRecentRotateCommands];
                [self.commandLineupBackBuffer removeAllRecentRotateBuffers];
                [self.commandLineup removeCommand:self.commandLineup.lastCommand];
            } else {
                [self.commandLineupBackBuffer addObject:[[RVRotateCommand alloc] initLeft]];
                [self.view changeLastCommand:self.commandLineup.lastCommand];
            }
        } else {
            [self.commandLineupBackBuffer addObject:[[RVRotateCommand alloc] initLeft]];
            RVRotateCommand *cmd = [[RVRotateCommand alloc] initLeft];
            [self.commandLineup addObject:cmd];
            [self.view addCommand:self.commandLineup.lastCommand];
        }
        [self.delegate layOutPathForCommands:self.commandLineup];
        return YES;
    } else {
        [self.errorAudioPlayer setCurrentTime:0.0];
        [self.errorAudioPlayer play];
    }
    return NO;
}

-(BOOL)turnAround
{
    if ([self.delegate canCompleteCommands:[self.commandLineup commandLineupWithCommand:[[RVRotateCommand alloc] initReverse]]]) {
        if ([self.commandLineup.lastCommand isKindOfClass:[RVRotateCommand class]]) {
            self.commandLineup.lastCommand.constant -= 180;
            if (self.commandLineup.lastCommand.constant == 0) {
                self.commandLineup.lastCommand.constant += 180;
                [self.view undoCommand:self.commandLineup.lastCommand];
                [self.view undoAllRecentRotateCommands];
                [self.commandLineupBackBuffer removeAllRecentRotateBuffers];
                [self.commandLineup removeCommand:self.commandLineup.lastCommand];
            } else {
                [self.commandLineupBackBuffer addObject:[[RVRotateCommand alloc] initReverse]];
                [self.view changeLastCommand:self.commandLineup.lastCommand];
            }
        } else {
            [self.commandLineupBackBuffer addObject:[[RVRotateCommand alloc] initReverse]];
            RVRotateCommand *cmd = [[RVRotateCommand alloc] initReverse];
            [self.commandLineup addObject:cmd];
            [self.view addCommand:self.commandLineup.lastCommand];
        }
        [self.delegate layOutPathForCommands:self.commandLineup];
        return YES;
    } else {
        [self.errorAudioPlayer setCurrentTime:0.0];
        [self.errorAudioPlayer play];
    }
    return NO;
}

-(BOOL)action;
{
    if ([self.delegate canCompleteCommands:[self.commandLineup commandLineupWithCommand:[[RVActionCommand alloc] init]]]) {
        [self.commandLineupBackBuffer addObject:[[RVActionCommand alloc] init]];
        if ([self.commandLineup.lastCommand isKindOfClass:[RVActionCommand class]]) {
            //don't do anything. it's not something you can do multiple times
        } else {
            RVActionCommand *cmd = [[RVActionCommand alloc] init];
            [self.commandLineup addObject:cmd];
            [self.view addCommand:self.commandLineup.lastCommand];
        }
        [self.delegate layOutPathForCommands:self.commandLineup];
        return YES;
    } else {
        [self.errorAudioPlayer setCurrentTime:0.0];
        [self.errorAudioPlayer play];
    }
    return NO;
}

-(BOOL)analyze;
{
    if ([self.delegate canCompleteCommands:[self.commandLineup commandLineupWithCommand:[[RVAnalyzeCommand alloc] init]]]) {
        RVAnalyzeCommand *cmd = [[RVAnalyzeCommand alloc] init];
        cmd.roverToolType = self.roverToolType;
        [self.commandLineupBackBuffer addObject:cmd];
        if ([self.commandLineup.lastCommand isKindOfClass:[RVAnalyzeCommand class]]) {
            //don't do anything. it's not something you can do multiple times
        } else {
            RVAnalyzeCommand *cmd = [[RVAnalyzeCommand alloc] init];
            cmd.roverToolType = self.roverToolType;
            [self.commandLineup addObject:cmd];
            [self.view addCommand:self.commandLineup.lastCommand];
        }
        [self.delegate layOutPathForCommands:self.commandLineup];
        return YES;
    } else {
        [self.errorAudioPlayer setCurrentTime:0.0];
        [self.errorAudioPlayer play];
    }
    return NO;
}

-(void)undo
{
    if (self.commandLineup.count != 0 &&
        !self.futureExecute) {
        RVCommand *cmd = [self.commandLineupBackBuffer popCommand];
        [self.commandLineup removeCommand:cmd];
        [self.view undoCommand:cmd];
        [self.delegate layOutPathForCommands:self.commandLineup];
    }
}

-(void)execute
{
    if (self.view.animating) {
        self.futureExecute = YES;
    } else {
        [self.delegate executeComands:self.commandLineup];
        [self.commandLineup removeAllObjects];
        [self.view clearCommands];
    }
}

-(NSMutableArray *)commandLineup
{
    if (!_commandLineup) {
        _commandLineup = [[NSMutableArray alloc] init];
    }
    return _commandLineup;
}

-(void)setView:(RVCommandLineupViewTwo *)view
{
    view.animationDelegate = self;
    _view = view;
}

-(void)finishedAnimatingCommands
{
    if (self.futureExecute) {
        self.futureExecute = NO;
        [self.delegate executeComands:self.commandLineup];
        [self.commandLineup removeAllObjects];
        [self.view clearCommands];
    }
}

-(NSMutableArray *)commandLineupBackBuffer
{
    if (!_commandLineupBackBuffer) {
        _commandLineupBackBuffer = [[NSMutableArray alloc] init];
    }
    return _commandLineupBackBuffer;
}

@end
