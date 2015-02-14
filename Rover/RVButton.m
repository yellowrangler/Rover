//
//  RVButton.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/19/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVButton.h"
#import "RVAudioReference.h"
@import AVFoundation;

@interface RVButton ()

@property (nonatomic, strong) AVAudioPlayer * upPlayer;
@property (nonatomic, strong) AVAudioPlayer * downPlayer;

@end

@implementation RVButton

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
	self.upPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference buttonUp] error:nil];
    [self.upPlayer prepareToPlay];
	self.downPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference buttonDown] error:nil];
    [self.downPlayer prepareToPlay];
}

-(void)setHighlighted:(BOOL)highlighted
{
	
	if (highlighted != YES)	{
		[self.upPlayer setCurrentTime:0.0];
		[self.upPlayer play];
	} else {
		[self.downPlayer setCurrentTime:0.0];
		[self.downPlayer play];
	}

	
	[super setHighlighted:highlighted];
}

@end
