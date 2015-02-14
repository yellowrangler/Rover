//
//  RVCommand.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RVCommand : NSObject

@property (nonatomic, assign) NSInteger constant;
@property (nonatomic, assign) NSInteger oldConstant;
@property (nonatomic, readonly) NSInteger lengthOfChange;
@property (nonatomic, readonly) NSString* changedString;

-(void)incrementConstant;
-(void)decrementConstant;
-(void)undoCommand:(RVCommand*)cmd;

@end
