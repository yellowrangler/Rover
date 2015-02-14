//
//  RVRoverBuildScreenViewController.m
//  Rover
//
//  Created by Sean Fitzgerald on 3/9/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

@import CoreGraphics;
@import AVFoundation;
#import "RVAudioReference.h"
#import "RVRoverBuildScreenViewController.h"
#import "Constants_Segues.h"
#import "Constants_Images.h"
#import "Constants_Layout.h"
#import "Constants_UIUX.h"
#import "RVUtilities.h"
#import "NSArray+LayoutConstraint.h"
#import "RVRoverBuildController.h"
#import "RVRoverBuildTool.h"
#import "RVRoverBuildToolChest.h"
#import "RVRoverBuildLocomotionToolChest.h"
#import "RVRoverBuildAnalyticsToolChest.h"
#import "RVRoverBuildCommunicationToolChest.h"
#import "RVNavigationController.h"
#import "Constants_Build_Graphics.h"

@interface RVRoverBuildScreenViewController () <UIScrollViewDelegate, UIAlertViewDelegate, RVRoverBuildControllerDelegate>

//audio players for the tool actions
@property (nonatomic, strong) AVAudioPlayer * equipToolPlayer;
@property (nonatomic, strong) AVAudioPlayer * pickupToolPlayer;
@property (nonatomic, strong) AVAudioPlayer * returnToolPlayer;

@property (nonatomic, strong) AVAudioPlayer * ambientAudioPlayer;

@property (nonatomic, strong) AVAudioPlayer * clickWheel1AudioPlayer;
@property (nonatomic, strong) AVAudioPlayer * clickWheel2AudioPlayer;
@property (nonatomic, strong) AVAudioPlayer * clickWheel3AudioPlayer;
@property (nonatomic, strong) AVAudioPlayer * clickWheel4AudioPlayer;
@property (nonatomic, strong) AVAudioPlayer * clickWheel5AudioPlayer;
@property (nonatomic, strong) AVAudioPlayer * clickWheel6AudioPlayer;
@property (nonatomic, strong) AVAudioPlayer * clickWheel7AudioPlayer;
@property (nonatomic, strong) AVAudioPlayer * clickWheel8AudioPlayer;
@property (nonatomic, strong) AVAudioPlayer * clickWheel9AudioPlayer;

//outlets and outlet collections
//imageviews
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *communicationCheck;
@property (weak, nonatomic) IBOutlet UIImageView *analysisCheck;
@property (weak, nonatomic) IBOutlet UIImageView *locomotionCheck;
@property (weak, nonatomic) IBOutlet UIImageView *toolTypeButtonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundColor;

//constraints
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *toolTypeButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *locomotionToolTypeCheckShadowConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *communicationToolTypeCheckShadowConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *analysisToolTypeCheckShadowConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *exitButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *scrollViewConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *textViewConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *weightTextViewConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *launchRoverButtonConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *launchRoverCheckGlowConstraints;

//other UI elements
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIButton *launchRoverButton;
@property (weak, nonatomic) IBOutlet UIImageView *launchRoverCheckGlow;
@property (weak, nonatomic) IBOutlet RVAnimatedTextView *guidanceTextView;
@property (weak, nonatomic) IBOutlet RVAnimatedTextView *weightTextView;

//Build System
@property (nonatomic, strong) RVRoverBuildLocomotionToolChest *locomotionToolChest;
@property (nonatomic, strong) RVRoverBuildAnalyticsToolChest *analyticsToolChest;
@property (nonatomic, strong) RVRoverBuildCommunicationToolChest *communicationToolChest;
@property (nonatomic, strong) RVRoverBuildToolChest *activeToolChest;
@property (nonatomic, strong) RVRoverBuildController *roverController;

//state variables used for when the tools are picked up, etc.
@property (nonatomic, strong) RVRoverBuildTool *toolInHand;

@property (nonatomic, assign) CGFloat lastScrollOffset;

@property (nonatomic, strong) UIImage *toolTypeButtonAnalysisUpImage;
@property (nonatomic, strong) UIImage *toolTypeButtonCommunicationUpImage;
@property (nonatomic, strong) UIImage *toolTypeButtonTransportationUpImage;

