//
//  BaiduLocationManager.h
//  EasyVanDriver
//
//  Created by coco on 15/12/7.
//  Copyright © 2015年 EasyVan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

@interface BaiduLocationManager : NSObject<BMKMapViewDelegate,BMKPoiSearchDelegate,BMKLocationServiceDelegate,BMKRouteSearchDelegate>
{
    BMKLocationService *_locService;
    CLLocation *cllocation;
    BMKGeoCodeSearch   *_getGeoCode;
    BMKReverseGeoCodeOption *reverseGeoCodeOption;//逆地理编码
}
//城市名
@property (strong,nonatomic) NSString *name;

//用户纬度
@property (nonatomic,assign) double userLatitude;

//用户经度
@property (nonatomic,assign) double userLongitude;

//用户位置
@property (strong,nonatomic) CLLocation *clloction;


//初始化单例
+ (BaiduLocationManager *)sharedInstance;

//初始化百度地图用户位置管理类
- (void)initBMKUserLocation;

//开始定位
-(void)startLocation;

//停止定位
-(void)stopLocation;

@end
