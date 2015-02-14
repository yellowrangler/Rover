//
//  RVAnimatedTextView.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/4/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@class RVAnimatedTextView;

@protocol RVAnimatedTextDelegate <NSObject>

-(void)textViewDidFinishedAnimating:(RVAnimatedTextView*)textView;
-(void)textViewPartiallyFinishedAnimating:(RVAnimatedTextView*)textView;
-(void)textViewDeletedAllText;

@end

@interface RVAnimatedTextView : UITextView

@property (nonatomic, assign) double typeInterval;
@property (nonatomic, assign) BOOL typing;
@property (nonatomic, assign) BOOL backspacing;
@property (nonatomic, assign) BOOL sendAlert;
@property (nonatomic, assign) BOOL startedTyping;
@property (nonatomic, assign) BOOL showUnderscore;

@property (nonatomic, strong) NSString *animatedText;
-(void)backspaceCharacterLength:(NSInteger)backLength replaceMentString:(NSString *)replacement;
-(void)appendString:(NSString*)appendString animated:(BOOL)animated;

@property (nonatomic, weak) id<RVAnimatedTextDelegate> animationDelegate;

@property (nonatomic, strong) AVAudioPlayer * typingAudioPlayer;

@property (nonatomic, strong) NSTimer *typeTimer;
@property (nonatomic, strong) NSTimer *underscoreTimer;

@end
