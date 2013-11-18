//
//  BMCamera.m
//  BomberManWar
//
//  Created by Rémy Bardou on 14/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMCamera.h"
#import "BMCharacter.h"

@interface BMCamera () {
    CGSize _cachedWorldSize;
}

@property (nonatomic, weak) SKNode *trackedElement;
@property (nonatomic, assign) CGFloat trackingEdgeBounds;

#pragma mark - Helpers
- (CGFloat) bestScaleForDevice;
- (CGPoint) boundedLayerPosition:(CGPoint)newPos;

@end

@implementation BMCamera

CGFloat const kCameraZoomLevel_Max = 5.0f;
CGFloat const kCameraZoomLevel_Min = 0.05f;

static BMCamera *_sharedCamera;
+ (instancetype) sharedCamera {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCamera = [[BMCamera alloc] init];
    });
    return _sharedCamera;
}

- (CGSize)winSize {
    CGSize winSize = self.world.scene.size;
    
    if ([self.delegate respondsToSelector:@selector(offsetMapDimension)]) {
        CGPoint offset = [self.delegate offsetMapDimension];
        winSize.width += offset.x;
        winSize.height += offset.y;
    }
    // invert if the orientation changed
    
    // then return the value
    return winSize;
}

- (CGSize)worldSize {
	//    if (CGSizeEqualToSize(_cachedWorldSize, CGSizeZero)) {
	_cachedWorldSize = self.world.calculateAccumulatedFrame.size;
	//    }
    return _cachedWorldSize;
}

//TODO: cache the value for best performance?
- (CGFloat) bestScaleForDevice {
    CGSize winSize = self.winSize;
    CGSize actualMapSize = [self.delegate actualMapSizeForCamera:self];
    
    CGFloat bestXScale = winSize.width / actualMapSize.width;
    CGFloat bestYScale = winSize.height / actualMapSize.height;
    
    return MAX(bestXScale, bestYScale);
}


/// @description ensures that the new position won't make go out of bounds (mapSize wise)
- (CGPoint) boundedLayerPosition:(CGPoint)newPos {
    CGSize winSize = self.winSize;
    CGSize mapSize = self.worldSize;
    
    CGPoint retval = newPos;
    
    // let's offset all positions, base on the anchorPoint
    retval.x += winSize.width * self.world.scene.anchorPoint.x;
    retval.y += winSize.height * self.world.scene.anchorPoint.y;
    
    // Now, let's check if we're out of bounds with the smaller values
    retval.x = MIN(retval.x, 0);
    retval.y = MIN(retval.y, 0);
    
    // Let's do the same check with the bigger values
    retval.x = MAX(retval.x, -mapSize.width + winSize.width);
    retval.y = MAX(retval.y, -mapSize.height + winSize.height);
    
    // Finally, restore the offset on those values (cause we're dealing with .position, not .frame.origin)
    retval.x -= winSize.width * self.world.scene.anchorPoint.x;
    retval.y -= winSize.height * self.world.scene.anchorPoint.y;
    
    return retval;
}

#pragma mark - Handle camera position, move it around

//TODO: do we really need this exposed?
- (CGPoint) cameraPosition {
    return self.world.position;
}

- (void) moveCameraBy:(CGPoint)trans {
    [self disableTracking];
    
    trans = CGPointMake(self.world.position.x + trans.x, self.world.position.y - trans.y);
    self.world.position = [self boundedLayerPosition:trans];
}

- (void) pointCameraToPoint:(CGPoint)position {
    // center the world on that position
    CGPoint cameraPositionInScene = [self.world.scene convertPoint:position fromNode:self.world];
    position = CGPointMake(self.world.position.x - cameraPositionInScene.x, self.world.position.y - cameraPositionInScene.y);
    
    // apply the change while ensuring the position doesnt cause the game to go out of bounds
    self.world.position = [self boundedLayerPosition:position];
}

//- (void) pointCameraToSpawn:(TDSpawn *)spawn {
//    [self disableTracking];
//    
//    [self pointCameraToPoint:spawn.position];
//}

- (void) pointCameraToCharacter:(BMCharacter *)character {
    [self pointCameraToCharacter:character trackingEnabled:NO];
}

- (void) pointCameraToCharacter:(BMCharacter *)character trackingEnabled:(BOOL)trackingEnabled {
    [self pointCameraToCharacter:character trackingEnabled:trackingEnabled keepUnitWithinEdgeBounds:-1];
}

- (void) pointCameraToCharacter:(BMCharacter *)character trackingEnabled:(BOOL)trackingEnabled keepUnitWithinEdgeBounds:(CGFloat)edgeBound {
    
    [self zoomOnNode:character withSizeOnScreenAsPercentage:0.1];
    
    if (trackingEnabled) {
        [self enableTrackingForElement:character withEdgeBounds:edgeBound];
    } else {
        [self disableTracking];
    }
}
//
//- (void) pointCameraToBuilding:(id)building {
//    [self disableTracking];
//}

#pragma mark - Node tracking management

- (void) updateCameraTracking {
    if (self.trackingEnabled) {
        [self pointCameraToPoint:self.trackedElement.position];
    }
}

- (void) enableTrackingForElement:(SKNode *)node withEdgeBounds:(CGFloat)edgeBounds; {
    self.trackedElement = node;
    self.trackingEdgeBounds = edgeBounds;
}

- (void) disableTracking {
    self.trackedElement = nil;
    self.trackingEdgeBounds = -1;
}

- (BOOL) trackingEnabled {
    if (self.trackedElement && self.trackedElement.parent && !self.trackedElement.hidden) {
        return YES;
    }
    return NO;
}

#pragma mark - Zoom management

- (void) zoomOnNode:(SKNode *)node {
    [self zoomOnNode:node withSizeOnScreenAsPercentage:0.5];
}

- (void) zoomOnNode:(SKNode *)node withSizeOnScreenAsPercentage:(CGFloat)sizeOnScreen {
    CGSize winSize = self.winSize;
    
    CGFloat desiredWidth = winSize.width * sizeOnScreen;
    CGFloat desiredHeight = winSize.height * sizeOnScreen;
    
    CGFloat bestXScale = desiredWidth / node.calculateAccumulatedFrame.size.width;
    CGFloat bestYScale = desiredHeight / node.calculateAccumulatedFrame.size.height;
    
    CGFloat newScale = MIN(bestXScale, bestYScale);
    
    //
    // We now have our optimal scale to zoom on that object
    // Let's zoom on it
    //
    
    [self setCameraZoomLevel:newScale];
    [self pointCameraToPoint:node.position];
}

- (void) setCameraToDefaultZoomLevel {
    [self disableTracking];
    
    CGFloat newScale = [self bestScaleForDevice];
    [self setCameraZoomLevel:newScale];
}

- (void) setCameraZoomLevel:(CGFloat)newDesiredScale {
//    [self disableTracking];
    
    // Let's find out what map position is currently in the center of the screen
    CGPoint centerOfScreenCoordinates = [self.world.scene convertPoint:CGPointMake(0.5, 0.5) toNode:self.world];
    
    // Calculates optimum zoom level to not go out of bounds
	newDesiredScale = MIN(kCameraZoomLevel_Max, MAX(newDesiredScale, self.bestScaleForDevice));
	
	// Change the zoom (scale)
	if (newDesiredScale != self.cameraZoomLevel) {
		[self.world setScale:newDesiredScale];
		
		// Then point the camera back to that same center position!
		[self pointCameraToPoint:centerOfScreenCoordinates];
	}
}

- (CGFloat) cameraZoomLevel {
    return self.world.xScale;
}


@end
