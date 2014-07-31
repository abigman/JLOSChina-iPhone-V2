//
//  TCTabBarC.h
//  TaoCZ
//
//  Created by jimneylee on 6/28/14.
//  Copyright 2014 taocz. All rights reserved.
//

#import "TCTabBarC.h"
#import "NIBadgeView.h"
#import <JSCustomBadge/JSCustomBadge.h>
#import "UINavigationBar+FlatUI.h"
#import "MLNavigationController.h"

#import "TCHomeC.h"

#define ANIMATION_DURATION 0.25f
#define MAX_TAB_COUNT 5
//#define USE_TAB_IMAGE

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface TabButton : UIButton

@property (nonatomic, strong) JSCustomBadge *badgeView;

- (void)setBadgeValue:(NSString *)value;

@end

@implementation TabButton

- (id)initWithIndex:(NSUInteger)index
{
    self = [super init];
    if (self) {
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13.f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        // badge
#if 0
        self.badgeView = [[NIBadgeView alloc] initWithFrame:CGRectZero];
        self.badgeView.tintColor = [UIColor redColor];
        self.badgeView.font = [UIFont systemFontOfSize:11.f];
        self.badgeView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.badgeView];
        
        self.badgeView.text = @"2";
#else
        self.badgeView = [JSCustomBadge customBadgeWithString:@"2"
                                                 withStringColor:[UIColor whiteColor]
                                                  withInsetColor:[UIColor redColor]
                                                  withBadgeFrame:YES
                                             withBadgeFrameColor:[UIColor redColor]
                                                       withScale:.8f
                                                     withShining:NO];
        //
        [self addSubview:self.badgeView];
#endif
    }
    
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.badgeView sizeToFit];
    self.badgeView.right = self.width;
    self.badgeView.top = 0.f;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Publick

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBadgeValue:(NSString *)value
{
    [self.badgeView autoBadgeSizeWithString:value];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface TCTabBarC()<UINavigationControllerDelegate>

@property (nonatomic, assign) int currentSelectedIndex;
@property (nonatomic, strong) NSMutableArray* tabBtns;
@property (nonatomic, strong) UIImageView* focusBgView;
@property (nonatomic, strong) UIImageView* tabBarBgView;
@property (nonatomic, strong) NSArray *prevViewControllers;

@end

@implementation TCTabBarC

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - init & dealloc

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {	
		self.delegate = self;
        self.navigationItem.hidesBackButton = YES;
	}
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc
{
	self.tabBtns = nil;
	self.tabBarBgView = nil;
	self.focusBgView = nil;
    self.prevViewControllers = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
	[super viewDidLoad];
	
#if 0
	UIImageView *bgView = [[UIImageView alloc] initWithImage:
						   [[UIImage imageNamed:@"tbg.png"] stretchableImageWithLeftCapWidth:1
																				topCapHeight:0]];
	bgView.userInteractionEnabled = YES;
	[self.view addSubview:bgView];
	self.tabBarBgView = bgView;
#else
    UIImageView *bgView = [[UIImageView alloc] init];
    bgView.userInteractionEnabled = YES;
    bgView.backgroundColor = RGBCOLOR(178, 178, 178);
    [self.view addSubview:bgView];
	self.tabBarBgView = bgView;
#endif
    
    self.viewControllers = [self generateViewContrllers];
    
	[self createTabBarBtns];
	[self layoutTabBarBtns];
    [self hideRealTabBar:self.view];
    
	self.currentSelectedIndex = 0;
    
    [self setBadgeValue:@"2" forTabIndex:0];
    [self setBadgeValue:@"5" forTabIndex:0];
    [self setBadgeValue:@"7" forTabIndex:0];
    [self setBadgeValue:@"4" forTabIndex:0];
    [self setBadgeValue:@"6" forTabIndex:0];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBadgeValue:(NSString *)value forTabIndex:(NSInteger)tabIndex
{
    TabButton *btn = [self.tabBtns objectAtIndex:tabIndex];
    if (tabIndex < self.tabBtns.count) {
        [btn setBadgeValue:value];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideRealTabBar:(UIView*)v
{
	for (UIView *view in v.subviews) {
		if ([view isKindOfClass:[UITabBar class]]) {
			view.hidden = YES;
			break;
		}
		else {
			[self hideRealTabBar:view];
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showTabBarAnimated:(BOOL)animated
{
    [self hideRealTabBar:self.view];
    [UIView animateWithDuration:animated ? ANIMATION_DURATION : 0.f animations:^{
        self.tabBarBgView.bottom = self.tabBar.bottom;
    } completion:^(BOOL finished) {
        [self hideRealTabBar:self.view];
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideTabBarAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? ANIMATION_DURATION : 0.f animations:^{
        self.tabBarBgView.top = self.tabBar.bottom;
    } completion:^(BOOL finished) {
        [self hideRealTabBar:self.view];
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray *)generateViewContrllers
{
    TCHomeC *homeC1 = [[TCHomeC alloc] initWithStyle:UITableViewStyleGrouped];
    MLNavigationController *navi1 = [[MLNavigationController alloc] initWithRootViewController:homeC1];
    navi1.navigationBar.tintColor = [UIColor darkGrayColor];
    navi1.delegate = self;
    if ([navi1 respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navi1.interactivePopGestureRecognizer.enabled = NO;
    }
    
    TCHomeC *homeC2 = [[TCHomeC alloc] initWithStyle:UITableViewStylePlain];
    MLNavigationController *navi2 = [[MLNavigationController alloc] initWithRootViewController:homeC2];
    navi2.navigationBar.tintColor = [UIColor darkGrayColor];
    navi2.delegate = self;
    if ([navi2 respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navi2.interactivePopGestureRecognizer.enabled = NO;
    }
    
    TCHomeC *homeC3 = [[TCHomeC alloc] initWithStyle:UITableViewStylePlain];
    MLNavigationController *navi3 = [[MLNavigationController alloc] initWithRootViewController:homeC3];
    navi3.navigationBar.tintColor = [UIColor darkGrayColor];
    navi3.delegate = self;
    if ([navi3 respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navi3.interactivePopGestureRecognizer.enabled = NO;
    }
    
    TCHomeC *homeC4 = [[TCHomeC alloc] initWithStyle:UITableViewStylePlain];
    MLNavigationController *navi4 = [[MLNavigationController alloc] initWithRootViewController:homeC4];
    navi4.navigationBar.tintColor = [UIColor darkGrayColor];
    navi4.delegate = self;
    if ([navi4 respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navi4.interactivePopGestureRecognizer.enabled = NO;
    }
    
    TCHomeC *homeC5 = [[TCHomeC alloc] initWithStyle:UITableViewStylePlain];
    MLNavigationController *navi5 = [[MLNavigationController alloc] initWithRootViewController:homeC5];
    navi5.navigationBar.tintColor = [UIColor darkGrayColor];
    navi5.delegate = self;
    if ([navi5 respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navi5.interactivePopGestureRecognizer.enabled = NO;
    }
    
    return [NSMutableArray arrayWithObjects:
            navi1, navi2, navi3, navi4, navi5, nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)configAppearenceForNav:(UINavigationController *)nav
{
    nav.navigationBar.titleTextAttributes = @{UITextAttributeFont : [UIFont boldSystemFontOfSize:18.f],
                                              UITextAttributeTextColor : [UIColor blackColor]};
    
    if (TTOSVersionIsAtLeast7()) {
        nav.navigationBar.translucent = NO;
    }
    else {
        [nav.navigationBar configureFlatNavigationBarWithColor:RGBCOLOR(248, 248, 248)];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createTabBarBtns
{
    int viewCount = self.viewControllers.count > MAX_TAB_COUNT ? MAX_TAB_COUNT : self.viewControllers.count;
	self.tabBtns = [NSMutableArray arrayWithCapacity:viewCount];
	for (int i = 0; i < viewCount; i++) {
#ifdef USE_TAB_IMAGE
		TabButton *btn = [TabButton buttonWithType:UIButtonTypeCustom];
#else
        TabButton *btn = [[TabButton alloc] initWithIndex:i];
        NSString* title;
        switch (i) {
            case 0:
                title = @"首页\r\nHome";
                break;
            case 1:
                title = @"分类\r\nCate";
                break;
            case 2:
                title = @"搜索\r\nSearch";
                break;
            case 3:
                title = @"购物车\r\nCart";
                break;
            case 4:
                title = @"我的\r\nMine";
                break;
            default:
                break;
        }
        [btn setTitle:title forState:UIControlStateNormal];
#endif
		[btn addTarget:self action:@selector(tabTouchedDown:) forControlEvents:UIControlEventTouchDown];
		[btn addTarget:self action:@selector(tabTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
		[self.tabBtns addObject:btn];
		[self.tabBarBgView  addSubview:btn];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutTabBarBtns
{
	self.tabBarBgView.frame = CGRectMake(0.f, self.tabBar.frame.origin.y,
										 self.tabBar.frame.size.width, self.tabBar.frame.size.height);
    
	int viewCount = self.viewControllers.count > MAX_TAB_COUNT ? MAX_TAB_COUNT : self.viewControllers.count;
	CGFloat width = self.tabBar.frame.size.width / viewCount;
	CGFloat height = self.tabBar.frame.size.height;
	self.focusBgView.frame = CGRectMake(self.currentSelectedIndex * width, 0.f, width, height);
	
	for (int i = 0; i < viewCount; i++) {
		UIButton *btn = [self.tabBtns objectAtIndex:i];
		btn.frame = CGRectMake(i * width, 0.f, width, height);
        
#ifdef USE_TAB_IMAGE
		UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"tab%d.png", i + 1]];
		UIImage* hImage = [UIImage imageNamed:[NSString stringWithFormat:@"tabh%d.png", i + 1]];
		[btn setImage:image forState:UIControlStateNormal];
		[btn setImage:hImage forState:UIControlStateHighlighted];
		[btn setImage:hImage forState:UIControlStateSelected];
#endif
        
		if (self.currentSelectedIndex == i) {
			[btn setSelected:YES];
		}
		else {
			[btn setSelected:NO];
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tabTouchedDown:(id)button
{
	int index = [self.tabBtns indexOfObject:button];
	if (self.currentSelectedIndex != index) {

		for (int i = 0; i < self.tabBtns.count; i++) {
			UIButton *btn = [self.tabBtns objectAtIndex:i];
			if (self.currentSelectedIndex == i) {
				[btn setSelected:NO];
			}
		}

		self.currentSelectedIndex = index;
		self.selectedIndex = self.currentSelectedIndex;
		[self performSelector:@selector(slideTabBg:) withObject:button];
	}
	else {
		[(UIButton*)button setHighlighted:YES];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tabTouchedUp:(id)button
{
	for (int i = 0; i < self.tabBtns.count; i++) {
		UIButton *btn = [self.tabBtns objectAtIndex:i];
		if (self.currentSelectedIndex == i) {
			[btn setSelected:YES];
		}
		else {
			[btn setSelected:NO];
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)slideTabBg:(UIButton *)btn
{
	[UIView beginAnimations:nil context:nil];  
	[UIView setAnimationDuration:0.2f];
	[UIView setAnimationDelegate:self];
	self.focusBgView.frame = CGRectMake(btn.frame.origin.x, btn.frame.origin.y,
                                        btn.frame.size.width, btn.frame.size.height);
	[UIView commitAnimations];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UINavigationControllerDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!self.prevViewControllers)
        self.prevViewControllers = [navigationController viewControllers];
    
    
    // We detect is the view as been push or popped
    BOOL pushed;
    
    if ([self.prevViewControllers count] <= [[navigationController viewControllers] count])
        pushed = YES;
    else
        pushed = NO;
    
    // Logic to know when to show or hide the tab bar
    BOOL isPreviousHidden, isNextHidden;
    
    isPreviousHidden = [[self.prevViewControllers lastObject] hidesBottomBarWhenPushed];
    isNextHidden = [viewController hidesBottomBarWhenPushed];
    
    self.prevViewControllers = [navigationController viewControllers];
    
    if (!isPreviousHidden && !isNextHidden)
        return;
    
    else if (!isPreviousHidden && isNextHidden)
        [self hideTabBarAnimated:animated];
    
    else if (isPreviousHidden && !isNextHidden)
        [self showTabBarAnimated:animated];
    
    else if (isPreviousHidden && isNextHidden)
        return;
}

@end
