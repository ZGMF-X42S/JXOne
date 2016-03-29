//
//  HomeViewController.m
//  JXOne
//
//  Created by Jason Jia on 3/29/16.
//  Copyright © 2016 ZGMF-X42S. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

/**
 *  当前一共有多少篇文章，默认为3篇
 */
@property (nonatomic, assign) NSInteger numberOfItems;
/**
 *  保存当前查看过的数据
 */
@property (nonatomic, copy) NSMutableArray *readItems;
/**
 *  最后展示的Item 的下标
 */
@property (nonatomic, assign) NSInteger lastConfigureViewForItemIndex;

/**
 *  当前是否正在右拉刷新标记
 */
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // testCode
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self setUpNavigationBarShowRightBarButtonItem:YES];
    
    // 初始化各种标记
    self.numberOfItems = 2;
    self.readItems = [[NSMutableArray alloc] init]; ///TODO:修改为懒加载
    self.lastConfigureViewForItemIndex = 0;
    self.isRefreshing = NO;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
