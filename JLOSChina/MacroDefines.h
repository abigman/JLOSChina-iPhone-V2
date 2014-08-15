//
//  MacroDefines.h
//  JLOSChina
//
//  Created by Lee jimney on 12/16/13.
//  Copyright (c) 2013 jimneylee. All rights reserved.
//

#ifndef JLOSChina_MacroDefines_h
#define JLOSChina_MacroDefines_h

// APP 基本信息
#define APP_NAME [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
#define APP_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define APP_ID [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"APP_STORE_ID"] longValue]
#define HOST_URL [[NSBundle mainBundle] objectForInfoDictionaryKey:@"HOST_URL"]
//#define HOST_API_URL [NSString stringWithFormat:@"%@/api/v2", HOST_URL]
#define HOST_API_URL [[NSBundle mainBundle] objectForInfoDictionaryKey:@"HOST_API_URL"]
#define HOST_WIKI_URL [NSString stringWithFormat:@"%@/wiki", HOST_URL]
#define HOST_INTRO [[NSBundle mainBundle] objectForInfoDictionaryKey:@"HOST_INTRO"]
#define FORUM_BASE_API_TYPE [RCGlobalConfig forumBaseAPIType]

// iOS 系统版本
#define IOS_IS_AT_LEAST_6 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IOS_IS_AT_LEAST_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

// 兼容ios6.0
#ifndef NSFoundationVersionNumber_iOS_6_1
#define NSFoundationVersionNumber_iOS_6_1  993.00
#endif

// 是否是iphone5的判断
#define IS_WIDESCREEN ([[UIScreen mainScreen] bounds].size.height > 500)
#define IS_IPHONE ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] \
                  ||[[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"])
#define IS_IPHONE5 (IS_IPHONE && IS_WIDESCREEN)

// 标签plist
#define EMOTION_PLIST @"emotion_icons.plist"

// Cell布局
#define CELL_PADDING_10 10
#define CELL_PADDING_8 8
#define CELL_PADDING_6 6
#define CELL_PADDING_4 4
#define CELL_PADDING_2 2

// Color配色
#define APP_THEME_COLOR RGBCOLOR(26, 144, 56)//(41, 41, 41)
#define APP_NAME_GREEN_COLOR RGBCOLOR(85, 201, 66)
#define APP_NAME_WHITE_COLOR RGBCOLOR(200, 200, 200)
#define TABLE_VIEW_BG_COLOR RGBCOLOR(237, 234, 234)
#define CELL_CONTENT_VIEW_BG_COLOR RGBCOLOR(247, 247, 247)
#define CELL_CONTENT_VIEW_BORDER_COLOR RGBCOLOR(234, 234, 234)

// 左侧菜单栏可视宽度比
#define LEFT_GAP_PERCENTAGE 0.55f

// group头部高度
#define GROUP_SECTION_HEADER_HEIGHT 20.f

#define KEY_WINDOW [UIApplication sharedApplication].keyWindow

// 自定义链接协议
#define PROTOCOL_AT_SOMEONE @"atsomeone://"
#define PROTOCOL_SHARP_FLOOR @"sharpfloor://"
#define PROTOCOL_SHARP_SOFTWARE @"sharpsoftware://"
#define PROTOCOL_NODE @"node://"

// Notification通知
#define DID_LOGIN_NOTIFICATION @"DID_LOGIN_NOTIFICATION"
#define DID_LOGOUT_NOTIFICATION @"DID_LOGOUT_NOTIFICATION"
#define DID_POST_NEW_TWEET_SUCCESS_NOTIFICATION @"DID_POST_NEW_TWEET_SUCCESS_NOTIFICATION"

// 内容类型：资讯、博客、帖子、动弹（微博）类型
//#define CATALOG_NEWS 1
//#define CATALOG_FORUM 2
//#define CATALOG_TWEET 3

// News Content HTML, idea from old version
#define HTML_Style @"<style>#oschina_title {color: #000000; margin-bottom: 6px; font-weight:bold;}#oschina_title img{vertical-align:middle;margin-right:6px;}#oschina_title a{color:#0D6DA8;}#oschina_outline {color: #707070; font-size: 15px;}#oschina_outline a{color:#0D6DA8;}#oschina_software{color:#808080;font-size:15px}#oschina_body img {max-width: 290px;}#oschina_body {font-size:18px;max-width:290px;line-height:24px;} #oschina_body table{max-width:290px;}#oschina_body pre { font-size:12pt;font-family:Courier New,Arial;border:1px solid #ddd;border-left:5px solid #6CE26C;background:#f6f6f6;padding:5px;}</style>"
#define HTML_Bottom @"<div style='margin-bottom:20px'/>"

#endif
