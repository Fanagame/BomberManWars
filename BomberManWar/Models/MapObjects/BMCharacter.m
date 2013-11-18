//
//  BMCharacter.m
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMCharacter.h"

NSInteger const kCharacterMovingSpeed = 100;
CFTimeInterval const kCharacterMovingDuration = 0.5;

@implementation BMCharacter

- (id) init {
	self = [super initWithImageNamed:@"bomberman-test"];
	
	if (self) {
		self.currentDirection = kDirectionNone;
	}
	
	return self;
}

- (void) move:(BMDirection)direction {
    SKAction *moveAction = nil;
    
    if (direction != self.currentDirection) {
        self.currentDirection = direction;
        
        if (direction == kDirectionRight) {
            moveAction = [SKAction moveByX:kCharacterMovingSpeed y:0 duration:kCharacterMovingDuration];
        } else if (direction == kDirectionLeft) {
            moveAction = [SKAction moveByX:-kCharacterMovingSpeed y:0 duration:kCharacterMovingDuration];
        } else if (direction == kDirectionUp) {
            moveAction = [SKAction moveByX:0 y:kCharacterMovingSpeed duration:kCharacterMovingDuration];
        } else if (direction == kDirectionDown) {
            moveAction = [SKAction moveByX:0 y:-kCharacterMovingSpeed duration:kCharacterMovingDuration];
        }
            
        if (moveAction) {
            [self removeAllActions];
            [self runAction:[SKAction repeatActionForever:moveAction]];
        } else if (direction == kDirectionNone) {
            [self removeAllActions];
        }
    }
}

@end
