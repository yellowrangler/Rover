//
//  RVCommandLineupViewCell.h
//  Rover
//
//  Created by Sean Fitzgerald on 4/20/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RVAnimatedTextView.h"

@interface RVCommandLineupViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet RVAnimatedTextView *textView;
@property (weak, nonatomic) IBOutlet RVAnimatedTextView *numberView;

@end
