//
//  ColorWheel.h
//  ColorWheel - Test
//
//  Created by The Guest Family on 6/15/17.
//  Copyright © 2017 AlphaApplications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelRotationProtocol.h"
#import "ColorWheelSection.h"

@interface ColorWheel : UIControl

@property (nonatomic, strong) NSMutableArray *sections;
@property int currentSection;
@property (weak) id <WheelRotationProtocol> wheelDelegate;
@property (nonatomic, strong) UIView *container;
@property int numberOfSections;
@property CGAffineTransform startTransform;

- (id) initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber;
- (void)rotate;

@end
