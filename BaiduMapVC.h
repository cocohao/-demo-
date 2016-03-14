//
//  BaiduMapVC.h
//  EasyVanDriver
//
//  Created by coco on 15/12/4.
//  Copyright © 2015年 EasyVan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderPickupDetailObject.h"
@interface BaiduMapVC : UIViewController

@property (nonatomic,strong)OrderPickupDetailObject *orderDetailObject;

@property (nonatomic,assign)int  addressCount;
- (void)convertToBaiDuLat:(float)lat andLong:(float)longitude;

@end
