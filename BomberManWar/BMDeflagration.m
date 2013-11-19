//
//  BMDeflagration.m
//  BomberManWar
//
//  Created by Remy Bardou on 11/18/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMDeflagration.h"
#import "BMConstants.h"

#define PHYSICS_COLLISION_EXPLOSION_SIZE_DOWNSCALING_FACTOR 0.3

@interface BMDeflagration () {
    NSMutableArray *_deflagrationFrames;
    NSMutableArray *_deflagrationSprites;
}

@property (nonatomic, strong) SKAction *deflagrationAction;

@end

@implementation BMDeflagration

- (id) initWithPosition:(CGPoint)position andMaxSize:(NSUInteger)maxSize {
    self = [super init];
    
    if (self) {
        self.deflagrationSprites = [[NSMutableArray alloc] init];
        self.position = position;
        self.maxSize = maxSize;
        
        [self loadAnimations];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraScaleDidUpdate) name:kCameraZoomChangedNotificationName object:nil];
    }
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) loadAnimations {
    _deflagrationFrames = [[NSMutableArray alloc] init];
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Bombs"];
    for (int i = 1; i < 26; i++) {
        SKTexture *t = [atlas textureNamed:[NSString stringWithFormat:@"explosion_%03d", i]];
        [_deflagrationFrames addObject:t];
    }
}

- (SKTexture *) defaultTexture {
    if (_deflagrationFrames.count > 0) {
        return _deflagrationFrames[0];
    }
    return nil;
}

- (SKAction *) deflagrationAction {
    if (!_deflagrationAction) {
        _deflagrationAction = [SKAction animateWithTextures:_deflagrationFrames timePerFrame:0.1];
    }
    return _deflagrationAction;
}

- (void) cameraScaleDidUpdate {
    if (self.scene) {
        for (SKNode *node in self.deflagrationSprites) {
            [self updatePhysicsForNode:node];
        }
    }
}

- (void) updatePhysicsForNode:(SKNode *)node {
    if (node) {
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.physicsSize];
        node.physicsBody.categoryBitMask = kPhysicsCategory_Deflagration;
        node.physicsBody.collisionBitMask = 0;
        node.physicsBody.dynamic = NO;
    }
}

#pragma mark - Public API

- (void) deflagrate {
    [self deflagrateWithCompletionHandler:nil];
}

- (void) deflagrateWithCompletionHandler:(void (^)())onComplete {
    SKTexture *texture = [self defaultTexture];
    CGSize tileSize = texture.size;
    
    BOOL leftProgressionStopped = NO;
    BOOL rightProgressionStopped = NO;
    BOOL upProgressionStopped = NO;
    BOOL downProgressionStopped = NO;
    
    // Add the central explosion (bomb location)
    SKSpriteNode *n = [[SKSpriteNode alloc] initWithTexture:texture];
    n.position = CGPointZero;
    [self addChild:n];
    [self.deflagrationSprites addObject:n];
    [self updatePhysicsForNode:n];
    [n runAction:self.deflagrationAction completion:^{
        if (onComplete) {
            onComplete();
        }
    }];
    
    // Then add all the other explosion sprites
    for (int i = 1; i <= self.maxSize; i++) {
        CGPoint nextPos = CGPointZero;
        CGPoint worldPos = CGPointZero;
        SKPhysicsBody *collisionBody = nil;
        
        // left
        if (!leftProgressionStopped) {
            nextPos = CGPointMake(- i * (tileSize.width), 0);
            worldPos = [self.scene convertPoint:nextPos fromNode:self];
            collisionBody = [self.scene.physicsWorld bodyInRect:CGRectMake(worldPos.x, worldPos.y, tileSize.width * PHYSICS_COLLISION_EXPLOSION_SIZE_DOWNSCALING_FACTOR, tileSize.height * PHYSICS_COLLISION_EXPLOSION_SIZE_DOWNSCALING_FACTOR)];
            if (!collisionBody || (collisionBody && collisionBody.categoryBitMask != kPhysicsCategory_Wall)) {
                n = [n copy];
                n.position = nextPos;
                [self addChild:n];
                [self.deflagrationSprites addObject:n];
                [n runAction:self.deflagrationAction];
            } else {
                leftProgressionStopped = YES;
            }
        }
        
        // right
        if (!rightProgressionStopped) {
            nextPos = CGPointMake(i * (tileSize.width), 0);
            worldPos = [self.scene convertPoint:nextPos fromNode:self];
            collisionBody = [self.scene.physicsWorld bodyInRect:CGRectMake(worldPos.x, worldPos.y, tileSize.width * PHYSICS_COLLISION_EXPLOSION_SIZE_DOWNSCALING_FACTOR, tileSize.height * PHYSICS_COLLISION_EXPLOSION_SIZE_DOWNSCALING_FACTOR)];
            if (!collisionBody || (collisionBody && collisionBody.categoryBitMask != kPhysicsCategory_Wall)) {
                n = [n copy];
                n.position = nextPos;
                [self addChild:n];
                [self.deflagrationSprites addObject:n];
                [n runAction:self.deflagrationAction];
            } else {
                rightProgressionStopped = YES;
            }
        }
        
        // up
        if (!upProgressionStopped) {
            nextPos = CGPointMake(0, - i * (tileSize.height));
            worldPos = [self.scene convertPoint:nextPos fromNode:self];
            collisionBody = [self.scene.physicsWorld bodyInRect:CGRectMake(worldPos.x, worldPos.y, tileSize.width * PHYSICS_COLLISION_EXPLOSION_SIZE_DOWNSCALING_FACTOR, tileSize.height * PHYSICS_COLLISION_EXPLOSION_SIZE_DOWNSCALING_FACTOR)];
            if (!collisionBody || (collisionBody && collisionBody.categoryBitMask != kPhysicsCategory_Wall)) {
                n = [n copy];
                n.position = nextPos;
                [self addChild:n];
                [self.deflagrationSprites addObject:n];
                [n runAction:self.deflagrationAction];
            } else {
                upProgressionStopped = YES;
            }
        }
        
        // down
        if (!downProgressionStopped) {
            nextPos = CGPointMake(0, i * (tileSize.height));
            worldPos = [self.scene convertPoint:nextPos fromNode:self];
            collisionBody = [self.scene.physicsWorld bodyInRect:CGRectMake(worldPos.x, worldPos.y, tileSize.width * PHYSICS_COLLISION_EXPLOSION_SIZE_DOWNSCALING_FACTOR, tileSize.height * PHYSICS_COLLISION_EXPLOSION_SIZE_DOWNSCALING_FACTOR)];
            if (!collisionBody || (collisionBody && collisionBody.categoryBitMask != kPhysicsCategory_Wall)) {
                n = [n copy];
                n.position = nextPos;
                [self addChild:n];
                [self.deflagrationSprites addObject:n];
                [n runAction:self.deflagrationAction];
            } else {
                downProgressionStopped = YES;
            }
        }
    }
}

@end
