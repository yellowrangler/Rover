//
//  RVRotateCommand.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVCommand.h"

@interface RVRotateCommand : RVCommand

-(instancetype)initRight;
-(instancetype)initLeft;
-(instancetype)initReverse;

@end
