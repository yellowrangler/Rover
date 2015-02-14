//
//  RVMapView.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVMapView.h"
#import "RVUtilities.h"
#import "Constants_Layout.h"
#import "Constants_Images.h"
@import AVFoundation;

@interface RVMapView () <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL snapBack;
@property (nonatomic, strong) RVMapLocation *roverLocation;
@property (nonatomic, strong) RVMapLocation *pathLocation;
@property (nonatomic, readonly) CGRect viewableRect;
//this is in units relative to the map size (99 points)
@property (nonatomic, readonly) RVMapLocation *mapSize;
@property (nonatomic, strong) NSMutableArray *animationArray;
@property (nonatomic, strong) NSMutableArray *path;
@property (nonatomic, strong) UIImageView *objectiveImageView;
@property (nonatomic, strong) NSMutableArray *rocks;

//audio for rover and tools
@property (nonatomic, strong) AVAudioPlayer *roverToolAudioPlayer;
@property (nonatomic, strong) AVAudioPlayer *roverTransportStartAudioPlayer;
@property (nonatomic, strong) AVAudioPlayer *roverTransportEndAudioPlayer;
@property (nonatomic, strong) AVAudioPlayer *roverTransportLoopAudioPlayer;

@property (nonatomic, assign) BOOL lastCommandWasMove;
@property (nonatomic, strong) NSTimer *audioTimer;

@end

@implementation RVMapView

//custom initializer methods
-(id)init
{
    self = [super init];
    if (self) {
        [self customSetup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customSetup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customSetup];
    }
    return self;
}

//setters
-(void)setMapImage:(UIImage *)mapImage
{
    self.mapImageView.image = mapImage;
    self.mapImageView.frame = CGRectMake(0,
                                         0,
                                         self.mapImage.size.width,
                                         self.mapImage.size.height);
    self.contentSize = mapImage.size;
}

-(void)setRoverImage:(UIImage *)roverImage
{
    self.roverImageView.image = roverImage;
    self.roverImageView.frame = CGRectMake(0,
                                           0,
                                           roverImage.size.width,
                                           roverImage.size.height);
}

-(void)setRoverLocation:(RVMapLocation *)roverLocation animated:(BOOL)animated
{
    if (animated) {
        self.roverLocation = roverLocation;
        [self setAnimatedRoverLocation:roverLocation];
    } else {
        self.roverLocation = roverLocation;
//        [self scrollRectToVisible:self.viewableRect animated:NO];
        [self modifiedScrollRectToViewableWithoutAnimation];
        self.roverImageView.center = CGPointMake([self mapStartX]/2 + (CGFloat)roverLocation.column * RV_MAP_UNIT_SIZE/2 + RV_MAP_UNIT_SIZE / 4,
                                                 [self mapStartY]/2 + (CGFloat)roverLocation.row * RV_MAP_UNIT_SIZE/2 + RV_MAP_UNIT_SIZE / 4);
        if ([roverLocation.direction isEqualToString:RV_MAP_NORTH]) {
            self.roverImageView.transform = CGAffineTransformMakeRotation(0);
        } else if([roverLocation.direction isEqualToString:RV_MAP_EAST]) {
            self.roverImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        } else if ([roverLocation.direction isEqualToString:RV_MAP_SOUTH]) {
            self.roverImageView.transform = CGAffineTransformMakeRotation(M_PI);
        } else if([roverLocation.direction isEqualToString:RV_MAP_WEST]) {
            self.roverImageView.transform = CGAffineTransformMakeRotation(3.0 * M_PI_2);
        }
    }
}

-(void)showAnimatedRocks:(NSArray *)rocks
{
    for (UIImageView *iv in self.rocks) {
        [iv removeFromSuperview];
    }
    [self.rocks removeAllObjects];
    for (RVMapLocation *location in rocks) {
        UIImageView *imageView;
        if( [self.mapName isEqualToString:@"pluto"]) {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_ROCK_PLUTO]];
        } else if ([self.mapName isEqualToString:@"moon"]) {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_ROCK_MOON]];
        } else if ([self.mapName isEqualToString:@"mars"]) {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_ROCK_MARS]];
        } else if ([self.mapName isEqualToString:@"titan"]) {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_ROCK_TITAN]];
        }
        imageView.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
        imageView.center = [self centerOfLocation:location];
        [self addSubview:imageView];
        [self.rocks addObject:imageView];
    }
    if (self.animationArray.count != 0) {
        [self.animationArray removeObjectAtIndex:0];
        if (self.animationArray.count != 0) {
            if ([[self.animationArray firstObject] isKindOfClass:[RVMapLocation class]]) {
                [self setRoverLocation:[self.animationArray firstObject] animated:YES];
            } else {
                NSDictionary *animationDict = [self.animationArray firstObject];
                if ([animationDict[@"remove_rock"] boolValue]) {
                    [self showAnimatedRocks:animationDict[@"rocks"]];
                } else if ([animationDict[@"remove_objective"] boolValue]) {
                    [self removeObjectiveAnimated];
                } else if ([animationDict[@"add_objective"] boolValue]) {
                    [self addObjectiveAnimated:animationDict[@"location"]];
                }
            }
        } else {
#warning REMOVE THIS CONSTANT
            [UIView animateWithDuration:0.5
                             animations:^(){
                                 for (UIView *v in self.path) {
                                     v.alpha = 0;
                                 }
                             } completion:^(BOOL finished) {
                                 for (UIView *v in self.path) {
                                     [v removeFromSuperview];
                                 }
                                 [self.animationDelegate roverFinishedMoving];
                             }];
        }
    }
}

