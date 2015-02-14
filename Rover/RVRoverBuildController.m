//
//  RVRoverBuildController.m
//  Rover
//
//  Created by Sean Fitzgerald on 5/7/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVRoverBuildController.h"
#import "Constants_Layout.h"
#import "RVUtilities.h"
#import "Constants_UIUX.h"
#import "RVJacobGuidanceController.h"
#import "Constants_Build_Graphics.h"

@interface RVRoverBuildController() <RVJacobGuidanceDelegate, RVAnimatedTextDelegate>

@property (nonatomic, strong) NSMutableDictionary *attachmentPoints;
@property (nonatomic, strong) NSMutableArray *tools;

@property (nonatomic, strong) NSMutableArray *singleAttachmentPoints;
@property (nonatomic, strong) NSMutableDictionary *toolsAttachedAtPoints;

@property (nonatomic, strong) RVJacobGuidanceController *jacobGuidance;

@end

@implementation RVRoverBuildController

//overide methods
-(id)init
{
    self = [super init];
    if (self) {
        [self setupAtttachmentPoints];
    }
    return self;
}

//helper methods
-(void)setupAtttachmentPoints
{
    NSMutableArray *attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ROVER_ATTACHMENT_POINTS_TREADS) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_TREADS_ATTACHMENT_POINTS:attachmentArray}];
    
    attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ROVER_ATTACHMENT_POINTS_WHEELS) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_WHEELS_ATTACHMENT_POINTS:attachmentArray}];
    
    attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_TRANSPORTATION_TOOLS_ROVER_ATTACHMENT_POINTS_HOVERCRAFT) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_HOVERCRAFT_ATTACHMENT_POINTS:attachmentArray}];
    
    attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ROVER_ATTACHMENT_POINTS_CHEMCAM) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_CHEMCAM_ATTACHMENT_POINTS:attachmentArray}];
    
    attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ROVER_ATTACHMENT_POINTS_LASER_DRILL) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_LASER_DRILL_ATTACHMENT_POINTS:attachmentArray}];
    
    attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ROVER_ATTACHMENT_POINTS_MICROSCOPE) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_MICROSCOPE_ATTACHMENT_POINTS:attachmentArray}];
    
    attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ROVER_ATTACHMENT_POINTS_ROCK_GRINDER) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_ROCK_GRINDER_ATTACHMENT_POINTS:attachmentArray}];
    
    attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ROVER_ATTACHMENT_POINTS_SPECTROMETER) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_SPECTROMETER_ATTACHMENT_POINTS:attachmentArray}];
    
    attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_ANALYSIS_TOOLS_ROVER_ATTACHMENT_POINTS_WEATHER_STATION) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_WEATHER_STATION_ATTACHMENT_POINTS:attachmentArray}];
    
    attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ROVER_ATTACHMENT_POINTS_HGANTENNA) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_HGANTENNA_ATTACHMENT_POINTS:attachmentArray}];
    
    attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ROVER_ATTACHMENT_POINTS_LGANTENNA) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_LGANTENNA_ATTACHMENT_POINTS:attachmentArray}];
    
    attachmentArray = [[NSMutableArray alloc] init];
    for (NSDictionary * pointDict in RV_LAYOUT_ROVER_BUILD_SCREEN_COMMUNICATION_TOOLS_ROVER_ATTACHMENT_POINTS_PANCAM) {
        CGPoint attPoint = pointHalf(CGPointMake([pointDict[@"X"] doubleValue], [pointDict[@"Y"] doubleValue]));
        [attachmentArray addObject:[NSValue valueWithCGPoint:attPoint]];
    }
    [self.attachmentPoints addEntriesFromDictionary:@{RV_PANCAM_ATTACHMENT_POINTS:attachmentArray}];
    
    for (NSString *key  in self.attachmentPoints.allKeys) {
        for (NSValue *pointValue in self.attachmentPoints[key]) {
            if (![self.singleAttachmentPoints containsObject:pointValue]) {
                [self.singleAttachmentPoints addObject:pointValue];
                [self.toolsAttachedAtPoints setObject:[@{@"tool_here":@NO} mutableCopy] forKey:pointValue];
            }
        }
    }
}

