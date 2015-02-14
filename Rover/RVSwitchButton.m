//
//  RVSwitchButton.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/20/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVSwitchButton.h"
#import "RVAudioReference.h"
@import AVFoundation;

@interface RVSwitchButton ()

@property (nonatomic, strong) AVAudioPlayer * upPlayer;

@end

@implementation RVSwitchButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupAudioPlayer];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self setupAudioPlayer];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupAudioPlayer];
    }
    return self;
}

-(void) setupAudioPlayer
{
	self.upPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference buttonDown] error:nil];
    [self.upPlayer prepareToPlay];
}

-(void)setHighlighted:(BOOL)highlighted
{
	
	if (highlighted == YES)	{
		[self.upPlayer setCurrentTime:0.0];
		[self.upPlayer play];
	}
	
	[super setHighlighted:highlighted];
}

@end
