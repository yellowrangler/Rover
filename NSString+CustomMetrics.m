//
//  NSString+CustomMetrics.m
//  Rover
//
//  Created by Sean Fitzgerald on 4/18/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#import "NSString+CustomMetrics.h"
@import CoreText;

@implementation NSString (CustomMetrics)

- (CGSize) boundsWithSize:(CGSize) bounds andFont:(UIFont*) uiFont
{
    
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef) uiFont.fontName,uiFont.pointSize, NULL);
    
    CGFloat ascent = CTFontGetAscent(ctFont);
    CGFloat descent = CTFontGetDescent(ctFont);
    CGFloat leading = CTFontGetLeading(ctFont);
    
    if (leading < 0)
        leading = 0;
    
    leading = floor (leading + 0.5);
    
    CGFloat lineHeight = floor (ascent + 0.5) + floor (descent + 0.5) + leading;
    CGFloat  ascenderDelta = 0;
    if (leading > 0)
        ascenderDelta = 0;
    else
        ascenderDelta = floor (0.2 * lineHeight + 0.5);
    
    CGFloat defaultLineHeight = lineHeight + ascenderDelta;
    
    CTParagraphStyleSetting paragraphSettings[1] = { {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof (CGFloat), &defaultLineHeight} };
    
    CTParagraphStyleRef  paragraphStyle = CTParagraphStyleCreate(paragraphSettings, 1);
    CFRange textRange = CFRangeMake(0, self.length);
    
    //  Create an empty mutable string big enough to hold our test
    CFMutableAttributedStringRef string = CFAttributedStringCreateMutable(kCFAllocatorDefault, self.length);
    
    //  Inject our text into it
    CFAttributedStringReplaceString(string, CFRangeMake(0, 0), (CFStringRef) self);
    
    //  Apply our font and line spacing attributes over the span
    CFAttributedStringSetAttribute(string, textRange, kCTFontAttributeName, ctFont);
    CFAttributedStringSetAttribute(string, textRange, kCTParagraphStyleAttributeName, paragraphStyle);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(string);
    CFRange fitRange;
    
    CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, textRange, NULL, bounds, &fitRange);
    
    CFRelease(framesetter);
    CFRelease(string);
    CFRelease(ctFont);
    
    return frameSize;
    
}

@end
