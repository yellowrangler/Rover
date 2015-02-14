//
//  RVVictoryScreenViewController.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/2/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVVictoryScreenViewController.h"
#import "RVNavigationController.h"
#import "RVAnimatedTextView.h"
#import "RVUtilities.h"
#import "NSArray+LayoutConstraint.h"
#import "Constants_Layout.h"
#import "Constants_Images.h"
#import "Constants_Content.h"
#import "RVAudioReference.h"
@import AVFoundation;

@interface RVVictoryScreenViewController () <RVAnimatedTextDelegate>

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *endGameButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *continueButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonBackgroundConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *guideImageViewConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *thermometerImageViewConsrtaints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *textViewConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *gameFailButtonConstraints;

@property (weak, nonatomic) IBOutlet UIButton *endGameButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *gameFailButton;

@property (weak, nonatomic) IBOutlet UIImageView *buttonBackground;
@property (weak, nonatomic) IBOutlet UIImageView *guideImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thermometerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBackgroundImageView;

@property (weak, nonatomic) IBOutlet RVAnimatedTextView *textViewAnimated;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) AVAudioPlayer *victoryScreenAudioPlayer;

@end

@implementation RVVictoryScreenViewController

//view lifecycle methods
-(void)viewDidLoad
{
    if ([self.gameData[@"reason"] isEqualToString:@"final"]) {
        if ([self.gameData[@"guide"] isEqualToString:@"Jacob"]) {
            self.guideImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_JACOB_SUCCESS];
        } else if ([self.gameData[@"guide"] isEqualToString:@"India"]) {
            self.guideImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_INDIA_SUCCESS];
        }
        if ([self.gameData[@"planet"] isEqualToString:@"pluto"]) {
            self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_PLUTO_OBJECTIVE_3];
        } else if ([self.gameData[@"planet"] isEqualToString:@"titan"]) {
            self.backgroundImageView.animationImages = @[[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TITAN_OBJECTIVE_2],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TITAN_OBJECTIVE_1]];
            self.backgroundBackgroundImageView.image = self.backgroundImageView.animationImages[0];
        } else if ([self.gameData[@"planet"] isEqualToString:@"moon"]) {
            self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MOON_OBJECTIVE];
            self.thermometerImageView.hidden = NO;
            NSMutableArray *thermometerMontage = [[NSMutableArray alloc] init];
            for (NSString *imageName in RV_IMAGES_VICTORY_SCREEN_MOON_THERMOMETER_3_MONTAGE_NAMES) {
                [thermometerMontage addObject:[UIImage imageNamed:imageName]];
            }
            self.thermometerImageView.animationImages = [thermometerMontage copy];
            [self.thermometerImageViewConsrtaints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_MOON_THERMOMETER_BARS)];
        } else if ([self.gameData[@"planet"] isEqualToString:@"mars"]) {
            self.backgroundImageView.animationImages = @[[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_1],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_2],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_3],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_4]];
            self.backgroundBackgroundImageView.image = self.backgroundImageView.animationImages[0];
        }
        self.gameFailButton.hidden = YES;
        self.buttonBackground.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TWO_BUTTON_BACKGROUND];
        [self.continueButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_TWO_BUTTON_CONTINUE_BUTTON)];
        [self.endGameButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_TWO_BUTTON_END_BUTTON)];
        [self.buttonBackgroundConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_TWO_BUTTON_BACKGROUND)];
        [self.continueButton setImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TWO_BUTTON_CONTINUE] forState:UIControlStateNormal];
        [self.continueButton setImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TWO_BUTTON_CONTINUE_DOWN] forState:UIControlStateHighlighted];
        [self.endGameButton setImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TWO_BUTTON_END] forState:UIControlStateNormal];
        [self.endGameButton setImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TWO_BUTTON_END_DOWN] forState:UIControlStateHighlighted];
    } else if ([self.gameData[@"reason"] isEqualToString:@"first"]) {
        if ([self.gameData[@"guide"] isEqualToString:@"Jacob"]) {
            self.guideImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_JACOB_SUCCESS];
        } else if ([self.gameData[@"guide"] isEqualToString:@"India"]) {
            self.guideImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_INDIA_SUCCESS];
        }
        if ([self.gameData[@"planet"] isEqualToString:@"pluto"]) {
            self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_PLUTO_OBJECTIVE_1];
        } else if ([self.gameData[@"planet"] isEqualToString:@"titan"]) {
            self.backgroundImageView.animationImages = @[[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TITAN_OBJECTIVE_2],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TITAN_OBJECTIVE_1]];
            self.backgroundBackgroundImageView.image = self.backgroundImageView.animationImages[0];
        } else if ([self.gameData[@"planet"] isEqualToString:@"moon"]) {
            self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MOON_OBJECTIVE];
            self.thermometerImageView.hidden = NO;
            NSMutableArray *thermometerMontage = [[NSMutableArray alloc] init];
            for (NSString *imageName in RV_IMAGES_VICTORY_SCREEN_MOON_THERMOMETER_1_MONTAGE_NAMES) {
                [thermometerMontage addObject:[UIImage imageNamed:imageName]];
            }
            self.thermometerImageView.animationImages = [thermometerMontage copy];
            [self.thermometerImageViewConsrtaints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_MOON_THERMOMETER_BARS)];
        } else if ([self.gameData[@"planet"] isEqualToString:@"mars"]) {
            self.backgroundImageView.animationImages = @[[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_1],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_2],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_3],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_4]];
            self.backgroundBackgroundImageView.image = self.backgroundImageView.animationImages[0];
        }
        self.buttonBackground.hidden = NO;
        self.endGameButton.hidden = YES;
        self.gameFailButton.hidden = YES;
        self.buttonBackground.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_CONTINUE_BUTTON_BACKGROUND];
        [self.buttonBackgroundConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_CONTINUE_BUTTON_BACKGROUND)];
        [self.continueButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_CONTINUE_BUTTON)];
        [self.continueButton setImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_CONTINUE_BUTTON] forState:UIControlStateNormal];
        [self.continueButton setImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_CONTINUE_BUTTON_DOWN] forState:UIControlStateHighlighted];
    } else if ([self.gameData[@"reason"] isEqualToString:@"second"]) {
        if ([self.gameData[@"guide"] isEqualToString:@"Jacob"]) {
            self.guideImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_JACOB_SUCCESS];
        } else if ([self.gameData[@"guide"] isEqualToString:@"India"]) {
            self.guideImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_INDIA_SUCCESS];
        }
        if ([self.gameData[@"planet"] isEqualToString:@"pluto"]) {
            self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_PLUTO_OBJECTIVE_2];
        } else if ([self.gameData[@"planet"] isEqualToString:@"titan"]) {
            self.backgroundImageView.animationImages = @[[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TITAN_OBJECTIVE_2],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TITAN_OBJECTIVE_1]];
            self.backgroundBackgroundImageView.image = self.backgroundImageView.animationImages[0];
        } else if ([self.gameData[@"planet"] isEqualToString:@"moon"]) {
            self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MOON_OBJECTIVE];
            self.thermometerImageView.hidden = NO;
            NSMutableArray *thermometerMontage = [[NSMutableArray alloc] init];
            for (NSString *imageName in RV_IMAGES_VICTORY_SCREEN_MOON_THERMOMETER_1_MONTAGE_NAMES) {
                [thermometerMontage addObject:[UIImage imageNamed:imageName]];
            }
            self.thermometerImageView.animationImages = [thermometerMontage copy];
            [self.thermometerImageViewConsrtaints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_MOON_THERMOMETER_BARS)];
        } else if ([self.gameData[@"planet"] isEqualToString:@"mars"]) {
            self.backgroundImageView.animationImages = @[[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_1],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_2],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_3],
                                                         [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_MARS_OBJECTIVE_4]];
            self.backgroundBackgroundImageView.image = self.backgroundImageView.animationImages[0];
        }
        self.buttonBackground.hidden = YES;
        self.endGameButton.hidden = YES;
        self.gameFailButton.hidden = YES;
        [self.continueButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_CONTINUE_BUTTON)];
        [self.continueButton setImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_CONTINUE_BUTTON] forState:UIControlStateNormal];
        [self.continueButton setImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_CONTINUE_BUTTON_DOWN] forState:UIControlStateHighlighted];
    } else if ([self.gameData[@"reason"] isEqualToString:@"fail"]) {
        self.victoryScreenAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference victoryScreenFailureBatteryDrained] error:nil];
        if ([self.gameData[@"guide"] isEqualToString:@"Jacob"]) {
            self.guideImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_JACOB_FAILURE];
        } else if ([self.gameData[@"guide"] isEqualToString:@"India"]) {
            self.guideImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_INDIA_FAILURE];
        }
        if ([self.gameData[@"planet"] isEqualToString:@"moon"]) {
            self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_OBJECTIVE_FAIL_MOON];
        } else if ([self.gameData[@"planet"] isEqualToString:@"mars"]) {
            self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_OBJECTIVE_FAIL_MARS];
        } else if ([self.gameData[@"planet"] isEqualToString:@"titan"]) {
            self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_OBJECTIVE_FAIL_TITAN];
        } else if ([self.gameData[@"planet"] isEqualToString:@"pluto"]) {
            self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_OBJECTIVE_FAIL_PLUTO];
        }
        self.buttonBackground.hidden = YES;
        self.continueButton.hidden = YES;
        self.endGameButton.hidden = YES;
        self.gameFailButton.hidden = NO;
        [self.gameFailButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_TRY_AGAIN_BUTTON)];
        [self.gameFailButton setImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TRY_AGAIN_BUTTON] forState:UIControlStateNormal];
        [self.gameFailButton setImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_TRY_AGAIN_BUTTON_DOWN] forState:UIControlStateHighlighted];
    }
    
    [self.textViewConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_TEXT_VIEW)];
    [self.guideImageViewConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_VICTORY_SCREEN_GUIDE_IMAGE)];
    
    //audio setup
    if ([self.gameData[@"reason"] isEqualToString:@"fail"]) {
        self.victoryScreenAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference victoryScreenFailureBatteryDrained] error:nil];
    } else if ([self.gameData[@"planet"] isEqualToString:@"moon"]) {
        self.victoryScreenAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference victoryScreenMoonThermometer] error:nil];
    } else if ([self.gameData[@"planet"] isEqualToString:@"mars"]) {
        self.victoryScreenAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference victoryScreenMarsRockGrinder] error:nil];
    } else if ([self.gameData[@"planet"] isEqualToString:@"titan"]) {
        self.victoryScreenAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference victoryScreenTitanLaserDrill] error:nil];
    } else if ([self.gameData[@"planet"] isEqualToString:@"pluto"]) {
        self.victoryScreenAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference victoryScreenPlutoCameraServo] error:nil];
    }
    [self.victoryScreenAudioPlayer prepareToPlay];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self.victoryScreenAudioPlayer play];
    if ([self.gameData[@"reason"] isEqualToString:@"final"]) {
        if ([self.gameData[@"planet"] isEqualToString:@"pluto"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_PLUTO_OBJECTIVE_3;
            UIImageView *flashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_PLUTO_FLASH]];
            flashImageView.frame = self.view.bounds;
            flashImageView.alpha = 0.0;
            [self.view addSubview:flashImageView];
            [UIView animateWithDuration:0.2
                             animations:^(void){
                                 flashImageView.alpha = 1.0;
                             }
                             completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.2
                                                  animations:^(void){
                                                      flashImageView.alpha = 0.0;
                                                  }
                                                  completion:^(BOOL finished){
                                                      [flashImageView removeFromSuperview];
                                                  }];
                             }];
        } else if ([self.gameData[@"planet"] isEqualToString:@"titan"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_TITAN_OBJECTIVE_3;
            self.backgroundImageView.animationRepeatCount = 1;
            self.backgroundImageView.animationDuration = 2.0;
            [self.backgroundImageView startAnimating];
        } else if ([self.gameData[@"planet"] isEqualToString:@"moon"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_MOON_OBJECTIVE_3;
            self.thermometerImageView.animationRepeatCount = 1;
            self.thermometerImageView.animationDuration = 2.0;
            [self.thermometerImageView startAnimating];
        } else if ([self.gameData[@"planet"] isEqualToString:@"mars"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_MARS_OBJECTIVE_3;
            self.backgroundImageView.animationRepeatCount = 1;
            self.backgroundImageView.animationDuration = 2.0;
            [self.backgroundImageView startAnimating];
        }
    } else if ([self.gameData[@"reason"] isEqualToString:@"first"]) {
        if ([self.gameData[@"planet"] isEqualToString:@"pluto"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_PLUTO_OBJECTIVE_1;
            UIImageView *flashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_PLUTO_FLASH]]; //here's where the flash happens
            flashImageView.frame = self.view.bounds;
            flashImageView.alpha = 0.0;
            [self.view addSubview:flashImageView];
            [UIView animateWithDuration:0.1//0.2
                             animations:^(void){
                                 flashImageView.alpha = 1.0;
                             }
                             completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.2
                                                  animations:^(void){
                                                      flashImageView.alpha = 0.0;
                                                  }
                                                  completion:^(BOOL finished){
                                                      [flashImageView removeFromSuperview];
                                                  }];
                             }];
        } else if ([self.gameData[@"planet"] isEqualToString:@"titan"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_TITAN_OBJECTIVE_1;
            self.backgroundImageView.animationRepeatCount = 1;
            self.backgroundImageView.animationDuration = 2.0;
            [self.backgroundImageView startAnimating];
        } else if ([self.gameData[@"planet"] isEqualToString:@"moon"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_MOON_OBJECTIVE_1;
            self.thermometerImageView.animationRepeatCount = 1;
            self.thermometerImageView.animationDuration = 2.0;
            [self.thermometerImageView startAnimating];
        } else if ([self.gameData[@"planet"] isEqualToString:@"mars"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_MARS_OBJECTIVE_1;
            self.backgroundImageView.animationRepeatCount = 1;
            self.backgroundImageView.animationDuration = 2.0;
            [self.backgroundImageView startAnimating];
        }
    } else if ([self.gameData[@"reason"] isEqualToString:@"second"]) {
        if ([self.gameData[@"planet"] isEqualToString:@"pluto"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_PLUTO_OBJECTIVE_2;
            UIImageView *flashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_PLUTO_FLASH]];
            flashImageView.frame = self.view.bounds;
            flashImageView.alpha = 0.0;
            [self.view addSubview:flashImageView];
            [UIView animateWithDuration:0.2
                             animations:^(void){
                                 flashImageView.alpha = 1.0;
                             }
                             completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.2
                                                  animations:^(void){
                                                      flashImageView.alpha = 0.0;
                                                  }
                                                  completion:^(BOOL finished){
                                                      [flashImageView removeFromSuperview];
                                                  }];
                             }];
        } else if ([self.gameData[@"planet"] isEqualToString:@"titan"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_TITAN_OBJECTIVE_2;
            self.backgroundImageView.animationRepeatCount = 1;
            self.backgroundImageView.animationDuration = 2.0;
            [self.backgroundImageView startAnimating];
        } else if ([self.gameData[@"planet"] isEqualToString:@"moon"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_MOON_OBJECTIVE_2;
            self.thermometerImageView.animationRepeatCount = 1;
            self.thermometerImageView.animationDuration = 2.0;
            [self.thermometerImageView startAnimating];
        } else if ([self.gameData[@"planet"] isEqualToString:@"mars"]) {
            self.textViewAnimated.animatedText = RV_CONTENT_VICTORY_SCREEN_MARS_OBJECTIVE_2;
            self.backgroundImageView.animationRepeatCount = 1;
            self.backgroundImageView.animationDuration = 2.0;
            [self.backgroundImageView startAnimating];
        }
    } else if ([self.gameData[@"reason"] isEqualToString:@"fail"]) {
        self.textViewAnimated.animatedText = @"Your rover ran out of battery power!\n\nTry your best to plan out your moves before sending them to the rover. Also, keep an eye on the compass on your screen to see where to go next!\n\nAre you ready to try this mission again?";
    }
    self.textViewAnimated.sendAlert = YES;
    self.textViewAnimated.animationDelegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.backgroundImageView startAnimating];
    [self.thermometerImageView startAnimating];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                  target:self
                                                selector:@selector(stopAnimating)
                                                userInfo:nil
                                                 repeats:NO];
    if ([self.gameData[@"planet"] isEqualToString:@"pluto"] &&
        ![self.gameData[@"reason"] isEqualToString:@"fail"]) {
        UIImageView *flashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_VICTORY_SCREEN_PLUTO_FLASH]];
        flashImageView.frame = self.view.bounds;
        flashImageView.alpha = 0.0;
        [self.view addSubview:flashImageView];
        [UIView animateWithDuration:0.2
                         animations:^(void){
                             flashImageView.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.2
                                              animations:^(void){
                                                  flashImageView.alpha = 0.0;
                                              }
                                              completion:^(BOOL finished){
                                                  [flashImageView removeFromSuperview];
                                              }];
                         }];
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

//nstimer method
-(void)stopAnimating
{
    if (self.thermometerImageView.isAnimating) {
        [self.thermometerImageView stopAnimating];
        self.thermometerImageView.image = self.thermometerImageView.animationImages.lastObject;
    }
    if (self.backgroundImageView.isAnimating) {
        [self.backgroundImageView stopAnimating];
        self.backgroundImageView.image = self.backgroundImageView.animationImages.lastObject;
    }
}

//actions
- (IBAction)continueButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//RVAnimatedTextView Delegate Methods
-(void)textViewDidFinishedAnimating:(RVAnimatedTextView *)textView
{
    [self.victoryScreenAudioPlayer stop];
    if ([self.gameData[@"reason"] isEqualToString:@"fail"]) {
        self.victoryScreenAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference victoryScreenFailureWopWop] error:nil];
    } else {
        self.victoryScreenAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference victoryScreenSuccessChime] error:nil];
    }
    [self.victoryScreenAudioPlayer play];
}

-(void)textViewPartiallyFinishedAnimating:(RVAnimatedTextView *)textView
{
    
}

/*
 * Properties
 */
-(void)setTimer:(NSTimer *)timer
{
    _timer = timer;
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

@end
