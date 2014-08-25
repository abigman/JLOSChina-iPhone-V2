//
//  RCTopicDetailC.m
//  JLOSChina
//
//  Created by Lee jimney on 12/10/13.
//  Copyright (c) 2013 jimneylee. All rights reserved.
//

#import "OSCCommonDetailC.h"
#import "OSCCommonDetailModel.h"
#import "OSCCommentEntity.h"
#import "OSCCommonBodyView.h"
#import "OSCCommonBodyWebView.h"
#import "OSCReplyModel.h"
#import "OSCQuickReplyC.h"
#import "OSCCommonRepliesListC.h"

#define SCROLL_DIRECTION_BOTTOM_TAG 1000
#define SCROLL_DIRECTION_UP_TAG 1001

@interface OSCCommonDetailC ()<RCQuickReplyDelegate, OSCCommonBodyViewDelegate>
@property (nonatomic, strong) OSCCommonDetailEntity* topicDetailEntity;
@property (nonatomic, strong) OSCCommonBodyView* topicBodyView;
@property (nonatomic, strong) OSCCommonBodyWebView* topicBodyWebView;

@property (nonatomic, strong) OSCQuickReplyC* quickReplyC;
@property (nonatomic, strong) UIButton* scrollBtn;
@end

@implementation OSCCommonDetailC

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTopicId:(unsigned long)topicId topicType:(OSCContentType)topicType
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        ((OSCCommonDetailModel*)self.model).topicId = topicId;
        ((OSCCommonDetailModel*)self.model).contentType = topicType;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"详细";
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.rightBarButtonItems =
        [NSArray arrayWithObjects:
         [OSCGlobalConfig createBarButtonItemWithTitle:@"查看回复" target:self
                                                action:@selector(showRepliesListView)],
         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                       target:self action:@selector(replyTopicAction)],
         nil];
        // cell not selectable, also cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.actions attachToClass:[self.model objectClass] tapBlock:nil/*self.tapAction*/];
        self.isCacheFirstLoad = NO;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = TABLE_VIEW_BG_COLOR;
    self.tableView.backgroundView = nil;
    
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    self.scrollBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    self.scrollBtn.backgroundColor = RGBACOLOR(0, 0, 0, 0.6f);
    self.scrollBtn.titleLabel.font = [UIFont boldSystemFontOfSize:30.f];
    self.scrollBtn.titleLabel.textColor = [UIColor whiteColor];
    self.scrollBtn.centerX = keyWindow.width / 2;
    self.scrollBtn.bottom = keyWindow.height - CELL_PADDING_8;
    [self.scrollBtn addTarget:self action:@selector(scrollToBottomOrTopAction)
             forControlEvents:UIControlEventTouchUpInside];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                 action:@selector(showNavigationBar)];
