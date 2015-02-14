//
//  RVCommand.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVCommand.h"

@interface RVCommand()

@end

@implementation RVCommand

-(id)init
{
    self = [super init];
    if (self) {
        _constant = 1;
    }
    return self;
}

-(void)incrementConstant
{
    self.constant += 1;
}

-(void)decrementConstant
{
    self.constant -= 1;
}

-(void)setConstant:(NSInteger)constant
{
    self.oldConstant = _constant;
    _constant = constant;
}

-(NSString *)description
{
    return @"not the correct description";
}

-(id)copy
{
    RVCommand *copy = [[RVCommand alloc] init];
    copy.constant = self.constant;
    copy.oldConstant = self.oldConstant;
    return copy;
}

@end
