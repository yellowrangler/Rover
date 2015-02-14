//
//  RVAnimatedTextView.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/4/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVAnimatedTextView.h"
#import "Constants_UIUX.h"
#import "RVAudioReference.h"
@import AVFoundation;

#define RV_ANIMATION_BACKSPACE (@"is it a backspace animation?")
#define RV_ANIMATION_BACKSPACE_LENGTH (@"the length of the backspacing")
#define RV_ANIMATION_BACKSPACE_REPLACEMENT_TEXT (@"the text to replaced the backspaced text")
#define RV_ANIMATION_APPEND (@"is it an append animation?")
#define RV_ANIMATION_APPEND_STRING (@"the string to be appended")

@interface RVAnimatedTextView ()

@property (nonatomic, strong) NSString *intendedText;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) NSInteger backspaceLength;
@property (nonatomic, strong) NSString *replacementString;

@property (nonatomic, strong) NSMutableArray *nextBuffer;
@property (nonatomic, assign) BOOL deletingAll;
@property (nonatomic, assign) BOOL hasUnderscore;

@end

@implementation RVAnimatedTextView

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

-(instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame
                  textContainer:textContainer];
    if (self) {
        [self customSetup];
    }
    return self;
    
}

-(void)customSetup
{
    self.typeInterval = RV_UIUX_TEXT_ANIMATION_INTERVAL;
    UIFont * font = [UIFont fontWithName:RV_UIUX_TEXT_FONT_NAME size:RV_UIUX_TEXT_FONT_SIZE];
    self.font = font;
    self.editable = NO;
    self.textColor = [UIColor whiteColor];
    CALayer *textLayer = (CALayer *)[self.layer.sublayers objectAtIndex:0];
    textLayer.shadowColor = [UIColor whiteColor].CGColor;
    textLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    textLayer.shadowOpacity = 1.0f;
    textLayer.shadowRadius = 3.0f;
    self.textContainerInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.typingAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference typing] error:nil];
    self.typingAudioPlayer.numberOfLoops = -1;
    [self.typingAudioPlayer prepareToPlay];
    self.selectable = NO; // Turn off text selection
}

-(void)underscore
{
    if (!self.typing &&
        !self.backspacing) {
        if (self.hasUnderscore) {
            [self removeUnderscore];
        } else {
            [self addUnderscore];
        }
    }
}

-(void)addUnderscore {
    self.text = [self.text stringByAppendingString:@"_"];
    self.hasUnderscore = YES;
}

-(void)removeUnderscore {
    self.text = [self.text substringToIndex:self.text.length-1];
    self.hasUnderscore = NO;
}

-(void)setShowUnderscore:(BOOL)showUnderscore
{
    _showUnderscore = showUnderscore;
    if (showUnderscore) {
        [self.underscoreTimer invalidate];
        self.underscoreTimer = [NSTimer scheduledTimerWithTimeInterval:RV_CURSOR_DELAY
                                                                target:self
                                                              selector:@selector(underscore)
                                                              userInfo:nil
                                                               repeats:YES];
    } else {
        [self.underscoreTimer invalidate];
        if (self.hasUnderscore) {
            [self removeUnderscore];
        }
    }
}

-(void)setAnimatedText:(NSString *)animatedText
{
//    if (self.backspacing || self.typing) {
//        NSLog(@"ERROR: Cannot backspace while still editing animated text");
//        return;
//    }
    if ([animatedText isEqualToString:@""]) {
        [self.animationDelegate textViewDidFinishedAnimating:self];
        return;
    }
    [self.typingAudioPlayer play];
    if (self.hasUnderscore) {
        [self removeUnderscore];
    }
    self.intendedText = animatedText;
    self.currentIndex = 1;
    [self.typeTimer invalidate];
    self.typing = YES;
    self.typeTimer = [NSTimer scheduledTimerWithTimeInterval:self.typeInterval
                                                      target:self
                                                    selector:@selector(timerFire)
                                                    userInfo:nil
                                                     repeats:YES];
    _animatedText = [animatedText substringToIndex:self.currentIndex];
    self.text = self.animatedText;
}

-(void)dealloc
{
    [self.typeTimer invalidate];
    [self.underscoreTimer invalidate];
}