@property (nonatomic, weak) UIButton *disabledButton;

@end

@implementation RVRoverBuildScreenViewController

/*
 Description of the Rover Build System:
 
 There is a Rover Build Controller that holds references to the tools that are currently attached to the Rover. It has a delegate method that tells when a tool has been attached. This allows the checkmarks on the buttons to light up.
 There are three tool chests (scrollViews), each with separate tools that deal with Analysis, Locomotion, and Communication. They hold references to tools taht are NOT on the Rover.
    Only one is active (visible) at a time, depending on the tool chest button that was tapped.
    When a touch is recognized in a tool chest view, that touch is passed to the currently open toolchest, which returns a reference to the tool that was tapped (IF one was tapped . Otherwise, nil)
 When a touch is recognized NOT in a tool chest view, that touch is passed to the Rover Build Controller, which returns either a tool or nil.
 
 When either the tool chest or the build controller passes back a tool, it relinquishes it's reference to that tool.
 
 When a touch is released anywhere on the screen and a tool is being held, that tool is first checked to see if it can snap with the Rover Build Controller. Otherwise, it is passed back to the tool chest for storage.
 
 */

//view lifecycle methods
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.toolTypeButtonAnalysisUpImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_ROVER_BUILD_SCREEN_TOOL_TYPE_BUTTONS_ANALYSIS_UP
                                                                                                          ofType:@"png"]];
    self.toolTypeButtonCommunicationUpImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_ROVER_BUILD_SCREEN_TOOL_TYPE_BUTTONS_COMMUNICATION_UP
                                                                                                               ofType:@"png"]];
    self.toolTypeButtonTransportationUpImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_ROVER_BUILD_SCREEN_TOOL_TYPE_BUTTONS_TRANSPORTATION_UP
                                                                                                                ofType:@"png"]];
    self.communicationCheck.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_LETS_GO_BUTTON_GLOW];
    self.analysisCheck.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_LETS_GO_BUTTON_GLOW];
    self.locomotionCheck.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_LETS_GO_BUTTON_GLOW];
    self.launchRoverCheckGlow.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_ROVER_BUILD_SCREEN_LAUNCH_ROVER_BUTTON_GLOW
                                                                                                       ofType:@"png"]];
    self.communicationCheck.hidden = self.locomotionCheck.hidden = self.analysisCheck.hidden = self.launchRoverCheckGlow.hidden = YES;

    [self.exitButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_PLANET_SELECT_SCREEN_EXIT_BUTTON
                                                                                               ofType:@"png"]] forState:UIControlStateNormal];
    [self.exitButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_PLANET_SELECT_SCREEN_EXIT_BUTTON_DOWN
                                                                                               ofType:@"png"]] forState:UIControlStateHighlighted];
    [self.launchRoverButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_ROVER_BUILD_SCREEN_LAUNCH_ROVER_BUTTON
                                                                                                      ofType:@"png"]] forState:UIControlStateNormal];
    [self.launchRoverButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_ROVER_BUILD_SCREEN_LAUNCH_ROVER_BUTTON_DOWN
                                                                                                      ofType:@"png"]] forState:UIControlStateHighlighted];

    [self layoutCustomConstraints];
    self.launchRoverCheckGlow.hidden = YES;
    
    [self setupAudioPlayers];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.backgroundImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:RV_IMAGES_ROVER_BUILD_SCREEN_BACKGROUND
                                                                                                      ofType:@"png"]];
    [self communicationButtonDown:nil];