-(void)removeObjectiveAnimated
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.objectiveImageView removeFromSuperview];
        if (self.animationArray.count != 0) {
            [self.animationArray removeObjectAtIndex:0];
            if (self.animationArray.count != 0) {
                if ([[self.animationArray firstObject] isKindOfClass:[RVMapLocation class]]) {
                    [self setRoverLocation:[self.animationArray firstObject] animated:YES];
                } else {
                    NSDictionary *animationDict = [self.animationArray firstObject];
                    if ([animationDict[@"remove_rock"] boolValue]) {
                        [self showAnimatedRocks:animationDict[@"rocks"]];
                    } else if ([animationDict[@"remove_objective"] boolValue]) {
                        [self removeObjectiveAnimated];
                    } else if ([animationDict[@"add_objective"] boolValue]) {
                        [self addObjectiveAnimated:animationDict[@"location"]];
                    }
                }
            } else {
#warning REMOVE THIS CONSTANT
                [UIView animateWithDuration:0.5
                                 animations:^(){
                                     for (UIView *v in self.path) {
                                         v.alpha = 0;
                                     }
                                 } completion:^(BOOL finished) {
                                     for (UIView *v in self.path) {
                                         [v removeFromSuperview];
                                     }
                                     [self calibrateCompass];
                                     [self.animationDelegate roverFinishedMoving];
                                 }];
            }
        }
    });
}

-(void)setAnimatedRoverLocation:(RVMapLocation *)roverLocation
{
    if (!self.lastCommandWasMove) {
        [self.roverTransportStartAudioPlayer play];
        self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.8
                                                      target:self.roverTransportLoopAudioPlayer
                                                    selector:@selector(play)
                                                    userInfo:nil
                                                     repeats:NO];
    }
    self.lastCommandWasMove = YES;
    [UIScrollView animateWithDuration:RV_MAP_MOVE_ANIMATION_DURATION
                           animations:^(void) {
                               [self scrollRectToVisible:self.viewableRect animated:NO];
                               self.roverImageView.center = CGPointMake([self mapStartX]/2 + (CGFloat)roverLocation.column * RV_MAP_UNIT_SIZE/2 + RV_MAP_UNIT_SIZE / 4,
                                                                        [self mapStartY]/2 + (CGFloat)roverLocation.row * RV_MAP_UNIT_SIZE/2 + RV_MAP_UNIT_SIZE / 4);
                               if ([roverLocation.direction isEqualToString:RV_MAP_NORTH]) {
                                   self.roverImageView.transform = CGAffineTransformMakeRotation(0);
                               } else if([roverLocation.direction isEqualToString:RV_MAP_EAST]) {
                                   self.roverImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
                               } else if ([roverLocation.direction isEqualToString:RV_MAP_SOUTH]) {
                                   self.roverImageView.transform = CGAffineTransformMakeRotation(M_PI);
                               } else if([roverLocation.direction isEqualToString:RV_MAP_WEST]) {
                                   self.roverImageView.transform = CGAffineTransformMakeRotation(3.0 * M_PI_2);
                               }
                           }
                           completion:^(BOOL finished) {
                               [self.animationDelegate roverTookOneStep];
                               if (self.animationArray.count != 0) {
                                   [self.animationArray removeObjectAtIndex:0];
                                   if (self.animationArray.count != 0) {
                                       if ([[self.animationArray firstObject] isKindOfClass:[RVMapLocation class]]) {
                                           [self setRoverLocation:[self.animationArray firstObject] animated:YES];
                                       } else {
                                           self.lastCommandWasMove = NO;
                                           NSDictionary *animationDict = [self.animationArray firstObject];
                                           if ([animationDict[@"remove_rock"] boolValue]) {
                                               [self.roverToolAudioPlayer setCurrentTime:0.0];
                                               [self.roverToolAudioPlayer play];
                                               [self showAnimatedRocks:animationDict[@"rocks"]];
                                           } else if ([animationDict[@"remove_objective"] boolValue]) {
                                               [self removeObjectiveAnimated];
                                           } else if ([animationDict[@"add_objective"] boolValue]) {
                                               [self addObjectiveAnimated:animationDict[@"location"]];
                                           }
                                       }
                                   } else {
#warning REMOVE THIS CONSTANT
                                       if (self.lastCommandWasMove) {
                                           self.lastCommandWasMove = NO;
                                       }
                                       [UIView animateWithDuration:0.5
                                                        animations:^(){
                                                            for (UIView *v in self.path) {
                                                                v.alpha = 0;
                                                            }
                                                        } completion:^(BOOL finished) {
                                                            for (UIView *v in self.path) {
                                                                [v removeFromSuperview];
                                                            }
                                                            [self.animationDelegate roverFinishedMoving];
                                                        }];
                                   }
                               }
                           }];
}

