//
//  DXCountryCodeController.m
//  DXCountryCode
//
//  Created by Jack on 20/3/11.
//  Copyright © 2019年 Jack. All rights reserved.
//  国家代码选择界面

#import "DXCountryCodeController.h"

#import "DXBubbleView.h"
#import "DSectionIndexView.h"
#import "DSectionIndexItemView.h"
#define kDXIsPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface DXCountryCodeController ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating,DSectionIndexViewDelegate,DSectionIndexViewDataSource>
{
    UITableView *_tableView;
    UISearchController *_searchController;
    NSDictionary *_sortedNameDict;
    NSArray *_indexArray;
    NSMutableArray *_results;
    
    NSString *_countryCode;
    NSString *_selectIndexStr;
    BOOL _isSearchStrEmpty;
}
@property (nonatomic,strong) DXBubbleView *dxBubbleView;/**< 右侧气泡view */
@property (strong, nonatomic) DSectionIndexView *sectionIndexView;/**< 右侧索引条view */

@property (nonatomic,strong) UIImageView *selectImagView;

@end

@implementation DXCountryCodeController

- (instancetype)init
{
    return [self initWithCountryCode:nil];
}

- (instancetype)initWithCountryCode:(NSString *)countryCode
{
    self = [super init];
       if (self) {
           if (!countryCode || !countryCode.length) {
               countryCode = @"86";
           }
           _countryCode = countryCode;
           _scrollToRowAtIndexPath = YES;
           _hidesNavigationBarDuringPresentation = YES;
       }
       return self;
}

- (void)loadCountryData
{
       NSString *plistPathCH = [[self dx_countryCodeBundle] pathForResource:@"sortedNameCH" ofType:@"plist"];
       _sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathCH];
       _indexArray = [[NSArray alloc] initWithArray:[[_sortedNameDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
           return [obj1 compare:obj2];
       }]];
}
#pragma mark - system
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNavBar];
    
    [self loadCountryData]; // 加载数据
    [self creatSubviews];
    
    [self addDXBubbleView];
    [self initIndexView];
    
    [self.sectionIndexView reloadItemViews];
    
    // 滚动到指定的section，并显示选定状态
    [self setupSelectState];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshIndexView];
    });
}
- (void)refreshIndexView{
    if ( _searchController.isActive && !_isSearchStrEmpty) {
        _sectionIndexView.hidden = YES;
    }else{
        _sectionIndexView.hidden = NO;
        
        CGSize size = CGSizeMake(22, 18.0f);
        
        if (kDXIsPad) {
            size = CGSizeMake(22, 21.0f);
        }
        
        CGFloat margin = kDXIsPad?-20:0;
        
        NSInteger indexViewHeight = _indexArray.count*size.height;
        _sectionIndexView.frame = CGRectMake(CGRectGetWidth(_tableView.frame) - size.width - margin, (CGRectGetHeight(_tableView.frame) - indexViewHeight)/2+20, size.width, indexViewHeight);
        [_sectionIndexView setBackgroundViewFrame];
    }
}

#pragma mark 初始化选中的索引
- (void)addDXBubbleView
{
    if (self.hideBubbleView == NO && self.hideSectionIndexView == NO)
    {
        NSArray *array = [[self dx_countryCodeBundle] loadNibNamed:@"DXBubbleView" owner:self options:nil];
        if (!self.dxBubbleView) {
            self.dxBubbleView = [array firstObject];
            self.dxBubbleView.backgroundColor = [UIColor clearColor];
            self.dxBubbleView.hidden = YES;
            [self.view addSubview:self.dxBubbleView];
        }
    }
}
#pragma mark - private
- (void)initIndexView
{
    if (self.hideSectionIndexView == NO)
    {
        _sectionIndexView = [[DSectionIndexView alloc] init];
        _sectionIndexView.backgroundColor = [UIColor clearColor];
        _sectionIndexView.dataSource = self;
        _sectionIndexView.delegate = self;
        _sectionIndexView.isShowCallout = YES;
        _sectionIndexView.calloutViewType = CalloutViewTypeForUserDefined;
        _sectionIndexView.calloutDirection = SectionIndexCalloutDirectionLeft;
        _sectionIndexView.calloutMargin = 10.f;
        [self.view addSubview:self.sectionIndexView];
        [self.view bringSubviewToFront:self.sectionIndexView];
    }
}

