//
//  RVMapController.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#warning REMOVE CONSTANTS FROM THIS FILE

#import "RVMapController.h"
#import "RVCommand.h"
#import "CSVParser.h"
#import "RVMapLocation.h"
#import "RVCommand.h"
#import "RVActionCommand.h"
#import "RVMoveCommand.h"
#import "RVRotateCommand.h"
#import "RVAnalyzeCommand.h"
#import "NSMutableArray+RVCommand.h"
#import "RVAudioReference.h"

@interface RVMapController () <CSVParserDelegate>

@property (nonatomic, strong) RVMapLocation *roverStartPosition;
@property (nonatomic, readonly) RVMapLocation *roverPosition;
@property (nonatomic, strong) CSVParser *mapLocationsParser;

//these define the current state of the map
@property (nonatomic, strong) NSMutableArray *mapAreas;
@property (nonatomic, strong) NSMutableArray *rocks;
@property (nonatomic, strong) NSMutableArray *objectives;
//

@property (nonatomic, assign) BOOL checkingCommands;
@property (nonatomic, assign) BOOL alertObjective;
@property (nonatomic, assign) NSInteger alertObjectiveNumber;
@property (nonatomic, assign) NSInteger numberOfSteps;

@property (nonatomic, strong) NSMutableArray *pathArray;

@end

@implementation RVMapController

// RVCommandLineupDelegate methods
-(void)executeComands:(NSMutableArray *)commandLineup
{
    self.numberOfSteps = 0;
    if (commandLineup.count == 0) {
        [self.roverAnimationDelegate roverFinishedMoving:self.numberOfSteps];
    }
    
    RVMapLocation *location = [self.roverPosition copy];
    for (RVCommand *cmd in commandLineup) {
        [self performCommand:cmd AtLocation:location];

        self.numberOfSteps++;
        
        if ([cmd isKindOfClass:[RVMoveCommand class]]) {
            for (NSInteger i = 0; i < cmd.constant; i++) {
                [self.view roverMoveForward];
            }
        } else if([cmd isKindOfClass:[RVRotateCommand class]]){
            if (cmd.constant == 90) {
                [self.view roverRotateLeft];
            } else if(cmd.constant == 180) {
                [self.view roverTurnAround];
            } else if(cmd.constant == -90) {
                [self.view roverRotateRight];
            }
        } else if([cmd isKindOfClass:[RVAnalyzeCommand class]]) {
            [self.view roverAnalyze];
            [self.view removeObjective];
            self.alertObjectiveNumber = self.objectiveNumber-1;
            self.alertObjective = YES;
            if (self.objectiveNumber < self.objectives.count) {
                [self.view addObjectiveCommand:self.objectives[self.objectiveNumber]];
            }
        } else if([cmd isKindOfClass:[RVActionCommand class]]) {
            [self.view roverUseTool];
            [self.view showRocks:self.rocks];
        }
    }
}

-(BOOL)canCompleteCommands:(NSMutableArray *)commandLineup
{
    if (self.checkingCommands) {
        return NO;
    }
    self.checkingCommands = YES;
    [self.pathArray removeAllObjects];
    NSArray *rocks = [self.rocks copy];
    NSArray *objectives = [self.objectives copy];
    NSMutableArray *mapAreas = [@[] mutableCopy];
    NSInteger objectiveIndex = self.objectiveNumber;
    for (NSMutableArray *row in self.mapAreas) {
        [mapAreas addObject:[row mutableCopy]];
    }
    BOOL canCompleteCommands = YES;
    
    RVMapLocation * roverLocation = [self.roverPosition copy];
    BOOL lastCommandWasActionOrAnalyze = NO;
    for (RVCommand * cmd in commandLineup) {
        if (![self canCompleteCommand:cmd atLocation:roverLocation] ||
            lastCommandWasActionOrAnalyze) {
            canCompleteCommands = NO;//rover could not complete that command
            break;
        }
        if ([cmd isKindOfClass:[RVAnalyzeCommand class]] ||
            [cmd isKindOfClass:[RVActionCommand class]]) {
            lastCommandWasActionOrAnalyze = YES;
        }
    }
    
    self.rocks = [rocks mutableCopy];
    self.objectives = [objectives mutableCopy];
    self.mapAreas = [mapAreas mutableCopy];
    self.objectiveNumber = objectiveIndex;
    self.checkingCommands = NO;
    return canCompleteCommands;
}

