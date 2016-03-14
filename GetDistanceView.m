//
//  GetDistanceView.m
//  EasyVanDriver
//
//  Created by coco on 16/1/14.
//  Copyright © 2016年 EasyVan. All rights reserved.
//

#import "GetDistanceView.h"

@implementation GetDistanceView
- (id)initWithLat:(float)lat andLng:(float)lng withOrderID:(NSString *)orderID
{
    self = [super init];
    if (self) {
        self.orderID = orderID;
        [self convertToBaiDuLat:lat andLong:lng];
        [self initUI];
    }
    return self;
}
- (void)initUI
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    self.distanceLab = label;
    label.textColor = hllNormalMiddelGrayTextColor;
    [self addSubview:label];
    NSString *str =  [[NSUserDefaults standardUserDefaults]objectForKey:self.orderID];
    if (str.length) {
        int distance = [str intValue];
        if (distance > 1000){
            self.distanceLab.text = [NSString stringWithFormat:@"距您约%.1f公里",distance/1000.0f];
            if (distance/1000.0f>9000) {
                self.distanceLab.text = @"";
            }
        }else{
            self.distanceLab.text = [NSString stringWithFormat:@"距您约%d米",distance];
        }
        [_locService stopUserLocationService];
    }else{
        //初始化检索对象
        _searcher = [[BMKRouteSearch alloc]init];
        _searcher.delegate = self;
        
        //初始化BMKLocationService
        _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
        //启动LocationService
        [_locService startUserLocationService];
        //设置定位精确度
        _locService.desiredAccuracy = 10.0;
    }
}
#pragma mark -- 发起路线检索
- (void)startRouteSearch
{
    //目的经纬度
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = self.lat;
    annotationCoord.longitude = self.lng;
    //发起检索
    //司机经纬度位置
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.pt = driverCoor;
    //起或中或终点经纬度位置
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.pt = annotationCoord;
    BMKDrivingRoutePlanOption *transitRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    transitRouteSearchOption.drivingPolicy = BMK_DRIVING_DIS_FIRST;
    transitRouteSearchOption.from = start;
    transitRouteSearchOption.to = end;
    
    BOOL flag = [_searcher drivingSearch:transitRouteSearchOption];
    if(flag)
    {
        NSLog(@"路线检索发送成功");
    }
    else
    {
        NSLog(@"路线检索发送失败");
    }
}

#pragma mark -- 驾车路线检索结果回调
-(void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        BMKDrivingRouteLine *plan = [result.routes firstObject];
        NSString *distance = [NSString stringWithFormat:@"%d",plan.distance];
        [[NSUserDefaults standardUserDefaults]setObject:distance forKey:self.orderID];
        [[NSUserDefaults standardUserDefaults]synchronize];
        if (plan.distance > 1000){
            self.distanceLab.text = [NSString stringWithFormat:@"距您约%.1f公里",plan.distance/1000.0f];
            if (plan.distance/1000.0f>9000) {
                self.distanceLab.text = @"";
            }
        }else{
            self.distanceLab.text = [NSString stringWithFormat:@"距您约%d米",plan.distance];
        }
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        //当路线起终点有歧义时通，获取建议检索起终点
        //result.routeAddrResult
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}
#pragma mark -- 国际坐标转换百度坐标
- (void)convertToBaiDuLat:(float)lat andLong:(float)longitude
{
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(lat, longitude);//原始坐标
    //转换 google地图、soso地图、aliyun地图、mapabc地图和amap地图所用坐标至百度坐标
    NSDictionary* testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_COMMON);
    //转换GPS坐标至百度坐标(加密后的坐标)
    testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
    //解密加密后的坐标字典
    CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(testdic);//转换后的百度坐标
    
    self.lat = baiduCoor.latitude;
    self.lng = baiduCoor.longitude;
}
//定位
//实现相关delegate 处理位置信息
#pragma mark -- 定位回调
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    double driverLat = userLocation.location.coordinate.latitude;
    double driverLng = userLocation.location.coordinate.longitude;
    driverCoor = CLLocationCoordinate2DMake(driverLat, driverLng);
    NSString *str =  [[NSUserDefaults standardUserDefaults]objectForKey:self.orderID];
    if (str.length) {
        return;
    }else{
        [self startRouteSearch];
    }
}

@end