//    [self.view addGestureRecognizer:tapGesture];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.quickReplyC.textView isFirstResponder]) {
        [self.quickReplyC.textView resignFirstResponder];
    }
    if (self.quickReplyC.view.superview) {
        [self.quickReplyC.view removeFromSuperview];
    }
    if (self.scrollBtn.superview) {
        [self.scrollBtn removeFromSuperview];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateTopicHeaderView
{
    if (!_topicBodyView) {
        _topicBodyView = [[OSCCommonBodyView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.width, 0.f)];
        _topicBodyView.delegate = self;
    }
    [self.topicBodyView updateViewWithTopicDetailEntity:self.topicDetailEntity];
    
    // call layoutSubviews at first to calculte view's height, dif from setNeedsLayout
    [self.topicBodyView layoutIfNeeded];
    if (!self.tableView.tableHeaderView) {
        self.tableView.tableHeaderView = self.topicBodyView;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateTopicHeaderWebView
{
    if (!_topicBodyWebView) {
        _topicBodyWebView = [[OSCCommonBodyWebView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.width, self.view.height)];
    }
    [self.topicBodyWebView updateViewWithTopicDetailEntity:self.topicDetailEntity];
    
#if 0
    // call layoutSubviews at first to calculte view's height, dif from setNeedsLayout
    [self.topicBodyWebView layoutIfNeeded];
    if (!self.tableView.tableHeaderView) {
        self.tableView.tableHeaderView = self.topicBodyWebView;
    }
#else
    [self.view addSubview:self.topicBodyWebView];
#endif
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showRepliesListView
{
    OSCCommonRepliesListC* c = [[OSCCommonRepliesListC alloc] initWithTopicId:((OSCCommonDetailModel*)self.model).topicId
                                                                    topicType:((OSCCommonDetailModel*)self.model).contentType
                                                                 repliesCount:((OSCCommonDetailModel*)self.model).topicDetailEntity.repliesCount];
    [self.navigationController pushViewController:c animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)replyTopicAction
{
    if ([OSCGlobalConfig getAuthUserID]) {
        [self showReplyAsInputAccessoryView];
    }
    else {
        [OSCGlobalConfig showLoginControllerFromNavigationController:self.navigationController];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showReplyAsInputAccessoryView
{
    if (![self.quickReplyC.textView.internalTextView isFirstResponder]) {
        // each time addSubview to keyWidow, otherwise keyborad is not showed, sorry, so dirty!
        [[UIApplication sharedApplication].keyWindow addSubview:_quickReplyC.view];
        self.quickReplyC.textView.internalTextView.inputAccessoryView = self.quickReplyC.view;
        
        // call becomeFirstResponder twice, I donot know why, feel so bad!
        // maybe because textview is in superview(self.quickReplyC.view)
        [self.quickReplyC.textView.internalTextView becomeFirstResponder];
        [self.quickReplyC.textView.internalTextView becomeFirstResponder];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (OSCQuickReplyC*)quickReplyC
{
    if (!_quickReplyC) {
        OSCCatalogType catalogType = [OSCGlobalConfig catalogTypeForContentType:((OSCCommonDetailModel*)self.model).contentType];
        _quickReplyC = [[OSCQuickReplyC alloc] initWithTopicId:((OSCCommonDetailModel*)self.model).topicId
                                                     catalogType:catalogType];
        _quickReplyC.replyDelegate = self;
    }
    return _quickReplyC;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToBottomOrTopAction
{
    if (SCROLL_DIRECTION_BOTTOM_TAG == self.scrollBtn.tag) {
        [self scrollToBottomAnimated:YES];
    }
    else if (SCROLL_DIRECTION_UP_TAG == self.scrollBtn.tag) {
        [self scrollToTopAnimated:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToBottomAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:CGRectMake(0.f, self.tableView.contentSize.height - self.view.height,
                                                   self.tableView.width, self.tableView.height) animated:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToTopAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:CGRectMake(0.f, 0.f,
                                                   self.tableView.width, self.tableView.height) animated:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showNavigationBar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)replyTopicWithFloorAtSomeone:(NSString*)floorAtsomeoneString
{
    if ([OSCGlobalConfig getAuthUserID]) {
        [self replyTopicAction];
        [self.quickReplyC appendString:floorAtsomeoneString];
    }
    else {
        [OSCGlobalConfig showLoginControllerFromNavigationController:self.navigationController];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Override

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)tableModelClass
{
    return [OSCCommonDetailModel class];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NIActionBlock)tapAction
{
    return ^BOOL(id object, id target, NSIndexPath* indexPath) {
        if (!self.editing) {
            if ([object isKindOfClass:[OSCCommentEntity class]]) {
                //RCReplyEntity* topic = (RCReplyEntity*)object;
                //nothing to do!
                [OSCGlobalConfig HUDShowMessage:@"TODO:relative recommend!" addedToView:self.view];
            }
            return YES;
        }
        else {
            return NO;
        }
    };
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFinishLoadData
{
    [super didFinishLoadData];
    
    self.topicDetailEntity = ((OSCCommonDetailModel*)self.model).topicDetailEntity;
#if 1
    [self updateTopicHeaderWebView];
#else
    [self updateTopicHeaderView];
#endif
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFailLoadData
{
    [super didFailLoadData];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showMessageForEmpty
{

}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showMessageForError
{
    NSString* msg = @"抱歉，无法获取信息！";
    [OSCGlobalConfig HUDShowMessage:msg addedToView:self.view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showMssageForLastPage
{
    // no page
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - OSCTopicBodyViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFinishLoadBodyContent
{
    // TODO: fix bug
#if 0
    NSUInteger rowCount = [self.tableView numberOfRowsInSection:0];
    if (rowCount > 0) {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:
                                 [NSIndexPath indexPathForRow:rowCount-1 inSection:0]];
        [UIView animateWithDuration:1.0f animations:^{
            self.tableView.contentOffset = CGPointMake(0.f, cell.bottom);
        } completion:^(BOOL finished) {
            
        }];
    }
#endif
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - RCQuickReplyDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReplySuccessWithMyReply:(OSCCommentEntity*)replyEntity
{
    if (replyEntity) {
        // nothing to do
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReplyFailure
{
    // nothing to do
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReplyCancel
{

}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// 显示跳到底部和顶部
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat minOffset = 200.f;
    
    if (scrollView.contentOffset.y > minOffset
        && scrollView.contentOffset.y < scrollView.contentSize.height - self.view.height - minOffset) {
        if (velocity.y > 0.f) {
            [self.scrollBtn setTitle:@"↓" forState:UIControlStateNormal];
            self.scrollBtn.tag = SCROLL_DIRECTION_BOTTOM_TAG;
        }
        else {
            [self.scrollBtn setTitle:@"↑" forState:UIControlStateNormal];
            self.scrollBtn.tag = SCROLL_DIRECTION_UP_TAG;
        }
        [[UIApplication sharedApplication].keyWindow addSubview:self.scrollBtn];
        [self.scrollBtn performSelector:@selector(removeFromSuperview) withObject:Nil afterDelay:2.0f];
    }
}

@end