-(void)layOutPathForCommands:(NSMutableArray*)commandLineup
{
    [self.view resetPath];
    NSInteger index = 0;
    for (RVCommand *cmd in commandLineup) {
        NSInteger commandCount = [commandLineup countCommands];
        BOOL last = (index == (commandCount-1));
        if ([cmd isKindOfClass:[RVMoveCommand class]]) {
            for (NSInteger i = 0; i < cmd.constant; i++) {
                [self.view pathMoveForward:last];
                index++;
                NSInteger commandCount = [commandLineup countCommands];
                last = (index == (commandCount-1));
            }
            index--;
        } else if([cmd isKindOfClass:[RVRotateCommand class]]){
            if (cmd.constant == 90) {
                [self.view pathRotateLeft:last];
            } else if(cmd.constant == 180) {
                [self.view pathTurnAround:last];
            } else if(cmd.constant == -90) {
                [self.view pathRotateRight:last];
            }
        } else if([cmd isKindOfClass:[RVAnalyzeCommand class]]) {
            [self.view pathAnalyze];
        } else if([cmd isKindOfClass:[RVActionCommand class]]) {
            [self.view pathUseTool];
        }
        index++;
    }
    [self.view setPath];
}

//accessor methods
-(RVMapLocation *)roverStartPosition
{
    return self.view.roverStartPosition;
}

-(RVMapLocation *)roverPosition
{
    return self.view.roverPosition;
}

-(NSMutableArray *)rocks
{
    if (!_rocks) {
        _rocks = [[NSMutableArray alloc] init];
    }
    return _rocks;
}

-(NSMutableArray *)objectives
{
    if (!_objectives) {
        _objectives = [[NSMutableArray alloc] initWithArray:@[[[RVMapLocation alloc] init],
                                                              [[RVMapLocation alloc] init],
                                                              [[RVMapLocation alloc] init]]];
    }
    return _objectives;
}

-(NSMutableArray *)pathArray
{
    if (!_pathArray) {
        _pathArray = [[NSMutableArray alloc] init];
    }
    return _pathArray;
}

//setters
-(void)setMapName:(NSString *)mapName
{
    _mapName = mapName;
    self.mapLocationsParser = [[CSVParser alloc] init];
    self.mapLocationsParser.delegate = self;
    [self.mapLocationsParser loadCSVFileWithResourceName:self.mapName];
    self.view.mapName = self.mapName;
    [self.view setMapImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", mapName]]];
}

-(void)setRoverName:(NSString *)roverName
{
    _roverName = roverName;
    self.view.roverImage = [UIImage imageNamed:[NSString stringWithFormat:@"rover%@.png", roverName]];
    if ([roverName isEqualToString:@"Hovercraft"]) {
        self.view.transportStartAudioURL = [RVAudioReference navigationScreenHovercraftStart];
        self.view.transportStopAudioURL = [RVAudioReference navigationScreenHovercraftEnd];
        self.view.transportLoopAudioURL = [RVAudioReference navigationScreenHovercraftLoop];
    } else {
        self.view.transportStartAudioURL = [RVAudioReference navigationScreenWheelsAndTreadsStart];
        self.view.transportStopAudioURL = [RVAudioReference navigationScreenWheelsAndTreadsEnd];
        self.view.transportLoopAudioURL = [RVAudioReference navigationScreenWheelsAndTreadsLoop];
    }
    self.view.toolAudioURL = [RVAudioReference navigationScreenRobotArm];
}

// CSVParserDelegate methods
-(void)parserLoaded:(CSVParser *)parser
{
    [parser parseInBackground];
}

-(void)parserDidFinishRow:(CSVParser *)parser withObject:(id)row
{
    
}

-(void)parserDidFinishParsingFile:(CSVParser *)parser withTable:(id)table
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self setupMapAreas:table];
        [self.view showRocks:self.rocks];
        [self.view addObjective:self.objectives[self.objectiveNumber]];
        [self.view resetRover];
    });
}

