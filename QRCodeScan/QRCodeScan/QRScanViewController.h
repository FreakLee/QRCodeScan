//
//  QRScanViewController.h
//  QRCodeScan
//  https://github.com/FreakLee/QRCodeScan
//  Created by Lyman on 16/9/19.
//  Copyright © 2016年 Lyman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QRScanViewController;
@protocol QRScanViewControllerDelegate <NSObject>

- (void)QRScanViewController:(QRScanViewController *)scanViewController didScanContent:(NSString *)content;

@end

@interface QRScanViewController : UIViewController
@property (nonatomic, weak) id<QRScanViewControllerDelegate>delegate;
@end