//    self.communicationToolChest.hidden = NO;
//    self.locomotionToolChest.hidden = NO;
//    self.analyticsToolChest.hidden = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.roverController showMessage];
    [self.ambientAudioPlayer play];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.guidanceTextView.sendAlert = NO;
    [self.roverController.messageTimer invalidate];
    [self.guidanceTextView.typingAudioPlayer stop];
    [self.guidanceTextView.underscoreTimer invalidate];
    [self.guidanceTextView.typeTimer invalidate];
    [self.guidanceTextView.typingAudioPlayer stop];
    self.communicationToolChest.hidden = YES;
    self.locomotionToolChest.hidden = YES;
    self.analyticsToolChest.hidden = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.backgroundImageView.image = nil;
    self.toolTypeButtonAnalysisUpImage = nil;
    self.toolTypeButtonCommunicationUpImage = nil;
    self.toolTypeButtonTransportationUpImage = nil;
    self.communicationCheck.image = nil;
    self.analysisCheck.image = nil;
    self.locomotionCheck.image = nil;
    self.launchRoverCheckGlow.image = nil;
    [self.exitButton setImage:nil forState:UIControlStateNormal];
    [self.exitButton setImage:nil forState:UIControlStateHighlighted];
    [self.launchRoverButton setImage:nil forState:UIControlStateNormal];
    [self.launchRoverButton setImage:nil forState:UIControlStateHighlighted];
    self.communicationToolChest = nil;
    self.analyticsToolChest = nil;
    self.locomotionToolChest = nil;
    [self.ambientAudioPlayer stop];
    self.communicationToolChest.hidden = YES;
    self.locomotionToolChest.hidden = YES;
    self.analyticsToolChest.hidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//view touch event methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect windowFrame = rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TOOL_WINDOW_VIEW);
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    if (CGRectContainsPoint(windowFrame, touchPoint) &&
        !self.toolInHand)//the point is inside the toolbox window
    {
        self.toolInHand = [self.activeToolChest toolForTouchLocation:pointFromOrigin(touchPoint, self.activeToolChest.frame.origin)];
        if (self.toolInHand) {
            [self.pickupToolPlayer setCurrentTime:0.0];
            [self.pickupToolPlayer play];
            [self.toolInHand removeFromSuperview];
            CGPoint originDifference = pointFromOrigin(self.activeToolChest.frame.origin, self.view.frame.origin);
            self.toolInHand.center = CGPointMake(self.toolInHand.center.x + originDifference.x,
                                                 self.toolInHand.center.y + originDifference.y);
            [self.view addSubview:self.toolInHand];
        }
    } else if(!self.toolInHand) {
        self.toolInHand = [self.roverController toolForTouchLocation:touchPoint];
        if (self.toolInHand) {//the user tapped a tool attached to the rover
            [self.pickupToolPlayer setCurrentTime:0.0];
            [self.pickupToolPlayer play];
        }
    }
    self.toolInHand.layer.zPosition = 10;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.toolInHand) {//only do stuff if there is an active tool being dragged
        UITouch *aTouch = [touches anyObject];
        CGPoint location = [aTouch locationInView:self.toolInHand];
        CGPoint previousLocation = [aTouch previousLocationInView:self.toolInHand];
        self.toolInHand.frame = CGRectOffset(self.toolInHand.frame,
                                             (location.x - previousLocation.x),
                                             (location.y - previousLocation.y));
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.toolInHand) {
        BOOL snapped = [self.roverController snapTool:self.toolInHand];
        if (!snapped) {
            [self.returnToolPlayer setCurrentTime:0.0];
            [self.returnToolPlayer play];
            //only one chest will actually store the tool. They only store tools that fit in their respective chests
            [self.communicationToolChest storeTool:self.toolInHand];
            [self.locomotionToolChest storeTool:self.toolInHand];
            [self.analyticsToolChest storeTool:self.toolInHand];
        } else {
            [self.equipToolPlayer setCurrentTime:0.0];
            [self.equipToolPlayer play];
            RVNavigationController *nav = (RVNavigationController*)self.navigationController;
            if ([self.toolInHand.toolType isEqualToString:RV_LOCOMOTION_TYPE_TOOL]) {
                nav.roverTransport = self.toolInHand.attachmentType;
            } else {
                nav.roverTool = self.toolInHand.attachmentType;
            }
        }
    }
    self.toolInHand.layer.zPosition = 9;
    if ([self.toolInHand.toolType isEqualToString:RV_LOCOMOTION_TYPE_TOOL]) {
        self.toolInHand.layer.zPosition = 8;
    }
    self.toolInHand = nil;
}

