//
//  RVCommandLineupViewTwo.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/21/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVCommandLineupViewTwo.h"
#import "RVCommandLineupViewCell.h"
#import "RVRotateCommand.h"
#import "NSMutableArray+RVCommand.h"

@interface RVCommandLineupViewTwo () <RVAnimatedTextDelegate>

@property (nonatomic, strong) NSMutableArray *futureBuffer;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) NSMutableArray *commands;
@property (nonatomic, assign) BOOL shouldReturn;

@end

@implementation RVCommandLineupViewTwo

//overridden methods
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

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self customSetup];
    }
    return self;
}

//tableViewDelegate methods
-(NSInteger)numberOfSections
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell * cell = [[UITableViewCell alloc] init];
        [cell setFrame:CGRectMake(0, 0, self.bounds.size.width, 10)];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else {
        return self.cells[indexPath.row-1];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 10;
    } else {
        return 70;
    }
}

//RVAnimatedTextDelegate methods
-(void)textViewDidFinishedAnimating:(RVAnimatedTextView *)textView
{
    [self.futureBuffer removeObjectAtIndex:0];
    [self nextFutureBuffer];
}

-(void)textViewPartiallyFinishedAnimating:(RVAnimatedTextView *)textView
{
    
}

-(void)textViewDeletedAllText
{
    [self.cells removeLastObject];
    [[(RVCommandLineupViewCell*)self.cells.lastObject textView] setShowUnderscore:YES];
    [self reloadData];
}

//public methods
-(void)addCommand:(RVCommand*)cmd
{
    [self.futureBuffer addObject:@{@"command":[cmd copy],
                                   @"reason":@"add"}];
    [self runFutureBuffer];
}

-(void)changeLastCommand:(RVCommand*)cmd
{
    [self.futureBuffer addObject:@{@"command":[cmd copy],
                                   @"reason":@"change"}];
    [self runFutureBuffer];
}

-(void)undoCommand:(RVCommand*)cmd
{
    [self.futureBuffer addObject:@{@"command":[cmd copy],
                                   @"reason":@"undo"}];
    [self runFutureBuffer];
}

-(void)clearCommands
{
    [self.futureBuffer addObject:@{@"reason":@"clear"}];
    [self runFutureBuffer];
}

-(void)undoAllRecentRotateCommands
{
    [self.futureBuffer addObject:@{@"reason":@"undo-rotate"}];
    [self runFutureBuffer];
}

//getters
-(NSMutableArray *)futureBuffer
{
    if (!_futureBuffer) {
        _futureBuffer = [[NSMutableArray alloc] init];
    }
    return _futureBuffer;
}

-(NSMutableArray *)cells
{
    if (!_cells) {
        _cells = [[NSMutableArray alloc] init];
    }
    return _cells;
}

-(NSMutableArray *)commands
{
    if (!_commands) {
        _commands = [[NSMutableArray alloc] init];
    }
    return _commands;
}

-(BOOL)animating
{
    return (self.futureBuffer.count != 0);
}

