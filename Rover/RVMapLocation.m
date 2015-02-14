//
//  RVMapLocation.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/19/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVMapLocation.h"

@implementation RVMapLocation

-(id)init
{
    self = [super init];
    if (self) {
        self.direction = RV_MAP_NORTH;
    }
    return self;
}

-(void)moveForward
{
    if ([self.direction isEqualToString:RV_MAP_NORTH]) {
        self.row--;
    } else if([self.direction isEqualToString:RV_MAP_EAST]) {
        self.column++;
    } else if ([self.direction isEqualToString:RV_MAP_SOUTH]) {
        self.row++;
    } else if([self.direction isEqualToString:RV_MAP_WEST]) {
        self.column--;
    }
}

-(void)turnLeft
{
    if ([self.direction isEqualToString:RV_MAP_NORTH]) {
        self.direction = RV_MAP_WEST;
    } else if([self.direction isEqualToString:RV_MAP_EAST]) {
        self.direction = RV_MAP_NORTH;
    } else if ([self.direction isEqualToString:RV_MAP_SOUTH]) {
        self.direction = RV_MAP_EAST;
    } else if([self.direction isEqualToString:RV_MAP_WEST]) {
        self.direction = RV_MAP_SOUTH;
    }
}

-(void)turnRight
{
    if ([self.direction isEqualToString:RV_MAP_NORTH]) {
        self.direction = RV_MAP_EAST;
    } else if([self.direction isEqualToString:RV_MAP_EAST]) {
        self.direction = RV_MAP_SOUTH;
    } else if ([self.direction isEqualToString:RV_MAP_SOUTH]) {
        self.direction = RV_MAP_WEST;
    } else if([self.direction isEqualToString:RV_MAP_WEST]) {
        self.direction = RV_MAP_NORTH;
    }
}

-(void)turnAround
{
    if ([self.direction isEqualToString:RV_MAP_NORTH]) {
        self.direction = RV_MAP_SOUTH;
    } else if([self.direction isEqualToString:RV_MAP_EAST]) {
        self.direction = RV_MAP_WEST;
    } else if ([self.direction isEqualToString:RV_MAP_SOUTH]) {
        self.direction = RV_MAP_NORTH;
    } else if([self.direction isEqualToString:RV_MAP_WEST]) {
        self.direction = RV_MAP_EAST;
    }
}

-(id)copy
{
    RVMapLocation* copy = [[[self class] alloc] init];
    if (copy) {
        [copy setRow:self.row];
        [copy setColumn:self.column];
        [copy setDirection:self.direction];
    }
    return copy;
}

-(BOOL)locationFaces:(RVMapLocation*)location
{
    RVMapLocation *copy = [self copy];
    [copy moveForward];
    if (copy.row == location.row &&
        copy.column == location.column) {
        return YES;
    } else {
        return NO;
    }
}

@end
