//
//  UIView+LMExtension.m
//  MyiOSCategories
//
//  Created by Lyman on 16/9/12.
//  Copyright © 2016年 Lyman. All rights reserved.
//

#import "UIView+LMExtension.h"

@implementation UIView (LMExtension)

#pragma mark - setter
- (void)setLm_x:(CGFloat)lm_x {
    CGRect frame = self.frame;
    frame.origin.x = lm_x;
    self.frame = frame;
}

- (void)setLm_y:(CGFloat)lm_y {
    CGRect frame = self.frame;
    frame.origin.y = lm_y;
    self.frame = frame;
}

- (void)setLm_width:(CGFloat)lm_width {
    CGRect frame = self.frame;
    frame.size.width = lm_width;
    self.frame = frame;
}

- (void)setLm_height:(CGFloat)lm_height {
    CGRect frame = self.frame;
    frame.size.height = lm_height;
    self.frame = frame;
}

- (void)setLm_centerX:(CGFloat)lm_centerX {
    CGPoint center = self.center;
    center.x = lm_centerX;
    self.center = center;
}

- (void)setLm_centerY:(CGFloat)lm_centerY {
    CGPoint center = self.center;
    center.y = lm_centerY;
    self.center = center;
}

- (void)setLm_size:(CGSize)lm_size {
    CGRect frame = self.frame;
    frame.size = lm_size;
    self.frame = frame;
}

- (void)setLm_origin:(CGPoint)lm_origin {
    CGRect frame = self.frame;
    frame.origin = lm_origin;
    self.frame = frame;
}

- (void)setLm_bottom:(CGFloat)lm_bottom {
    self.lm_y = lm_bottom - self.lm_height;
}

- (void)setLm_right:(CGFloat)lm_right {
    self.lm_x = lm_right - self.lm_width;
}

#pragma mark - getter

- (CGFloat)lm_x {
    return self.frame.origin.x;
}

- (CGFloat)lm_y {
    return self.frame.origin.y;
}

- (CGFloat)lm_width {
    return self.frame.size.width;
}

- (CGFloat)lm_height {
    return self.frame.size.height;
}

- (CGFloat)lm_centerX {
    return self.center.x;
}

- (CGFloat)lm_centerY {
    return self.center.y;
}

- (CGSize)lm_size {
    return self.frame.size;
}

- (CGPoint)lm_origin {
    return self.frame.origin;
}

- (CGFloat)lm_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)lm_right {
    return self.frame.origin.x + self.frame.size.width;
}

@end