-(void)timerFire
{
    if (![self.typingAudioPlayer isPlaying]) {
        [self.typingAudioPlayer play];
        [self.typeTimer invalidate];
        self.typeTimer = [NSTimer scheduledTimerWithTimeInterval:self.typeInterval
                                                          target:self
                                                        selector:@selector(timerFire)
                                                        userInfo:nil
                                                         repeats:YES];
    }
    
    self.startedTyping = YES;
    if (!self.backspacing) {
        if ([self.intendedText characterAtIndex:self.currentIndex] == '\n') {
            [self.typingAudioPlayer stop];
            [self.typeTimer invalidate];
            self.typeTimer = [NSTimer scheduledTimerWithTimeInterval:self.typeInterval * 4
                                                              target:self
                                                            selector:@selector(timerFire)
                                                            userInfo:nil
                                                             repeats:YES];
        }
        _animatedText = [self.intendedText substringToIndex:++self.currentIndex];
        self.text = self.animatedText;
        if (self.currentIndex == self.intendedText.length) {
            [self.typeTimer invalidate];
            if(self.sendAlert) {
                [self.animationDelegate textViewPartiallyFinishedAnimating:self];
            }
            self.typing = NO;
            if (self.nextBuffer.count > 0) {
                [self nextTypingAction:self.nextBuffer.firstObject];
                [self.nextBuffer removeObjectAtIndex:0];
            } else if(self.sendAlert) {
                [self.typingAudioPlayer stop];
                [self.animationDelegate textViewDidFinishedAnimating:self];
            } else {
                [self.typingAudioPlayer stop];
            }
        }
    } else {
        _animatedText = [self.text substringToIndex:self.text.length-1];
        self.text = self.animatedText;
        self.backspaceLength--;
        if (self.backspaceLength == 0) {
            [self.typeTimer invalidate];
            self.backspacing = NO;
            if (self.replacementString.length != 0) {
                [self appendString:self.replacementString animated:YES];
            } else {
                if (self.deletingAll) {
                    self.deletingAll = NO;
                    [self.animationDelegate textViewDeletedAllText];
                }
                
                [self.typingAudioPlayer stop];
                [self.animationDelegate textViewDidFinishedAnimating:self];
            }
        }
    }
}

-(void)backspaceCharacterLength:(NSInteger)backLength replaceMentString:(NSString *)replacement
{
    if (self.hasUnderscore) {
        [self removeUnderscore];
    }
    if (self.backspacing || self.typing) {
        [self.nextBuffer addObject:@{RV_ANIMATION_BACKSPACE:[NSNumber numberWithBool:YES],
                                     RV_ANIMATION_APPEND:[NSNumber numberWithBool:NO],
                                     RV_ANIMATION_BACKSPACE_LENGTH:[NSNumber numberWithInteger:backLength],
                                     RV_ANIMATION_BACKSPACE_REPLACEMENT_TEXT:replacement}];
    } else {
        if (self.text.length == backLength) {
            self.deletingAll = YES;
        }
        self.replacementString = replacement;
        self.backspaceLength = backLength;
        [self.typeTimer invalidate];
        self.backspacing = YES;
        self.typeTimer = [NSTimer scheduledTimerWithTimeInterval:self.typeInterval
                                                          target:self
                                                        selector:@selector(timerFire)
                                                        userInfo:nil
                                                         repeats:YES];
        NSString *text = self.text;
        if (self.text.length == 0 ||
            backLength > self.text.length) {
            NSLog(@"BIG PROBLEMS!!!!!!");
            [self.typeTimer invalidate];
            [self.animationDelegate textViewDidFinishedAnimating:self];
            return;
        }
        _animatedText = [self.text substringToIndex:self.text.length-1];
        self.text = self.animatedText;
        self.backspaceLength--;
    }
}

-(double)typeInterval
{
    if (_typeInterval == 0) {
        _typeInterval = 0.1;
    }
    return _typeInterval;
}

-(void)appendString:(NSString*)appendString animated:(BOOL)animated
{
    if (self.hasUnderscore) {
        [self removeUnderscore];
    }
    if (!animated) {
        self.text = [self.text stringByAppendingString:appendString];
    } else {
        if (self.backspacing || self.typing) {
            [self.nextBuffer addObject:@{RV_ANIMATION_APPEND:[NSNumber numberWithBool:YES],
                                         RV_ANIMATION_BACKSPACE:[NSNumber numberWithBool:NO],
                                         RV_ANIMATION_APPEND_STRING:appendString}];
        } else {
            [self.typeTimer invalidate];
            self.typing = YES;
            self.intendedText = [self.text stringByAppendingString:appendString];
            self.currentIndex = self.text.length + 1;
            self.typeTimer = [NSTimer scheduledTimerWithTimeInterval:self.typeInterval
                                                              target:self
                                                            selector:@selector(timerFire)
                                                            userInfo:nil
                                                             repeats:YES];
            _animatedText = [self.intendedText substringToIndex:self.currentIndex];
            self.text = self.animatedText;
        }
    }
}

-(void)nextTypingAction:(NSDictionary*)action
{
    if ([action[RV_ANIMATION_BACKSPACE] boolValue]) {
        [self backspaceCharacterLength:[action[RV_ANIMATION_BACKSPACE_LENGTH] integerValue]
                     replaceMentString:action[RV_ANIMATION_BACKSPACE_REPLACEMENT_TEXT]];
    } else if ([action[RV_ANIMATION_APPEND] boolValue]) {
        [self appendString:action[RV_ANIMATION_APPEND_STRING] animated:YES];
    }
}

-(NSMutableArray *)nextBuffer
{
    if (!_nextBuffer) {
        _nextBuffer = [[NSMutableArray alloc] init];
    }
    return _nextBuffer;
}

/*
 * Properties
 */

-(void)setTypeTimer:(NSTimer *)typeTimer
{
    _typeTimer = typeTimer;
    [[NSRunLoop currentRunLoop] addTimer:_typeTimer forMode:NSRunLoopCommonModes];
}

-(void)setUnderscoreTimer:(NSTimer *)underscoreTimer
{
    _underscoreTimer = underscoreTimer;
    [[NSRunLoop currentRunLoop] addTimer:_underscoreTimer forMode:NSRunLoopCommonModes];
}

@end