-(void)setLastCommandWasMove:(BOOL)lastCommandWasMove
{
    _lastCommandWasMove = lastCommandWasMove;
    if (!lastCommandWasMove) {
        [self.audioTimer invalidate];
        [self.roverTransportEndAudioPlayer play];
        [self.roverTransportLoopAudioPlayer stop];
        [self.roverTransportStartAudioPlayer stop];
    }
}

//accessor methods
-(UIImage *)mapImage
{
    return self.mapImageView.image;
}

-(UIImage *)roverImage
{
    return self.roverImageView.image;
}

-(UIImageView *)roverImageView
{
    if (!_roverImageView) {
        _roverImageView = [[UIImageView alloc] init];
        _roverImageView.layer.zPosition = 2;//rover z layer is 2
        [self addSubview:_roverImageView];
    }
    return _roverImageView;
}

-(UIImageView *)mapImageView
{
    if (!_mapImageView) {
        _mapImageView = [[UIImageView alloc] init];
        _mapImageView.layer.zPosition = 0;//map z layer is 0
        [self addSubview:_mapImageView];
    }
    return _mapImageView;
}

-(CGRect)viewableRect
{
    CGFloat roverY = RV_MAP_UNIT_SIZE/2 * (CGFloat)self.roverLocation.row + [self mapStartY]/2;
    CGFloat roverX = RV_MAP_UNIT_SIZE/2 * (CGFloat)self.roverLocation.column + [self mapStartX]/2;
    return CGRectMake(roverX - self.bounds.size.width / 2,
                      roverY - self.bounds.size.height / 2,
                      self.bounds.size.width,
                      self.bounds.size.height);
}

-(NSMutableArray *)animationArray
{
    if (!_animationArray) {
        _animationArray = [[NSMutableArray alloc] init];
    }
    return _animationArray;
}

-(RVMapLocation *)roverPosition
{
    return self.roverLocation;
}

-(NSMutableArray *)path
{
    if (!_path) {
        _path = [[NSMutableArray alloc] init];
    }
    return _path;
}

-(NSMutableArray *)rocks
{
    if (!_rocks) {
        _rocks = [[NSMutableArray alloc] init];
    }
    return _rocks;
}

-(AVAudioPlayer *)roverToolAudioPlayer
{
    if (!_roverToolAudioPlayer) {
        _roverToolAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.toolAudioURL error:nil];
    }
    return _roverToolAudioPlayer;
}

-(AVAudioPlayer *)roverTransportEndAudioPlayer
{
    if (!_roverTransportEndAudioPlayer) {
        _roverTransportEndAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.transportStopAudioURL error:nil];
    }
    return _roverTransportEndAudioPlayer;
}

-(AVAudioPlayer *)roverTransportStartAudioPlayer
{
    if (!_roverTransportStartAudioPlayer) {
        _roverTransportStartAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.transportStartAudioURL error:nil];
    }
    return _roverTransportStartAudioPlayer;
}

-(AVAudioPlayer *)roverTransportLoopAudioPlayer
{
    if (!_roverTransportLoopAudioPlayer) {
        _roverTransportLoopAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.transportLoopAudioURL error:nil];
        _roverTransportLoopAudioPlayer.numberOfLoops = -1;
    }
    return _roverTransportLoopAudioPlayer;
}

-(void)setAudioTimer:(NSTimer *)audioTimer
{
    _audioTimer = audioTimer;
    [[NSRunLoop currentRunLoop] addTimer:_audioTimer forMode:NSRunLoopCommonModes];
}

