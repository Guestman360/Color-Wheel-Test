//
//  ColorWheelSection.m
//  ColorWheel - Test
//
//  Created by The Guest Family on 6/15/17.
//  Copyright © 2017 AlphaApplications. All rights reserved.
//

#import "ColorWheelSection.h"

@implementation ColorWheelSection

@synthesize minValue, maxValue, midValue, section;

- (NSString *) description {
    return [NSString stringWithFormat: @"%i | %f, %f, %f", self.section, self.minValue, self.midValue, self.maxValue];
}

@end
