//
//  TDObject.m
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "BMTMXObject.h"
#import "BMArtificialIntelligence.h"

@implementation BMTMXObject

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithColor:[UIColor clearColor] size:CGSizeZero];
    
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
        [self setup];
    }
    
    return self;
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"Key %@ does not exist for class %@", key, self.class);
}

- (void) setup {
    // Implement in subclasses
}

- (void) setX:(CGFloat)x {
    self.position = CGPointMake(x + (self.size.width * self.anchorPoint.x), self.position.y);
}

- (void) setY:(CGFloat)y {
    self.position = CGPointMake(self.position.x, y + (self.size.height * self.anchorPoint.y));
}

- (void) setWidth:(CGFloat)width {
    self.size = CGSizeMake(width, self.size.height);
    [self setX:self.position.x];
}

- (void) setHeight:(CGFloat)height {
    self.size = CGSizeMake(self.size.width, height);
    [self setY:self.position.y];
}

@end
