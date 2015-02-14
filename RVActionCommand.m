//
//  RVActionCommand.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVActionCommand.h"

@implementation RVActionCommand

-(NSString *)description
{
    return [self descriptionWithConstant:self.constant];
}

-(NSString*)descriptionWithConstant:(NSInteger) constant
{
    return @"Use rover arm";
}

-(NSInteger)lengthOfChange
{
    return 0;
}

-(NSString *)changedString
{
    return @"";
}

-(id)copy
{
    RVActionCommand *copy = [[RVActionCommand alloc] init];
    copy.constant = self.constant;
    copy.oldConstant = self.oldConstant;
    return copy;
}

-(void)undoCommand:(RVCommand*)cmd
{
    self.constant -= cmd.constant;
}

@end