//scrollview delegate methods
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self applyScrollViewOffset];
}

//actions
- (IBAction)next:(id)sender {
    if (!self.launchRoverCheckGlow.hidden) {
        [self performSegueWithIdentifier:RV_SEGUE_ROVER_BUILD_SCREEN_TO_LAUNCH_SCREEN
                                  sender:self];
    }
}

- (IBAction)communicationButtonDown:(UIButton *)sender
{
    self.activeToolChest = self.communicationToolChest;
    self.toolTypeButtonImageView.image = self.toolTypeButtonCommunicationUpImage;
    [self setupScrolling];
    self.disabledButton.enabled = YES;
    sender.enabled = NO;
    self.disabledButton = sender;
}

- (IBAction)analysisButtonDown:(UIButton *)sender
{
    self.activeToolChest = self.analyticsToolChest;
    self.toolTypeButtonImageView.image = self.toolTypeButtonAnalysisUpImage;
    [self setupScrolling];
    self.disabledButton.enabled = YES;
    sender.enabled = NO;
    self.disabledButton = sender;
}

- (IBAction)transportationButtonDown:(UIButton *)sender
{
    self.activeToolChest = self.locomotionToolChest;
    self.toolTypeButtonImageView.image = self.toolTypeButtonTransportationUpImage;
    [self setupScrolling];
    self.disabledButton.enabled = YES;
    sender.enabled = NO;
    self.disabledButton = sender;
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

//UIAlertViewDelegate Methods
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {//the user tapped YES
        [self exitMenuYesAction];
    } else {//the user tapped NO
        [self exitMenuNoAction];
    }
}

//RVRoverBuildController Delegate Methods
-(void)communicationToolAttached
{
    self.communicationCheck.alpha = 0.0;
    self.communicationCheck.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         self.communicationCheck.alpha = 1.0;
                     }];
}

-(void)analysisToolAttached
{
    self.analysisCheck.alpha = 0.0;
    self.analysisCheck.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         self.analysisCheck.alpha = 1.0;
                     }];
}

-(void)locomotionToolAttached
{
    self.locomotionCheck.alpha = 0.0;
    self.locomotionCheck.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         self.locomotionCheck.alpha = 1.0;
                     }];
}

-(void)communicationToolUnattached
{
    self.communicationCheck.alpha = 1.0;
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         self.communicationCheck.alpha = 0.0;
                     }];
}

-(void)analysisToolUnattached
{
    self.analysisCheck.alpha = 1.0;
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         self.analysisCheck.alpha = 0.0;
                     }];
}

-(void)locomotionToolUnattached
{
    self.locomotionCheck.alpha = 1.0;
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         self.locomotionCheck.alpha = 0.0;
                     }];
}

-(void)toolDisplaced:(RVRoverBuildTool *)tool
{
    [self.communicationToolChest storeTool:tool];
    [self.analyticsToolChest storeTool:tool];
    [self.locomotionToolChest storeTool:tool];
}

-(void)roverFinished
{
    self.launchRoverCheckGlow.alpha = 0.0;
    self.launchRoverCheckGlow.hidden = NO;
    self.launchRoverCheckGlow.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_LETS_GO_BUTTON_GLOW];
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         self.launchRoverCheckGlow.alpha = 1.0;
                     }];
}

-(void)roverUnfinished
{
    self.launchRoverCheckGlow.image = [UIImage imageNamed:RV_IMAGES_PLANET_SELECT_SCREEN_LETS_GO_BUTTON_GLOW];
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         self.launchRoverCheckGlow.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.launchRoverCheckGlow.image = nil;
                         self.launchRoverCheckGlow.hidden = YES;
                     }];
}

