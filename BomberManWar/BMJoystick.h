//
//  BMJoystick.h
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "BMEnums.h"

@class BMJoystick;

@protocol BMJoystickDelegate <NSObject>

- (void)joystick:(BMJoystick *)joystick directionUpdated:(BMDirection *)direction;

@end

@interface BMJoystick : SKNode

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGPoint destination;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, weak) id<BMJoystickDelegate> delegate;

- (BMDirection) currentDirection;

@end
