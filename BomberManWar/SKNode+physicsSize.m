//
//  SKNode+physicsSize.m
//  BomberManWar
//
//  Created by Remy Bardou on 11/18/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "SKNode+physicsSize.h"
#import "BMGameScene.h"

@implementation SKNode (physicsSize)

- (CGSize) physicsSize {
    BMGameScene *scene = (BMGameScene *)self.scene;
    CGSize size = self.calculateAccumulatedFrame.size;
    
    return CGSizeMake(size.width * scene.world.xScale, size.height * scene.world.yScale);
}

@end
