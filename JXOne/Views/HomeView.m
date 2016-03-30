//
//  HomeView.m
//  JXOne
//
//  Created by Jason Jia on 3/29/16.
//  Copyright © 2016 ZGMF-X42S. All rights reserved.
//

#import "HomeView.h"
#import <Masonry/Masonry.h>
#import "HomeEntity.h"
#import "CustomImageView.h"

#define PaintInfoTextColor [UIColor colorWithRed:85 / 255.0 green:85 / 255.0 blue:85 / 255.0 alpha:1] // #555555
#define DayTextColor [UIColor colorWithRed:55 / 255.0 green:194 / 255.0 blue:241 / 255.0 alpha:1] // #37C2F1
#define MonthAndYearTextColor [UIColor colorWithRed:173 / 255.0 green:173 / 255.0 blue:173 / 255.0 alpha:1] // #ADADAD
#define BackgroudColor [UIColor whiteColor]

@interface HomeView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *volLabel;
@property (nonatomic, strong) CustomImageView *paintImageView;
@property (nonatomic, strong) UILabel *paintNameLabel;
@property (nonatomic, strong) UILabel *paintAuthorLabel;
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *monthAndYearLabel;
@property (nonatomic, strong) UIImageView *contentBGImageView;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIButton *praiseNumberBtn;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView; //item 加载指示器

@end

