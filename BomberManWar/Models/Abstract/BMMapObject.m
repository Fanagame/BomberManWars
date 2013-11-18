//
//  TDMapObject.m
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "BMMapObject.h"
#import "BMArtificialIntelligence.h"

@implementation BMMapObject

- (id) initWithObjectID:(NSInteger)objectID {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePhysics) name:kCameraZoomChangedNotificationName object:nil];
    }
    
    return self;
}

- (BMGameScene *)gameScene {
    BMGameScene *scene = (id)[self scene];
    
    if ([scene isKindOfClass:[BMGameScene class]]) {
        return scene;
    } else {
        return nil;
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Physics

- (void) updatePhysics {
    // override in subclasses
}

#pragma mark - Loop Update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [self.intelligence updateWithTimeSinceLastUpdate:interval];
}

#pragma mark - Collision handling

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    // do nothing here
}

- (void)stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    // do nothing either
}

@end
