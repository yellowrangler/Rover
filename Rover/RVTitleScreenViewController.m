//
//  RVTitleScreenViewController.m
//  Rover
//
//  Created by Sean Fitzgerald on 3/9/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVTitleScreenViewController.h"
#import "RVUtilities.h"
#import "Constants_Segues.h"
#import "Constants_Images.h"
#import "Constants_Layout.h"
#import "RVAudioReference.h"
@import AVFoundation;

@interface RVTitleScreenViewController ()

//x, y, width, height
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startButtonLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startButtonWidthConstraint;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) AVAudioPlayer * introAudioPlayer;

@end

@implementation RVTitleScreenViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.startButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_TITLE_SCREEN_START_BUTTON_UP ofType:@"png"]]
                      forState:UIControlStateNormal];
    [self.startButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_TITLE_SCREEN_START_BUTTON_DOWN ofType:@"png"]]
                      forState:UIControlStateHighlighted];
    self.introAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference titleScreenIntro] error:nil];
    [self.introAudioPlayer prepareToPlay];
    self.introAudioPlayer.numberOfLoops = -1;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    self.backgroundImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backgroundTitleScreen@2x" ofType:@"png"]];
    
    CGRect startFrame = rectQuarter((CGRect)RV_LAYOUT_TITLE_SCREEN_START_BUTTON);
    self.startButtonTopConstraint.constant = startFrame.origin.y;
    self.startButtonLeftConstraint.constant = startFrame.origin.x;
    self.startButtonHeightConstraint.constant = startFrame.size.height;
    self.startButtonWidthConstraint.constant = startFrame.size.width;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.introAudioPlayer play];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.backgroundImageView.image = nil;
    [self.introAudioPlayer stop];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)startButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:RV_SEGUE_TITLE_SCREEN_TO_PLANET_SELECT_SCREEN
                              sender:self];
}

@end
