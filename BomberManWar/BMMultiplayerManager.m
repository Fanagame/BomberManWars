//
//  BMMultiplayerManager.m
//  BomberManWar
//
//  Created by Remy Bardou on 11/20/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMMultiplayerManager.h"

NSString * const kMultiplayerServiceName = @"bbmanwar";
NSString * const kMultiplayerAdvertisingStatusChanged = @"kMultiplayerAdvertisingStatusChanged";

@interface BMMultiplayerManager ()

@property (nonatomic, strong) MCPeerID *myPeerId;
@property (nonatomic, strong) MCSession *mySession;
@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, assign) BOOL isAdvertising;

@end

@implementation BMMultiplayerManager

static BMMultiplayerManager *_sharedManager;

+ (instancetype) sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BMMultiplayerManager alloc] init];
    });
    return _sharedManager;
}

#pragma mark - Public API

- (void) startBeingAvailableForAGame {
    [self.advertiser start];
    self.isAdvertising = YES;
}

- (void) stopBeingAvailableForAGame {
    [self.advertiser stop];
    self.isAdvertising = NO;
}

- (void) startLookingForPlayersWithCompletionHandler:(FindPlayersCompletionBlock)onComplete {
    [self stopBeingAvailableForAGame];
    
    self.completionBlock = onComplete;
    
    if (self.presentingViewController) {
        [self.presentingViewController presentViewController:self.browser animated:YES completion:nil];
    } else {
        [self returnFailure];
    }
}

- (void) stopLookingForPlayers {
    [self stopBeingAvailableForAGame];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) endSession {
    self.advertiser = nil;
    self.browser = nil;
    self.mySession = nil;
}

#pragma mark - Private API

- (void) returnFailure {
    if (self.completionBlock) {
        self.completionBlock(NO);
        self.completionBlock = nil;
    }
}

- (void) returnSuccess {
    if (self.completionBlock) {
        self.completionBlock(YES);
        self.completionBlock = nil;
    }
}

- (void) coinToss {
    
//    NSError *error = nil;
//    
//    if (![self.mySession sendData:nil toPeers:nil withMode:MCSessionSendDataReliable error:&error]) {
//        NSLog(@"Coin toss error: %@", error.description);
//        
//        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//        [self returnFailure];
//    }    
}

#pragma mark - Browser delegate

- (void) browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    NSLog(@"browserViewControllerDidFinish");
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self returnSuccess];
}

- (void) browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    NSLog(@"browserViewControllerWasCancelled");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self returnFailure];
}

#pragma mark - Session delegate
#pragma mark Implemented
- (void) session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSLog(@"session didChangeState");
}

- (void) session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"session didReceiveData");
}

#pragma mark Not implemented

- (void) session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

- (void) session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler {
    
}

- (void) session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

#pragma mark - Properties

- (MCPeerID *) myPeerId {
    if (!_myPeerId) {
        _myPeerId = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    }
    return _myPeerId;
}

- (MCSession *) mySession {
    if (!_mySession) {
        _mySession = [[MCSession alloc] initWithPeer:self.myPeerId];
        _mySession.delegate = self;
    }
    return _mySession;
}

- (MCBrowserViewController *) browser {
    if (!_browser) {
        _browser = [[MCBrowserViewController alloc] initWithServiceType:kMultiplayerServiceName session:self.mySession];
        _browser.delegate = self;
        _browser.maximumNumberOfPeers = 2;
        _browser.maximumNumberOfPeers = 2;
    }
    return _browser;
}

- (MCAdvertiserAssistant *) advertiser {
    if (!_advertiser) {
        _advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:kMultiplayerServiceName discoveryInfo:nil session:self.mySession];
    }
    return _advertiser;
}

// this is not very solid
- (BOOL) multiplayerEnabled {
    return (_mySession != nil);
}

- (void) setIsAdvertising:(BOOL)isAdvertising {
    if (_isAdvertising != isAdvertising) {
        _isAdvertising = isAdvertising;
        [[NSNotificationCenter defaultCenter] postNotificationName:kMultiplayerAdvertisingStatusChanged object:nil];
    }
}

@end

@implementation BMMultiplayerPacket

+ (BMMultiplayerPacket *) packetWithType:(BMPacketType)packetType andBlob:(NSDictionary *)blob {
    BMMultiplayerPacket *packet = [[BMMultiplayerPacket alloc] init];
    packet.packetType = packetType;
    packet.blob = blob;
    
    return packet;
}

+ (BMMultiplayerPacket *) packetWithType:(BMPacketType)packetType {
    return [self packetWithType:packetType andBlob:nil];
}

+ (BMMultiplayerPacket *) packetWithData:(NSData *)data {
    BMMultiplayerPacket *packet = [[BMMultiplayerPacket alloc] init];
    
    if (data != nil) {
        BMPacketType packetType = kPacketTypeUnknown;
        
        NSData *packetTypeFlag = [data subdataWithRange:NSMakeRange(0, sizeof(packet.packetType))];
        [packetTypeFlag getBytes:&packetType length:sizeof(packetType)];
        
        packet.packetType = packetType;
        
        // if this is not the whole packet, then we must have blob
        if (packetTypeFlag.length < data.length) {
            NSData *packetBlob = [data subdataWithRange:NSMakeRange(packetTypeFlag.length, data.length - packetTypeFlag.length)];
            NSDictionary *blob = [NSKeyedUnarchiver unarchiveObjectWithData:packetBlob];
            packet.blob = blob;
        }
    }
    
    return packet;
}

- (NSData *) dataRepresentation {
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendBytes:&_packetType length:sizeof(_packetType)];
    
    if (self.blob) {
        [data appendData:[NSKeyedArchiver archivedDataWithRootObject:self.blob]];
    }
    
    return data;
}

@end
