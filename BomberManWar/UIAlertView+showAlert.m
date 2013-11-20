//
//  UIAlertView+showAlert.m
//  BomberManWar
//
//  Created by Remy Bardou on 11/19/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "UIAlertView+showAlert.h"

@implementation UIAlertView (showAlert)

+ (void) showAlertWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
