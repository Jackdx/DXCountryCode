//
//  DXBubbleView.m
//
//  
//  Created by jack on 17/9/30.
//  Copyright © 2017年 dx. All rights reserved.
//

#import "DXBubbleView.h"

@interface DXBubbleView ()

@property (nonatomic,strong) IBOutlet UILabel *indexLabel;

@end

@implementation DXBubbleView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    NSInteger position = ([UIScreen mainScreen].bounds.size.height - 64 - 80)/2+58;
    self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-60, position, 44, 44);
}

- (void)setIndexString:(NSString *)indexString
{
    _indexString = indexString;
    self.indexLabel.text = indexString;
}

@end
