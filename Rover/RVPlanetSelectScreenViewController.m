//
//  RVPlanetSelectScreenViewController.m
//  Rover
//
//  Created by Sean Fitzgerald on 3/9/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVPlanetSelectScreenViewController.h"
#import "Constants_Segues.h"
#import "Constants_Images.h"
#import "Constants_Layout.h"
#import "Constants_UIUX.h"
#import "Constants_Content.h"
#import "RVUtilities.h"
#import "RVAnimatedTextView.h"
#import "NSArray+LayoutConstraint.h"
#import "RVNavigationController.h"
#import "RVIndiaGuindanceSystem.h"
#import "RVAudioReference.h"
@import AVFoundation;

@interface RVPlanetSelectScreenViewController () <RVAnimatedTextDelegate, UIAlertViewDelegate, RVIndiaGuidanceDelegate>

@property (nonatomic, strong) AVAudioPlayer * ambientAudioPlayer;
@property (nonatomic, strong) NSTimer *guidanceMessageTimer;

//layout properties
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *moonButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *marsButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *titanButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *plutoButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *moonGlowConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *marsGlowConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *titanGlowConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *plutoGlowConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *exitButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *letsGoButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *letsGoGlowConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *indiaTextViewConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *planetInformationImageViewConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *earthButtonConstraints;

//imageViews
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *planetInformationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *letsGoGlow;

//planet glows
@property (nonatomic, weak) IBOutlet UIImageView *moonGlowImageView;
@property (nonatomic, weak) IBOutlet UIImageView *marsGlowImageView;
@property (nonatomic, weak) IBOutlet UIImageView *titanGlowImageView;
@property (nonatomic, weak) IBOutlet UIImageView *plutoGlowImageView;

//buttons
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIButton *letsGoButton;

//easier storage
@property (nonatomic, strong) NSArray *planetGlows;

//Guidance System
@property (nonatomic, strong) RVIndiaGuindanceSystem *guidanceSystem;
@property (weak, nonatomic) IBOutlet RVAnimatedTextView *indiaTextView;

//logic
@property (nonatomic, strong) NSString *selectedPlanet;

@end

@implementation RVPlanetSelectScreenViewController

/*
 TODO LIST
 */

