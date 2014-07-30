//
//  SMTrendCell.m
//  SinaMBlogNimbus
//
//  Created by jimneylee on 13-8-15.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "OSCFriendCell.h"
#import "OSCFriendEntity.h"

#define TITLE_FONT_SIZE [UIFont boldSystemFontOfSize:17.f]

@implementation OSCFriendCell

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return 44.0f;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.textLabel.font = TITLE_FONT_SIZE;

    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse
{
    [super prepareForReuse];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews
{
    [super layoutSubviews];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(id)object
{
    [super shouldUpdateCellWithObject:object];
    if ([object isKindOfClass:[OSCFriendEntity class]]) {
        OSCFriendEntity* entity = (OSCFriendEntity*)object;
        self.textLabel.text = [entity getNameWithAt];
    }
    return YES;
}

@end