#pragma mark - 滚动到指定的section，并显示选定状态
- (void)setupSelectState
{
    for (int section = 0; section < _indexArray.count; section++)
    {
        NSArray *capatalArr = _sortedNameDict[_indexArray[section]];
        for (int row = 0; row < capatalArr.count; row++)
        {
            NSString *allCountryStr = capatalArr[row];
            NSArray  * array = [allCountryStr componentsSeparatedByString:@"+"];
            NSString * code = array.lastObject;
            if ([code isEqualToString:_countryCode])
            {
                [_tableView reloadData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];

                _selectIndexStr = [self showCodeStringIndex:indexPath];
                // 延时0.1s才能取到不为空的cell
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UITableViewCell *cell = [self->_tableView cellForRowAtIndexPath:indexPath];
                    if (self.hideSelectImage == NO && self.showType == DXCountryCodeTpyeLeft)
                    {
                        cell.accessoryView = self.selectImagView;
                    }
                });
                if (self.scrollToRowAtIndexPath) {
                    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
                return;
            }
        }
    }
}
#pragma mark - 创建导航栏view
- (void)initNavBar
{
    self.navigationItem.title = @"选择国家和地区";
    if (self.navigationTitle.length) {
        self.navigationItem.title = self.navigationTitle;
    }
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *backBtnTitle = self.backBtnTitle?:@"取消";
    [backBtn setTitle:backBtnTitle forState:UIControlStateNormal];
    if (self.backBtnImage) {
        [backBtn setImage:self.backBtnImage forState:UIControlStateNormal];
    }
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    if (self.backBtn) {
        [self.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    }
}
- (void)goBack
{
    if (_searchController.active) {
        _searchController.active = NO;
    }
    [_searchController.searchBar resignFirstResponder];
    if (self.presentingViewController)
    {
        // 有时候会出现延迟几秒才会返回的问题，加0.1s延时就解决了
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - private
 //创建子视图
- (void)creatSubviews{
    _results = [NSMutableArray arrayWithCapacity:1];
    CGFloat tableViewOffset = kDXIsPad?20:0;
     CGFloat statusBarH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, statusBarH, self.view.bounds.size.width-tableViewOffset, self.view.bounds.size.height-statusBarH) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 44.0;
    _tableView.backgroundColor = UIColor.clearColor;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.hidesNavigationBarDuringPresentation = self.hidesNavigationBarDuringPresentation;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, _searchController.searchBar.bounds.size.height)];
    [headerView addSubview:_searchController.searchBar];
    
    [self setupSearchBarStyle]; // 调整SearchBar样式
    
    if (self.hideSearchBar == NO) {
        _tableView.tableHeaderView = headerView;
    }
}
#pragma mark - 调整searchBar外观
- (void)setupSearchBarStyle
{
    if (self.adjustSearchBarStyleBlock == nil)
    {
        UISearchBar *searchBar = _searchController.searchBar;
        searchBar.backgroundImage = [self dx_imageWithColor:[UIColor whiteColor]];
        searchBar.barStyle = UISearchBarStyleDefault;
        UITextField *searchField = [searchBar valueForKey:@"searchField"];
        searchField.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        //    for (UIView *view in searchBar.subviews.firstObject.subviews)
        //    {
        //        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
        //            break;
        //        }
        //    }
    }
    else
    {
        self.adjustSearchBarStyleBlock(_searchController.searchBar);
    }
}

- (NSString *)showCodeStringIndex:(NSIndexPath *)indexPath {
    NSString *showCodeSting;
    if (_searchController.isActive && !_isSearchStrEmpty) {
        if (_results.count > indexPath.row) {
            showCodeSting = [_results objectAtIndex:indexPath.row];
        }
    } else {
        if (_indexArray.count > indexPath.section) {
            NSArray *sectionArray = [_sortedNameDict valueForKey:[_indexArray objectAtIndex:indexPath.section]];
            if (sectionArray.count > indexPath.row) {
                showCodeSting = [sectionArray objectAtIndex:indexPath.row];
            }
        }
    }
    return showCodeSting;
}

