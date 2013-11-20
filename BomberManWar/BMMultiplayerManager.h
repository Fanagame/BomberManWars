//
//  BMMultiplayerManager.h
//  BomberManWar
//
//  Created by Remy Bardou on 11/20/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "BMEnums.h"

typedef void(^FindPlayersCompletionBlock)(BOOL success);
extern NSString * const kMultiplayerAdvertisingStatusChanged;

@interface BMMultiplayerManager : NSObject<MCBrowserViewControllerDelegate, MCSessionDelegate>

@property (nonatomic, readonly) BOOL multiplayerEnabled;
@property (nonatomic, readonly) BOOL isHost;
@property (nonatomic, readonly) BOOL isAdvertising;

@property (nonatomic, readonly) MCPeerID *myPeerId;
@property (nonatomic, readonly) MCSession *mySession;

@property (nonatomic, copy) FindPlayersCompletionBlock completionBlock;

@property (nonatomic, weak) UIViewController *presentingViewController;

+ (instancetype) sharedManager;

- (void) startBeingAvailableForAGame;
- (void) stopBeingAvailableForAGame;

- (void) startLookingForPlayersWithCompletionHandler:(FindPlayersCompletionBlock)onComplete;
- (void) stopLookingForPlayers;

- (void) endSession;

@end

@interface BMMultiplayerPacket : NSObject

@property (nonatomic, assign) BMPacketType packetType;
@property (nonatomic, strong) NSDictionary *blob;

- (NSData *) dataRepresentation;

+ (BMMultiplayerPacket *) packetWithType:(BMPacketType)packetType;
+ (BMMultiplayerPacket *) packetWithType:(BMPacketType)packetType andBlob:(NSDictionary *)blob;
+ (BMMultiplayerPacket *) packetWithData:(NSData *)data;

@end