//UIScrollViewDelegate methods
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat originX = self.viewableRect.origin.x;
    CGFloat originY = self.viewableRect.origin.y;
    if (originX < 0) {
        originX = 0;
    }
    if (originX > scrollView.contentSize.width - self.viewableRect.size.width) {
        originX = scrollView.contentSize.width - self.viewableRect.size.width;
    }
    if (originY < 0) {
        originY = 0;
    }
    if (originY > scrollView.contentSize.height - self.viewableRect.size.height) {
        originY = scrollView.contentSize.height - self.viewableRect.size.height;
    }
    [scrollView setContentOffset:CGPointMake(originX, originY) animated:YES];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    CGFloat originX = self.viewableRect.origin.x;
    CGFloat originY = self.viewableRect.origin.y;
    if (originX < 0) {
        originX = 0;
    }
    if (originX > scrollView.contentSize.width - self.viewableRect.size.width) {
        originX = scrollView.contentSize.width - self.viewableRect.size.width;
    }
    if (originY < 0) {
        originY = 0;
    }
    if (originY > scrollView.contentSize.height - self.viewableRect.size.height) {
        originY = scrollView.contentSize.height - self.viewableRect.size.height;
    }
    [scrollView setContentOffset:CGPointMake(originX, originY) animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL mustScrollBack = NO;
    CGPoint scrollLocation = scrollView.contentOffset;
    if (scrollLocation.x > self.roverImageView.frame.origin.x) {
        scrollLocation.x = self.roverImageView.frame.origin.x;
        mustScrollBack = YES;
    }
    if (scrollLocation.y > self.roverImageView.frame.origin.y) {
        scrollLocation.y = self.roverImageView.frame.origin.y;
        mustScrollBack = YES;
    }
    if (scrollLocation.x < self.roverImageView.frame.origin.x + self.roverImageView.frame.size.width - self.viewableRect.size.width) {
        scrollLocation.x = self.roverImageView.frame.origin.x + self.roverImageView.frame.size.width - self.viewableRect.size.width;
        mustScrollBack = YES;
    }
    if (scrollLocation.y < self.roverImageView.frame.origin.y + self.roverImageView.frame.size.height - self.viewableRect.size.height) {
        scrollLocation.y = self.roverImageView.frame.origin.y + self.roverImageView.frame.size.height - self.viewableRect.size.height;
        mustScrollBack = YES;
    }
    if (mustScrollBack) {
        [self setContentOffset:scrollLocation];
    }
    [self calibrateCompass];
}

//public methods

-(void)roverMoveForward
{
    RVMapLocation * loc;
    if (self.animationArray.count != 0) {
        loc = [[self.animationArray lastObject] copy];
    } else {
        loc = [self.roverLocation copy];
    }
    [loc moveForward];
    if (self.animationArray.count == 0) {
        [self setRoverLocation:loc animated:YES];
        [self.animationArray addObject:loc];
    } else {
        [self.animationArray addObject:loc];
    }
}

-(void)roverRotateRight
{
    RVMapLocation * loc;
    if (self.animationArray.count != 0) {
        loc = [[self.animationArray lastObject] copy];
    } else {
        loc = [self.roverLocation copy];
    }
    [loc turnRight];
    if (self.animationArray.count == 0) {
        [self setRoverLocation:loc animated:YES];
        [self.animationArray addObject:loc];
    } else {
        [self.animationArray addObject:loc];
    }
}

-(void)roverRotateLeft
{
    RVMapLocation * loc;
    if (self.animationArray.count != 0) {
        loc = [[self.animationArray lastObject] copy];
    } else {
        loc = [self.roverLocation copy];
    }
    [loc turnLeft];
    if (self.animationArray.count == 0) {
        [self setRoverLocation:loc animated:YES];
        [self.animationArray addObject:loc];
    } else {
        [self.animationArray addObject:loc];
    }
}

-(void)roverTurnAround
{
    RVMapLocation * loc;
    if (self.animationArray.count != 0) {
        loc = [[self.animationArray lastObject] copy];
    } else {
        loc = [self.roverLocation copy];
    }
    [loc turnAround];
    if (self.animationArray.count == 0) {
        [self setRoverLocation:loc animated:YES];
        [self.animationArray addObject:loc];
    } else {
        [self.animationArray addObject:loc];
    }
}

-(void)roverUseTool
{
    RVMapLocation * loc;
    if (self.animationArray.count != 0) {
        loc = [[self.animationArray lastObject] copy];
    } else {
        loc = [self.roverLocation copy];
    }
    //play audio
    if (self.animationArray.count == 0) {
        [self setRoverLocation:loc animated:YES];
        [self.animationArray addObject:loc];
    } else {
        [self.animationArray addObject:loc];
    }
}