//public methods
-(BOOL)snapTool:(RVRoverBuildTool*)tool
{
    //check if the tool can attach to any of the points.
    NSArray *attachmentPoints = self.attachmentPoints[tool.attachmentType];
    BOOL attachable = NO;
    CGPoint attachmentPoint;
    for (NSValue *pointValue in attachmentPoints) {
        CGPoint roverAttachmentPoint = [pointValue CGPointValue];
        CGPoint toolAttachmentPoint = CGPointMake(tool.attachmentPoint.x + tool.frame.origin.x, tool.attachmentPoint.y + tool.frame.origin.y);
        if (pointIsNearPoint(roverAttachmentPoint, toolAttachmentPoint, RV_UIUX_ROVER_BUILD_SCREEN_MINIMUM_SNAP_DISTANCE))
        {
            attachable = YES;
            attachmentPoint = [pointValue CGPointValue];
            break;
        }
    }
    if (attachable) {
        [self.tools addObject:tool];
        if ([self.toolsAttachedAtPoints[[NSValue valueWithCGPoint:attachmentPoint]][@"tool_here"] boolValue]) {
            //there is already a tool here. Remove it.
            RVRoverBuildTool *toolOld = self.toolsAttachedAtPoints[[NSValue valueWithCGPoint:attachmentPoint]][@"tool"];
            [self.jacobGuidance removeTool:toolOld];
            if ([toolOld.toolType isEqualToString:RV_COMMUNICATION_TYPE_TOOL] &&
                !self.jacobGuidance.communicationSystemCompleted) {
                [self.delegate communicationToolUnattached];
            } else if ([toolOld.toolType isEqualToString:RV_ANALYSIS_TYPE_TOOL] &&
                       !self.jacobGuidance.analysisSystemCompleted) {
                [self.delegate analysisToolUnattached];
            } else if ([toolOld.toolType isEqualToString:RV_LOCOMOTION_TYPE_TOOL] &&
                       !self.jacobGuidance.locomotionSystemCompleted) {
                [self.delegate locomotionToolUnattached];
            }
            [self.tools removeObject:toolOld];
            [self.delegate toolDisplaced:toolOld];
            self.toolsAttachedAtPoints[[NSValue valueWithCGPoint:attachmentPoint]][@"tool_here"] = @NO;
        }
        [tool animateToAttachmentPoint:attachmentPoint];
        self.toolsAttachedAtPoints[[NSValue valueWithCGPoint:attachmentPoint]][@"tool_here"] = @YES;
        self.toolsAttachedAtPoints[[NSValue valueWithCGPoint:attachmentPoint]][@"tool"] = tool;
        
        //alert the guidance system that there is a new tool;
        [self.jacobGuidance newTool:tool];
        self.weightTextView.text = [NSString stringWithFormat:@"%ld", (long)self.jacobGuidance.currentWeight];
        if (self.jacobGuidance.currentWeight > 185) { // More than 185 is an incorrect rover and it cannot fly
            self.weightTextView.textColor = [UIColor redColor];
        } else {
            self.weightTextView.textColor = [UIColor whiteColor];
        }
        
        //now we need to find out if that tool is required so that we can undo the check glow marks
        if ([tool.toolType isEqualToString:RV_COMMUNICATION_TYPE_TOOL] &&
            self.jacobGuidance.communicationSystemCompleted) {
            [self.delegate communicationToolAttached];
        } else if ([tool.toolType isEqualToString:RV_ANALYSIS_TYPE_TOOL] &&
                   self.jacobGuidance.analysisSystemCompleted) {
            [self.delegate analysisToolAttached];
        } else if ([tool.toolType isEqualToString:RV_LOCOMOTION_TYPE_TOOL] &&
                   self.jacobGuidance.locomotionSystemCompleted) {
            [self.delegate locomotionToolAttached];
        }
    }
    return attachable;
}

