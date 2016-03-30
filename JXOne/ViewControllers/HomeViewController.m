//
//  HomeViewController.m
//  JXOne
//
//  Created by Jason Jia on 3/29/16.
//  Copyright © 2016 ZGMF-X42S. All rights reserved.
//

#import "HomeViewController.h"
#import "RightPullToRefreshView.h"
#import "HomeEntity.h"
#import <MJExtension/MJExtension.h>
#import "HomeView.h"
#import "HTTPTool.h"


@interface HomeViewController () <RightPullToRefreshViewDelegate, RightPullToRefreshViewDataSource>
/**
 *  iCarousel 实现的滑动窗口
 */
@property (nonatomic, strong) RightPullToRefreshView *rightPullToRefreshView;

/** 当前一共有多少篇文章，默认为3篇 */
@property (nonatomic, assign) NSInteger numberOfItems;
/** 保存当前查看过的数据 */
@property (nonatomic, strong) NSMutableDictionary *readItems;
/**  最后展示的Item 的下标 */
@property (nonatomic, assign) NSInteger lastConfigureViewForItemIndex;

/** 当前是否正在右拉刷新标记 */
@property (nonatomic, assign) BOOL isRefreshing;

@end

@implementation HomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // tabbar icon 图片
        UIImage *deselectedImage = [[UIImage imageNamed:@"tabbar_item_home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedImage   = [[UIImage imageNamed:@"tabbar_item_home_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        // 底部导航item
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:nil tag:0];
        tabBarItem.image = deselectedImage;
        tabBarItem.selectedImage = selectedImage;
        self.tabBarItem = tabBarItem;
    }
    return self;
}
#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // testCode
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self setUpNavigationBarShowRightBarButtonItem:YES];
    
    // 初始化各种标记
    self.numberOfItems = 2;
    self.readItems     = [[NSMutableDictionary alloc] init]; ///TODO:修改为懒加载
    self.lastConfigureViewForItemIndex = 0;
    self.isRefreshing  = NO;
    
    CGRect viewFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - self.tabBarController.tabBar.height);
    self.rightPullToRefreshView = [[RightPullToRefreshView alloc] initWithFrame:viewFrame];
    self.rightPullToRefreshView.delegate   = self;
    self.rightPullToRefreshView.dataSource = self;
    [self.view addSubview:self.rightPullToRefreshView];
    
    [self requestHomeContentAtIndex:0];
    
}

- (void)dealloc {
    self.rightPullToRefreshView.delegate = nil;
    self.rightPullToRefreshView.dataSource = nil;
    self.rightPullToRefreshView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RightPullToRefreshViewDataSource

- (NSInteger)numberOfItemsInRightPullToRefreshView:(RightPullToRefreshView *)rightPullToRefreshView {
    //testCode
    return self.numberOfItems;
}

- (UIView *)rightPullToRefreshView:(RightPullToRefreshView *)rightPullToRefreshView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    HomeView *homeView = nil;
    
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rightPullToRefreshView.frame), CGRectGetHeight(rightPullToRefreshView.frame))];
        homeView = [[HomeView alloc] initWithFrame:view.bounds];
        [view addSubview:homeView];
    } else {
        homeView = (HomeView *)view.subviews[0];
    }
    
    if (index == self.numberOfItems - 1 || index == self.readItems.allKeys.count) { //当前为新的Items
        [homeView refreshSubviewsForNewItem]; // 开始加载指示器动画
    } else { // 当前这个这个 item 展示过，但没有显示过数据
        self.lastConfigureViewForItemIndex = MAX(index, self.lastConfigureViewForItemIndex);
        // 从保存查看过的数据中读取数据
        [homeView configureViewWithHomeEntity:self.readItems[@(index).stringValue] animated:YES];
        
    }
//    UIView *testView = [[UIView alloc] initWithFrame:self.view.bounds];
//    switch (index) {
//        case 0:
//            testView.backgroundColor = [UIColor redColor];
//            break;
//        case 1:
//            testView.backgroundColor = [UIColor blueColor];
//            break;
//        case 2:
//            testView.backgroundColor = [UIColor yellowColor];
//            break;
//        case 3:
//            testView.backgroundColor = [UIColor greenColor];
//            break;
//    }
    return view;
}

#pragma mark - RightPullToRefreshViewDelegate
- (void)rightPullToRefreshViewRefreshing:(RightPullToRefreshView *)rightPullToRefreshView {
    [self refreshing];
}

- (void)rightPullToRefreshView:(RightPullToRefreshView *)rightPullToRefreshView didDisplayItemAtIndex:(NSInteger)index {
    if (index == self.numberOfItems - 1) { // 如果当前显示的是最后一个，则添加一个 item
        self.numberOfItems ++;
        [self.rightPullToRefreshView insertItemAtIndex:(self.numberOfItems - 1) animated:YES];
    }
    
    if (index < self.readItems.allKeys.count && self.readItems[@(index).stringValue]) {
        HomeView *homeView = (HomeView *)[rightPullToRefreshView itemViewAtIndex:index].subviews[0];
        [homeView configureViewWithHomeEntity:self.readItems[@(index).stringValue] animated:
         (self.lastConfigureViewForItemIndex == 0 || self.lastConfigureViewForItemIndex < index)];
    } else { // 如果页面存在，内容不存在，请求内容
        [self requestHomeContentAtIndex:index];
    }
}

#pragma mark - Network Requests

// 右拉刷新
- (void)refreshing {
    if (self.readItems.allKeys.count > 0) {// 避免第一个还未加载的时候右拉刷新更新数据
        [self showHUDWithText:@""];
        self.isRefreshing = YES;
        [self requestHomeContentAtIndex:0];
    }
}

- (void)requestHomeContentAtIndex:(NSInteger)index {
    [HTTPTool requestHomeContentByIndex:index success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"result"] isEqualToString:REQUEST_SUCCESS]) {
            HomeEntity *returnHomeEntity = [HomeEntity objectWithKeyValues:responseObject[@"hpEntity"]];
            NSLog(@"---- HomeEntity ----\n%@", returnHomeEntity);
            if (self.isRefreshing) {
                [self endRefreshing];
                NSString *hpId = ((HomeEntity *)self.readItems[@"0"]).strHpId;
                if ([returnHomeEntity.strHpId isEqualToString:hpId]) { // 没有新数据
                    [self showHUDWithText:IsLatestData delay:HUD_DELAY];
                } else {
                    [self.readItems removeAllObjects]; //需要删除所有数据，因为如果相差太多天，要么会出现断层，要么加载过多数据。
                    [self hideHud];
                }
                
                [self endRequestHomeContent:returnHomeEntity atIndex:index];
            } else {
                [self hideHud];
                [self endRequestHomeContent:returnHomeEntity atIndex:index];
            }
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Homepage Network Error : %@", error);
    }];
}

#pragma mark - Private
- (void)endRefreshing {
    self.isRefreshing = NO;
    [self.rightPullToRefreshView endRefreshing];
}

- (void)endRequestHomeContent:(HomeEntity *)homeEntity atIndex:(NSInteger)index {
    NSLog(@"index: %ld", (long)index);
    [self.readItems setObject:homeEntity forKey:[@(index) stringValue]];
    [self.rightPullToRefreshView reloadItemAtIndex:index animated:NO];
}








@end