//RVMapViewAnimationDelegate methods
-(void)roverFinishedMoving
{
    [self.roverAnimationDelegate roverFinishedMoving:self.numberOfSteps];
    if (self.alertObjective) {
        self.alertObjective = NO;
        [self.roverDelegate roverFinishedObjectiveNumber:self.alertObjectiveNumber];
    }
}

-(void)updateCompassRoseAngle:(double)angle
{
    [self.roverAnimationDelegate updateCompassRoseAngle:angle];
}

-(void)roverTookOneStep
{
    [self.roverAnimationDelegate roverTookOneStep];
}

//helper methods
-(void)setupMapAreas:(NSArray*)table
{
    NSMutableArray *mapAreas = [[NSMutableArray alloc] init];
    NSInteger rowNumber = 0;
    for (NSArray *row in table) {
        [mapAreas addObject:[[NSMutableArray alloc] init]];
        NSInteger columnNumber = 0;
        for (NSString *cell in row) {
            if ([cell isEqualToString:@"X"]) {//the rover IS allowed on this cell
                [mapAreas[rowNumber] addObject:@YES];
            } else if ([cell isEqualToString:@"W"] &&
                       self.canDriveOnWater) {//the rover IS allowed on this cell and the cell is water
                [mapAreas[rowNumber] addObject:@YES];
            } else { //the rover is NOT allowed on this cell, although there may be a rock or an objective or something
                [mapAreas[rowNumber] addObject:@NO];
                if ([cell isEqualToString:@"R"]) {
                    RVMapLocation *rockLoc = [[RVMapLocation alloc] init];
                    rockLoc.row = rowNumber;
                    rockLoc.column = columnNumber;
                    [self.rocks addObject:rockLoc];
                } else if ([cell isEqualToString:@"1"]) {
                    [(RVMapLocation*)self.objectives[0] setRow:rowNumber];
                    [(RVMapLocation*)self.objectives[0] setColumn:columnNumber];
                } else if ([cell isEqualToString:@"2"]) {
                    [(RVMapLocation*)self.objectives[1] setRow:rowNumber];
                    [(RVMapLocation*)self.objectives[1] setColumn:columnNumber];
                } else if ([cell isEqualToString:@"3"]) {
                    [(RVMapLocation*)self.objectives[2] setRow:rowNumber];
                    [(RVMapLocation*)self.objectives[2] setColumn:columnNumber];
                } else if([cell isEqualToString:@"S"]) {
                    mapAreas[rowNumber][[mapAreas[rowNumber] count]-1] = @YES;
                    RVMapLocation *loc = [[RVMapLocation alloc] init];
                    loc.row = rowNumber;
                    loc.column = columnNumber;
                    self.roverStartPosition = loc;
                }
            }
            columnNumber++;
        }
        mapAreas[rowNumber] = [mapAreas[rowNumber] mutableCopy];
        rowNumber++;
    }
    self.mapAreas = mapAreas;
}

-(void)setRoverStartPosition:(RVMapLocation*)roverStartPosition
{
    self.view.roverStartPosition = roverStartPosition;
}

