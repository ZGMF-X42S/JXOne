//
//  RightPullToRefreshView.h
//  JXOne
//
//  Created by Jason Jia on 3/30/16.
//  Copyright © 2016 ZGMF-X42S. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RightPullToRefreshViewDelegate;
@protocol RightPullToRefreshViewDataSource;

@interface RightPullToRefreshView : UIView

@property (nonatomic, assign) id <RightPullToRefreshViewDelegate> delegate;
@property (nonatomic, assign) id <RightPullToRefreshViewDataSource> dataSource;
@property (nonatomic, readonly) NSInteger currentItemIndex;
@property (nonatomic, strong, readonly) UIView *currentItemView;
@property (nonatomic, strong, readonly) UIView *contentView;

/**
 *  插入一个新的 item
 *
 *  @param index    新的 item 的下标
 *  @param animated 是否需要动画
 */
- (void)insertItemAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  重新加载数据
 */
- (void)reloadData;

/**
 *  重新加载指定下标的 item
 *
 *  @param index    要重新加载的 item 的下标
 *  @param animated 动画
 */
- (void)reloadItemAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  获取指定下标的 item
 *
 *  @param index 要获取的item 的下标
 *
 *  @return 返回需求的item
 */
- (UIView *)itemViewAtIndex:(NSInteger)index;

/**
 *  结束刷新
 */
- (void)endRefreshing;

@end

#pragma mark - DataSource
@protocol RightPullToRefreshViewDataSource <NSObject>

@required
/**
 *  一共有多少个 item
 *
 *  @param rightPullToRefreshView rightPullToRefreshView
 *
 *  @return item 的个数
 */
- (NSInteger)numberOfItemsInRightPullToRefreshView:(RightPullToRefreshView *)rightPullToRefreshView;

/**
 *  当前要显示的 item 的 view
 *
 *  @param rightPullToRefreshView rightPullToRefreshView
 *  @param index                  当前要显示的 item 的下标
 *  @param view                   重用的 view
 *
 *  @return item 的 view
 */
- (UIView *)rightPullToRefreshView:(RightPullToRefreshView *)rightPullToRefreshView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view;

@end

#pragma mark - Delegate
@protocol RightPullToRefreshViewDelegate <NSObject>

@optional

/**
 *  右拉刷新时回调的方法
 *
 *  @param rightPullToRefreshView rightPullToRefreshView
 */
- (void)rightPullToRefreshViewRefreshing:(RightPullToRefreshView *)rightPullToRefreshView;

/**
 *  当当前显示的是最后一个 item 时回调，用于添加新的 item
 *
 *  @param rightPullToRefreshView rightPullToRefreshView
 */
- (void)rightPullToRefreshViewDidScrollToLastItem:(RightPullToRefreshView *)rightPullToRefreshView;

/**
 *  item 在屏幕上显示完毕
 *
 *  @param rightPullToRefreshView rightPullToRefreshView
 *  @param index                  当前 item 的下标
 */
- (void)rightPullToRefreshView:(RightPullToRefreshView *)rightPullToRefreshView didDisplayItemAtIndex:(NSInteger)index;

/**
 *  当前要展示的 item 的下标发生变化
 *
 *  @param rightPullToRefreshView rightPullToRefreshView
 */
- (void)rightPullToRefreshViewCurrentItemIndexDidChange:(RightPullToRefreshView *)rightPullToRefreshView;

@end




