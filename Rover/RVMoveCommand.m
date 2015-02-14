//
//  RVMoveCommand.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVMoveCommand.h"

@implementation RVMoveCommand

-(NSString *)description
{
    return [self descriptionWithConstant:self.constant];
}

-(NSString*)descriptionWithConstant:(NSInteger) constant
{
    if (constant == 1) {
        return [NSString stringWithFormat:@"Move forward %ld meter", (long)constant];
    }
    return [NSString stringWithFormat:@"Move forward %ld meters", (long)constant];
}

-(NSInteger)lengthOfChange
{
    NSString *oldDescription = [self descriptionWithConstant:self.oldConstant];
    return (oldDescription.length - @"Move forward ".length);
}

-(NSString *)changedString
{
    return [self.description substringFromIndex:@"Move forward ".length];
}

-(id)copy
{
    RVMoveCommand *copy = [[RVMoveCommand alloc] init];
    copy.constant = self.constant;
    copy.oldConstant = self.oldConstant;
    return copy;
}

-(void)undoCommand:(RVCommand*)cmd
{
    self.constant -= cmd.constant;
}

@end
