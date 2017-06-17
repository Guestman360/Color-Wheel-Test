//
//  ColorWheel.m
//  ColorWheel - Test
//
//  Created by The Guest Family on 6/15/17.
//  Copyright © 2017 AlphaApplications. All rights reserved.
//

#import "ColorWheel.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface ColorWheel()

- (void) drawWheel;
- (float) calculateDistanceFromCenter:(CGPoint)point;
- (void) buildSections;

@property (nonatomic)SystemSoundID clickSound;

@end

static float deltaAngle;
@implementation ColorWheel

@synthesize currentSection, sections, startTransform, wheelDelegate, container, numberOfSections;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber {
    if ((self = [super initWithFrame:frame])) {
        self.currentSection = 0;
        self.numberOfSections = sectionsNumber;
        self.wheelDelegate = del;
        [self drawWheel];
    }
    return self;
}

- (void)drawWheel {
#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)
    
    //This sets entire screen as container
    container = [[UIView alloc] initWithFrame:self.frame];
    CGFloat angleSize = 2*M_PI/numberOfSections;
    CGPoint centerOne = CGPointMake(CGRectGetWidth(container.bounds)/2.f, CGRectGetHeight(container.bounds)/2.f);
    CGFloat radius = (self.container.frame.size.width)/2;
    
    //Array of colors declared here
    NSMutableArray *colorsArray = [[NSMutableArray alloc] initWithObjects:[UIColor blueColor],[UIColor greenColor],[UIColor redColor],[UIColor purpleColor], nil];
    
    //for loop responsible for creating the sections of the circle
    for (int i = 0; i < numberOfSections; i++) {
        
        CGFloat angle = DEGREES_TO_RADIANS(-135);
        CGFloat startingAngle = angle + (angleSize * i);
        CGFloat endingAngle = angle + (angleSize * (i + 1));
        
        //creates a slice in wheel, adds color from array
        CAShapeLayer *slice = [CAShapeLayer layer];
        UIColor *color;
        color = [colorsArray objectAtIndex:i];
        slice.fillColor = color.CGColor;
        
        UIBezierPath *circlePath = [UIBezierPath bezierPath];
        [circlePath moveToPoint:centerOne];
        [circlePath addLineToPoint:CGPointMake(centerOne.x + radius * cosf(startingAngle), centerOne.y + radius * sinf(startingAngle))];
        [circlePath addArcWithCenter:centerOne radius:radius startAngle:startingAngle endAngle:endingAngle clockwise:YES];
        [circlePath closePath];
        slice.path = circlePath.CGPath;
        [[self.container layer] addSublayer:slice];
    }
    
    //builds the sections of circle
    container.userInteractionEnabled = NO;
    [self addSubview:container];
    sections = [NSMutableArray arrayWithCapacity:numberOfSections];
    if (numberOfSections % 2 == 0) {
        [self buildSections];
    }
    [self.wheelDelegate wheelDidChangeValue:[NSString stringWithFormat:@"%i", self.currentSection]];
    
}

- (void)rotate {
    CGAffineTransform t = CGAffineTransformRotate(container.transform, -0.78);
    container.transform = t;
}

//Handles the "locking" effect on the wheel
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint touchPoint = [touch locationInView:self];
    float dist = [self calculateDistanceFromCenter:touchPoint];
    if (dist < 15 || dist > (self.container.frame.size.width)/2) {
        NSLog(@"ignoring tap (%f,%f)", touchPoint.x, touchPoint.y);
        return NO;
    }
    float distX = touchPoint.x - container.center.x;
    float distY = touchPoint.y - container.center.y;
    deltaAngle = atan2(distX, distY);
    startTransform = container.transform;
    return YES;
}

//Allows user to hold and rotate wheel continuously
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    NSLog(@"rad is %f", radians);
    CGPoint pt = [touch locationInView:self];
    float dx = pt.x - container.center.x;
    float dy = pt.y - container.center.y;
    float ang = atan2(dy, dx);
    float angleDifference = deltaAngle - ang;
    container.transform = CGAffineTransformRotate(startTransform, - angleDifference);
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {

    //get current container rotation in radians
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    //initialize new value
    CGFloat newVal = 0.0;
    //iterate through all sections
    for (ColorWheelSection *s in sections) {
        //check for anomly (occurs wit heven number of sections)
        if (s.minValue > 0 && s.maxValue < 0) {
            if (s.maxValue > radians || s.minValue < radians) {
                //find the quadrant (positive or negative)
                if (radians > 0) {
                    newVal = radians - M_PI;
                    [self playClickSound];
                } else {
                    newVal = M_PI + radians;
                    [self playClickSound];
                }
                currentSection = s.section;
            }
        }
        //all non-anomalous cases
        else if (radians > s.minValue && radians < s.maxValue) {
            newVal = radians - s.midValue;
            currentSection = s.section;
            [self playClickSound];
        }
    }
    //set up animation for final rotation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    CGAffineTransform t = CGAffineTransformRotate(container.transform, -newVal);
    container.transform = t;
    [UIView commitAnimations];
    //[defaults setInteger:self.currentSection forKey:@"currentColor"];
    [self.wheelDelegate wheelDidChangeValue:[NSString stringWithFormat:@"%i", self.currentSection]];
}

- (float)calculateDistanceFromCenter:(CGPoint)point {
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float dx = point.x - center.x;
    float dy = point.y - center.y;
    return sqrt(dx*dx + dy*dy);
}

- (void)buildSections {
    //define section length
    CGFloat fanWidth = M_PI*2/numberOfSections;
    //set inital midpoint
    CGFloat mid = 0;
    //iterate through all sections
    for (int i = 0; i < numberOfSections; i++) {
        ColorWheelSection *wheelSection = [[ColorWheelSection alloc] init];
        //set section values
        wheelSection.midValue = mid;
        wheelSection.minValue = mid - (fanWidth/2);
        wheelSection.maxValue = mid + (fanWidth/2);
        wheelSection.section = i;
        if (wheelSection.maxValue-fanWidth < - M_PI) {
            mid = M_PI;
            wheelSection.midValue = mid;
            wheelSection.minValue = fabsf(wheelSection.maxValue);
        }
        mid -= fanWidth;
        NSLog(@"cl is %@", wheelSection);
        //add section to array
        [sections addObject:wheelSection];
    }
}

- (void)playClickSound {
    //fetch sound from bundle
    NSString *dotSoundPath = [[NSBundle mainBundle]pathForResource:@"click" ofType:@"wav"];
    NSURL *dotURL = [NSURL fileURLWithPath:dotSoundPath isDirectory:NO];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)dotURL, &_clickSound);
    
    AudioServicesPlaySystemSound(self.clickSound);
}


@end
