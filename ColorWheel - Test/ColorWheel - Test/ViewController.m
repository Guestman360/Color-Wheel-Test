//
//  ViewController.m
//  ColorWheel - Test
//
//  Created by The Guest Family on 6/15/17.
//  Copyright © 2017 AlphaApplications. All rights reserved.
//

#import "ViewController.h"
#import "ColorWheel.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface ViewController ()<WCSessionDelegate>

@end

@implementation ViewController

/*
 IMPORTANT NOTE ABOUT PERFORMANCE - 
 
 The app works as intended but may take a minute to establish a connection with the watch so if nothing is showing on the watch just let it sit for a minute or so and try moving wheel again
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //creates the wheel in the view, makes use of the protocol I created
    ColorWheel *wheel = [[ColorWheel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) andDelegate:self withSections:4];
    [self.view addSubview:wheel];
}

- (void)wheelDidChangeValue:(NSString *)newValue {
    // create connectivity session to pass data between phone and watch
    WCSession* session = [WCSession defaultSession];
    session.delegate = self;
    [session activateSession];
    // pass 'newValue' as "theSection" the phone app is currently on
    [session sendMessage:@{@"theSection":newValue} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        NSLog(@"Phone Message Sent From Phone");
    } errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"Error Sending Message From Phone");
    }];
}

//Methods below helped silence warnings I was getting
-(void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {
    
}

-(void)sessionDidBecomeInactive:(WCSession *)session {
    
}

-(void)sessionDidDeactivate:(WCSession *)session {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
