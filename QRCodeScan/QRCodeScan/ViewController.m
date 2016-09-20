//
//  ViewController.m
//  QRCodeScan
//
//  Created by Lyman on 16/9/19.
//  Copyright © 2016年 Lyman. All rights reserved.
//

#import "ViewController.h"
#import "QRScanViewController.h"
@interface ViewController ()<QRScanViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *scanTipOrResultLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"QRCodeScan";
    
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"qrCode"] style:UIBarButtonItemStylePlain target:self action:@selector(beginingScanning)];
    self.navigationItem.rightBarButtonItem = scanItem;
}

- (void)beginingScanning {
    QRScanViewController *qrScanViewController = [[QRScanViewController alloc] init];
    qrScanViewController.delegate = self;
    [self.navigationController pushViewController:qrScanViewController animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self beginingScanning];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - QRScanViewControllerDelegate
- (void)QRScanViewController:(QRScanViewController *)scanViewController didScanContent:(NSString *)content {
    if (content.length) {
        self.scanTipOrResultLabel.text = [NSString stringWithFormat:@"扫描结果为：%@",content];
    } 
}
@end
