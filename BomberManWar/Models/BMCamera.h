//
//  BMCamera.h
//  BomberManWar
//
//  Created by Rémy Bardou on 14/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class BMCamera, BMCharacter;

@protocol BMCameraDelegate <NSObject>

- (CGSize) actualMapSizeForCamera:(BMCamera *)camera;
- (CGSize) mapSizeForCamera:(BMCamera *)camera;
- (CGPoint) offsetMapDimension;

@end

@interface BMCamera : NSObject

@property (nonatomic, weak) SKNode *world;
@property (nonatomic, weak) id<BMCameraDelegate> delegate;

+ (instancetype) sharedCamera;

#pragma mark - Point camera somewhere
- (CGPoint) cameraPosition;
- (void) pointCameraToPoint:(CGPoint)position;
//- (void) pointCameraToSpawn:(TDSpawn *)spawn;
- (void) pointCameraToCharacter:(BMCharacter *)character;
- (void) pointCameraToCharacter:(BMCharacter *)character trackingEnabled:(BOOL)trackingEnabled;
//- (void) pointCameraToBuilding:(id)building;
- (void) moveCameraBy:(CGPoint)tran;

#pragma mark - Tracking
- (void) updateCameraTracking;
- (void) enableTrackingForElement:(SKNode *)node withEdgeBounds:(CGFloat)edgeBounds;
- (void) disableTracking;
- (BOOL) trackingEnabled;

#pragma mark - Zoom on something
- (void) zoomOnNode:(SKNode *)node;
- (void) zoomOnNode:(SKNode *)node withSizeOnScreenAsPercentage:(CGFloat)sizeOnScreen;
- (void) setCameraToDefaultZoomLevel;
- (void) setCameraZoomLevel:(CGFloat)newZoomLevel;
- (CGFloat) cameraZoomLevel;

@end
