//
//  TDHudButton.h
//  CoopTD
//
//  Created by Remy Bardou on 11/10/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMEnums.h"

@interface BMHudButton : UIButton

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign, readonly) BMHudButtonShape shape;
@property (nonatomic, assign, readonly) BMHudButtonColor color;

- (id) initWithTitle:(NSString *)title;
- (id) initWithTitle:(NSString *)title shape:(BMHudButtonShape)buttonShape;
- (id) initWithTitle:(NSString *)title color:(BMHudButtonColor)buttonColor;
- (id) initWithTitle:(NSString *)title shape:(BMHudButtonShape)buttonShape color:(BMHudButtonColor)color;

@end
