//
//  ViewController.m
//  网易新闻练习
//
//  Created by Lee on 15/11/22.
//  Copyright © 2015年 Lee. All rights reserved.
//

#import "ViewController.h"
#import "TopLineViewController.h"
#import "HotViewController.h"
#import "VideoViewController.h"
#import "ScoietyViewController.h"
#import "SubscribeViewController.h"
#import "ScienceViewController.h"

//设置导航条高度
static CGFloat const navBarH = 64;
//设置滚动标题视图的高度
static CGFloat const titleScreenH = 44;
//文字的形变
static CGFloat const transformScale = 1.3;

//屏幕的大小
#define screenW [UIScreen mainScreen].bounds.size.width
#define screenH [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UIScrollViewDelegate>
/** 标题滚动视图 */
@property (nonatomic, weak) UIScrollView *titleScrollView;

@property (nonatomic, weak) UIScrollView *contentScrollView;

//选中按钮
@property(nonatomic, strong)UIButton *selButton;
//存放按钮的数组
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;
@end

@implementation ViewController
- (NSMutableArray *)buttons
{
    if (_buttons == nil) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //添加标题滚动视图
    [self setUpTitleScrollView];
    //添加所有的子控制器
    [self setUpAllChildController];
    //添加内容滚动视图
    [self setUpContentScrollView];
//    NSLog(@"%@",NSStringFromCGRect([UIScreen mainScreen].bounds));
    [self setUpTitleButtom];
    //取消
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.contentScrollView.delegate = self;
    
}

//使用代理监听屏幕滑动，设置滑动对应的文字放大或缩小
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 获取偏移量
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 获取左边角标
    NSInteger leftIndex = offsetX / screenW;
    
    // 左边按钮
    UIButton *leftBtn = self.buttons[leftIndex];
    
    // 右边角标
    NSInteger rightIndex = leftIndex + 1;
    
    // 右边按钮
    UIButton *rightButton = nil;
    // 5 4
    if (rightIndex < self.buttons.count) {
        rightButton = self.buttons[rightIndex];
    }
    // 获取右边缩放
    CGFloat rightSacle = offsetX / screenW - leftIndex;
    
    CGFloat leftScale = 1 - rightSacle;
    NSLog(@"%f %f",leftScale,rightSacle);
    // 缩放按钮
    leftBtn.transform = CGAffineTransformMakeScale(leftScale * 0.3 + 1, leftScale * 0.3 + 1);
    
    // 1 ~ 1.3
    rightButton.transform = CGAffineTransformMakeScale(rightSacle * 0.3 + 1, rightSacle * 0.3 + 1);
    
    // 颜色渐变
    // 右边按钮 -> 黑色 -> 红色  R: 0 ~ 1
    UIColor *rightColor = [UIColor colorWithRed:rightSacle green:0 blue:0 alpha:1];
    UIColor *leftColor = [UIColor colorWithRed:leftScale green:0 blue:0 alpha:1];
    [rightButton setTitleColor:rightColor forState:UIControlStateNormal];
    // 左边按钮 -> 红色 -> 黑色  R: 1 ~ 0
    [leftBtn setTitleColor:leftColor forState:UIControlStateNormal];
}


#pragma mark -<UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //选中对应按钮
    //1.求出对应视图view的滚动偏移量（相对于原点）
    CGFloat offsetX = scrollView.contentOffset.x;
    //求出当前的索引（按钮，view）
    int page = offsetX/screenW;
//    NSLog(@"%d",self.buttons.count);
    //选中对应的按钮  有两种方法，第一种就是遍历标题控件中的所有子控件，然后再判断取出对应按钮
    //还有一种就是创建按钮的时候，就把按钮添加到一个专一存放按钮的数组中
    [self selectBtn:self.buttons[page]];
    //跳转到对应自控制器的VIEW
    [self showVC:offsetX];
}

//滑动时显示对应的view  给我一个当前的偏移量X，跳转到对应的view
- (void)showVC:(CGFloat)x
{
    int i = x / screenW;
    
    UIViewController *showVC = self.childViewControllers[i];
    
    showVC.view.frame = CGRectMake(x, 0, screenW, self.contentScrollView.bounds.size.height);
    [self.contentScrollView addSubview:showVC.view];
}


