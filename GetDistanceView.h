//
//  GetDistanceView.h
//  EasyVanDriver
//
//  Created by coco on 16/1/14.
//  Copyright © 2016年 EasyVan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

@interface GetDistanceView : UIView<BMKMapViewDelegate,BMKPoiSearchDelegate,BMKLocationServiceDelegate,BMKRouteSearchDelegate,BMKGeoCodeSearchDelegate>
{
    BMKLocationService *_locService;
    BMKRouteSearch     *_searcher;
    CLLocationCoordinate2D   driverCoor;
}
@property (nonatomic,assign)float lat;
@property (nonatomic,assign)float lng;
@property (nonatomic,strong)NSString * orderID;
@property (nonatomic,strong)UILabel  *distanceLab;

- (id)initWithLat:(float)lat andLng:(float)lng withOrderID:(NSString *)orderID;//初始化传入经纬度
@end
