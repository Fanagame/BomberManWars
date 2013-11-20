//
//  BMViewController.m
//  BomberManWar
//
//  Created by Rémy Bardou on 14/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMGameViewController.h"
#import "BMGameScene.h"

#define DEFAULT_MAP_NAME @"bomberman-demo"

@implementation BMGameViewController

- (NSMutableArray *) players {
    if (!_players) {
        _players = [[NSMutableArray alloc] init];
    }
    return _players;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void) viewDidAppear:(BOOL)animated {
    // Create and configure the scene.
//	[self showGameCenter];
    [self startGame];
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void) startGame {
    SKView * skView = (SKView *)self.view;
    
    __weak BMGameViewController *weakSelf = self;
    [BMGameScene loadSceneAssetsForMapName:DEFAULT_MAP_NAME withCompletionHandler:^{
        BMGameScene * scene = [[BMGameScene alloc] initWithSize:skView.bounds.size andMapName:DEFAULT_MAP_NAME];
        scene.scaleMode = SKSceneScaleModeAspectFill;
		scene.parentViewController = weakSelf;
        
        scene.multiplayerEnabled = weakSelf.multiplayerEnabled;
        scene.gameCenterPlayers = weakSelf.players;
        scene.localGameCenterPlayer = weakSelf.localPlayer;
        scene.isClient = weakSelf.isClient;
        
        // Present the scene.
        [skView presentScene:scene];
    }];
}

- (BMGameScene *) gameScene {
    SKView * skView = (SKView *)self.view;
    return (BMGameScene *)skView.scene;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
    self.navigationController.navigationBarHidden = YES;

	[BMGameScene releaseSceneAssetsForMapName:DEFAULT_MAP_NAME];
}

//- (BMGameCenterManager *) gameCenterManager {
//    if (!_gameCenterManager) {
//        _gameCenterManager = [[BMGameCenterManager alloc] init];
//        _gameCenterManager.presentingViewController = self;
//        _gameCenterManager.delegate = self;
//    }
//    return _gameCenterManager;
//}

- (void) showGameCenter {
//    if ([BMGameCenterManager isGameCenterAvailable]) {
//        [[self gameCenterManager] authenticateLocalUserWithCompletionHandler:^(BOOL success) {
//            if (success) {
//                [[self gameCenterManager] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self delegate:self];
//            } else {
//                [self showGameCenter];
//            }
//        }];
//    } else {
//        [UIAlertView showAlertWithMessage:@"You need Game Center to run this game."];
//    }

//    __weak BMViewController *weakSelf = self;
//    [[BMGameCenterManager sharedManager] setMainController:self];
//    [[BMGameCenterManager sharedManager] authenticateAndFindOtherPlayersWithCompletionHandler:^(BOOL success){
//        if (success) {
//            [self startGame];
//        } else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"You need Game Center to play this game." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            
//            [weakSelf showGameCenter];
//        }
//    }];

    
    //    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
//    if (gameCenterController != nil)
//    {
//        gameCenterController.gameCenterDelegate = self;
//        [self presentViewController: gameCenterController animated: YES completion:nil];
//    }
}





@end
