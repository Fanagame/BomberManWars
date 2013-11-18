//
//  BMJoystick.m
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMJoystick.h"

@interface BMJoystick () {
    BMDirection _currentDirection;
}

@property (nonatomic, assign) BMDirection currentDirection;

@end

@implementation BMJoystick

static BMJoystick *_localPlayerJoystick;
+ (instancetype) localPlayerJoystick {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _localPlayerJoystick = [[BMJoystick alloc] init];
    });
    return _localPlayerJoystick;
}

- (id) init {
    self = [super init];
    
    if (self) {
        self.fillColor = [UIColor purpleColor];
        self.strokeColor = [UIColor blackColor];
    }
    
    return self;
}

- (void) setCurrentDirection:(BMDirection)currentDirection {
    if (currentDirection != _currentDirection) {
        _currentDirection = currentDirection;
        
        [self.delegate joystick:self directionUpdated:self.currentDirection];
    }
}

- (void) setHidden:(BOOL)hidden {
    if (hidden && hidden != self.hidden) {
        self.currentDirection = kDirectionNone;
    }
    
    [super setHidden:hidden];
}

- (void) updateDirectionWithTranslation:(CGPoint)vector {
    if (self.enabled) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, self.position.x, self.position.y);
        CGPathAddLineToPoint(path, NULL, self.position.x + vector.x, self.position.y - vector.y);
        self.path = path;
        CGPathRelease(path);

        CGFloat angle = atan2f(vector.x, vector.y);
        if (angle < 0) { angle += 2 * M_PI; }
        
        if (angle >= M_PI_4 && angle < 3 * M_PI_4) {
            self.currentDirection = kDirectionRight;
        } else if (angle >= 3 * M_PI_4 && angle < 5 * M_PI_4) {
            self.currentDirection = kDirectionUp;
        } else if (angle >= 5 * M_PI_4 && angle < 7 * M_PI_4) {
            self.currentDirection = kDirectionLeft;
        } else {
            self.currentDirection = kDirectionDown;
        }
    } else {
        self.currentDirection = kDirectionNone;
    }
}

@end
