//
//  BMJoystick.m
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMJoystick.h"

@implementation BMJoystick

- (id) init {
	self = [super init];
	if (self) {
		[self addObserver:self forKeyPath:@"origin" options:NSKeyValueObservingOptionNew context:NULL];
		[self addObserver:self forKeyPath:@"destination" options:NSKeyValueObservingOptionNew context:NULL];
	}
	return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
//	if ([delegate respondsToSelector:@selector(joystick:directionUpdated:)])
//		[delegate joystick:self directionUpdated:[self currentDirection]];
}

- (BMDirection) currentDirection {
//	if (enabled) {
//		CGPoint vectorPoint = ccpSub(self.destination, self.origin);
//		vectorPoint = ccpNormalize(vectorPoint);
//		
//		CGFloat angle = CC_RADIANS_TO_DEGREES(ccpToAngle(vectorPoint));
//		angle += 180.0;
//		
//		BMDirection direction = kDirectionUp;
//		
//		if (angle >= 315.0 || (angle >= 0 && angle < 45.0)) {
//			direction = kDirectionLeft;
//		} else if (angle >= 45.0 && angle < 135.0) {
//			direction = kDirectionDown;
//		} else if (angle >= 135.0 && angle < 225.0) {
//			direction = kDirectionRight;
//		} // else UP
//		
//		return direction;
//	}
//	else {
//		return kDirectionNone;
//	}
	return kDirectionNone;
}

//- (void) draw {
//	if (self.enabled) {
//		ccDrawColor4B(255, 0, 0, 255); //Color of the line RGBA
//		glLineWidth(5.0f); //Stroke width of the line
//		ccDrawLine(origin, destination);
//	}
//}


@end
