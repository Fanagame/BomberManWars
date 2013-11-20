//
//  BMGameCenterManager.h
//  BomberManWar
//
//  Created by Remy Bardou on 11/19/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol BMGameCenterManagerDelegate

- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
- (void)inviteReceived;

@optional
- (void) processGameCenterAuth: (NSError*) error;
- (void) mappedPlayerIDToPlayer: (GKPlayer*) player error: (NSError*) error;

@end

@protocol BMGameCenterMatchDataDelegate <NSObject>

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;

@end

@interface BMGameCenterManager : NSObject<GKMatchDelegate, GKMatchmakerViewControllerDelegate>
{
    BOOL userAuthenticated;
    BOOL matchStarted;
}

@property (strong) UIViewController *presentingViewController;
@property (strong) GKMatch *match;
@property (nonatomic, weak)  id<BMGameCenterManagerDelegate>  delegate;
@property (nonatomic, weak) id<BMGameCenterMatchDataDelegate> dataDelegate;
@property (strong) NSMutableDictionary *playersDict;
@property (strong) GKPlayer *localPlayer;

@property (strong) GKInvite *pendingInvite;
@property (strong) NSArray *pendingPlayersToInvite;

- (void) findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController delegate:(id)theDelegate;
- (void) authenticateLocalUserWithCompletionHandler:(void(^)(BOOL success))onComplete;
- (void) mapPlayerIDtoPlayer: (NSString*) playerID;
- (void) endGame;

+ (BOOL) isGameCenterAvailable;

+ (instancetype) currentSession;

@end
