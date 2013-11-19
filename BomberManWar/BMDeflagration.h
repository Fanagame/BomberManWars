//
//  BMDeflagration.h
//  BomberManWar
//
//  Created by Remy Bardou on 11/18/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMMapObject.h"

@interface BMDeflagration : SKNode

@property (nonatomic, strong) NSMutableArray *deflagrationSprites;

@property (nonatomic, assign) NSUInteger maxSize;

- (id) initWithPosition:(CGPoint)position andMaxSize:(NSUInteger)maxSize;
- (void) deflagrate; // is that a word?
- (void) deflagrateWithCompletionHandler:(void(^)())onComplete;

//TODO: find a nicer way to do that
- (void) cameraScaleDidUpdate;

@end