//helper methods
-(void)setupCell:(RVCommandLineupViewCell*)cell
{
#warning REMOVE THESE CONSTANTS
    [cell setFrame:CGRectMake(0, 0, self.bounds.size.width, 70)];
    RVAnimatedTextView *numberView = [[RVAnimatedTextView alloc] initWithFrame:CGRectMake(0,
                                                                                          0,
                                                                                          40,
                                                                                          cell.bounds.size.height)];
    RVAnimatedTextView *textView = [[RVAnimatedTextView alloc] initWithFrame:CGRectMake(40,
                                                                                        0,
                                                                                        cell.bounds.size.width - 40,
                                                                                        cell.bounds.size.height)];
    cell.textView = textView;
    cell.numberView = numberView;
    [cell addSubview:textView];
    [cell addSubview:numberView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textView.backgroundColor = [UIColor clearColor];
    cell.textView.animationDelegate = self;
    cell.textView.sendAlert = YES;
    cell.numberView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    cell.textView.opaque = NO;
    cell.numberView.opaque = NO;
}

-(void)runFutureBuffer
{
    if (self.futureBuffer.count == 1) {
        [self nextFutureBuffer];
    }
}

-(void)nextFutureBuffer
{
    if (self.futureBuffer.count != 0) {
        NSString *change = self.futureBuffer.firstObject[@"reason"];
        if ([change isEqualToString:@"add"]) {
            RVCommandLineupViewCell *cell = [[RVCommandLineupViewCell alloc] init];
            [self setupCell:cell];
            cell.numberView.animatedText = [NSString stringWithFormat:@"%d.", self.cells.count+1];
            cell.textView.animatedText = [self.futureBuffer.firstObject[@"command"] description];
            
            CGRect frame1 =cell.textView.frame;
            CGRect frame2 = cell.numberView.frame;
            
            [[(RVCommandLineupViewCell*)self.cells.lastObject textView] setShowUnderscore:NO];
            [self.cells addObject:cell];
            cell.textView.showUnderscore = YES;
            [self.commands addObject:[self.futureBuffer.firstObject[@"command"] copy]];
            [self reloadDataAndScroll];
        } else if ([change isEqualToString:@"change"]) {
            RVCommandLineupViewCell* cell = self.cells.lastObject;
            RVCommand* command = self.futureBuffer.firstObject[@"command"];
            [cell.textView backspaceCharacterLength:command.lengthOfChange
                                  replaceMentString:command.changedString];
            self.commands[self.commands.count-1] = [self.futureBuffer.firstObject[@"command"] copy];
            [self reloadDataAndScroll];
        } else if ([change isEqualToString:@"undo"]) {
            RVCommandLineupViewCell* cell = self.cells.lastObject;
            RVCommand* command = self.futureBuffer.firstObject[@"command"];
            if ([self.commands commandCausesRemoval:self.futureBuffer.firstObject[@"command"]]) {
                [cell.textView backspaceCharacterLength:command.description.length
                                      replaceMentString:@""];
                [self.commands removeCommand:[command copy]];
            } else {
                [self.commands removeCommand:command];
                [cell.textView backspaceCharacterLength:[self.commands.lastObject lengthOfChange]
                                      replaceMentString:[self.commands.lastObject changedString]];
            }
        } else if ([change isEqualToString:@"clear"]) {
            [self.commands removeAllObjects];
            [self clearCommandTable];
        } else if ([change isEqualToString:@"undo-rotate"]) {
            for (int i = self.commands.count - 1; i >= 0; i--) {
                if ([self.commands[i] isKindOfClass:[RVRotateCommand class]]) {
                    [self.commands removeLastObject];
                } else {
                    break;
                }
            }
            [self.futureBuffer removeObjectAtIndex:0];
            [self nextFutureBuffer];
        }
    } else {
        [self.animationDelegate finishedAnimatingCommands];
    }
}

-(void)customSetup
{
    self.delegate = self;
    self.dataSource = self;
}

-(void)clearCommandTable
{
    self.shouldReturn = YES;
    [self setContentOffset:CGPointMake(0, self.contentSize.height)
                  animated:YES];
    if (self.cells.count == 0) {
        self.shouldReturn = NO;
        [self.futureBuffer removeObjectAtIndex:0];
        [self nextFutureBuffer];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.shouldReturn) {
        self.shouldReturn = NO;
        [self.cells removeAllObjects];
        [self reloadData];
        [self.futureBuffer removeObjectAtIndex:0];
        [self nextFutureBuffer];
    }
}

-(void)reloadDataAndScroll
{
    [self reloadData];
    NSIndexPath* ipath = [NSIndexPath indexPathForRow:[self numberOfRowsInSection:0]-1
                                            inSection:0];
    [self scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
}

@end
