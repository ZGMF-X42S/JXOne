//
//  UIView+Extension.h
//
//  Created by Jason Jia on 3/5/16.
//  Copyright © 2016 ZGMF-X42S. All rights reserved.
//
/**
 *  快速获取和赋值 UIView的位置相关值
 */
#import <UIKit/UIKit.h>

@interface UIView (Extension)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize  size;
//@property (nonatomic, assign) CGPoint origin;
@end
