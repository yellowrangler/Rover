//
//  RVGameScreenViewController.m
//  Rover
//
//  Created by Sean Fitzgerald on 3/9/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVGameScreenViewController.h"
#import "Constants_Images.h"
#import "RVCommandLineupController.h"
#import "RVMapController.h"
#import "RVMapView.h"
#import "RVCommandLineupViewTwo.h"
#import "RVAnimatedTextView.h"
#import "RVNavigationController.h"
#import "RVVictoryScreenViewController.h"
#import "NSArray+LayoutConstraint.h"
#import "RVUtilities.h"
#import "Constants_Images.h"
#import "Constants_Layout.h"
#import "Constants_UIUX.h"
#import "Constants_Segues.h"
#import "RVAudioReference.h"
@import AVFoundation;


@interface RVGameScreenViewController () <RVMapControllerAnimationDelegate, UIAlertViewDelegate, RVMapControllerRoverDelegate>

//game views
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet RVMapView *mapView;
@property (weak, nonatomic) IBOutlet RVCommandLineupViewTwo *commandLineupView;

//buttons
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIButton *sendCommandsButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *moveForwardButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *aroundButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *robotArmButton;
@property (weak, nonatomic) IBOutlet UIButton *analyzeButton;
@property (weak, nonatomic) IBOutlet UIButton *tutorialYesButton;
@property (weak, nonatomic) IBOutlet UIButton *tutorialNoButton;

//constraints
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *exitButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *robotArmButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *analyzeButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *rightButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *aroundButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *commandLineupBackgroundConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *commandLineupConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *mapScrollViewConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *leftButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *undoButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *batteryConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *compassRoseConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *sendCommandsButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *moveForwardButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *tutorialYesButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *tutorialNoButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *signalImageViewContraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *signalBackgroundImageViewConstraints;

//imageViews
@property (weak, nonatomic) IBOutlet UIImageView *batteryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *compassRoseSmallImageView;
@property (weak, nonatomic) IBOutlet UIImageView *compassRoseObjectiveImageView;
@property (weak, nonatomic) IBOutlet UIImageView *compassRoseArrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *compassRoseLargeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (weak, nonatomic) IBOutlet UIImageView *signalImageView;
@property (weak, nonatomic) IBOutlet UIImageView *signalBackgroundImageView;

//Game Controllers and utilities
@property (nonatomic, strong) RVCommandLineupController* commandLineupController;
@property (nonatomic, strong) RVMapController* mapController;
@property (nonatomic, assign) BOOL roverAnimating;

//
@property (nonatomic, strong) NSDictionary *gameData;
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, assign) NSInteger numberOfSteps;

//tutorial data
@property (nonatomic, strong) NSArray *tutorialImageNames;
@property (nonatomic, strong) UIImageView *tutorialRoverImageView;
@property (nonatomic, assign) NSInteger tutorialNumber;

@property (nonatomic, strong) AVAudioPlayer *ambientAudioPlayer;
@property (nonatomic, strong) AVAudioPlayer *lowBatterySignalAudioPlayer;
@property (nonatomic, strong) AVAudioPlayer *signalAudioPlayer;

@end

@implementation RVGameScreenViewController