//添加标题滚动视图上的按钮
- (void)setUpTitleButtom
{
    float btnX = 0;
    float btnY = 0;
    float btnW = 93;
    float btnH = titleScreenH;
    for (int i = 0; i < self.childViewControllers.count; i++) {
        //创建按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btnX = btnW * i;
        btn.tag = i;
        //设置按钮位置尺寸
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
//        btn.backgroundColor = [UIColor redColor];
        [btn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        //设置按钮的文字及按钮颜色
        UIViewController *vc = self.childViewControllers[i];
        [btn setTitle:vc.title forState:UIControlStateNormal];
        
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        //添加所有按钮到数组中
        [self.buttons addObject:btn];
        [self.titleScrollView addSubview:btn];
        if (btn.tag == 0) {
//            [self selectBtn:btn];
            [self titleClick:btn];
        }
    }
    //设置滚动区域
    self.titleScrollView.contentSize = CGSizeMake(btnW * self.childViewControllers.count , 0);
    self.titleScrollView.showsHorizontalScrollIndicator = NO;
}
//按钮点击事件
- (void)titleClick:(UIButton *)btn
{
    //先让按钮达到选中状态
    [self selectBtn:btn];
    //滚动到对应的界面
//    NSLog(@"%zd",btn.tag);
//    NSLog(@"%zd",screenW);
    CGFloat offsetX = btn.tag * screenW;
//    self.contentScrollView.contentOffset = CGPointMake(offsetX, 0);
    //根据按钮tag拿到对应的控制器
//    NSLog(@"%zd",offsetX);
    UIViewController *vc = self.childViewControllers[btn.tag];
    vc.view.frame = CGRectMake(offsetX, 0, screenW, screenH);
    [self.contentScrollView addSubview:vc.view];
    //滚到对应区域
    self.contentScrollView.contentOffset = CGPointMake(offsetX,0);
        NSLog(@"%@--%f",NSStringFromCGRect(vc.view.frame),screenW);
}

//按钮选中状态
- (void)selectBtn:(UIButton *)btn
{
    //还原变大后的尺寸
    //使用CGAffineTransformIdentity属性可以还原由于Transform而发生的改变，
    self.selButton.transform = CGAffineTransformIdentity;
    self.selButton.selected = NO;
    btn.selected = YES;
    self.selButton = btn;
    //让文字的大小变化
    btn.transform = CGAffineTransformMakeScale(transformScale, transformScale);
    //让选中的按钮显示居中
    [self setBtnTitleCenter:btn];
}

// 让选中的按钮居中显示
- (void)setBtnTitleCenter:(UIButton *)btn
{

    // 设置标题滚动区域的偏移量
    CGFloat offsetX = btn.center.x - screenW * 0.5;
    if (offsetX < 0) {
        offsetX = 0;
    }
    // 计算下最大的标题视图滚动区域
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - screenW;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    // 滚动区域
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];

}
- (void)setUpTitleScrollView
{
    UIScrollView *titleView = [[UIScrollView alloc] init];
    //先判断有没有导航条
    CGFloat y = self.navigationController?navBarH:0;
    titleView.frame = CGRectMake(0, y, screenW, titleScreenH);
    titleView.backgroundColor = [UIColor grayColor];
    //添加
    [self.view addSubview:titleView];
    self.titleScrollView = titleView;
}

//添加所有的子控制器（因为点击标题按钮会显示不同的VIEW所以需要几个不同的子控制器）
- (void)setUpAllChildController
{
    // 头条
    TopLineViewController *topLineVc = [[TopLineViewController alloc] init];
    topLineVc.title = @"头条";
    [self addChildViewController:topLineVc];
    // 热点
    
    HotViewController *hotVc = [[HotViewController alloc] init];
    hotVc.title = @"热点";
    [self addChildViewController:hotVc];
    // 视频
    VideoViewController *videoVc = [[VideoViewController alloc] init];
    videoVc.title = @"视频";
    [self addChildViewController:videoVc];
    
    // 社会
    ScoietyViewController *societyVc = [[ScoietyViewController alloc] init];
    societyVc.title = @"社会";
    [self addChildViewController:societyVc];
    
    // 订阅
    SubscribeViewController *readerVc = [[SubscribeViewController alloc] init];
    readerVc.title = @"订阅";
    [self addChildViewController:readerVc];
    
    
    // 科技
    ScienceViewController *scienceVc = [[ScienceViewController alloc] init];
    scienceVc.title = @"科技";
    [self addChildViewController:scienceVc];
    
}
//添加内容滚动视图
- (void)setUpContentScrollView
{
    UIScrollView *contentView = [[UIScrollView alloc] init];
    //计算chicun
    CGFloat y = CGRectGetMaxY(self.titleScrollView.frame);
    contentView.frame = CGRectMake(0, y, screenW, screenH - y);
//    contentView.backgroundColor = [UIColor blueColor];
//    NSLog(@"%zd",self.childViewControllers.count);
    //设置滚动区域
    contentView.contentSize = CGSizeMake(self.childViewControllers.count * screenW,0);
    contentView.pagingEnabled = YES;
    [self.view addSubview:contentView];

    self.contentScrollView = contentView;
    
}
@end
