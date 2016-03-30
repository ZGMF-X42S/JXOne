//
//  RightPullToRefreshView.m
//  JXOne
//
//  Created by Jason Jia on 3/30/16.
//  Copyright © 2016 ZGMF-X42S. All rights reserved.
//

#import "RightPullToRefreshView.h"
#import <iCarousel/iCarousel.h>

#define LabelOffsetX 20
#define LeftRefreshLabelTextColor [UIColor colorWithRed:90 / 255.0 green:91 / 255.0 blue:92 / 255.0 alpha:1] // #5A5B5C

@interface RightPullToRefreshView () <iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) iCarousel *carousel;
@property (strong, nonatomic) UILabel *leftRefreshLabel;

@end


@implementation RightPullToRefreshView {
    /** 视图控件高度 */
    CGFloat selfHeight; //self.frame
    /** 当前一个有多少个 item */
    NSInteger numberOfItems;
    /** 保存当 leftRefreshLabel 的 text 为“右拉刷新...”时的宽，在右拉的时候用到 */
    CGFloat leftRefreshLabelWidth;
    /** 标记是否需要刷新，default NO */
    BOOL isNeedRefresh;
    /** 标记是否能够 scroll back */
    BOOL canScrollBack; //，用在刷新的时候不改变 leftRefreshLabel 的 frame，默认为 YES
    // 保存右拉的 x 距离
    CGFloat draggedX;
    /** 最后一次显示的 item 下标 */
    NSInteger lastItemIndex;
}

#pragma mark - View Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUp];
    }
    return self;
}

#pragma mark - Private
/**
 *  设置RightPullToRefreshView 各项属性
 */
- (void)setUp {
    self.backgroundColor = [UIColor whiteColor];
    selfHeight    = CGRectGetHeight(self.frame);
    isNeedRefresh = NO;
    canScrollBack = YES;
    draggedX      = 0;
    lastItemIndex = -1;
    
    [self setUpViews];
}

// TODO:懒加载处理
- (void)setUpViews {
    self.carousel = [[iCarousel alloc] initWithFrame:self.bounds];
    self.carousel.delegate   = self;
    self.carousel.dataSource = self;
    self.carousel.type       = iCarouselTypeLinear;
    self.carousel.vertical   = NO;
    self.carousel.pagingEnabled    = YES;
    self.carousel.bounceDistance   = 0.7;
    self.carousel.decelerationRate = 0.6; //运动减速Rate
    [self addSubview:self.carousel];
    
    // 文字Label 设置
    self.leftRefreshLabel      = [[UILabel alloc] initWithFrame:CGRectZero];
    self.leftRefreshLabel.font = systemFont(10);
    self.leftRefreshLabel.textColor = LeftRefreshLabelTextColor;
    self.leftRefreshLabel.textAlignment = NSTextAlignmentLeft;
    self.leftRefreshLabel.text = LeftDragToRightForRefreshHintText;
    [self.leftRefreshLabel sizeToFit];
    [self.leftRefreshLabel setNeedsDisplay];
    leftRefreshLabelWidth = CGRectGetWidth(self.leftRefreshLabel.frame);
    CGRect labelFrame = CGRectMake(0 - leftRefreshLabelWidth * 1.5 - LabelOffsetX, (CGRectGetMaxY(self.carousel.frame) - CGRectGetHeight(self.leftRefreshLabel.frame)) / 2.0, leftRefreshLabelWidth * 1.5, CGRectGetHeight(self.leftRefreshLabel.frame));
    self.leftRefreshLabel.frame = labelFrame;
    [self.carousel.contentView addSubview:self.leftRefreshLabel];
}

#pragma mark - Public

- (void)insertItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    numberOfItems ++ ;
    
    // 在最后插入一个新的 item
    [self.carousel insertItemAtIndex:(numberOfItems - 1) animated:YES];
}

- (void)reloadData {
    [self.carousel reloadData]; // about DataSource
}

- (void)reloadItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self.carousel reloadItemAtIndex:index animated:animated];
}

- (UIView *)itemViewAtIndex:(NSInteger)index {
    return [self.carousel itemViewAtIndex:index];
}

- (void)endRefreshing {
    if (isNeedRefresh) {
        CGRect frame = self.leftRefreshLabel.frame;
        frame.origin.x = 0 - leftRefreshLabelWidth * 1.5 - LabelOffsetX;
        
        [UIView animateWithDuration:DefaultAnimationDuration animations:^{
            self.carousel.contentOffset = CGSizeMake(0, 0);
            self.leftRefreshLabel.frame = frame;
        } completion:^(BOOL finished) {
            isNeedRefresh = NO;
            canScrollBack = YES;
        }];
    }
}

#pragma mark - Getter

- (NSInteger)currentItemIndex {
    return self.carousel.currentItemIndex;
}