//view lifecycle methods
-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.commandLineupController.roverToolType = [(RVNavigationController*)self.navigationController roverTool];
    
    //set up the delegate structure for the game, itself
    self.commandLineupController.view = self.commandLineupView;
    self.commandLineupController.delegate = self.mapController;
    self.mapController.view = self.mapView;
    self.mapView.animationDelegate = self.mapController;
    self.mapController.roverAnimationDelegate = self;
    self.mapController.roverDelegate = self;
    
    //set up the view
    //constraints
    [self.exitButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_EXIT_BUTTON)];
    [self.robotArmButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_ROBOT_ARM_BUTTON)];
    [self.analyzeButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_ANALYZE_BUTTON)];
    [self.rightButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_RIGHT_BUTTON)];
    [self.aroundButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_AROUND_BUTTON)];
    [self.leftButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_LEFT_BUTTON)];
    [self.sendCommandsButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_SEND_COMMAND_BUTTON)];
    [self.undoButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_UNDO_BUTTON)];
    [self.commandLineupBackgroundConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_COMMMAND_LINEUP_BACKGROUND)];
    [self.commandLineupConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_COMMMAND_LINEUP)];
    [self.mapScrollViewConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_MAP_WINDOW)];
    [self.batteryConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_BATTERY_IMAGE)];
    [self.compassRoseConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_COMPASS_ROSE)];
    [self.moveForwardButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_MOVE_FORWARD_BUTTON)];
    [self.tutorialNoButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_TUTORIAL_NO)];
    [self.tutorialYesButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_TUTORIAL_YES)];
    [self.signalBackgroundImageViewConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_TRANSMISSION_SCREEN)];
    [self.signalImageViewContraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_TRANSMISSION_SIGNAL)];

    //images for buttons
    [self.exitButton setImage:[UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_EXIT_BUTTON] forState:UIControlStateNormal];
    [self.exitButton setImage:[UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_EXIT_BUTTON_DOWN] forState:UIControlStateHighlighted];
    [self.sendCommandsButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_SEND_COMMAND_BUTTON] forState:UIControlStateNormal];
    [self.sendCommandsButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_SEND_COMMAND_BUTTON_DOWN] forState:UIControlStateHighlighted];
    [self.undoButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_UNDO_BUTTON] forState:UIControlStateNormal];
    [self.undoButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_UNDO_BUTTON_DOWN] forState:UIControlStateHighlighted];
    [self.moveForwardButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_MOVE_FORWARD_BUTTON] forState:UIControlStateNormal];
    [self.moveForwardButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_MOVE_FORWARD_BUTTON_DOWN] forState:UIControlStateHighlighted];
    [self.leftButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_LEFT_BUTTON] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_LEFT_BUTTON_DOWN] forState:UIControlStateHighlighted];
    [self.aroundButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_AROUND_BUTTON] forState:UIControlStateNormal];
    [self.aroundButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_AROUND_BUTTON_DOWN] forState:UIControlStateHighlighted];
    [self.rightButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_RIGHT_BUTTON] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_RIGHT_BUTTON_DOWN] forState:UIControlStateHighlighted];
    [self.robotArmButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_ROBOT_ARM_BUTTON] forState:UIControlStateNormal];
    [self.robotArmButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_ROBOT_ARM_BUTTON_DOWN] forState:UIControlStateHighlighted];
    [self.analyzeButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_ANALYZE_BUTTON] forState:UIControlStateNormal];
    [self.analyzeButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_ANALYZE_BUTTON_DOWN] forState:UIControlStateHighlighted];
    [self.tutorialYesButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_YES] forState:UIControlStateNormal];
    [self.tutorialYesButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_YES_DOWN] forState:UIControlStateHighlighted];
    [self.tutorialNoButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_NO] forState:UIControlStateNormal];
    [self.tutorialNoButton setImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_NO_DOWN] forState:UIControlStateHighlighted];
    
    //images for image views
    self.compassRoseLargeImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_COMPASS_ROSE_OUTER];
    self.compassRoseObjectiveImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_COMPASS_ROSE_TEXT_1];
    self.compassRoseSmallImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_COMPASS_ROSE_INNER];
    self.compassRoseArrowImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_COMPASS_ROSE_ARROW];
    self.batteryImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_BATTERY_IMAGE_4];
    self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_BACKGROUND];
    self.mapName = [(RVNavigationController*)self.navigationController planet];
    self.roverName = [(RVNavigationController*)self.navigationController roverTransport];
    self.mapController.mapName = self.mapName;
    self.mapController.roverName = self.roverName;
    
    self.ambientAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference navigationScreenAmbient] error:nil];
    self.ambientAudioPlayer.numberOfLoops = -1;
    [self.ambientAudioPlayer prepareToPlay];
    self.signalAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference navigationScreenTransmission] error:nil];
    [self.signalAudioPlayer prepareToPlay];
    self.lowBatterySignalAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference navigationScreenLowBattery] error:nil];
    [self.lowBatterySignalAudioPlayer prepareToPlay];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.backgroundImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_BACKGROUND];
    if (!self.loaded) {
        self.loaded = YES;
        self.tutorialImageNames = @[RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_1,
                                    RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_2,
                                    RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_3,
                                    RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_4,
                                    RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_5,
                                    RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_6,
                                    RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_7,
                                    RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_8,
                                    RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_9];
        self.tutorialImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_TUTORIAL_1];
    } else {
        self.tutorialYesButton.hidden = YES;
        self.tutorialNoButton.hidden = YES;
        self.tutorialImageView.hidden = YES;
    }
    [self.ambientAudioPlayer play];
    
    //make the compass images animate rotation in opposite directions
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = @0.0;
    rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
    rotation.duration = RV_UIUX_GAME_PLAY_SCREEN_GLOW_ROTATION_DURATION; // time for rotation
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    [self.compassRoseLargeImageView.layer addAnimation:rotation forKey:@"Spin"];
    [self.compassRoseSmallImageView.layer addAnimation:[rotation copy] forKey:@"Spin"];
    CABasicAnimation *backwardsRotation = [rotation copy];
    backwardsRotation.toValue = [NSNumber numberWithFloat:(-2*M_PI)];
    [self.compassRoseObjectiveImageView.layer addAnimation:backwardsRotation forKey:@"Spin"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mapView calibrateCompass];
    [self.mapView modifiedScrollRectToViewableWithoutAnimation];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:RV_SEGUE_GAME_SCREEN_TO_VICTORY_SCREEN]) {
        RVVictoryScreenViewController *vc = segue.destinationViewController;
        vc.gameData = self.gameData;
    }
    [super prepareForSegue:segue sender:sender];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.ambientAudioPlayer stop];
}

