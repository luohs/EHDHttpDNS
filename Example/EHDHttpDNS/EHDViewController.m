//
//  EHDViewController.m
//  EHDHttpDNS
//
//  Created by luohuasheng on 11/29/2017.
//  Copyright (c) 2017 luohuasheng. All rights reserved.
//

#import "EHDViewController.h"
#import <EHDHttpDNS/HttpDNS.h>
@interface EHDViewController ()

@end

@implementation EHDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString *ip = [[HttpDNS sharedInstance] ipWithHost:@"restapi.hsyuntai.com"];
    NSLog(@"DNS解析：%@", ip);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *ip = [[HttpDNS sharedInstance] ipWithHost:@"pay.hsyuntai.com"];
        NSLog(@"DNS解析：%@", ip);
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
@end