- (UIView *)currentItemView {
    return [self.carousel itemViewAtIndex:self.currentItemIndex];
}

- (UIView *)contentView {
    return self.carousel.contentView;
}

#pragma mark - Setter

- (void)setDelegate:(id<RightPullToRefreshViewDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        
        if (_delegate && _dataSource) {
            [self setNeedsLayout];
        }
    }
}

- (void)setDataSource:(id<RightPullToRefreshViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        
        if (_dataSource) {
            [self.carousel reloadData];
        }
    }
}

#pragma mark - iCarousel DataSource
// View 的数量
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    numberOfItems = [self.dataSource numberOfItemsInRightPullToRefreshView:self];
    return numberOfItems;
}

// 
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    return [self.dataSource rightPullToRefreshView:self viewForItemAtIndex:index reusingView:view];
}

#pragma mark - iCarousel Delegate
/**
 *  Returns the width of each item in the carousel
 */
- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    return CGRectGetWidth(self.frame);
}
/**
 *  This method is called whenever the carousel scrolls far enough for the currentItemIndex property to change. 
 *  It is called regardless of whether the item index was updated programatically or through user interaction.
 */
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    //	NSLog(@"carousel CurrentItemIndexDidChange index = %ld", carousel.currentItemIndex);
    if ([self.delegate respondsToSelector:@selector(rightPullToRefreshViewCurrentItemIndexDidChange:)]) {
        [self.delegate rightPullToRefreshViewCurrentItemIndexDidChange:self];
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    //右拉，根据范围，标记是否需要刷新视图
    if (carousel.scrollOffset <= 0) {
        if (canScrollBack) {
            // 计算右拉的距离
            draggedX = fabs(carousel.scrollOffset * carousel.itemWidth);
            self.leftRefreshLabel.x = draggedX - CGRectGetWidth(self.leftRefreshLabel.frame) - LabelOffsetX;
            
            // 右拉刷新有效距离
            CGFloat RefreshX = leftRefreshLabelWidth * 1.5 +LabelOffsetX;
            if (draggedX >= RefreshX) {
                // 根据宽度动态的修改Label 显示的文字
                self.leftRefreshLabel.text = LeftReleaseToRefreshHintText;
                // 将刷新标记改为需要刷新
                isNeedRefresh = YES; //这个刷新标记动作也放在carouselDidEndDragging
            } else {
                self.leftRefreshLabel.text = LeftDragToRightForRefreshHintText;
                isNeedRefresh = NO;
            }
        }
    }
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    // 当当前 item 为第一个的时候，右拉释放，decelerate为 NO，其他滑动否则为 YES
    if (!decelerate && isNeedRefresh) { //当前View 为最左且刷新标记为YES
        // 设置 leftRefreshLabel 的显示文字、X 轴坐标
        self.leftRefreshLabel.text = LeftReleaseIsRefreshingHintText; //动态修改Label 文字为正在载入
        CGRect frame = self.leftRefreshLabel.frame;
        // leftRefreshLabelWidth 为文字为 右拉刷新时的宽度，替换为正在载入宽度变化
        frame.origin.x = leftRefreshLabelWidth - CGRectGetWidth(self.leftRefreshLabel.frame);
        
        canScrollBack = NO;// 如果要刷新就不弹回
        // 将文字变化，右侧的itemView 让出这一宽度的过程动画化
        [UIView animateWithDuration:DefaultAnimationDuration animations:^{
            // carousel item 的 X 轴偏移
            carousel.contentOffset = CGSizeMake(CGRectGetMaxX(frame) + LabelOffsetX, 0);
            // 修正一下leftRefreshLabel 位置
            self.leftRefreshLabel.frame = frame;
        }];
        
        // 刷新动作回调
        if ([self.delegate respondsToSelector:@selector(rightPullToRefreshViewRefreshing:)]) {
            [self.delegate rightPullToRefreshViewRefreshing:self];
        }
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    //	NSLog(@"carousel DidEndScrollingAnimation");
    // 如果当前的 item 为第一个并且 leftRefreshLabel 可以 scroll back，那么就刷新 leftRefreshLabel
    if (carousel.currentItemIndex == 0 && canScrollBack) { ///TODO, bug
        self.leftRefreshLabel.text = LeftDragToRightForRefreshHintText;
        isNeedRefresh = NO;
    }
    
    if (lastItemIndex != carousel.currentItemIndex) {
        if ([self.delegate respondsToSelector:@selector(rightPullToRefreshView:didDisplayItemAtIndex:)]) {
            [self.delegate rightPullToRefreshView:self didDisplayItemAtIndex:carousel.currentItemIndex];
        }
    }
    
    lastItemIndex = carousel.currentItemIndex;
    
}





@end