//accessor methods
-(RVCommandLineupController *)commandLineupController
{
    if (!_commandLineupController) {
        _commandLineupController = [[RVCommandLineupController alloc] init];
    }
    return _commandLineupController;
}

-(RVMapController *)mapController
{
    if (!_mapController) {
        _mapController = [[RVMapController alloc] init];
    }
    return _mapController;
}

//button actions
- (IBAction)moveForwardTapped:(UIButton *)sender {
    if (!self.roverAnimating) {
        [self.commandLineupController moveForward];

    }
}
- (IBAction)leftTurnTapped:(UIButton *)sender {
    if (!self.roverAnimating) {
        [self.commandLineupController turnLeft];
    }
}
- (IBAction)rightTurnTapped:(UIButton *)sender {
    if (!self.roverAnimating) {
        [self.commandLineupController turnRight];
    }
}
- (IBAction)turnAroundTapped:(UIButton *)sender {
    if (!self.roverAnimating) {
        [self.commandLineupController turnAround];
    }
}
- (IBAction)robotArmTapped:(UIButton *)sender {
    if (!self.roverAnimating) {
        [self.commandLineupController action];
    }
}
- (IBAction)analyzeTapped:(UIButton *)sender {
    if (!self.roverAnimating) {
        [self.commandLineupController analyze];
    }
}
- (IBAction)executeCommandLineup:(UIButton *)sender {
    if (!self.roverAnimating &&
        self.commandLineupController.commandLineup.count > 0) {
        self.roverAnimating = YES;
        [self transmissionAnimation];
    }
}
- (IBAction)undoPreviousCommand:(UIButton *)sender {
    if (!self.roverAnimating) {
        [self.commandLineupController undo];
    }
}
- (IBAction)exitButtonTapped:(UIButton *)sender {
    [[[UIAlertView alloc] initWithTitle:@"End Mission"
                                message:@"Are you sure you want to end your mission?"
                               delegate:self
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@"Yes", nil] show];
}
- (void)tutorialTapped {
    self.tutorialNumber++;
    if (self.tutorialNumber == 1) {
        //show the rover on the top
        self.tutorialRoverImageView = [[UIImageView alloc] initWithImage:self.mapView.roverImage];
        self.tutorialRoverImageView.frame = self.mapView.roverImageView.frame;
        self.tutorialRoverImageView.center = CGPointMake(self.mapView.frame.origin.x + (self.mapView.roverImageView.frame.origin.x - self.mapView.contentOffset.x) + self.mapView.roverImageView.frame.size.width / 2,
                                                       self.mapView.frame.origin.y + (self.mapView.roverImageView.frame.origin.y - self.mapView.contentOffset.y) + self.mapView.roverImageView.frame.size.height / 2);
        [self.view addSubview:self.tutorialRoverImageView];
    }
    if (self.tutorialNumber == 2) {
        [self.tutorialRoverImageView removeFromSuperview];
    }
    if (self.tutorialNumber == self.tutorialImageNames.count) {
        self.tutorialImageView.hidden = YES;
        return;
    }
    self.tutorialImageView.image = [UIImage imageNamed:self.tutorialImageNames[self.tutorialNumber]];
}
- (IBAction)tutorialYesTapped:(id)sender {
    [self.tutorialImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(tutorialTapped)]];
    self.tutorialNoButton.hidden = YES;
    self.tutorialYesButton.hidden = YES;
    [self tutorialTapped];
}
- (IBAction)tutorialNoTapped:(id)sender {
    self.tutorialImageView.hidden = YES;
    self.tutorialNoButton.hidden = YES;
    self.tutorialYesButton.hidden = YES;
}

