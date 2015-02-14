//
//  RVNavigationController.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/28/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RVNavigationController : UINavigationController

@property (nonatomic, strong) NSString *planet;
@property (nonatomic, strong) NSString *roverTool;
@property (nonatomic, strong) NSString *roverTransport;

@end