-(void)roverAnalyze
{
    RVMapLocation * loc;
    if (self.animationArray.count != 0) {
        loc = [[self.animationArray lastObject] copy];
    } else {
        loc = [self.roverLocation copy];
    }
    //do nothing
    if (self.animationArray.count == 0) {
        [self setRoverLocation:loc animated:YES];
        [self.animationArray addObject:loc];
    } else {
        [self.animationArray addObject:loc];
    }
}

-(void)resetRover
{
    [self setRoverLocation:self.roverStartPosition animated:NO];
}

-(void)pathMoveForward:(BOOL)final
{
    [self.pathLocation moveForward];
    UIImageView *pathPiece = [self pathPieceAtLocation:self.pathLocation];
    if (final) {
        pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_STRAIGHT_END_IMAGE_NAME];
    } else {
        pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_STRAIGHT_IMAGE_NAME];
    }
    CGAffineTransform rotate;
    if ([self.pathLocation.direction isEqualToString:RV_MAP_NORTH]) {
        //no transformation necessary
        rotate = CGAffineTransformMakeRotation(0);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_EAST]) {
        rotate = CGAffineTransformMakeRotation(M_PI_2);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_SOUTH]) {
        rotate = CGAffineTransformMakeRotation(M_PI);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_WEST]) {
        rotate = CGAffineTransformMakeRotation(-M_PI_2);
    }
    pathPiece.transform = rotate;
    [self.path addObject:pathPiece];
}

-(void)pathRotateRight:(BOOL)final
{
    if (self.path.count == 1) {
        [self.path removeAllObjects];
        UIImageView *pathPiece = [self pathPieceAtLocation:self.pathLocation];
        pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_INIT_IMAGE_NAME];
        CGAffineTransform rotate;
        if ([self.pathLocation.direction isEqualToString:RV_MAP_NORTH]) {
            //no transformation necessary
            rotate = CGAffineTransformMakeRotation(M_PI_2);
        } else if ([self.pathLocation.direction isEqualToString:RV_MAP_EAST]) {
            rotate = CGAffineTransformMakeRotation(M_PI);
        } else if ([self.pathLocation.direction isEqualToString:RV_MAP_SOUTH]) {
            rotate = CGAffineTransformMakeRotation(-M_PI_2);
        } else if ([self.pathLocation.direction isEqualToString:RV_MAP_WEST]) {
            rotate = CGAffineTransformMakeRotation(0);
        }
        pathPiece.transform = rotate;
        [self.path addObject:pathPiece];
        [self.pathLocation turnRight];
        return;
    }
    [self.path removeLastObject];
    UIImageView *pathPiece = [self pathPieceAtLocation:self.pathLocation];
    if (final) {
        pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_CURVED_END_IMAGE_NAME];
    } else {
        pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_CURVED_IMAGE_NAME];
    }
    CGAffineTransform flip = CGAffineTransformMakeScale(-1, 1);
    CGAffineTransform rotate;
    if ([self.pathLocation.direction isEqualToString:RV_MAP_NORTH]) {
        //no transformation necessary
        rotate = CGAffineTransformMakeRotation(0);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_EAST]) {
        rotate = CGAffineTransformMakeRotation(M_PI_2);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_SOUTH]) {
        rotate = CGAffineTransformMakeRotation(M_PI);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_WEST]) {
        rotate = CGAffineTransformMakeRotation(-M_PI_2);
    }
    [self.pathLocation turnRight];
    pathPiece.transform = CGAffineTransformConcat(flip, rotate);
    [self.path addObject:pathPiece];
}

-(void)pathRotateLeft:(BOOL)final
{
    if (self.path.count == 1) {
        [self.path removeAllObjects];
        self.pathLocation = [self.roverLocation copy];
        UIImageView *pathPiece = [self pathPieceAtLocation:self.pathLocation];
        pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_INIT_IMAGE_NAME];
        CGAffineTransform rotate;
        if ([self.pathLocation.direction isEqualToString:RV_MAP_NORTH]) {
            //no transformation necessary
            rotate = CGAffineTransformMakeRotation(-M_PI_2);
        } else if ([self.pathLocation.direction isEqualToString:RV_MAP_EAST]) {
            rotate = CGAffineTransformMakeRotation(0);
        } else if ([self.pathLocation.direction isEqualToString:RV_MAP_SOUTH]) {
            rotate = CGAffineTransformMakeRotation(M_PI_2);
        } else if ([self.pathLocation.direction isEqualToString:RV_MAP_WEST]) {
            rotate = CGAffineTransformMakeRotation(M_PI);
        }
        pathPiece.transform = rotate;
        [self.path addObject:pathPiece];
        [self.pathLocation turnLeft];
        return;
    }
    [self.path removeLastObject];
    UIImageView *pathPiece = [self pathPieceAtLocation:self.pathLocation];
    if (final) {
        pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_CURVED_END_IMAGE_NAME];
    } else {
        pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_CURVED_IMAGE_NAME];
    }