- (void)selectCodeIndex:(NSIndexPath *)indexPath {
    NSString * originText = [self showCodeStringIndex:indexPath];
    NSArray  * array = [originText componentsSeparatedByString:@"+"];
    NSString * countryName = [array.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * code = array.lastObject;
    
    if (self.deleagete && [self.deleagete respondsToSelector:@selector(returnCountryName:code:)]) {
        [self.deleagete returnCountryName:countryName code:code];
    }
    
    if (self.returnCountryCodeBlock != nil) {
        self.returnCountryCodeBlock(countryName,code);
    }

    [self goBack];
//    NSLog(@"选择国家: %@   代码: %@",countryName,code);
}
#pragma mark DSectionIndexViewDataSource && delegate method
- (NSInteger)numberOfItemViewForSectionIndexView:(DSectionIndexView *)sectionIndexView
{
    return _indexArray.count;
}

- (DSectionIndexItemView *)sectionIndexView:(DSectionIndexView *)sectionIndexView itemViewForSection:(NSInteger)section
{
    DSectionIndexItemView *itemView = [[DSectionIndexItemView alloc] init];
    //    itemView.frame = CGRectMake(0, 0, 20, 20);
    if (section < _indexArray.count) {
        itemView.titleLabel.text = [_indexArray objectAtIndex:section];
    }else{
        itemView.titleLabel.text = @"";
    }
    
    itemView.titleLabel.font = [UIFont systemFontOfSize:kDXIsPad?15:12];
    itemView.titleLabel.textColor = [UIColor blackColor];
    if (self.indexViewColor) {
        itemView.titleLabel.textColor = self.indexViewColor;
    }
    itemView.titleLabel.highlightedTextColor = [UIColor colorWithRed:21/255.0 green:166/255.0 blue:220/255.0 alpha:1];
    if (self.highlightedIndexViewColor) {
        itemView.titleLabel.highlightedTextColor = self.highlightedIndexViewColor;
    }
    itemView.titleLabel.shadowColor = [UIColor whiteColor];
    itemView.titleLabel.shadowOffset = CGSizeMake(0, 1);
    
    return itemView;
}

- (UIView *)sectionIndexView:(DSectionIndexView *)sectionIndexView calloutViewForSection:(NSInteger)section
{
    if (section<_indexArray.count) {
        _dxBubbleView.indexString = [_indexArray objectAtIndex:section];
    }else{
        _dxBubbleView.indexString = @"";
    }
    
    _dxBubbleView.hidden = NO;
    return _dxBubbleView;
}

- (NSString *)sectionIndexView:(DSectionIndexView *)sectionIndexView
               titleForSection:(NSInteger)section
{
    if (section < _indexArray.count) {
        return [_indexArray objectAtIndex:section];
    }else{
        return @"";
    }
}

- (void)sectionIndexView:(DSectionIndexView *)sectionIndexView didSelectSection:(NSInteger)section
{
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *inputText = searchController.searchBar.text;
   
    if (inputText.length == 0) {
        _isSearchStrEmpty = YES;
        [self refreshIndexView];
        [_tableView reloadData];
        return;
    }
    _isSearchStrEmpty = NO;
    [self refreshIndexView];
    if (_results.count > 0) {
        [_results removeAllObjects];
    }
    __weak __typeof(self)weakSelf = self;
    [_sortedNameDict.allValues enumerateObjectsUsingBlock:^(NSArray * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj containsString:inputText]) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf->_results addObject:obj];
            }
        }];
    }];
    [_tableView reloadData];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_searchController.isActive && !_isSearchStrEmpty) {
        return 1;
    } else {
        return [_sortedNameDict allKeys].count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchController.isActive && !_isSearchStrEmpty) {
        return [_results count];
    } else {
        if (_indexArray.count > section) {
            NSArray *array = [_sortedNameDict objectForKey:[_indexArray objectAtIndex:section]];
            return array.count;
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"dxCountryIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.rightCodeColor) {
            cell.detailTextLabel.textColor = self.rightCodeColor;
        }
    }
    NSString *codeStr = [self showCodeStringIndex:indexPath];
    cell.textLabel.text = codeStr;
    if (self.showType == DXCountryCodeTpyeRight)
    {
        NSArray  * array = [codeStr componentsSeparatedByString:@"+"];
        NSString * countryName = [array.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString * code = array.lastObject;
        cell.textLabel.text = countryName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@",code];
    }

    if (self.hideSelectImage == NO && self.showType == DXCountryCodeTpyeLeft)
    {
        BOOL isEqual = ([_selectIndexStr isEqualToString:cell.textLabel.text]);
        cell.accessoryView = isEqual?self.selectImagView: nil;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView) {
        if (_searchController.isActive && !_isSearchStrEmpty)
        {
            return 0;
        }
        return 30;
    } else {
        return 0;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_indexArray.count && _indexArray.count > section) {
        return [_indexArray objectAtIndex:section];
    }
    return nil;
}

#pragma mark - 选择国际获取代码
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectCodeIndex:indexPath];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchController.searchBar resignFirstResponder];

}

#pragma mark 懒加载
- (UIImageView *)selectImagView
{
    if (!_selectImagView) {
        UIImage *image = [UIImage imageWithContentsOfFile:[[self dx_countryCodeBundle] pathForResource:@"icon_row_select@2x" ofType:@"png"]];
        _selectImagView = [[UIImageView alloc] initWithImage:image];
    }
    return _selectImagView;
}

#pragma mark 私有方法
- (NSBundle *)dx_countryCodeBundle
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"DXCountryCode" ofType:@"bundle"]];
    return bundle;
}

- (UIImage *)dx_imageWithColor:(UIColor *)color {
    return [self dx_imageWithColor:color size:CGSizeMake(1, 1)];
}

- (UIImage *)dx_imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end