//UIAlertViewDelegate Methods
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"End Mission"]) {
        if (buttonIndex == 1) {//the user tapped YES
            [self exitMenuYesAction];
        } else {//the user tapped NO
            [self exitMenuNoAction];
        }
    }
}

//RVMapControllerRoverDelegate methods
-(void)roverFinishedObjectiveNumber:(NSInteger)objectiveNumber
{
    NSString *guideName;
    if ([self.mapName isEqualToString:@"moon"]) {
        guideName = @"Jacob";
    } else if ([self.mapName isEqualToString:@"pluto"]) {
        guideName = @"India";
    } else if ([self.mapName isEqualToString:@"mars"]) {
        guideName = @"Jacob";
    } else if ([self.mapName isEqualToString:@"titan"]) {
        guideName = @"India";
    }
    switch (objectiveNumber) {
        case 0:
            self.gameData = @{@"guide":guideName,
                              @"reason":@"first",
                              @"planet":self.mapName};
            self.compassRoseObjectiveImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_COMPASS_ROSE_TEXT_2];
            break;
        case 1:
            self.gameData = @{@"guide":guideName,
                              @"reason":@"second",
                              @"planet":self.mapName};
            self.compassRoseObjectiveImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_COMPASS_ROSE_TEXT_3];
            break;
        case 2:
            self.gameData = @{@"guide":guideName,
                              @"reason":@"final",
                              @"planet":self.mapName};
            break;
            
        default:
            break;
    }
    [self performSegueWithIdentifier:RV_SEGUE_GAME_SCREEN_TO_VICTORY_SCREEN sender:self];
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

-(void)roverFinishedMoving:(NSInteger)numberOfSteps
{
    self.roverAnimating = NO;
}

-(void)roverTookOneStep
{
    NSInteger numberOfSteps = self.numberOfSteps = self.numberOfSteps + 1;
    if (numberOfSteps < RV_MAX_BATTERY_LIFE / 5) {
        self.batteryImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_BATTERY_IMAGE_4];
    } else if(numberOfSteps < RV_MAX_BATTERY_LIFE * 2 / 5){
        self.batteryImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_BATTERY_IMAGE_3];
    } else if(numberOfSteps < RV_MAX_BATTERY_LIFE * 3 / 5){
        self.batteryImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_BATTERY_IMAGE_2];
    } else if(numberOfSteps < RV_MAX_BATTERY_LIFE * 4 / 5){
        self.batteryImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_BATTERY_IMAGE_1];
    } else if (numberOfSteps == RV_MAX_BATTERY_LIFE * 4 / 5){
        [self.lowBatterySignalAudioPlayer play];
        self.batteryImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_BATTERY_IMAGE_1_RED];
        [UIView animateWithDuration:RV_BATTERY_FLICKER_RATE
                         animations:^(void){
                             self.batteryImageView.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:RV_BATTERY_FLICKER_RATE
                                              animations:^(void){
                                                  self.batteryImageView.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished){
                                                  if (self.numberOfSteps >= 16){
                                                      [self.lowBatterySignalAudioPlayer play];
                                                      [UIView animateWithDuration:RV_BATTERY_FLICKER_RATE
                                                                       animations:^(void){
                                                                           self.batteryImageView.alpha = 0.0;
                                                                       }
                                                                       completion:^(BOOL finished){
                                                                           [UIView animateWithDuration:RV_BATTERY_FLICKER_RATE
                                                                                            animations:^(void){
                                                                                                self.batteryImageView.alpha = 1.0;
                                                                                            }
                                                                                            completion:^(BOOL finished){
                                                                                                if (self.numberOfSteps >= 16){
                                                                                                    [self.lowBatterySignalAudioPlayer play];
                                                                                                    [self flickerBatteryLife];
                                                                                                }
                                                                                            }];
                                                                       }];
                                                  }
                                              }];
                         }];