//view lifecycle methods
-(void)viewDidLoad{
    [super viewDidLoad];
    
    //set images
    [self.exitButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_PLANET_SELECT_SCREEN_EXIT_BUTTON ofType:@"png"]]
                     forState:UIControlStateNormal];
    [self.exitButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_PLANET_SELECT_SCREEN_EXIT_BUTTON_DOWN ofType:@"png"]]
                     forState:UIControlStateHighlighted];
    [self.letsGoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_PLANET_SELECT_SCREEN_LETS_GO_BUTTON ofType:@"png"]]
                       forState:UIControlStateNormal];
    [self.letsGoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_PLANET_SELECT_SCREEN_LETS_GO_BUTTON_DOWN ofType:@"png"]]
                       forState:UIControlStateHighlighted];
    self.moonGlowImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_PLANET_SELECT_SCREEN_MOON_GLOW ofType:@"png"]];
    self.marsGlowImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_PLANET_SELECT_SCREEN_MARS_GLOW ofType:@"png"]];
    self.titanGlowImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_PLANET_SELECT_SCREEN_TITAN_GLOW ofType:@"png"]];
    self.plutoGlowImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_PLANET_SELECT_SCREEN_PLUTO_GLOW ofType:@"png"]];
    
    //set up the planet glow rotations
    self.planetGlows = @[self.moonGlowImageView, self.marsGlowImageView, self.titanGlowImageView, self.plutoGlowImageView];
    for (UIImageView *iv in self.planetGlows) {
        iv.hidden = YES;
        CABasicAnimation *rotation;
        rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.fromValue = [NSNumber numberWithFloat:0];
        rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
        rotation.duration = RV_UIUX_PLANET_SELECT_SCREEN_GLOW_ROTATION_DURATION; // time for rotation
        rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
        [iv.layer addAnimation:rotation forKey:@"Spin"];
    }
    
    //set up the animated typing view
    self.indiaTextView.typeInterval = RV_UIUX_TEXT_ANIMATION_INTERVAL;
    self.indiaTextView.editable = YES;
    UIFont * font = [UIFont fontWithName:RV_UIUX_TEXT_FONT_NAME size:RV_UIUX_TEXT_FONT_SIZE];
    self.indiaTextView.font = font;
    self.indiaTextView.editable = NO;
    self.indiaTextView.animationDelegate = self;
    self.indiaTextView.textColor = [UIColor whiteColor];
    self.indiaTextView.sendAlert = YES;
    CALayer *textLayer = (CALayer *)[self.indiaTextView.layer.sublayers objectAtIndex:0];
    textLayer.shadowColor = [UIColor whiteColor].CGColor;
    textLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    textLayer.shadowOpacity = 1.0f;
    textLayer.shadowRadius = 3.0f;
    
    self.letsGoButton.hidden = NO;
    
    //layout constraints
    [self.letsGoButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_PLANET_SELECTOR_SCREEN_LETS_GO_BUTTON)];
    [self.letsGoGlowConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_PLANET_SELECTOR_SCREEN_LETS_GO_BUTTON_GLOW)];
    [self.exitButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_PLANET_SELECTOR_SCREEN_EXIT_BUTTON)];
    [self.planetInformationImageViewConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_PLANET_SELECTOR_SCREEN_PLANET_INFO)];
    [self.indiaTextViewConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_PLANET_SELECTOR_SCREEN_TEXT)];
    [self.moonButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_PLANET_SELECTOR_SCREEN_MOON)];
    [self.marsButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_PLANET_SELECTOR_SCREEN_MARS)];
    [self.titanButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_PLANET_SELECTOR_SCREEN_TITAN)];
    [self.plutoButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_PLANET_SELECTOR_SCREEN_PLUTO)];
    [self.earthButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_PLANET_SELECTOR_SCREEN_EARTH_BUTTON)];
    [self.moonGlowConstraints setLayoutSize:sizeQuarter((CGSize)RV_LAYOUT_PLANET_SELECTOR_SCREEN_MOON_GLOW)];
    [self.marsGlowConstraints setLayoutSize:sizeQuarter((CGSize)RV_LAYOUT_PLANET_SELECTOR_SCREEN_MARS_GLOW)];
    [self.titanGlowConstraints setLayoutSize:sizeQuarter((CGSize)RV_LAYOUT_PLANET_SELECTOR_SCREEN_TITAN_GLOW)];
    [self.plutoGlowConstraints setLayoutSize:sizeQuarter((CGSize)RV_LAYOUT_PLANET_SELECTOR_SCREEN_PLUTO_GLOW)];
    
    //setup guidance system;
    self.guidanceSystem.delegate = self;
    
    self.ambientAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference planetSelectScreenAmbient] error:nil];
    [self.ambientAudioPlayer prepareToPlay];
    self.ambientAudioPlayer.numberOfLoops = -1;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_BACKGROUND];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.guidanceSystem nextMessage];
    [self.ambientAudioPlayer play];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.indiaTextView.typingAudioPlayer stop];
    [self.indiaTextView.underscoreTimer invalidate];
    [self.indiaTextView.typeTimer invalidate];
    [self.indiaTextView.typingAudioPlayer stop];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.backgroundImageView.image = nil;
    [self.exitButton setImage:nil forState:UIControlStateNormal];
    [self.exitButton setImage:nil forState:UIControlStateHighlighted];
    [self.letsGoButton setImage:nil forState:UIControlStateNormal];
    [self.letsGoButton setImage:nil forState:UIControlStateHighlighted];
    self.moonGlowImageView.image = nil;
    self.marsGlowImageView.image = nil;
    self.titanGlowImageView.image = nil;
    self.plutoGlowImageView.image = nil;

    [self.ambientAudioPlayer stop];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:RV_SEGUE_PLANET_SELECT_SCREEN_TO_ROVER_BUILD_SCREEN]) {
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

//actions
- (IBAction)moonButtonDown:(UIButton *)sender {
    for (UIImageView *iv in self.planetGlows) {
        iv.hidden = YES;
    }
    self.moonGlowImageView.hidden = NO;
//    self.indiaTextView.animatedText = RV_CONTENT_PLANET_SELECTOR_SCREEN_INDIA_TEXT_MOON;
    self.planetInformationImageView.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_PLANET_INFORMATION_MOON];
    self.selectedPlanet = @"moon";
}

- (IBAction)marsButtonDown:(UIButton *)sender {
    for (UIImageView *iv in self.planetGlows) {
        iv.hidden = YES;
    }
    self.marsGlowImageView.hidden = NO;
//    self.indiaTextView.animatedText = RV_CONTENT_PLANET_SELECTOR_SCREEN_INDIA_TEXT_MARS;
    self.planetInformationImageView.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_PLANET_INFORMATION_MARS];
    self.selectedPlanet = @"mars";
}

