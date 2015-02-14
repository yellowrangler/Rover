//
//  RVMapLocation.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/19/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RV_MAP_NORTH (@"NORTH")
#define RV_MAP_EAST (@"EAST")
#define RV_MAP_SOUTH (@"SOUTH")
#define RV_MAP_WEST (@"WEST")

@interface RVMapLocation : NSObject

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, strong) NSString *direction;

-(void)moveForward;
-(void)turnAround;
-(void)turnRight;
-(void)turnLeft;
-(BOOL)locationFaces:(RVMapLocation*)location;

@end
