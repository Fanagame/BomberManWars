//
//  TDHudButton.m
//  CoopTD
//
//  Created by Remy Bardou on 11/10/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "BMHudButton.h"

#define BUTTON_SIZE 48

@interface BMHudButton ()

@property (nonatomic, assign) BMHudButtonColor color;
@property (nonatomic, assign) BMHudButtonShape shape;

@end

@implementation BMHudButton

- (id)initWithTitle:(NSString *)title {
    return [self initWithTitle:title shape:BMHudButtonShape_Circle];
}

- (id)initWithTitle:(NSString *)title color:(BMHudButtonColor)buttonColor {
    return [self initWithTitle:title shape:BMHudButtonShape_Circle color:buttonColor];
}

- (id)initWithTitle:(NSString *)title shape:(BMHudButtonShape)buttonShape {
    return [self initWithTitle:title shape:buttonShape color:BMHudButtonColor_Red];
}

- (id)initWithTitle:(NSString *)title shape:(BMHudButtonShape)buttonShape color:(BMHudButtonColor)color {
    self = [super init];
    
    if (self) {
        self.frame = CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE);
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
        self.shape = buttonShape;
        self.color = color;
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0 / [UIScreen mainScreen].scale];
        UIImage *bgImage = [UIImage imageNamed:[self buttonImageName]];
        [self setBackgroundImage:[bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.5 topCapHeight:bgImage.size.height * 0.5] forState:UIControlStateNormal];
        [self setTitle:title forState:UIControlStateNormal];
        [self sizeToFit];
    }
    
    return self;
}

- (NSString *) buttonImageName {
    NSMutableString *imgName = [[NSMutableString alloc] initWithString:@"btn_"];
    
    switch (self.shape) {
        case BMHudButtonShape_Circle:
            [imgName appendString:@"circle_"];
            break;
        default:
            [imgName appendString:@"rect_"];
            break;
    }
    
    switch (self.color) {
        case BMHudButtonColor_Blue:
            [imgName appendString:@"blue"];
            break;
        case BMHudButtonColor_Yellow:
            [imgName appendString:@"yellow"];
            break;
        case BMHudButtonColor_Green:
            [imgName appendString:@"green"];
            break;
        case BMHudButtonColor_Orange:
            [imgName appendString:@"orange"];
            break;
        default:
            [imgName appendString:@"red"];
            break;
    }
    
    return imgName;
}

- (CGPoint) position {
    return self.frame.origin;
}

- (void) setPosition:(CGPoint)position {
    self.frame = CGRectMake(position.x, position.y, self.frame.size.width, self.frame.size.height);
}

@end
