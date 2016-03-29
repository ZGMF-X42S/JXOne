//
//  BaseViewController.m
//  JXOne
//
//  Created by Jason Jia on 3/29/16.
//  Copyright © 2016 ZGMF-X42S. All rights reserved.
//

#import "BaseViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
//#import "DSNavigationBar.h"

@interface BaseViewController () <MBProgressHUDDelegate>

@end

@implementation BaseViewController {
    MBProgressHUD *HUD;
}
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blueColor];
    // 从导航栏下开始布局
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //UIImageView *testImageView = [[UIImageView alloc] initWithImage:[self imageWithColor:[UIColor redColor]]];
    //[self.view addSubview:testImageView];
}

#pragma mark - Public Methods
- (void)setUpNavigationBarShowRightBarButtonItem:(BOOL)show {
    // 显示导航栏上的"一个" 图标
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navLogo"]];
    if (show) {
        // 初始化导航栏右侧的分享按钮
        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        [shareButton setBackgroundImage:[UIImage imageNamed:@"nav_share_btn_normal"] forState:UIControlStateNormal];
        [shareButton setBackgroundImage:[UIImage imageNamed:@"nav_share_btn_highlighted"] forState:UIControlStateHighlighted];
        
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
        
        self.navigationItem.rightBarButtonItem = shareItem;
    }
}

- (void)dontShowBackButtonTitle {
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Private Methods
/**
 *  创建一个具有颜色点 图片
 *
 *  @param color 颜色
 *
 *  @return 返回一个位图
 */
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Touch Events

- (void)share {
    
}

#pragma mark - MBProgressHUD

- (void)showHUDWaitingWhileExecuting:(SEL)method
{
    // hud 会使所有View 是去input，并使用有可能的最高层级
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.color = [UIColor colorWithRed:100 / 255.0 green:100 / 255.0 blue:100 / 255.0 alpha:0.9];
    
    // 注册HUB 回调（为了合适的时机remove HUD）
    HUD.delegate = self;
    
    // 显示HUD 当下面的方法在新线程执行
    [HUD showWhileExecuting:method onTarget:self withObject:nil animated:YES];
}

- (void)showHUDWithText:(NSString *)text delay:(NSTimeInterval)delay {
    if (!HUD.isHidden) {
        [HUD hide:NO];
    }
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Configure for text only and offset down
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = text;
    HUD.margin = 10.f;
    HUD.removeFromSuperViewOnHide = YES;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    [HUD hide:YES afterDelay:delay];
}

- (void)showHUDDone {
    [self showHUDDoneWithText:@"Done"];
}

- (void)showHUDDoneWithText:(NSString *)text {
    if (!HUD.isHidden) {
        [HUD hide:NO];
    }
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_right"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = text;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    [HUD show:YES];
    [HUD hide:YES afterDelay:HUD_DELAY];
}

- (void)showHUDErrorWithText:(NSString *)text {
    if (!HUD.isHidden) {
        [HUD hide:NO];
    }
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_error"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = text;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    [HUD show:YES];
    [HUD hide:YES afterDelay:HUD_DELAY];
}

- (void)showHUDNetError {
    [self showHUDErrorWithText:BadNetwork];
}

- (void)showHUDServerError {
    [self showHUDErrorWithText:@"Server Error"];
}

- (void)showWithLabelText:(NSString *)showText executing:(SEL)method {
    if (!HUD.isHidden) {
        [HUD hide:NO];
    }
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = showText;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    [HUD showWhileExecuting:method onTarget:self withObject:nil animated:YES];
}

- (void)showHUDWithText:(NSString *)text {
    [self hideHud];
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Configure for text only and offset down
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = text;
    HUD.margin = 10.f;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    HUD.removeFromSuperViewOnHide = YES;
}

- (void)processServerErrorWithCode:(NSInteger)code andErrorMsg:(NSString *)msg {
    if (code == 500) {
        [self showHUDServerError];
    } else {
        [self showHUDDoneWithText:msg];
    }
}

- (void)hideHud {
    if (!HUD.isHidden) {
        [HUD hide:NO];
    }
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    if (self.hudWasHidden) {
        self.hudWasHidden();
    }
}



















@end
