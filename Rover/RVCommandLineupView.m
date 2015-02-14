//
//  RVCommandLineupView.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "RVCommandLineupView.h"
#import "Constants_Layout.h"
#import "NSString+CustomMetrics.h"
#import "RVCommandLineupViewCell.h"
#import "NSMutableArray+RVCommand.h"
#import "RVRotateCommand.h"

@interface RVCommandLineupView () <UITextViewDelegate, RVAnimatedTextDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *commands;
@property (nonatomic, strong) NSMutableArray *newCells;
@property (nonatomic, strong) NSMutableArray *changedCells;
@property (nonatomic, assign) BOOL shouldReturn;

@property (nonatomic, strong) NSMutableArray * futureCells;

@end

@implementation RVCommandLineupView

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

-(void)customSetup
{
    self.delegate = self;
    self.dataSource = self;
}

-(NSMutableArray *)commands
{
    if (!_commands) {
        _commands = [[NSMutableArray alloc] init];
    }
    return _commands;
}

-(NSMutableArray *)newCells
{
    if (!_newCells) {
        _newCells = [[NSMutableArray alloc] init];
    }
    return _newCells;
}

-(NSInteger)numberOfSections
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"command lineup cell";
    RVCommandLineupViewCell *cell = [self dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[RVCommandLineupViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textView.backgroundColor = [UIColor clearColor];
    cell.textView.animationDelegate = self;
    cell.textView.sendAlert = YES;
    cell.numberView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    cell.textView.opaque = NO;
    cell.numberView.opaque = NO;
    int row = indexPath.row;
    if ([self.newCells[indexPath.row] boolValue]) {
        cell.numberView.animatedText = [NSString stringWithFormat:@"%d.", indexPath.row];
        cell.textView.animatedText = [self.commands[indexPath.row] description];
        self.newCells[indexPath.row] = @NO;
    } else if([self.changedCells[indexPath.row] boolValue]){
        [cell.textView backspaceCharacterLength:[(RVCommand*)self.commands[indexPath.row] lengthOfChange]
                              replaceMentString:[NSString stringWithFormat:@"%@",[(RVCommand*)self.commands[indexPath.row] changedString]]];
        self.changedCells[indexPath.row] = @NO;
    } else {
        cell.numberView.text = [NSString stringWithFormat:@"%d.", indexPath.row];
        cell.textView.text = [self.commands[indexPath.row] description];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commands.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

-(void)reloadDataAndScroll
{
    [self reloadData];
    NSIndexPath* ipath = [NSIndexPath indexPathForRow:[self numberOfRowsInSection:0]-1
                                            inSection:0];
    [self scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
}

-(void)addCommand:(RVCommand*)cmd
{
    [self.futureCells addObject:@{@"command":[cmd copy],
                                  @"change":@NO,
                                  @"undo":@NO}];
    if (self.futureCells.count == 1) {
        [self.newCells addObject:@YES];
        [self.changedCells addObject:@NO];
        [self.commands addObject:cmd];
        [self reloadDataAndScroll];
    }
}

-(void)changeLastCommand:(RVCommand*)cmd
{
    [self.futureCells addObject:@{@"command":[cmd copy],
                                  @"change":@YES,
                                  @"undo":@NO}];
    if (self.futureCells.count == 1) {
        self.changedCells[self.changedCells.count-1] = @YES;
        self.commands[self.commands.count-1] = [cmd copy];
        [self reloadDataAndScroll];
    }
}

-(void)undoCommand:(RVCommand*)cmd
{
    [self.futureCells addObject:@{@"command":[cmd copy],
                                  @"change":@NO,
                                  @"undo":@YES}];
    if (self.futureCells.count == 1) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:self.commands.count-1
                                               inSection:0];
        RVCommandLineupViewCell *cell = (RVCommandLineupViewCell*)[self cellForRowAtIndexPath:path];
        NSMutableArray *tempCommands = [self.commands mutableCopy];
        [tempCommands removeCommand:cmd];
        if (tempCommands.count < self.newCells.count) {
//            int length = cell.textView.text.length;
//            [cell.textView backspaceCharacterLength:length
//                                  replaceMentString:@""];
//            if (!cell) {
                [self reloadData];
                [self textViewDeletedAllText];
                [self textViewDidFinishedAnimating:nil];
//            }
        } else {
            //self.changedCells[self.changedCells.count-1] = @YES;
            [self reloadDataAndScroll];
        }
    }
}

-(void)textViewDeletedAllText
{
    [self.commands removeLastObject];
    [self.changedCells removeLastObject];
    [self.newCells removeLastObject];
    [self reloadData];
}

-(void)textViewDidFinishedAnimating:(RVAnimatedTextView *)textView
{
    [self.futureCells removeObjectAtIndex:0];
    if (self.futureCells.count != 0) {//there is a cell change queued up
        RVCommand *cmd = [self.futureCells objectAtIndex:0][@"command"];
        if ([[self.futureCells objectAtIndex:0][@"change"] boolValue]) {
            self.changedCells[self.changedCells.count-1] = @YES;
            self.commands[self.commands.count-1] = cmd;
            [self reloadDataAndScroll];
        } else if ([[self.futureCells objectAtIndex:0][@"undo"] boolValue]) {
            [self reloadData];
            NSIndexPath *path = [NSIndexPath indexPathForRow:self.commands.count-1
                                                   inSection:0];
            RVCommandLineupViewCell *cell = (RVCommandLineupViewCell*)[self cellForRowAtIndexPath:path];
            NSMutableArray *tempCommands = [self.commands mutableCopy];
            [tempCommands removeCommand:cmd];
            if (tempCommands.count < self.newCells.count) {
//                int length = cell.textView.text.length;
//                [cell.textView backspaceCharacterLength:length
//                                      replaceMentString:@""];
//                if (!cell) {
                    [self reloadData];
                    [self textViewDeletedAllText];
                    [self textViewDidFinishedAnimating:nil];
//                }
            } else {
                //self.changedCells[self.changedCells.count-1] = @YES;
                [self reloadDataAndScroll];
            }
        } else if ([[self.futureCells objectAtIndex:0][@"all-rotates"] boolValue]) {
            [self removeAllRecentRotateCommands];
        } else {
            [self.newCells addObject:@YES];
            [self.changedCells addObject:@NO];
            [self.commands addObject:cmd];
            [self reloadDataAndScroll];
        }
    } else {
        [self.animationDelegate finishedTyping];
    }
}

-(void)textViewPartiallyFinishedAnimating:(RVAnimatedTextView *)textView
{
    
}

-(void)clearCommands
{
    self.shouldReturn = YES;
    [self setContentOffset:CGPointMake(0, self.contentSize.height)
                  animated:YES];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.shouldReturn) {
        self.shouldReturn = NO;
        [self.commands removeAllObjects];
        [self.newCells removeAllObjects];
        [self.changedCells removeAllObjects];
        [self reloadData];
    }
}

-(NSMutableArray *)changedCells
{
    if (!_changedCells) {
        _changedCells = [[NSMutableArray alloc] init];
    }
    return _changedCells;
}

-(NSMutableArray *)futureCells
{
    if (!_futureCells) {
        _futureCells = [[NSMutableArray alloc] init];
    }
    return _futureCells;
}

-(BOOL)typing
{
    return (self.futureCells.count != 0);
}

-(void)undoAllRecentRotateCommands
{
    [self.futureCells addObject:@{@"command":[[RVCommand alloc] init],
                                  @"change":@NO,
                                  @"undo":@NO,
                                  @"all-rotates":@YES}];
    if (self.futureCells.count == 1) {
        [self removeAllRecentRotateCommands];
    }
}

-(void)removeAllRecentRotateCommands
{
    for (int i = self.commands.count - 1; i >= 0; i--) {
        if ([self.commands[i] isKindOfClass:[RVRotateCommand class]]) {
            [self.commands removeLastObject];
            [self.newCells removeLastObject];
            [self.changedCells removeLastObject];
        } else {
            break;
        }
    }
    [self reloadData];
    [self textViewDidFinishedAnimating:nil];
}


@end