@implementation HomeView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews {
    self.backgroundColor = BackgroudColor;
    
    
    self.scrollView = [UIScrollView new];
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.tag = ScrollViewTag;
    self.scrollView.backgroundColor = BackgroudColor;
    self.scrollView.scrollsToTop = YES;
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    // 初始化容器视图
    self.containerView = [UIView new];
    [self.scrollView addSubview:self.containerView];
    self.containerView.backgroundColor = BackgroudColor;
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
        
    }];
    
    // 初始化 VOL 文字控件
    self.volLabel = [UILabel new];
    self.volLabel.font = systemFont(13);
    self.volLabel.textColor = VOLTextColor;
    self.volLabel.backgroundColor = BackgroudColor;
    [self.containerView addSubview:self.volLabel];
    
    [self.volLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.left.and.top.equalTo(self.containerView.mas_left).with.offset(10);
        make.left.equalTo(self.containerView.mas_left).with.offset(10);
        make.top.equalTo(self.containerView.mas_top).with.offset(10);
        make.right.equalTo(self.containerView.mas_right).with.offset(-10);
        make.height.mas_equalTo(@16);
    }];
    
    // 初始化显示画控件
    self.paintImageView = [[CustomImageView alloc] init];
    self.paintImageView.backgroundColor = BackgroudColor;
    [self.containerView addSubview:self.paintImageView];
    
    CGFloat paintWidth  = SCREEN_WIDTH - 20;
    CGFloat paintHeight = paintWidth * 0.75;
    [self.paintImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.volLabel.mas_bottom).with.offset(10);
        make.left.equalTo(self.containerView.mas_left).with.offset(10);
        make.right.equalTo(self.containerView.mas_right).with.offset(-10);
        make.height.mas_equalTo(@(paintHeight));
    }];
    
    // 初始化图片描述文字控件
    self.paintNameLabel = [UILabel new];
    self.paintNameLabel.textColor = PaintInfoTextColor;
    self.paintNameLabel.font = systemFont(12);
    self.paintNameLabel.textAlignment = NSTextAlignmentRight;
    [self.containerView addSubview:self.paintNameLabel];
    [self.paintNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.paintImageView.mas_bottom).with.offset(10);
        make.left.equalTo(self.containerView.mas_left).with.offset(10);
        make.right.equalTo(self.containerView.mas_right).with.offset(-10);
    }];
    
    // 初始化画作者
    self.paintAuthorLabel = [UILabel new];
    self.paintAuthorLabel.textColor = PaintInfoTextColor;
    self.paintAuthorLabel.font = systemFont(12);
    self.paintAuthorLabel.textAlignment = NSTextAlignmentRight;
    [self.containerView addSubview:self.paintAuthorLabel];
    [self.paintAuthorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.paintNameLabel.mas_bottom).with.offset(0);
        make.left.equalTo(self.containerView.mas_left).with.offset(10);
        make.right.equalTo(self.containerView.mas_right).with.offset(-10);
    }];
    
    // 初始化 日期 - 日 文字控件
    self.dayLabel = [UILabel new];
    self.dayLabel.textColor = DayTextColor;
    self.dayLabel.backgroundColor = BackgroudColor;
    self.dayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:43];
    self.dayLabel.textAlignment = NSTextAlignmentCenter;
    self.dayLabel.shadowOffset = CGSizeMake(1, 1);
    self.dayLabel.shadowColor = BackgroudColor;
    [self.containerView addSubview:self.dayLabel];
    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.paintAuthorLabel.mas_bottom).with.offset(20);
        make.left.equalTo(self.containerView.mas_left).with.offset(10);
        make.width.mas_equalTo(@70);
        make.height.mas_equalTo(@40);
    }];
    
    // 初始化 日期 - 月 年 文字控件
    self.monthAndYearLabel = [UILabel new];
    self.monthAndYearLabel.textColor = MonthAndYearTextColor;
    self.monthAndYearLabel.backgroundColor = BackgroudColor;
    self.monthAndYearLabel.font = [UIFont fontWithName:@"CenturyGothic-Bold" size:10];
    self.monthAndYearLabel.textAlignment = NSTextAlignmentCenter;
    self.monthAndYearLabel.shadowOffset = CGSizeMake(1, 1);
    [self.containerView addSubview:self.monthAndYearLabel];
    [self.monthAndYearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dayLabel.mas_bottom).with.offset(2);
        make.left.equalTo(self.containerView.mas_left).with.offset(10);
        make.width.mas_equalTo(@70);
        make.height.mas_equalTo(@12);
    }];
    
    // 初始化内容背景图片控件
    self.contentBGImageView = [UIImageView new];
    [self.containerView addSubview:self.contentBGImageView];
    [self.contentBGImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.paintAuthorLabel.mas_bottom).with.offset(20);
        make.left.equalTo(self.dayLabel.mas_right).with.offset(10);
        make.right.equalTo(self.containerView.mas_right).with.offset(-10);
    }];
    
    // 初始化内容控件
    self.contentTextView = [UITextView new];
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
    self.contentTextView.editable = NO;
    self.contentTextView.scrollEnabled = NO;
    self.contentTextView.backgroundColor = [UIColor clearColor];
    [self.contentBGImageView addSubview:self.contentTextView];
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentBGImageView.mas_left).with.offset(6);
        make.top.equalTo(self.contentBGImageView.mas_top).with.offset(0);
        make.right.equalTo(self.contentBGImageView.mas_right).with.offset(-6);
        make.bottom.equalTo(self.contentBGImageView.mas_bottom).with.offset(0);
    }];
    
    // 初始化点赞按钮
    self.praiseNumberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.praiseNumberBtn.titleLabel.font = systemFont(12);
    [self.praiseNumberBtn setTitleColor:PraiseBtnTextColor forState:UIControlStateNormal];
    
    UIImage *btnImage = [[UIImage imageNamed:@"home_likeBg"]
                         stretchableImageWithLeftCapWidth:20    //leftCapWidth:左边不拉伸区域
                         topCapHeight:2];                       //topCapHeight:上面不拉伸区域
    [self.praiseNumberBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.praiseNumberBtn setImage:[UIImage imageNamed:@"home_like"] forState:UIControlStateNormal];
    [self.praiseNumberBtn setImage:[UIImage imageNamed:@"home_like_hl"] forState:UIControlStateSelected];
    
    self.praiseNumberBtn.imageEdgeInsets   = UIEdgeInsetsMake(2, 0, 0, 0);
    self.praiseNumberBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    
    [self.praiseNumberBtn addTarget:self action:@selector(praise) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.praiseNumberBtn];
    [self.praiseNumberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentBGImageView.mas_bottom).with.offset(30);
        make.right.equalTo(self.containerView.mas_right).with.offset(0);
        make.height.mas_equalTo(@28);
        make.bottom.equalTo(self.containerView.mas_bottom).with.offset(-16);
    }];
    
    // 初始化加载中指示器
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.hidesWhenStopped = YES;
    [self addSubview:self.indicatorView];
    
}

