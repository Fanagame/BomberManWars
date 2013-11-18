//
//  BMWall.m
//  BomberManWar
//
//  Created by Remy Bardou on 11/17/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMWall.h"
#import "BMConstants.h"

@implementation BMWall

- (void) setup {
//    self.color = [UIColor purpleColor];
    self.color = [UIColor clearColor];
}

- (void) updatePhysics {
    if (self.gameScene.world) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width * self.gameScene.world.xScale, self.size.height * self.gameScene.world.yScale)];
        self.physicsBody.categoryBitMask = kPhysicsCategory_Wall;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.dynamic = NO;
    }
}

@end
