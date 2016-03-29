//
//  CircularLoaderView.h
//  JXOne
//
//  Created by Jason Jia on 3/29/16.
//  Copyright © 2016 ZGMF-X42S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircularLoaderView : UIView

@property (nonatomic, assign) CGFloat progress;

/**
 *  显示图片效果执行
 */
- (void)reveal;

@end
