//
//  TDMapObject.h
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "BMGameScene.h"

@class BMArtificialIntelligence;

@interface BMMapObject : SKSpriteNode

@property (nonatomic, assign) NSInteger objectID;
@property (nonatomic, assign) NSInteger uniqueID;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *baseCacheKey;
@property (nonatomic, strong) BMArtificialIntelligence *intelligence;

- (id) initWithObjectID:(NSInteger)objectID;

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval;
- (BMGameScene *)gameScene;
- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact;
- (void)stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact;

@end