//    CGAffineTransform flip = CGAffineTransformMakeScale(1, 1);
    CGAffineTransform rotate;
    if ([self.pathLocation.direction isEqualToString:RV_MAP_NORTH]) {
        //no transformation necessary
        rotate = CGAffineTransformMakeRotation(0);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_EAST]) {
        rotate = CGAffineTransformMakeRotation(M_PI_2);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_SOUTH]) {
        rotate = CGAffineTransformMakeRotation(M_PI);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_WEST]) {
        rotate = CGAffineTransformMakeRotation(-M_PI_2);
    }
    [self.pathLocation turnLeft];
    pathPiece.transform = rotate;
    [self.path addObject:pathPiece];
}

-(void)pathTurnAround:(BOOL)final
{
    if (self.path.count == 1) {
        [self.path removeAllObjects];
        self.pathLocation = [self.roverLocation copy];
        UIImageView *pathPiece = [self pathPieceAtLocation:self.pathLocation];
        pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_INIT_IMAGE_NAME];
        CGAffineTransform rotate;
        if ([self.pathLocation.direction isEqualToString:RV_MAP_NORTH]) {
            //no transformation necessary
            rotate = CGAffineTransformMakeRotation(M_PI);
        } else if ([self.pathLocation.direction isEqualToString:RV_MAP_EAST]) {
            rotate = CGAffineTransformMakeRotation(-M_PI_2);
        } else if ([self.pathLocation.direction isEqualToString:RV_MAP_SOUTH]) {
            rotate = CGAffineTransformMakeRotation(0);
        } else if ([self.pathLocation.direction isEqualToString:RV_MAP_WEST]) {
            rotate = CGAffineTransformMakeRotation(M_PI_2);
        }
        pathPiece.transform = rotate;
        [self.path addObject:pathPiece];
        [self.pathLocation turnAround];
        return;
    }
    [self.path removeLastObject];
    UIImageView *pathPiece = [self pathPieceAtLocation:self.pathLocation];
    if (final) {
        pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_AROUND_END_IMAGE_NAME];
        
    } else {
        pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_AROUND_IMAGE_NAME];
    }
    CGAffineTransform rotate;
    if ([self.pathLocation.direction isEqualToString:RV_MAP_NORTH]) {
        //no transformation necessary
        rotate = CGAffineTransformMakeRotation(0);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_EAST]) {
        rotate = CGAffineTransformMakeRotation(M_PI_2);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_SOUTH]) {
        rotate = CGAffineTransformMakeRotation(M_PI);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_WEST]) {
        rotate = CGAffineTransformMakeRotation(-M_PI_2);
    }
    [self.pathLocation turnAround];
    pathPiece.transform = rotate;
    [self.path addObject:pathPiece];
}

-(void)pathUseTool
{
    [self.pathLocation moveForward];
    UIImageView *pathPiece = [self pathPieceAtLocation:self.pathLocation];
    pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_TOOL_IMAGE_NAME];
    CGAffineTransform rotate;
    if ([self.pathLocation.direction isEqualToString:RV_MAP_NORTH]) {
        //no transformation necessary
        rotate = CGAffineTransformMakeRotation(0);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_EAST]) {
        rotate = CGAffineTransformMakeRotation(M_PI_2);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_SOUTH]) {
        rotate = CGAffineTransformMakeRotation(M_PI);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_WEST]) {
        rotate = CGAffineTransformMakeRotation(-M_PI_2);
    }
    pathPiece.transform = rotate;
    [self.path addObject:pathPiece];
    [self.pathLocation turnAround];
    [self.pathLocation moveForward];
    [self.pathLocation turnAround];
}

-(void)pathAnalyze
{
//    [self.path removeLastObject];
    [self.pathLocation moveForward];
    UIImageView *pathPiece = [self pathPieceAtLocation:self.pathLocation];
    pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_ANALYZE_IMAGE_NAME];
    CGAffineTransform rotate;
    if ([self.pathLocation.direction isEqualToString:RV_MAP_NORTH]) {
        //no transformation necessary
        rotate = CGAffineTransformMakeRotation(0);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_EAST]) {
        rotate = CGAffineTransformMakeRotation(M_PI_2);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_SOUTH]) {
        rotate = CGAffineTransformMakeRotation(M_PI);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_WEST]) {
        rotate = CGAffineTransformMakeRotation(-M_PI_2);
    }
    pathPiece.transform = rotate;
    [self.path addObject:pathPiece];
    [self.pathLocation turnAround];
    [self.pathLocation moveForward];
    [self.pathLocation turnAround];
}

