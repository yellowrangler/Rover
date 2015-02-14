//
//  Utilities.h
//  Rover
//
//  Created by Sean Fitzgerald on 3/14/14.
//  Copyright (c) 2014 Sean T Fitzgerald. All rights reserved.
//

#ifndef Rover_Utilities_h
#define Rover_Utilities_h

#include <CoreGraphics/CoreGraphics.h>

CGRect rectQuarter(CGRect source);
CGPoint pointHalf(CGPoint source);
CGSize sizeQuarter(CGSize source);
CGRect frameFromOrigin(CGRect source, CGPoint origin);
CGPoint pointFromOrigin(CGPoint source, CGPoint origin);
bool pointIsNearPoint(CGPoint point1, CGPoint point2, CGFloat radius);

#endif
