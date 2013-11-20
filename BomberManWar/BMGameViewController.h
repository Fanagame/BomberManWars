//
//  BMViewController.h
//  BomberManWar
//

//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>

@interface BMGameViewController : UIViewController

@property (nonatomic, assign) BOOL multiplayerEnabled;
@property (nonatomic, assign) BOOL isClient;
@property (nonatomic, strong) GKPlayer *localPlayer;
@property (nonatomic, strong) NSMutableArray *players;

@end
