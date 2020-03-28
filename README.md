# DXCountryCode

[![CI Status](https://img.shields.io/travis/Jackdx/DXCountryCode.svg?style=flat)](https://travis-ci.org/Jackdx/DXCountryCode)
[![Version](https://img.shields.io/cocoapods/v/DXCountryCode.svg?style=flat)](https://cocoapods.org/pods/DXCountryCode)
[![License](https://img.shields.io/cocoapods/l/DXCountryCode.svg?style=flat)](https://cocoapods.org/pods/DXCountryCode)
[![Platform](https://img.shields.io/cocoapods/p/DXCountryCode.svg?style=flat)](https://cocoapods.org/pods/DXCountryCode)

国家和地区码选择控制器，支持present或push方式跳转，两三行代码搞定。适配iphone和ipad。如果对默认效果不满意，还支持各种自定义。

### 效果演示：
![image](https://github.com/Jackdx/DXCountryCode/raw/master/photo1.png)

![image](https://github.com/Jackdx/DXCountryCode/raw/master/photo2.png)

![image](https://github.com/Jackdx/DXCountryCode/raw/master/photo3.png)

![image](https://github.com/Jackdx/DXCountryCode/raw/master/photo4.png)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

DXCountryCode is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DXCountryCode'
```
### How To Use
present方式
```
    DXCountryCodeController *countryCodeVC = [[DXCountryCodeController alloc] initWithCountryCode:@"86"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:countryCodeVC];
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
        NSLog(@"countryName:%@, code:%@",countryName,code);
    };
    [self presentViewController:nav animated:YES completion:nil];
```

push方式
```  
    DXCountryCodeController *countryCodeVC = [[DXCountryCodeController alloc] initWithCountryCode:@"86"];
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
        NSLog(@"countryName:%@, code:%@",countryName,code);
    };
    [self.navigationController pushViewController:countryCodeVC animated:YES];
```


## Author

Jackdx, 871077947@qq.com

## License

DXCountryCode is available under the MIT license. See the LICENSE file for more info.