- (IBAction)titanButtonDown:(UIButton *)sender {
    for (UIImageView *iv in self.planetGlows) {
        iv.hidden = YES;
    }
    self.titanGlowImageView.hidden = NO;
//    self.indiaTextView.animatedText = RV_CONTENT_PLANET_SELECTOR_SCREEN_INDIA_TEXT_TITAN;
    self.planetInformationImageView.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_PLANET_INFORMATION_TITAN];
    self.selectedPlanet = @"titan";
}

- (IBAction)plutoButtonDown:(UIButton *)sender {
    for (UIImageView *iv in self.planetGlows) {
        iv.hidden = YES;
    }
    self.plutoGlowImageView.hidden = NO;
//    self.indiaTextView.animatedText = RV_CONTENT_PLANET_SELECTOR_SCREEN_INDIA_TEXT_PLUTO;
    self.planetInformationImageView.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_PLANET_INFORMATION_PLUTO];
    self.selectedPlanet = @"pluto";
}

- (IBAction)exitButtonTapped:(UIButton *)sender {
    /*[[[UIAlertView alloc] initWithTitle:@"Quit the game."
                                message:@"Are you sure?"
                               delegate:self
                      cancelButtonTitle:@"NO"
                      otherButtonTitles:@"YES", nil] show];*/
    [[[UIAlertView alloc] initWithTitle:@"End Mission"
                                message:@"Are you sure you want to end your mission?"
                               delegate:self
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@"Yes", nil] show];
}

- (IBAction)next:(id)sender {
    if (self.selectedPlanet) {
        [self performSegueWithIdentifier:RV_SEGUE_PLANET_SELECT_SCREEN_TO_ROVER_BUILD_SCREEN
                                  sender:self];
    }
}

- (IBAction)earthButtonTapped:(UIButton *)sender {
    for (UIImageView *iv in self.planetGlows) {
        iv.hidden = YES;
    }
    self.selectedPlanet = nil;
}

//UIAlertViewDelegate Methods
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {//the user tapped YES
        [self exitMenuYesAction];
    } else {//the user tapped NO
        [self exitMenuNoAction];
    }
}

//RVIndiaGuidanceSystemDelegate Methods
-(void)writeMessage:(NSString *)message
{
    [self.guidanceMessageTimer invalidate];
    self.indiaTextView.animatedText = message;
}

-(void)finishedIntroduction
{
    //do nothing
}

//RVTextViewAnimationDelegate
-(void)textViewDidFinishedAnimating:(RVAnimatedTextView *)textView
{
    //wait two seconds so that the user can read the text
    self.guidanceMessageTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                 target:self.guidanceSystem
                                                               selector:@selector(nextMessage)
                                                               userInfo:nil
                                                                repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.guidanceMessageTimer
                                 forMode:NSRunLoopCommonModes];
}

-(void)textViewPartiallyFinishedAnimating:(RVAnimatedTextView *)textView
{
    //do nothing
}

//helper methods
-(void)exitMenuYesAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)exitMenuNoAction
{
    //do nothing because the alert view dismisses itself
}

-(void)finishedTyping
{
    self.letsGoButton.hidden = NO;
}

//accessor methods
-(void)setSelectedPlanet:(NSString *)selectedPlanet
{
    _selectedPlanet = selectedPlanet;
    if (selectedPlanet) {
        self.letsGoGlow.alpha = 0.0;
        self.letsGoGlow.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_LETS_GO_BUTTON_GLOW];
        [UIView animateWithDuration:0.3
                         animations:^(void){
                             self.letsGoGlow.alpha = 1.0;
                         }];
    } else {
        self.letsGoGlow.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_LETS_GO_BUTTON_GLOW];
        [UIView animateWithDuration:0.3
                         animations:^(void){
                             self.letsGoGlow.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             self.letsGoGlow.image = nil;
                         }];
        self.planetInformationImageView.image = nil;
    }
    RVNavigationController *nav = (RVNavigationController*)self.navigationController;
    nav.planet = selectedPlanet;
    if ([selectedPlanet isEqualToString:@"moon"]) {
        nav.roverTransport = @"Wheels";
        nav.roverTool = @"weatherStation";
    } else if ([selectedPlanet isEqualToString:@"pluto"]) {
        nav.roverTransport = @"Treads";
        nav.roverTool = @"pancam";
    } else if ([selectedPlanet isEqualToString:@"titan"]) {
        nav.roverTransport = @"Hovercraft";
        nav.roverTool = @"microscope";
    }
    self.guidanceSystem.selectedPlanet = selectedPlanet;
    [self.guidanceSystem nextMessage];
}

-(RVIndiaGuindanceSystem *)guidanceSystem
{
    if (!_guidanceSystem) {
        _guidanceSystem = [[RVIndiaGuindanceSystem alloc] init];
    }
    return _guidanceSystem;
}

@end