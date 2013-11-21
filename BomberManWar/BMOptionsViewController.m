//
//  BMOptionsViewController.m
//  BomberManWar
//
//  Created by Remy Bardou on 11/19/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMOptionsViewController.h"
#import "BMGameViewController.h"
#import "BMConstants.h"

NSString * const kStartGameSegueName = @"startGame";

@interface BMOptionsViewController ()

@property (nonatomic, assign) BOOL isClient;

@end

@implementation BMOptionsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [BMMultiplayerManager sharedManager].presentingViewController = self;

    __weak BMOptionsViewController *weakSelf = self;
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf disableMultiplayer];
    });
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMultiplayerAdvertisingStatusChanged object:nil queue:nil usingBlock:^(NSNotification *note) {
        if ([BMMultiplayerManager sharedManager].isAdvertising) {
            self.advertiserStateCell.textLabel.text = @"is advertising";
        } else {
            self.advertiserStateCell.textLabel.text = @"is NOT advertising";
        }
    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.isClient = NO; // reset the status
    
    [[BMMultiplayerManager sharedManager] startBeingAvailableForAGame];
    
#ifndef DISABLE_GAMECENTER_AUTOCONNECT
    [self tryAuthenticatingToGameCenter];
#endif
}

- (void) enableMultiplayer {
    self.findMultiplayerGameCell.alpha = 1.0;
    self.findMultiplayerGameCell.userInteractionEnabled = YES;
}

- (void) disableMultiplayer {
    self.findMultiplayerGameCell.alpha = 0.2;
    self.findMultiplayerGameCell.userInteractionEnabled = NO;
}

- (void) enableAuthenticate {
    self.authenticateCell.alpha = 1.0;
    self.authenticateCell.userInteractionEnabled = YES;
}

- (void) disableAuthenticate {
    self.authenticateCell.alpha = 0.2;
    self.authenticateCell.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                // start game (segue, dont do anything)
                break;
            }
            case 1: {
                // authenticate on game center
                [self tryAuthenticatingToGameCenter];
                break;
            } case 2:
                // find a multiplayer game
                [self setupMultiplayer];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self findNearbyPlayers];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) tryAuthenticatingToGameCenter {
    __weak BMOptionsViewController *weakSelf = self;
    
    [self disableAuthenticate];
    [[self gameCenterManager] authenticateLocalUserWithCompletionHandler:^(BOOL success) {
        if (success) {
            [weakSelf disableAuthenticate];
            [weakSelf enableMultiplayer];
        } else {
            [weakSelf enableAuthenticate];
            [weakSelf disableMultiplayer];
        }
    }];
}

- (BMGameCenterManager *) gameCenterManager {
    [[BMGameCenterManager currentSession] setDelegate:self];
    [[BMGameCenterManager currentSession] setPresentingViewController:self];
    return [BMGameCenterManager currentSession];
}

- (void) setupMultiplayer {
    [[self gameCenterManager] findMatchWithMinPlayers:2 maxPlayers:4 viewController:self delegate:self];
}

- (void) findNearbyPlayers {
    [[BMMultiplayerManager sharedManager] startLookingForPlayersWithCompletionHandler:^(BOOL success) {
        if (success) {
            [UIAlertView showAlertWithMessage:@"Found a nearby player! Yay!"];
        } else {
            [UIAlertView showAlertWithMessage:@"Failed to find a nearby player!"];
        }
    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kStartGameSegueName] && [segue.destinationViewController isKindOfClass:[BMGameViewController class]]) {
        
        BMGameViewController *vc = (BMGameViewController *)segue.destinationViewController;
        
        if ([self gameCenterManager].playersDict.count > 0) {
            vc.multiplayerEnabled = YES;
            [vc.players addObjectsFromArray:[self gameCenterManager].playersDict.allValues];
            vc.localPlayer = [[self gameCenterManager] localPlayer];
            vc.isClient = self.isClient;
        } else {
            vc.multiplayerEnabled = NO;
            vc.localPlayer = nil;
            vc.isClient = self.isClient;
            [vc.players removeAllObjects];
        }
    }
}

#pragma mark - BMGameCenterManager delegate

- (void) matchStarted {
    [self performSegueWithIdentifier:kStartGameSegueName sender:nil];
}

- (void) matchEnded {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [UIAlertView showAlertWithMessage:@"The game was ended!"];
}

- (void) match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    // handle game updates
    // should send this to the scene
}

- (void) inviteReceived {
    NSLog(@"invite received on %@!!", [UIDevice currentDevice].name);
    self.isClient = YES;
    [self setupMultiplayer];
}

@end