-(void)resetPath
{
    for (UIView* view in self.path) {
        [view removeFromSuperview];
    }
    [self.path removeAllObjects];
    self.pathLocation = [self.roverLocation copy];
    UIImageView *pathPiece = [self pathPieceAtLocation:self.pathLocation];
    pathPiece.image = [UIImage imageNamed:RV_MAP_PATH_INIT_IMAGE_NAME];
    CGAffineTransform rotate;
    if ([self.pathLocation.direction isEqualToString:RV_MAP_NORTH]) {
        //no transformation necessary
        rotate = CGAffineTransformMakeRotation(0);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_EAST]) {
        rotate = CGAffineTransformMakeRotation(M_PI_2);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_SOUTH]) {
        rotate = CGAffineTransformMakeRotation(M_PI);
    } else if ([self.pathLocation.direction isEqualToString:RV_MAP_WEST]) {
        rotate = CGAffineTransformMakeRotation(-M_PI_2);
    }
    pathPiece.transform = rotate;
    [self.path addObject:pathPiece];
}

-(void)setPath
{
    for (UIView *v in self.path) {
        [self addSubview:v];
    }
}

-(void)addObjective:(RVMapLocation*)location
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self calibrateCompass];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RV_IMAGES_GAME_PLAY_SCREEN_OBJECTIVE]];
        imageView.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
        imageView.center = [self centerOfLocation:location];
        [self addSubview:imageView];
        self.objectiveImageView = imageView;
    });
}

-(void)addObjectiveAnimated:(RVMapLocation*)location
{
    [self addObjective:location];
    if (self.animationArray.count != 0) {
        [self.animationArray removeObjectAtIndex:0];
        if (self.animationArray.count != 0) {
            if ([[self.animationArray firstObject] isKindOfClass:[RVMapLocation class]]) {
                [self setRoverLocation:[self.animationArray firstObject] animated:YES];
            } else {
                NSDictionary *animationDict = [self.animationArray firstObject];
                if ([animationDict[@"remove_rock"] boolValue]) {
                    [self showAnimatedRocks:animationDict[@"rocks"]];
                } else if ([animationDict[@"remove_objective"] boolValue]) {
                    [self removeObjectiveAnimated];
                } else if ([animationDict[@"add_objective"] boolValue]) {
                    [self addObjectiveAnimated:animationDict[@"location"]];
                }
            }
        } else {
#warning REMOVE THIS CONSTANT
            [UIView animateWithDuration:0.5
                             animations:^(){
                                 for (UIView *v in self.path) {
                                     v.alpha = 0;
                                 }
                             } completion:^(BOOL finished) {
                                 for (UIView *v in self.path) {
                                     [v removeFromSuperview];
                                 }
                                 [self.animationDelegate roverFinishedMoving];
                             }];
        }
    }
}

-(void)removeObjective
{
    if (self.animationArray.count == 0) {
        [self.animationArray addObject:@{@"remove_rock":@NO,
                                         @"remove_objective":@YES}];
        [self removeObjectiveAnimated];
    } else {
        [self.animationArray addObject:@{@"remove_rock":@NO,
                                         @"remove_objective":@YES}];
    }
}

-(void)addObjectiveCommand:(RVMapLocation*)location
{
    if (self.animationArray.count == 0) {
        [self.animationArray addObject:@{@"remove_rock":@NO,
                                         @"remove_objective":@NO,
                                         @"add_objective":@YES,
                                         @"location":location}];
        [self removeObjectiveAnimated];
    } else {
        [self.animationArray addObject:@{@"remove_rock":@NO,
                                         @"remove_objective":@NO,
                                         @"add_objective":@YES,
                                         @"location":location}];
    }
}

-(void)showRocks:(NSArray*)rocks
{
    if (self.animationArray.count == 0) {
        [self.animationArray addObject:@{@"remove_rock":@YES,
                                         @"remove_objective":@NO,
                                         @"rocks":rocks}];
        [self showAnimatedRocks:rocks];
    } else {
        [self.animationArray addObject:@{@"remove_rock":@YES,
                                         @"remove_objective":@NO,
                                         @"rocks":rocks}];
    }
}

//helper methods
-(void)customSetup
{
    self.maximumZoomScale = self.minimumZoomScale = 1.0;
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.bounces = NO;
}

