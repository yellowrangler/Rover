//
//  RVCommandLineupViewCell.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/20/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVCommandLineupViewCell.h"

@implementation RVCommandLineupViewCell

-(id)init
{
    self = [super init];
    if (self) {
        [self customSetup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customSetup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customSetup];
    }
    return self;
}

-(void)customSetup
{
    self.backgroundColor = [UIColor clearColor];
}
@end