- (void)startRefreshing {
    self.indicatorView.center = self.center;
    //self.indicatorView.activityIndicatorViewStyle = [UIActivityIndicatorViewStyleGray];
    [self.indicatorView startAnimating];
}

- (void)praise {
    // 由于没有接口，仅仅模拟
    self.praiseNumberBtn.selected = !self.praiseNumberBtn.isSelected;
}

#pragma mark - Public Methods
/**
 *  按照给定的数据显示视图(读取数据完成后）
 *
 *  @param homeEntity 要显示的数据
 *  @param animated   是否需要图片的加载动画
 */
- (void)configureViewWithHomeEntity:(HomeEntity *)homeEntity animated:(BOOL)animated {
    [self.indicatorView stopAnimating];
    self.containerView.hidden = NO;
    
    CGFloat activationPointX = self.scrollView.accessibilityActivationPoint.x;
    if (activationPointX > 0 && activationPointX < SCREEN_WIDTH) {
        self.scrollView.scrollsToTop = YES;
    } else {
        self.scrollView.scrollsToTop = NO;
    }
    
    // 赋值
    self.volLabel.text = homeEntity.strHpTitle;
    NSURL *imageURL = [NSURL URLWithString:homeEntity.strThumbnailUrl];
    [self.paintImageView configureImageViwWithImageURL:imageURL animated:animated];
    self.paintNameLabel.text = [homeEntity.strAuthor componentsSeparatedByString:@"&"][0];
    self.paintAuthorLabel.text = [homeEntity.strAuthor componentsSeparatedByString:@"&"][1];
    
    NSString *marketTime = [BaseFunction homeENMarketTimeWithOriginalMarketTime:homeEntity.strMarketTime];
    self.dayLabel.text = [marketTime componentsSeparatedByString:@"&"][0]; //@"dd&MMM , yyyy"
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    NSDictionary *attribute;
    attribute = @{NSParagraphStyleAttributeName : paragraphStyle,
                  NSForegroundColorAttributeName : [UIColor whiteColor],
                  NSFontAttributeName : [UIFont systemFontOfSize:13]};
    self.contentTextView.attributedText = [[NSAttributedString alloc] initWithString:homeEntity.strContent attributes:attribute];
    [self.contentTextView sizeToFit];
    
    self.contentBGImageView.image = [[UIImage imageNamed:@"contBack"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    [self.praiseNumberBtn setTitle:[NSString stringWithFormat:@"  %@", homeEntity.strPn] forState:UIControlStateNormal];
    [self.praiseNumberBtn sizeToFit];
    
    // 获取数据布局完毕，计算containerView 的大小，设置contentSize
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetHeight(self.containerView.frame));
}

- (void)refreshSubviewsForNewItem {
    self.volLabel.text = @"";
    //	self.paintImageView.image = nil;
    self.paintNameLabel.text = @"";
    self.paintAuthorLabel.text = @"";
    self.dayLabel.text = @"";
    self.monthAndYearLabel.text = @"";
    
    self.contentTextView.text = @"";
    [self.contentTextView sizeToFit];
    
    self.contentBGImageView.image = nil;
    
    [self.praiseNumberBtn setTitle:@"" forState:UIControlStateNormal];
    [self.praiseNumberBtn sizeToFit];
    
    self.containerView.hidden = YES;
    self.scrollView.scrollsToTop = NO;
    
    [self startRefreshing];
}

@end