-(CGPoint)centerOfLocation:(RVMapLocation*)mapLocation
{
    return CGPointMake([self mapStartX]/2 + (CGFloat)mapLocation.column * RV_MAP_UNIT_SIZE/2 + RV_MAP_UNIT_SIZE / 4,
                       [self mapStartY]/2 + (CGFloat)mapLocation.row * RV_MAP_UNIT_SIZE/2 + RV_MAP_UNIT_SIZE / 4);
}

-(CGSize)sizeOfMapSquare
{
    return CGSizeMake(RV_MAP_UNIT_SIZE/2, RV_MAP_UNIT_SIZE/2);
}

-(UIImageView*)pathPieceAtLocation:(RVMapLocation*)location
{
    UIImageView *pathPiece = [[UIImageView alloc] initWithFrame:(CGRect){[self centerOfLocation:location], [self sizeOfMapSquare]}];
    pathPiece.center = [self centerOfLocation:location];
    pathPiece.layer.zPosition = 1;//path z layer is 1
    return pathPiece;
}

-(CGFloat)mapStartX
{
    if ([self.mapName isEqualToString:@"pluto"]) {
        return RV_MAP_PLUTO_START_X;
    } else if ([self.mapName isEqualToString:@"mars"]) {
        return RV_MAP_MARS_START_X;
    } else if ([self.mapName isEqualToString:@"moon"]) {
        return RV_MAP_MOON_START_X;
    } else if ([self.mapName isEqualToString:@"titan"]) {
        return RV_MAP_TITAN_START_X;
    }
    return 0.0;
}

-(CGFloat)mapStartY
{
    if ([self.mapName isEqualToString:@"pluto"]) {
        return RV_MAP_PLUTO_START_Y;
    } else if ([self.mapName isEqualToString:@"mars"]) {
        return RV_MAP_MARS_START_Y;
    } else if ([self.mapName isEqualToString:@"moon"]) {
        return RV_MAP_MOON_START_Y;
    } else if ([self.mapName isEqualToString:@"titan"]) {
        return RV_MAP_TITAN_START_Y;
    }
    return 0.0;
}

-(void)calibrateCompass
{
    CGRect compassRect = rectQuarter((CGRect)RV_LAYOUT_GAME_PLAY_SCREEN_COMPASS_ROSE);
    CGPoint compassCenterFromSuperView = CGPointMake(CGRectGetMidX(compassRect), CGRectGetMidY(compassRect));
    CGPoint compassCenterFromScrollView = pointFromOrigin(compassCenterFromSuperView, self.frame.origin);
    CGPoint oppositeOffset = CGPointMake(-self.contentOffset.x, -self.contentOffset.y);
    CGPoint compassCenterRelativeToMap = pointFromOrigin(compassCenterFromScrollView, oppositeOffset);
    CGPoint objectivePosition = self.objectiveImageView.center;
    double angle = atan2f(compassCenterRelativeToMap.x - objectivePosition.x, compassCenterRelativeToMap.y - objectivePosition.y);
    [self.animationDelegate updateCompassRoseAngle:2 * M_PI - angle];
}

-(void)modifiedScrollRectToViewableWithoutAnimation
{
    CGPoint scrollLocation = self.viewableRect.origin;
    
    if (scrollLocation.x < 0) {
        scrollLocation.x = 0;
    }
    if (scrollLocation.x > self.contentSize.width - self.viewableRect.size.width) {
        scrollLocation.x = self.contentSize.width - self.viewableRect.size.width;
    }
    if (scrollLocation.y < 0) {
        scrollLocation.y = 0;
    }
    if (scrollLocation.y > self.contentSize.height - self.viewableRect.size.height) {
        scrollLocation.y = self.contentSize.height - self.viewableRect.size.height;
    }

    if (scrollLocation.x > self.roverImageView.frame.origin.x) {
        scrollLocation.x = self.roverImageView.frame.origin.x;
    }
    if (scrollLocation.y > self.roverImageView.frame.origin.y) {
        scrollLocation.y = self.roverImageView.frame.origin.y;
    }
    if (scrollLocation.x < self.roverImageView.frame.origin.x + self.roverImageView.frame.size.width - self.viewableRect.size.width) {
        scrollLocation.x = self.roverImageView.frame.origin.x + self.roverImageView.frame.size.width - self.viewableRect.size.width;
    }
    if (scrollLocation.y < self.roverImageView.frame.origin.y + self.roverImageView.frame.size.height - self.viewableRect.size.height) {
        scrollLocation.y = self.roverImageView.frame.origin.y + self.roverImageView.frame.size.height - self.viewableRect.size.height;
    }
    [self setContentOffset:scrollLocation];
    [self calibrateCompass];
}

@end
