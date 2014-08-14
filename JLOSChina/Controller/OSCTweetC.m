//
//  OSCTweetC.m
//  JLOSChina
//
//  Created by jimneylee on 13-12-10.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "OSCTweetC.h"
#import "SDSegmentedControl.h"

#import "OSCTweetTimelineModel.h"
#import "OSCTweetEntity.h"
#import "OSCCommonDetailC.h"
#import "OSCQuickReplyC.h"
#import "OSCCommonRepliesListC.h"
#import "OSCTweetBodyView.h"
#import "OSCTweetPostC.h"

@interface OSCTweetC ()<RCQuickReplyDelegate>

@property (nonatomic, strong) SDSegmentedControl *segmentedControl;
@property (nonatomic, strong) OSCQuickReplyC* quickReplyC;

@end

@implementation OSCTweetC

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"社区动弹";
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.rightBarButtonItems =
        [NSArray arrayWithObjects:
//         [OSCGlobalConfig createRefreshBarButtonItemWithTarget:self
//                                                        action:@selector(autoPullDownRefreshActionAnimation)],
         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                       target:self action:@selector(postNewTweetAction)],
         nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginNotification)
                                                     name:DID_LOGIN_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPostNewTweetNotification)
                                                     name:DID_POST_NEW_TWEET_SUCCESS_NOTIFICATION object:nil];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = TABLE_VIEW_BG_COLOR;
    self.tableView.backgroundView = nil;
    
    [self initSegmentedControl];
    ((OSCTweetTimelineModel*)self.model).tweetType = self.segmentedControl.selectedSegmentIndex;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showReplyAsInputAccessoryViewWithTweetId:(unsigned long)tweetId
{
    if (![self.quickReplyC.textView.internalTextView isFirstResponder]) {
        self.quickReplyC.topicId = tweetId;
        self.quickReplyC.catalogType = OSCCatalogType_Tweet;
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
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)initSegmentedControl
{
    if (!_segmentedControl) {
        // TODO: pull request to author fix this bug: initWithFrame can not call [self commonInit]
        _segmentedControl = [[SDSegmentedControl alloc] init];
        _segmentedControl.frame = CGRectMake(0.f, 0.f, self.view.width, _segmentedControl.height);
        _segmentedControl.interItemSpace = 0.f;
        [_segmentedControl addTarget:self action:@selector(segmentedDidChange)
                    forControlEvents:UIControlEventValueChanged];
    }
    
    NSArray* sectionNames = @[@"最新动弹", @"热门动弹", @"我的动弹"];
    for (int i = 0; i < sectionNames.count; i++) {
        [self.segmentedControl insertSegmentWithTitle:sectionNames[i]
                                              atIndex:i
                                             animated:NO];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)segmentedDidChange
{
    // first cancel request operation
    [self.model cancelRequstOperation];
    
    ((OSCTweetTimelineModel*)self.model).tweetType = self.segmentedControl.selectedSegmentIndex;
    
    // TODO:remove all, sometime crash, fix later on
    // if (self.model.sections.count > 0) {
    //     [self.model removeSectionAtIndex:0];
    // }
    
    // scroll top
    [self scrollToTopAnimated:NO];
    
    // after scrollToTopAnimated then pull down to refresh, performce perfect
    [self performSelector:@selector(autoPullDownRefreshActionAnimation) withObject:self afterDelay:0.1f];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToTopAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:CGRectMake(0.f, 0.f,
                                                   self.tableView.width, self.tableView.height)
                               animated:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (OSCQuickReplyC*)quickReplyC
{
    if (!_quickReplyC) {
        _quickReplyC = [[OSCQuickReplyC alloc] init];
        _quickReplyC.replyDelegate = self;
    }
    return _quickReplyC;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)postNewTweetAction
{
    if ([OSCGlobalConfig loginedUserEntity]) {
        OSCTweetPostC* postC = [[OSCTweetPostC alloc] init];
        [self.navigationController pushViewController:postC animated:YES];
    }
    else {
        [OSCGlobalConfig showLoginControllerFromNavigationController:self.navigationController];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showRepliesListViewWithTweetEntity:(OSCTweetEntity*)tweetEntity
{
    OSCCommonRepliesListC* c = [[OSCCommonRepliesListC alloc] initWithTopicId:tweetEntity.tweetId
                                                                    topicType:OSCContentType_Tweet
                                                                 repliesCount:tweetEntity.repliesCount];
    [self.navigationController pushViewController:c animated:YES];
    
    // table header view with body
    OSCTweetBodyView* bodyView = [[OSCTweetBodyView alloc] initWithFrame:self.view.bounds];
    bodyView.height = [OSCTweetBodyView heightForObject:tweetEntity withViewWidth:self.view.width];
    [bodyView shouldUpdateCellWithObject:tweetEntity];
    c.tableView.tableHeaderView = bodyView;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)popDownReplyView
{
    if (self.quickReplyC.textView.isFirstResponder) {
        [self.quickReplyC.textView resignFirstResponder];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Override

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)tableModelClass
{
    return [OSCTweetTimelineModel class];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NIActionBlock)tapAction
{
    return ^BOOL(id object, id target, NSIndexPath* indexPath) {
        if ([object isKindOfClass:[OSCTweetEntity class]]) {
            OSCTweetEntity* entity = (OSCTweetEntity*)object;
            if (entity.tweetId > 0) {
                [self showRepliesListViewWithTweetEntity:entity];
            }
            else {
                [OSCGlobalConfig HUDShowMessage:@"不存在或已被删除！" addedToView:self.view];
            }
        }
        return YES;
    };
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showMessageForEmpty
{
    NSString* msg = @"信息为空";
    [OSCGlobalConfig HUDShowMessage:msg addedToView:self.view];
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
    NSString* msg = @"已是最后一页";
    [OSCGlobalConfig HUDShowMessage:msg addedToView:self.view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Login/Logout Notification

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoginNotification
{
#if 0// no use for oauth
    if (OSCTweetType_Mine == self.segmentedControl.selectedSegmentIndex
        && ![OSCGlobalConfig loginedUserEntity]) {
        // TODO:remove all, sometime crash, fix later on
        //    if (self.model.sections.count > 0) {
        //        [self.model removeSectionAtIndex:0];
        //    }
        [OSCGlobalConfig showLoginControllerFromNavigationController:self.navigationController];
    }
#endif
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLogoutNotification
{
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - New Tweet Notification

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didPostNewTweetNotification
{
    if (OSCTweetType_Latest == ((OSCTweetTimelineModel*)self.model).tweetType
        || OSCTweetType_Mine ==  ((OSCTweetTimelineModel*)self.model).tweetType) {
        [self scrollToTopAnimated:NO];
        [self performSelector:@selector(autoPullDownRefreshActionAnimation) withObject:self afterDelay:0.1f];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self popDownReplyView];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellFactory tableView:tableView heightForRowAtIndexPath:indexPath model:self.model];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.segmentedControl;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    static CGFloat kDefaultSegemetedControlHeight = 43.f;// see: SDSegmentedControl commonInit
    return kDefaultSegemetedControlHeight;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - RCQuickReplyDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReplySuccessWithMyReply:(OSCCommentEntity*)replyEntity
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