//helper methods
-(void)setupScrolling
{
    //setup scrolling
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    CGRect scrollViewRect = rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_SCROLLBAR_VIEW);
    UIImage *scrollNubImage = [UIImage imageNamed:RV_IMAGES_ROVER_BUILD_SCREEN_SCROLLBAR];
    int numberNubImages = self.activeToolChest.frame.size.width / (scrollNubImage.size.width + RV_LAYOUT_ROVER_BUILD_SCREEN_SCROLLBAR_DISTANCE_BETWEEN_NUBS/2) + 2;
    UIView * scrollNubHolder = [[UIView alloc] initWithFrame:CGRectMake(-scrollNubImage.size.width/2, (scrollViewRect.size.height - scrollNubImage.size.height)/2, (scrollNubImage.size.width + RV_LAYOUT_ROVER_BUILD_SCREEN_SCROLLBAR_DISTANCE_BETWEEN_NUBS/2) * numberNubImages, scrollNubImage.size.height)];
    for (int i = 0; i < numberNubImages; i++) {
        UIImageView *nubImageView = [[UIImageView alloc] initWithImage:scrollNubImage];
        nubImageView.frame = CGRectMake(RV_LAYOUT_ROVER_BUILD_SCREEN_SCROLLBAR_DISTANCE_BETWEEN_NUBS/4 + i*scrollNubImage.size.width + i*RV_LAYOUT_ROVER_BUILD_SCREEN_SCROLLBAR_DISTANCE_BETWEEN_NUBS/2,
                                        0,
                                        scrollNubImage.size.width,
                                        scrollNubImage.size.height);
        [scrollNubHolder addSubview:nubImageView];
    }
    self.scrollView.contentSize = CGSizeMake(self.activeToolChest.frame.size.width,
                                             scrollNubHolder.frame.size.height);
    [self.scrollView addSubview:scrollNubHolder];
}

-(void)exitMenuYesAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)exitMenuNoAction
{
    //do nothing. the alertview dismisses itself
}

-(void)layoutCustomConstraints
{
    [self.toolTypeButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TOOL_TYPE_BUTTONS)];
    [self.scrollViewConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_SCROLLBAR_VIEW)];
    [self.analysisToolTypeCheckShadowConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TOOL_TYPE_ANALYSIS_CHECK_SHADOW)];
    [self.communicationToolTypeCheckShadowConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TOOL_TYPE_COMMUNICATION_CHECK_SHADOW)];
    [self.locomotionToolTypeCheckShadowConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TOOL_TYPE_LOCOMOTION_CHECK_SHADOW)];
    [self.exitButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_EXIT_BUTTON)];
    [self.textViewConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_TEXT)];
    [self.weightTextViewConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_WEIGHT_TEXT)];
    [self.launchRoverButtonConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_LAUNCH_ROVER_BUTTON)];
    [self.launchRoverCheckGlowConstraints setLayoutRect:rectQuarter((CGRect)RV_LAYOUT_ROVER_BUILD_SCREEN_LAUNCH_ROVER_CHECK_GLOW)];
}

-(void)applyScrollViewOffset
{
    CGRect originalFrame = self.activeToolChest.originalFrame;
    CGFloat xOffset = self.scrollView.contentOffset.x;
    self.activeToolChest.frame = CGRectMake(originalFrame.origin.x - xOffset,
                                            originalFrame.origin.y,
                                            originalFrame.size.width,
                                            originalFrame.size.height);
    
    //all measurements, constants etc. here are because of the scrollview bouncing. There doesn't seem to be an easy way to do it without estimating and testing.
    CGFloat maxOffset = originalFrame.size.width + 400;
    
    NSInteger thisClickValue = round((xOffset + 400) / maxOffset * 9.0);
    NSInteger oldClickValue = round((self.lastScrollOffset + 400) / maxOffset * 9.0);
    
    if (thisClickValue != oldClickValue) {
        switch (thisClickValue) {
            case 1:
                [self.clickWheel1AudioPlayer play];
                break;
            case 2:
                [self.clickWheel2AudioPlayer play];
                break;
            case 3:
                [self.clickWheel3AudioPlayer play];
                break;
            case 4:
                [self.clickWheel4AudioPlayer play];
                break;
            case 5:
                [self.clickWheel5AudioPlayer play];
                break;
            case 6:
                [self.clickWheel6AudioPlayer play];
                break;
            case 7:
                [self.clickWheel7AudioPlayer play];
                break;
            case 8:
                [self.clickWheel8AudioPlayer play];
                break;
            case 9:
                [self.clickWheel9AudioPlayer play];
                break;
                
            default:
                break;
        }
    }
    
    self.lastScrollOffset = xOffset;
}

