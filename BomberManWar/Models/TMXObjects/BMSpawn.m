//
//  TDSpawn.m
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "BMSpawn.h"

@implementation BMSpawn

- (void) setup {
    self.color = [UIColor redColor];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Loop Update

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
}

@end
