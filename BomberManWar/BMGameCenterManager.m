//
//  BMGameCenterManager.m
//  BomberManWar
//
//  Created by Remy Bardou on 11/19/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMGameCenterManager.h"
#import <GameKit/GameKit.h>

@implementation BMGameCenterManager

static BMGameCenterManager *_currentSession = nil;
+ (instancetype) currentSession {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentSession = [[BMGameCenterManager alloc] init];
    });
    
    return _currentSession;
}

- (id) init
{
    self = [super init];
    if(self!= NULL)
    {
        // when we init, we check if Game Center is available
        if([BMGameCenterManager isGameCenterAvailable]) {
            
            // this is very important... since we must know if the user logs in/out
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        
        self.localPlayer = [GKLocalPlayer localPlayer];
        userAuthenticated = YES;
        
        [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
            
            self.pendingInvite = acceptedInvite;
            self.pendingPlayersToInvite = playersToInvite;
            [self.delegate inviteReceived];
        };
        
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        self.localPlayer = nil;
        userAuthenticated = NO;
    }
}

+ (BOOL) isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (void) authenticateLocalUserWithCompletionHandler:(void(^)(BOOL success))onComplete
{
    __weak BMGameCenterManager *weakSelf = self;
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *loginVC, NSError *error) {
            if ([GKLocalPlayer localPlayer].isAuthenticated) {
                if (onComplete)
                    onComplete(YES);
            } else if (loginVC) {
//                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.presentingViewController presentViewController:loginVC animated:YES completion:nil];
//                });
            } else {
                if (onComplete)
                    onComplete(NO);
            }
        };
//    });
}

#pragma mark -
#pragma mark find match with min players
// Add new method, right after authenticateLocalUser
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController delegate:(id<BMGameCenterManagerDelegate>)theDelegate {
    
    if (![BMGameCenterManager isGameCenterAvailable]) return;
    
    matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    self.delegate = theDelegate;
    
    if (self.pendingInvite != nil) {
        
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:self.pendingInvite];
        mmvc.matchmakerDelegate = self;
        [self.presentingViewController presentViewController:mmvc animated:YES completion:nil];
        
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
        
    } else {
        
        // with minPlayers/maxPlayers we define how many players our multiplayer
        // game may or must have
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        GKMatchRequest *request = [[GKMatchRequest alloc] init];
        request.minPlayers = minPlayers;
        request.maxPlayers = maxPlayers;
        request.playersToInvite = self.pendingPlayersToInvite;
        
        GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
        mmvc.matchmakerDelegate = self;
        
        [self.presentingViewController presentViewController:mmvc animated:YES completion:nil];
        
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
    }
}

#pragma mark -
#pragma mark get players info
// Add new method after authenticationChanged
- (void)lookupPlayers {
    
    NSLog(@"Looking up %d players...", self.match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:self.match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {

        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            matchStarted = NO;
            [self.delegate matchEnded];
        } else {
            self.playersDict = [[NSMutableDictionary alloc] initWithCapacity:players.count];
            for (GKPlayer *player in players) {
                self.playersDict[player.playerID] = player;
            }
            matchStarted = YES;
            [self.delegate matchStarted];
        }
    }];
    
}

#pragma mark GKMatchmakerViewControllerDelegate
// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error finding match: %@", error.localizedDescription);
    
    UIAlertView *resetAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    [resetAlert show];
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.match = theMatch;
    self.match.delegate = self;
    if (!matchStarted && self.match.expectedPlayerCount == 0) {
        
        // Add inside matchmakerViewController:didFindMatch, right after @"Ready to start match!":
        [self lookupPlayers];
    }
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    if (self.match != theMatch) return;
    
    if (self.dataDelegate) {
        [self.dataDelegate match:theMatch didReceiveData:data fromPlayer:playerID];
    }
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    
    if (self.match != theMatch) return;
    
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (!matchStarted && theMatch.expectedPlayerCount == 0) {
                
                NSLog(@"Ready to start match!");
                [self lookupPlayers];
            }
            
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            matchStarted = NO;
            [self.delegate matchEnded];
            break;
    }
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (self.match != theMatch) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    matchStarted = NO;
    [self.delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error {
    
    if (self.match != theMatch) return;
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    matchStarted = NO;
    [self.delegate matchEnded];
}

- (void) mapPlayerIDtoPlayer: (NSString*) playerID
{
    [GKPlayer loadPlayersForIdentifiers: [NSArray arrayWithObject: playerID] withCompletionHandler:^(NSArray *playerArray, NSError *error)
     {
         GKPlayer* player= NULL;
         for (GKPlayer* tempPlayer in playerArray)
         {
             if([tempPlayer.playerID isEqualToString: playerID])
             {
                 player= tempPlayer;
                 break;
             }
         }
         
//         [self callDelegateOnMainThread: @selector(mappedPlayerIDToPlayer:error:) withArg: player error: error];
     }];
    
}

- (void) endGame {
    [self.match disconnect];
    self.match = nil;
    self.dataDelegate = nil;
    self.playersDict = nil;
}

@end