-(BOOL)canCompleteCommand:(RVCommand*)cmd atLocation:(RVMapLocation*)loc
{
    RVMapLocation *cpy = [loc copy];
    if ([cmd isKindOfClass:[RVMoveCommand class]]) {
        for (int i = 0; i < cmd.constant; i++) {
            [cpy moveForward];
            if (![self canDriveOnLocation:cpy]) {
                return NO;
            }
        }
    } else if([cmd isKindOfClass:[RVRotateCommand class]]) {
    } else if([cmd isKindOfClass:[RVActionCommand class]]) {
        if (![self canPerformActionAtLocation:loc]) {
            return NO;
        }
    } else if([cmd isKindOfClass:[RVAnalyzeCommand class]]) {
        if (![self canAnalyzeAtLocation:loc]) {
            return NO;
        }
    }
    [self performCommand:cmd AtLocation:loc];
    return YES;
}

-(BOOL)canDriveOnLocation:(RVMapLocation*)location
{
    //if there is a path currently at that location
    BOOL hasLocationInArray = NO;
    for (RVMapLocation *loc in self.pathArray) {
        if (location.row == loc.row &&
            location.column == loc.column) {
            hasLocationInArray = YES;
        }
    }
    
    if(hasLocationInArray){
        return NO;
    } else {
        [self.pathArray addObject:[location copy]];
    }
    
    //this is a filtering algorithm. Can return NO at any check. Only returns YES at the end.
    //first check to see if it is on the map
    if (location.row >= self.mapAreas.count ||
        location.column >= [(NSArray*)self.mapAreas[0] count]) {
        return NO;
    }
    //now check to see if there is safe terrain at that point
    BOOL travelable = [self.mapAreas[location.row][location.column] boolValue];
    if (!travelable) {
        return NO;
    }
    //now check to se if it is inside the visible area (4 blocks up and down, 6 blocks left and right)
    if (location.row > self.roverPosition.row + 4 ||
        location.row < self.roverPosition.row - 4 ||
        location.column > self.roverPosition.column + 6 ||
        location.column < self.roverPosition.column - 6) {
        return NO;
    }

    return YES;
}

-(void)performCommand:(RVCommand*) command
           AtLocation:(RVMapLocation*)location
{
    if ([command isKindOfClass:[RVMoveCommand class]]) {
        for (int i = 0; i < command.constant; i++) {
            [location moveForward];
        }
    } else if([command isKindOfClass:[RVRotateCommand class]]) {
        if (command.constant == 90) {
            [location turnLeft];
        } else if(command.constant == -90) {
            [location turnRight];
        } else if(command.constant == 180) {
            [location turnAround];
        }
    } else if([command isKindOfClass:[RVActionCommand class]]) {
        [self breakRock:location];
    } else if([command isKindOfClass:[RVAnalyzeCommand class]]) {
        [self analyzeObjective:location];
    }
}

-(BOOL)canPerformActionAtLocation:(RVMapLocation*)location
{
    BOOL facingRock = NO;
    for (RVMapLocation *rockLocation in self.rocks) {
        if ([location locationFaces:rockLocation]) {
            facingRock = YES;
            break;
        }
    }
    return facingRock;
}

-(BOOL)canAnalyzeAtLocation:(RVMapLocation*)location
{
    return [location locationFaces:(RVMapLocation*)self.objectives[self.objectiveNumber]];
}

-(void)analyzeObjective:(RVMapLocation*)location
{
    self.objectiveNumber++;
    RVMapLocation *objecLoc = [location copy];
    [objecLoc moveForward];
    self.mapAreas[objecLoc.row][objecLoc.column] = @YES;
}

-(void)breakRock:(RVMapLocation*)location
{
    NSInteger removalindex = 0;
    for (RVMapLocation *rockLocation in self.rocks) {
        if ([location locationFaces:rockLocation]) {
            break;
        }
        removalindex++;
    }
    [self.rocks removeObjectAtIndex:removalindex];
    RVMapLocation *rockLoc = [location copy];
    [rockLoc moveForward];
    self.mapAreas[rockLoc.row][rockLoc.column] = @YES;
}

@end
