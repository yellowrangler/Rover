//
//  Utilities.c
//  Rover
//
//  Created by Sean Fitzgerald on 3/14/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#include <stdio.h>
#include <math.h>
#include "RVUtilities.h"

CGRect rectQuarter(CGRect source)
{
    return (CGRect){(CGPoint){source.origin.x/2,source.origin.y/2},(CGSize){source.size.width/2,source.size.height/2}};
}

CGSize sizeQuarter(CGSize source)
{
    return (CGSize){source.width/2, source.height/2};
}

CGRect frameFromOrigin(CGRect source, CGPoint origin)
{
    return (CGRect){source.origin.x - origin.x, source.origin.y - origin.y, source.size.width, source.size.height};
}

CGPoint pointFromOrigin(CGPoint source, CGPoint origin)
{
    return (CGPoint){source.x - origin.x, source.y - origin.y};
}

bool pointIsNearPoint(CGPoint point1, CGPoint point2, CGFloat radius)
{
    CGFloat distance = sqrt(pow(point1.x - point2.x,2) + pow(point1.y-point2.y, 2));
    return (radius > distance);
}

CGPoint pointHalf(CGPoint source)
{
    return CGPointMake(source.x/2, source.y/2);
}