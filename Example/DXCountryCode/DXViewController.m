//
//  DXViewController.m
//  DXCountryCode
//
//  Created by Jackdx on 03/18/2020.
//  Copyright (c) 2020 Jackdx. All rights reserved.
//

#import "DXViewController.h"
#import "DXCountryCodeController.h"


@interface DXViewController ()<DXCountryCodeControllerDelegate>
{
    
    __weak IBOutlet UILabel *showCodeLB;
}

@end

@implementation DXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showCodeLB.text = @"86";
    });    
}

- (IBAction)pushTocountryCode:(UIButton *)sender {
    
    DXCountryCodeController *countryCodeVC = [[DXCountryCodeController alloc] initWithCountryCode:showCodeLB.text];
//    countryCodeVC.deleagete = self;
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
        self->showCodeLB.text = code;
        NSLog(@"countryName:%@, code:%@",countryName,code);
    };
    [self.navigationController pushViewController:countryCodeVC animated:YES];

}
- (IBAction)presentTocountryCode:(UIButton *)sender {
    
    DXCountryCodeController *countryCodeVC = [[DXCountryCodeController alloc] initWithCountryCode:showCodeLB.text];
//    countryCodeVC.deleagete = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:countryCodeVC];
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
        self->showCodeLB.text = code;
    };
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - XWCountryCodeControllerDelegate
- (void)returnCountryName:(NSString *)countryName code:(NSString *)code {
    showCodeLB.text = code;
}



@end
