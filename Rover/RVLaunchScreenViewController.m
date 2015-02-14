//
//  RVLaunchScreenViewController.m
//  Rover
//
//  Created by Sean Fitzgerald on 3/9/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVLaunchScreenViewController.h"
#import "Constants_Images.h"
#import "Constants_UIUX.h"
#import "Constants_Segues.h"
#import "RVNavigationController.h"
#import "RVAudioReference.h"
@import CoreGraphics;
@import AVFoundation;

@interface RVLaunchScreenViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *launchMontageImageView;

@property (nonatomic, strong) NSArray *montageImageNames;
@property (nonatomic, assign) NSInteger imageIndex;

@property (nonatomic, strong) NSTimer *montageTimer;

@property (nonatomic, strong) AVAudioPlayer * montageAudioPlayer;

@end

@implementation RVLaunchScreenViewController

#pragma mark View Lifecycle Methods
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupLaunchMontage];
    self.imageIndex = 0;
    self.montageAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference journeyAnimationSequence] error:nil];
    [self.montageAudioPlayer prepareToPlay];
    self.launchMontageImageView.image = [UIImage imageNamed:self.montageImageNames[self.imageIndex]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self nextMontageImage];
    [self.montageAudioPlayer play];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.montageTimer invalidate];//this is tied to the run loop, so it will actually call even after the view is removed from memory and cause a silent crash that is very difficult to find. Better to invalidate it when leaving the view just in case.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.launchMontageImageView.animationImages = nil;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark View Setup Helper Methods
-(void)setupLaunchMontage
{
    NSString *planet = [(RVNavigationController*)self.navigationController planet];
    if ([planet isEqualToString:@"moon"]) {
        self.montageImageNames = RV_IMAGES_LAUNCH_SCREEN_MONTAGE_MOON;
    } else if ([planet isEqualToString:@"pluto"]) {
        self.montageImageNames = RV_IMAGES_LAUNCH_SCREEN_MONTAGE_PLUTO;
    } else if ([planet isEqualToString:@"titan"]) {
        self.montageImageNames = RV_IMAGES_LAUNCH_SCREEN_MONTAGE_TITAN;
    } else if ([planet isEqualToString:@"mars"]) {
        self.montageImageNames = RV_IMAGES_LAUNCH_SCREEN_MONTAGE_MARS;
    }
}

-(void)nextMontageImage
{
    switch (self.imageIndex) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11:
            self.montageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                 target:self
                                                               selector:@selector(nextMontageImage)
                                                               userInfo:nil
                                                                repeats:NO];
            self.launchMontageImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.montageImageNames[self.imageIndex]
                                                                                                                 ofType:@"png"]];
            break;
        case 12:
        case 13:
            self.montageTimer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                                 target:self
                                                               selector:@selector(nextMontageImage)
                                                               userInfo:nil
                                                                repeats:NO];

            self.launchMontageImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.montageImageNames[self.imageIndex]
                                                                                                                 ofType:@"png"]];
            break;
        case 14:
            self.montageTimer = [NSTimer scheduledTimerWithTimeInterval:.01
                                                                 target:self
                                                               selector:@selector(nextMontageImage)
                                                               userInfo:nil
                                                                repeats:NO];
            self.launchMontageImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.montageImageNames[self.imageIndex]
                                                                                                                 ofType:@"png"]];
            break;
        case 15:
            [self departView];
        default:
            break;
    }
    self.imageIndex++;
}

-(void)departView
{
    [self performSegueWithIdentifier:RV_SEGUE_LAUNCH_SCREEN_TO_GAME_SCREEN
                              sender:self];
}

- (IBAction)unwindToLaunchScreen:(UIStoryboardSegue *)unwindSegue
{
}

@end
