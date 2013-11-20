//
//  BMOptionsViewController.h
//  BomberManWar
//
//  Created by Remy Bardou on 11/19/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMGameCenterManager.h"
#import "BMMultiplayerManager.h"

@interface BMOptionsViewController : UITableViewController<UITableViewDelegate, BMGameCenterManagerDelegate>

@property (nonatomic, weak) IBOutlet UITableViewCell *findMultiplayerGameCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *authenticateCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *advertiserStateCell;

@end
