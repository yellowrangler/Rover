//
//  NSArray+LayoutConstraint.m
//  Rover
//
//  Created by Sean Fitzgerald on 3/14/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "NSArray+LayoutConstraint.h"

@implementation NSArray (LayoutConstraint)

-(void)setLayoutRect:(CGRect)frame
{
    [(NSLayoutConstraint*)self[0] setConstant:frame.origin.x];
    [(NSLayoutConstraint*)self[1] setConstant:frame.origin.y];
    [(NSLayoutConstraint*)self[2] setConstant:frame.size.width];
    [(NSLayoutConstraint*)self[3] setConstant:frame.size.height];
}

-(void)setLayoutSize:(CGSize)size
{
    [(NSLayoutConstraint*)self[0] setConstant:size.width];
    [(NSLayoutConstraint*)self[1] setConstant:size.height];
}

@end