//    } else if (numberOfSteps == (int)(RV_MAX_BATTERY_LIFE * 0.95)){
//        [self.lowBatterySignalAudioPlayer play];
//        self.batteryImageView.image = [UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_BATTERY_IMAGE_1_RED];
//        [self flickerBatteryLife];
    }  else if (numberOfSteps == 20){
        self.batteryImageView.image = nil;
        self.gameData = @{@"guide":@"Jacob",
                          @"reason":@"fail",
                          @"planet":self.mapName};
        [self performSegueWithIdentifier:RV_SEGUE_GAME_SCREEN_TO_VICTORY_SCREEN sender:self];
    }
}

-(void)flickerBatteryLife
{
    [UIView animateWithDuration:RV_BATTERY_FLICKER_RATE
                     animations:^(void){
                         self.batteryImageView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:RV_BATTERY_FLICKER_RATE
                                          animations:^(void){
                                              self.batteryImageView.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished){
                                              if (self.numberOfSteps >= RV_MAX_BATTERY_LIFE * 4 / 5 &&
                                                  !(self.numberOfSteps >= RV_MAX_BATTERY_LIFE)){
                                                  if (self.numberOfSteps >= (int)(RV_MAX_BATTERY_LIFE * 0.95)) {
                                                      [self.lowBatterySignalAudioPlayer play];
                                                  }
                                                  [self flickerBatteryLife];
                                              }
                                          }];
                     }];
}

-(void)updateCompassRoseAngle:(double)angle
{
    self.compassRoseArrowImageView.transform = CGAffineTransformMakeRotation(angle);
}

-(void)transmissionAnimation
{
    [self.signalAudioPlayer play];
    self.signalImageView.image = [UIImage imageNamed:@"transmittingSignal.png"];
    self.signalBackgroundImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@TransmittingScreen.png", [(RVNavigationController*)self.navigationController planet]]];
    self.signalBackgroundImageView.hidden = NO;
    self.signalImageView.hidden = NO;
    [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:0.4
                                                                          target:self
                                                                        selector:@selector(swapSignal:)
                                                                        userInfo:@{@"time":@0}
                                                                         repeats:NO]
                                 forMode:NSRunLoopCommonModes];
}

//timer fire methods
-(void)swapSignal:(NSTimer*)timer
{
    NSInteger count = [timer.userInfo[@"time"] integerValue];
    if (count  % 2) { //count is even
        self.signalImageView.hidden = YES;
    } else { //count is odd
        self.signalImageView.hidden = NO;
    }
    if (count == 4) {
        self.signalBackgroundImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@TransmittingScreen.png", [(RVNavigationController*)self.navigationController planet]]];
        self.signalImageView.image = [UIImage imageNamed:@"receivingSignal.png"];
    }
    if (count < 8) {
        [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:0.4
                                                                              target:self
                                                                            selector:@selector(swapSignal:)
                                                                            userInfo:@{@"time":[NSNumber numberWithInteger:count+1]}
                                                                             repeats:NO] forMode:NSRunLoopCommonModes];
    } else {
        self.signalBackgroundImageView.hidden = YES;
        self.signalImageView.hidden = YES;
        [self.commandLineupController execute];
    }
}

- (IBAction)unwindToGameScreen:(UIStoryboardSegue *)unwindSegue
{
}

- (IBAction)resetGameScreenWithNoTutorial:(UIStoryboardSegue *)unwindSegue
{
//    [self.navigationController popViewControllerAnimated:NO];
}

@end