-(void)setupAudioPlayers
{
    self.returnToolPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenReturn] error:nil];
    self.pickupToolPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenPickup] error:nil];
    self.equipToolPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenEquip] error:nil];
    [self.returnToolPlayer prepareToPlay];
    [self.pickupToolPlayer prepareToPlay];
    [self.equipToolPlayer prepareToPlay];
    
    self.ambientAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenAmbient] error:nil];
    [self.ambientAudioPlayer prepareToPlay];
    self.ambientAudioPlayer.numberOfLoops = -1;
    
    self.clickWheel1AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenClickWheel1] error:nil];
    self.clickWheel2AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenClickWheel2] error:nil];
    self.clickWheel3AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenClickWheel3] error:nil];
    self.clickWheel4AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenClickWheel4] error:nil];
    self.clickWheel5AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenClickWheel5] error:nil];
    self.clickWheel6AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenClickWheel6] error:nil];
    self.clickWheel7AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenClickWheel7] error:nil];
    self.clickWheel8AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenClickWheel8] error:nil];
    self.clickWheel9AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[RVAudioReference roverBuildScreenClickWheel9] error:nil];
    
    [self.clickWheel1AudioPlayer prepareToPlay];
    [self.clickWheel2AudioPlayer prepareToPlay];
    [self.clickWheel3AudioPlayer prepareToPlay];
    [self.clickWheel4AudioPlayer prepareToPlay];
    [self.clickWheel5AudioPlayer prepareToPlay];
    [self.clickWheel6AudioPlayer prepareToPlay];
    [self.clickWheel7AudioPlayer prepareToPlay];
    [self.clickWheel8AudioPlayer prepareToPlay];
    [self.clickWheel9AudioPlayer prepareToPlay];
}

//accessor methods
-(void)setActiveToolChest:(RVRoverBuildToolChest *)activeToolChest
{
    _activeToolChest.hidden = YES;
    activeToolChest.hidden = NO;
    _activeToolChest = activeToolChest;
}

-(RVRoverBuildController *)roverController
{
    if (!_roverController) {
        _roverController = [[RVRoverBuildController alloc] init];
        _roverController.delegate = self;
        _roverController.planet = [(RVNavigationController*)self.navigationController planet];
        _roverController.textView = self.guidanceTextView;
        _roverController.weightTextView = self.weightTextView;
    }
    return _roverController;
}

-(RVRoverBuildCommunicationToolChest *)communicationToolChest
{
    if (!_communicationToolChest) {
        _communicationToolChest = [[RVRoverBuildCommunicationToolChest alloc] init];
        _communicationToolChest.hidden = YES;
        [self.view addSubview:_communicationToolChest];
        [self.view sendSubviewToBack:_communicationToolChest];
        [self.view sendSubviewToBack:self.backgroundColor];
    }
    return _communicationToolChest;
}

-(RVRoverBuildAnalyticsToolChest *)analyticsToolChest
{
    if (!_analyticsToolChest) {
        _analyticsToolChest = [[RVRoverBuildAnalyticsToolChest alloc] init];
        _analyticsToolChest.hidden = YES;
        [self.view addSubview:_analyticsToolChest];
        [self.view sendSubviewToBack:_analyticsToolChest];
        [self.view sendSubviewToBack:self.backgroundColor];
    }
    return _analyticsToolChest;
}

-(RVRoverBuildLocomotionToolChest *)locomotionToolChest
{
    if (!_locomotionToolChest) {
        _locomotionToolChest = [[RVRoverBuildLocomotionToolChest alloc] init];
        _locomotionToolChest.hidden = YES;
        [self.view addSubview:_locomotionToolChest];
        [self.view sendSubviewToBack:_locomotionToolChest];
        [self.view sendSubviewToBack:self.backgroundColor];
    }
    return _locomotionToolChest;
}

-(void)setToolInHand:(RVRoverBuildTool *)toolInHand
{
    _toolInHand = toolInHand;
    [self.view bringSubviewToFront:_toolInHand];
}

@end
