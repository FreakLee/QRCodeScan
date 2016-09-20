//
//  UIView+LMExtension.h
//  MyiOSCategories
//
//  Created by Lyman on 16/9/12.
//  Copyright © 2016年 Lyman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LMExtension)

/** frame.origin.x */
@property (nonatomic, assign) CGFloat   lm_x;

/** frame.origin.y */
@property (nonatomic, assign) CGFloat   lm_y;

/** frame.size.width */
@property (nonatomic, assign) CGFloat   lm_width;

/** frame.size.height */
@property (nonatomic, assign) CGFloat   lm_height;

/** center.x */
@property (nonatomic, assign) CGFloat   lm_centerX;

/** center.y */
@property (nonatomic, assign) CGFloat   lm_centerY;

/** frame.size */
@property (nonatomic, assign) CGSize    lm_size;

/** frame.origin */
@property (nonatomic, assign) CGPoint   lm_origin;

/** frame.origin.y + frame.size.height */
@property (nonatomic, assign) CGFloat   lm_bottom;

/** frame.origin.x + frame.size.width */
@property (nonatomic, assign) CGFloat   lm_right;

@end
