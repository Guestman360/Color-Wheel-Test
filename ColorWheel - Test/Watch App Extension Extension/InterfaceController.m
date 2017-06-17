//
//  InterfaceController.m
//  Watch App Extension Extension
//
//  Created by The Guest Family on 6/16/17.
//  Copyright © 2017 AlphaApplications. All rights reserved.
//

#import "InterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import <UIKit/UIKit.h>
#import <WatchKit/WatchKit.h>


@interface InterfaceController()<WCSessionDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *watchImage;

@end


@implementation InterfaceController

@synthesize currentColor;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    //Sets up the session to connect with phone
    WCSession *session = [WCSession defaultSession];
    session.delegate = self;
    [session activateSession];
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    //Gets rid of annoying warning
}

//Responsible for setting up connection with phone to relay info back and forth
-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    //receive approriate Section data from phone
    NSString *colorSection = [message valueForKey:@"theSection"];
    //take that data and transfer from a string to int
    int colorSectionNumber = [colorSection intValue];
    NSLog(@"this is the sector number %i", colorSectionNumber);
    //run switch statement to determine which color should appear on watch app
    UIColor *fillColor;
    
    switch (colorSectionNumber) {
        case 0:
            fillColor = [UIColor blueColor];
            break;
        case 1:
            fillColor = [UIColor greenColor];
            break;
        case 2:
            fillColor = [UIColor redColor];
            break;
        case 3:
            fillColor = [UIColor purpleColor];
            break;
        default:
            break;
    }
    
    //build circle for watch display
    CGFloat scale = [WKInterfaceDevice currentDevice].screenScale;
    UIGraphicsBeginImageContextWithOptions(self.contentFrame.size, false, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Circle created here
    CGColorRef newColor = fillColor.CGColor;
    CGContextSetFillColorWithColor(context, newColor);
    CGFloat contentFrameWidth = self.contentFrame.size.width;
    CGFloat contentFrameHeight = self.contentFrame.size.height;
    CGPoint center = CGPointMake(contentFrameWidth / 2.0, contentFrameHeight / 2.0);
    CGFloat radius = MIN(contentFrameWidth / 2.0, contentFrameHeight/ 2.0) - 2;
    CGContextBeginPath (context);
    CGContextAddArc(context, center.x, center.y, radius, 0, 2 * M_PI, 1);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    //turn circle into a UIImage that can be displayed on the watch app
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    UIImage *drawingImage = [UIImage imageWithCGImage:cgimage];
    UIGraphicsEndImageContext();
    [self.watchImage setImage:drawingImage];

}


@end



