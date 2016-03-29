//
//  CustomImageView.h
//  JXOne
//
//  Created by Jason Jia on 3/29/16.
//  Copyright © 2016 ZGMF-X42S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomImageView : UIImageView
/**
 *  自定义动画显示图片
 *
 *  @param url      <#url description#>
 *  @param animated <#animated description#>
 */
- (void)configureImageViwWithImageURL:(NSURL *)url animated:(BOOL)animated;

@end
