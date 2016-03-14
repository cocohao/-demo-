//
//  BaiduLocationManager.m
//  EasyVanDriver
//
//  Created by coco on 15/12/7.
//  Copyright © 2015年 EasyVan. All rights reserved.
//

#import "BaiduLocationManager.h"

@implementation BaiduLocationManager

@synthesize clloction,name;

static BaiduLocationManager *sharedInstance = nil;

+ (BaiduLocationManager *)sharedInstance
{
    static BaiduLocationManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}
- (id)init
{
    if (self = [super init]) {
       [self initBMKUserLocation];
    }
    return self;
}
#pragma 初始化百度地图用户位置管理类
/**
 *  初始化百度地图用户位置管理类
 */
- (void)initBMKUserLocation
{
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [self startLocation];
    
    _getGeoCode = [[BMKGeoCodeSearch alloc]init];
    _getGeoCode.delegate = self;
    
    reverseGeoCodeOption = [[BMKReverseGeoCodeOption alloc]init];
    
}
#pragma 打开定位服务
/**
 *  打开定位服务
 */
-(void)startLocation
{
    [_locService startUserLocationService];
}
#pragma 关闭定位服务

/**
 *  关闭定位服务
 */
-(void)stopLocation
{
    [_locService stopUserLocationService];
}
#pragma BMKLocationServiceDelegate
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
//- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
//{
//    cllocation = userLocation.location;
//    _clloction = cllocation;
//    _userLatitude = cllocation.coordinate.latitude;
//    _userLongitude = cllocation.coordinate.longitude;
//    [self stopLocation];//(如果需要实时定位不用停止定位服务)
//}
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    self.clloction = userLocation.location;
    
    //发起反地理编码
    CLLocationCoordinate2D pt = userLocation.location.coordinate;
    
    reverseGeoCodeOption.reverseGeoPoint = pt;
    BOOL flag = [_getGeoCode reverseGeoCode:reverseGeoCodeOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }

}
//反地理编码获取地名
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    NSArray *arr = result.poiList;
    BMKPoiInfo *infoName = arr[0];
    self.name = infoName.name;
    for (int i = 0; i<arr.count; i++) {
        BMKPoiInfo *info = arr[i];
        NSLog(@"---------------%@",info.name);
        
    }
    // NSLog(@"%@----------%@",result.address,[result.poiList firstObject].name);
}
/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser
{
    
}
/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    [self stopLocation];
}
@end
