//
//  RVRotateCommand.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVRotateCommand.h"

@interface RVRotateCommand ()

@end

@implementation RVRotateCommand

-(instancetype)initRight
{
    self = [super init];
    if (self) {
        self.constant = self.oldConstant = -90;
        
    }
    return self;
}

-(instancetype)initLeft
{
    self = [super init];
    if (self) {
        self.constant = self.oldConstant = 90;
    }
    return self;
}

-(instancetype)initReverse
{
    self = [super init];
    if (self) {
        self.constant = self.oldConstant = 180;
    }
    return self;
}

-(void)incrementConstant
{
    self.constant += 90;
}

-(void)decrementConstant
{
    self.constant -= 90;
}

-(void)setConstant:(NSInteger)constant
{
//    convert to one circle's worth of degrees
    constant = constant % 360;
    if (constant > 180) {
        constant -= 360;
    } else if (constant <= -180) {
        constant += 360;
    }
    super.constant = constant;
}

-(NSString *)description
{
    return [self descriptionWithConstant:self.constant];
}

-(NSString*)descriptionWithConstant:(NSInteger) constant
{
    if (constant % 180 == 0) {
        return [NSString stringWithFormat:@"Turn around"];
    }
    if (constant > 0) {
        return [NSString stringWithFormat:@"Turn left  %d°", constant];
    } else {
        return [NSString stringWithFormat:@"Turn right %d°", -constant];
    }
}

-(NSInteger)lengthOfChange
{
    NSString *oldDescription = [self descriptionWithConstant:self.oldConstant];
    return (oldDescription.length - @"Turn ".length);
}

-(NSString *)changedString
{
    return [self.description substringFromIndex:@"Turn ".length];
}

-(id)copy
{
    RVRotateCommand *copy = [[RVRotateCommand alloc] init];
    copy.constant = self.constant;
    copy.oldConstant = self.oldConstant;
    return copy;
}

-(void)undoCommand:(RVCommand*)cmd
{
    if (cmd.constant == 90) {
        [self decrementConstant];
    } else if(cmd.constant == -90) {
        [self incrementConstant];
    } else if(cmd.constant == 180) {
        [self decrementConstant];
        [self decrementConstant];
    }
}

@end