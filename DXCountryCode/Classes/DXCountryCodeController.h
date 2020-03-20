//
//  DXCountryCodeController.h
//  DXCountryCode
//
//  Created by Jack on 20/3/11.
//  Copyright © 2019年 Jack. All rights reserved.
//  国家代码选择界面

#import <UIKit/UIKit.h>

typedef void(^ReturnCountryCodeBlock) (NSString *countryName, NSString *code);
typedef void(^AdjustSearchBarStyleBlock) (UISearchBar *searchBar);

@protocol DXCountryCodeControllerDelegate <NSObject>

@optional

/**
 Delegate 回调所选国家代码

 @param countryName 所选国家
 @param code 所选国家代码
 */
-(void)returnCountryName:(NSString *)countryName code:(NSString *)code;

@end

typedef enum {
    DXCountryCodeTpyeLeft,
    DXCountryCodeTpyeRight
} DXCountryCodeTpye;


@interface DXCountryCodeController : UIViewController

/// 可以使用代理或block把选择的国家地区码返回出去
@property (nonatomic, weak) id<DXCountryCodeControllerDelegate> deleagete;
@property (nonatomic, copy) ReturnCountryCodeBlock returnCountryCodeBlock;

/// Use this init method / 用这个初始化方法 。参数格式是@"86"这样的。如果调用init，默认就是86
- (instancetype)initWithCountryCode:(NSString *)countryCode;

/**
  以下属性为可选，不提供的话都有默认值
*/
/// 默认值为：选择国家和地区
@property (nonatomic, copy) NSString *navigationTitle;

/// 默认值为：取消
@property (nonatomic, copy) NSString *backBtnTitle;

/// 默认没有图片。如果要到达只有图片的效果，还要把backBtnTitle设置为@""
@property (nonatomic, strong) UIImage *backBtnImage;

/// 默认值为一个文字为 取消的按钮。如果对此按钮的样式不满意，可以自己传一个按钮。
@property (nonatomic, strong) UIButton *backBtn;

/// 控制隐藏 右边选中字母时放大的气泡。默认显示
@property (nonatomic, assign) BOOL hideBubbleView;

/// 控制隐藏 右边索引条。默认显示
@property (nonatomic, assign) BOOL hideSectionIndexView;

/// 控制 是否显示选中图标。默认显示选中图标
@property (nonatomic, assign) BOOL hideSelectImage;

/// 控制 是否滚动到选中的section。默认Yes, 滚动到 选中的section
@property (nonatomic, assign) BOOL scrollToRowAtIndexPath;

/// 控制 进入搜索状态时是否隐藏导航栏。默认Yes
@property (nonatomic, assign) BOOL hidesNavigationBarDuringPresentation;

/// 控制 是否隐藏搜索框。默认NO
@property (nonatomic, assign) BOOL hideSearchBar;

/// 控制 国家码显示在左边还是右边。默认在左边
@property (nonatomic, assign) DXCountryCodeTpye showType;

/// 国家码的颜色，只有在showType为DXCountryCodeTpyeRight时才能生效。
@property (nonatomic, strong) UIColor *rightCodeColor;

/// 右边索引条的文字的颜色
@property (nonatomic, strong) UIColor *indexViewColor;

/// 右边索引条的文字高亮的颜色
@property (nonatomic, strong) UIColor *highlightedIndexViewColor;

/// 调整SearchBar的样式。searchBar就是searchController.searchBar。
@property (nonatomic, copy) AdjustSearchBarStyleBlock adjustSearchBarStyleBlock;
@end