-(RVRoverBuildTool*)toolForTouchLocation:(CGPoint)touch
{
    RVRoverBuildTool *tappedTool = nil;
    for (RVRoverBuildTool *tool in self.tools) {
        if (CGRectContainsPoint(tool.frame, touch)) {
            [self.tools removeObject:tool];
            [self.jacobGuidance removeTool:tool];
            if (self.jacobGuidance.roverIsFinished) {
                [self.delegate roverFinished];
            } else {
                [self.delegate roverUnfinished];
            }
            self.weightTextView.text = [NSString stringWithFormat:@"%d", self.jacobGuidance.currentWeight];
            if (self.jacobGuidance.currentWeight > 185) {
                self.weightTextView.textColor = [UIColor redColor];
            } else {
                self.weightTextView.textColor = [UIColor whiteColor];
            }
            tappedTool = tool;
            for (NSMutableDictionary *dict in self.toolsAttachedAtPoints.allValues) {
                if ([dict[@"tool_here"] boolValue] &&
                    dict[@"tool"] == tool) {
                    dict[@"tool_here"] = @NO;
                }
            }
            if ([tool.toolType isEqualToString:RV_COMMUNICATION_TYPE_TOOL] &&
                !self.jacobGuidance.communicationSystemCompleted) {
                [self.delegate communicationToolUnattached];
            } else if ([tool.toolType isEqualToString:RV_ANALYSIS_TYPE_TOOL] &&
                       !self.jacobGuidance.analysisSystemCompleted) {
                [self.delegate analysisToolUnattached];
            } else if ([tool.toolType isEqualToString:RV_LOCOMOTION_TYPE_TOOL] &&
                       !self.jacobGuidance.locomotionSystemCompleted) {
                [self.delegate locomotionToolUnattached];
            }
            break;
        }
    }
    return tappedTool;
}

-(void)showMessage
{
    [self.jacobGuidance nextMessage];
}

//Jacob Guidance System Delegate Methods
-(void)writeMessage:(NSString *)message
{
    [self.messageTimer invalidate];
    self.textView.animatedText = message;
    if (self.jacobGuidance.roverIsFinished) {
        [self.delegate roverFinished];
    } else {
        [self.delegate roverUnfinished];
    }
}

//Animated Text View Delegate Methods
-(void)textViewDidFinishedAnimating:(RVAnimatedTextView *)textView
{
    if (self.jacobGuidance.isIntroduction) {
        self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                             target:self.jacobGuidance
                                                           selector:@selector(nextMessage)
                                                           userInfo:nil
                                                            repeats:NO];
    } else {
        self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                             target:self.jacobGuidance
                                                           selector:@selector(nextGeneralMessage)
                                                           userInfo:nil
                                                            repeats:NO];
    }
}

-(void)textViewPartiallyFinishedAnimating:(RVAnimatedTextView *)textView
{
}

-(void)textViewDeletedAllText
{
}

//accessor methods
-(NSMutableDictionary *)attachmentPoints
{
    if (!_attachmentPoints) {
        _attachmentPoints = [[NSMutableDictionary alloc] init];
    }
    return _attachmentPoints;
}

-(NSMutableArray *)tools
{
    if (!_tools) {
        _tools = [[NSMutableArray alloc] init];
    }
    return _tools;
}

-(NSMutableArray *)singleAttachmentPoints
{
    if (!_singleAttachmentPoints) {
        _singleAttachmentPoints = [[NSMutableArray alloc] init];
    }
    return _singleAttachmentPoints;
}

-(NSMutableDictionary *)toolsAttachedAtPoints
{
    if (!_toolsAttachedAtPoints) {
        _toolsAttachedAtPoints = [[NSMutableDictionary alloc] init];
    }
    return _toolsAttachedAtPoints;
}

-(RVJacobGuidanceController *)jacobGuidance
{
    if (!_jacobGuidance) {
        _jacobGuidance = [[RVJacobGuidanceController alloc] init];
        _jacobGuidance.delegate = self;
    }
    return _jacobGuidance;
}

-(void)setPlanet:(NSString *)planet
{
    self.jacobGuidance.planet = planet;
    _planet = planet;
}

-(void)setTextView:(RVAnimatedTextView *)textView
{
    _textView = textView;
    textView.sendAlert = YES;
    textView.animationDelegate = self;
}

-(void)setMessageTimer:(NSTimer *)messageTimer
{
    _messageTimer = messageTimer;
    [[NSRunLoop currentRunLoop] addTimer:_messageTimer forMode:NSRunLoopCommonModes];
}

@end
