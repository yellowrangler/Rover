//
//  RVIndiaGuindanceSystem.h
//  Rover
//
//  Created by Sean Fitzgerald on 5/10/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVRoverBuildToolChest.h"

@protocol RVIndiaGuidanceDelegate

-(void)finishedIntroduction;
-(void)writeMessage:(NSString*)message;

@end

@interface RVIndiaGuindanceSystem : NSObject

@property (nonatomic, weak) id<RVIndiaGuidanceDelegate> delegate;
@property (nonatomic, strong) NSString *selectedPlanet;

-(void)nextMessage;

@end
