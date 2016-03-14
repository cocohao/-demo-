//
//  BaiduMapVC.m
//  EasyVanDriver
//
//  Created by coco on 15/12/4.
//  Copyright © 2015年 EasyVan. All rights reserved.
//

#import "BaiduMapVC.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件
#import "UIImage+Heaven.h"

@interface BaiduMapVC ()<BMKMapViewDelegate,BMKPoiSearchDelegate,BMKLocationServiceDelegate,BMKRouteSearchDelegate,BMKGeoCodeSearchDelegate>
{
    BMKMapView         * _mapView;
    BMKLocationService *_locService;
    BMKRouteSearch     *_searcher;
    //BMKGeoCodeSearch   *_getGeoCode;
    //BMKReverseGeoCodeOption *reverseGeoCodeOption;//逆地理编码
    BMKPointAnnotation *driverAnnotationPoint;
    BMKPointAnnotation *startAnnotationPoint;
    BMKPointAnnotation *midAnnotationPoint;
    BMKPointAnnotation *endAnnotationPoint;
    float addressLat;
    float addressLng;

}
@end

@implementation BaiduMapVC
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    //[_locService stopUserLocationService];
    _mapView.delegate = nil; // 不用时，置nil
   // _searcher.delegate = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"地图";
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.frame];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
//    _getGeoCode = [[BMKGeoCodeSearch alloc]init];
//    _getGeoCode.delegate = self;
//    
//    reverseGeoCodeOption = [[BMKReverseGeoCodeOption alloc]init];

    //设置地图显示精度
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = addressLat;
    annotationCoord.longitude = addressLng;
    BMKCoordinateRegion region ;
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;
    region.center = annotationCoord;
    [_mapView setRegion:region animated:YES];

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
    
   [self creatAnnotation];
}
#pragma mark -- 司机及起始中标记创建
- (void)creatAnnotation
{
    NSArray *adressArr = self.orderDetailObject.exactAddrArr;
    //司机位置
    driverAnnotationPoint = [[BMKPointAnnotation alloc] init];
    [_mapView addAnnotation:driverAnnotationPoint];
    //起点位置
    float lat = [self.orderDetailObject getLatitudeOfIndex:0];
    float lng = [self.orderDetailObject getLongitudeOfIndex:0];
    
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(lat, lng);//原始坐标
    //转换 google地图、soso地图、aliyun地图、mapabc地图和amap地图所用坐标至百度坐标
    NSDictionary* testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_COMMON);
    //转换GPS坐标至百度坐标(加密后的坐标)
    testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
    
    //解密加密后的坐标字典
    CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(testdic);//转换后的百度坐标
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = baiduCoor.latitude;
    annotationCoord.longitude = baiduCoor.longitude;
    startAnnotationPoint = [[BMKPointAnnotation alloc]init];
    startAnnotationPoint.coordinate = annotationCoord;
    [_mapView addAnnotation:startAnnotationPoint];
    
    //中点位置
    if (self.addressCount!=0&&self.addressCount!=adressArr.count-1) {
        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude = addressLat;
        annotationCoord.longitude = addressLng;
        midAnnotationPoint = [[BMKPointAnnotation alloc]init];
        midAnnotationPoint.coordinate = annotationCoord;
        [_mapView addAnnotation:midAnnotationPoint];
    }
    
    //终点位置
    if (self.addressCount == adressArr.count-1) {
        CLLocationCoordinate2D annotationCoordend;
        annotationCoordend.latitude = addressLat;
        annotationCoordend.longitude = addressLng;
        endAnnotationPoint = [[BMKPointAnnotation alloc]init];
        endAnnotationPoint.coordinate = annotationCoordend;
        [_mapView addAnnotation:endAnnotationPoint];
    }
    //当地址超过两个时,点击终点也要同时显示中点标注
    if (self.addressCount == adressArr.count-1&&adressArr.count>2) {
        float lat = [self.orderDetailObject getLatitudeOfIndex:self.addressCount-1];
        float lng = [self.orderDetailObject getLongitudeOfIndex:self.addressCount-1];
        
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(lat, lng);//原始坐标
        //转换 google地图、soso地图、aliyun地图、mapabc地图和amap地图所用坐标至百度坐标
        NSDictionary* testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_COMMON);
        //转换GPS坐标至百度坐标(加密后的坐标)
        testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
        
        //解密加密后的坐标字典
        CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(testdic);//转换后的百度坐标
        
        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude = baiduCoor.latitude;
        annotationCoord.longitude = baiduCoor.longitude;
        midAnnotationPoint = [[BMKPointAnnotation alloc]init];
        midAnnotationPoint.coordinate = annotationCoord;
        [_mapView addAnnotation:midAnnotationPoint];

    }
   
}
#pragma mark -- 发起路线检索
- (void)startRouteSearch
{

    //目的经纬度
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = addressLat;
    annotationCoord.longitude = addressLng;
    //发起检索
    //司机经纬度位置
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.pt = driverAnnotationPoint.coordinate;
    //起或中或终点经纬度位置
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.pt = annotationCoord;
    BMKDrivingRoutePlanOption *transitRouteSearchOption =         [[BMKDrivingRoutePlanOption alloc]init];
    transitRouteSearchOption.drivingPolicy = BMK_DRIVING_DIS_FIRST;
    transitRouteSearchOption.from = start;
    transitRouteSearchOption.to = end;
    
    
    BOOL flag = [_searcher drivingSearch:transitRouteSearchOption];
    if(flag)
    {
        NSLog(@"bus检索发送成功");
    }
    else
    {
        NSLog(@"bus检索发送失败");
    }

}

#pragma mark -- 驾车路线检索结果回调
-(void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)[result.routes lastObject];
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:i];
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
       
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        //当路线起终点有歧义时通，获取建议检索起终点
        //result.routeAddrResult
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
    
}
#pragma mark -- 在处理路径回调中处理路径的显示
-(BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id )overlay
{
    
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay] ;
        polylineView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = 5.0;
        
        return polylineView;
    }
    return nil;
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
    NSLog(@"lat=%f,lng=%f",baiduCoor.latitude,baiduCoor.longitude);
    
    addressLat = baiduCoor.latitude;
    addressLng = baiduCoor.longitude;
    
}
//定位
//实现相关delegate 处理位置信息
#pragma mark -- 定位回调
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    _mapView.showsUserLocation = YES;

//    //发起反地理编码
//    
//    CLLocationCoordinate2D pt = userLocation.location.coordinate;
//    
//    reverseGeoCodeOption.reverseGeoPoint = pt;
//    BOOL flag = [_getGeoCode reverseGeoCode:reverseGeoCodeOption];
//    if(flag)
//    {
//        NSLog(@"反geo检索发送成功");
//    }
//    else
//    {
//        NSLog(@"反geo检索发送失败");
//    }

    driverAnnotationPoint.coordinate = userLocation.location.coordinate;
    [self startRouteSearch];

}

//- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
//{
//    
//    NSArray *arr = result.poiList;
//    for (int i = 0; i<arr.count; i++) {
//        BMKPoiInfo *info = arr[i];
//        NSLog(@"---------------%@",info.name);
//
//    }
//   // NSLog(@"%@----------%@",result.address,[result.poiList firstObject].name);
//    
//}
#pragma mark -- 返回各种点的标注图
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
      static NSString *EVDriverAnnotationIdentifier = @"EVDriverAnnotationIdentifier";
     static NSString *startAnnotationIdentifier = @"startAnnotationIdentifier";
    static NSString *midAnnotationIdentifier = @"midAnnotationIdentifier";
    static NSString *endAnnotationIdentifier = @"endAnnotationIdentifier";
    BMKAnnotationView *newAnnotationView;
    UIImage *pinImage;
    
    if (annotation == driverAnnotationPoint) {
        newAnnotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:EVDriverAnnotationIdentifier];
        pinImage = [UIImage imageNamed:@"pin_driver"];
        newAnnotationView.image = pinImage;
        [newAnnotationView setFrame:CGRectMake(0, 0, 35, 35)];
        
    }
    if (annotation == startAnnotationPoint) {
        newAnnotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:startAnnotationIdentifier];
        pinImage = [UIImage imageNamed:@"ic_map_start"];
        newAnnotationView.image = pinImage;
        [newAnnotationView setFrame:CGRectMake(0, 0, 35, 35)];
        if (self.addressCount == 0)
        {
            UIImage *tempImage = [UIImage stretchableWithImage:@"map_shadow_white.png" xPos:0.1 yPos:0.2];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:[self.orderDetailObject.exactAddrArr[self.addressCount] objectForKey:@"address"] forState:UIControlStateNormal];
            [button setTitleColor:hllNormalMiddelGrayTextColor forState:UIControlStateNormal];
            [button setBackgroundImage:tempImage forState:UIControlStateNormal];
            button.titleEdgeInsets = UIEdgeInsetsMake(-8, 0, 0, 0);
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            button.titleLabel.numberOfLines = 0;
            button.center = CGPointMake(newAnnotationView.frame.size.width*0.5, -button.bounds.size.height*0.5-15-20);
            button.bounds = CGRectMake(0, 0, SCREEN_WIDTH - 70,70);
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [newAnnotationView addSubview:button];
        }
    }
    if (annotation == midAnnotationPoint) {
        newAnnotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:midAnnotationIdentifier];
        pinImage = [UIImage imageNamed:@"ic_map_waypt_new"];
        newAnnotationView.image = pinImage;
        [newAnnotationView setFrame:CGRectMake(0, 0, 35, 35)];
        if (self.addressCount!=0&&self.addressCount!=self.orderDetailObject.exactAddrArr.count-1){
        UIImage *tempImage = [UIImage stretchableWithImage:@"map_shadow_white.png" xPos:0.1 yPos:0.2];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[self.orderDetailObject.exactAddrArr[self.addressCount] objectForKey:@"address"] forState:UIControlStateNormal];
        [button setTitleColor:hllNormalMiddelGrayTextColor forState:UIControlStateNormal];
        [button setBackgroundImage:tempImage forState:UIControlStateNormal];
        button.titleEdgeInsets = UIEdgeInsetsMake(-8, 0, 0, 0);
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.titleLabel.numberOfLines = 0;
        button.center = CGPointMake(newAnnotationView.frame.size.width*0.5, -button.bounds.size.height*0.5-15-20);
        button.bounds = CGRectMake(0, 0, SCREEN_WIDTH - 70,70);
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [newAnnotationView addSubview:button];
        }

    }
    if (annotation == endAnnotationPoint) {
        newAnnotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:endAnnotationIdentifier];
        pinImage = [UIImage imageNamed:@"ic_map_end"];
        newAnnotationView.image = pinImage;
        [newAnnotationView setFrame:CGRectMake(0, 0, 35, 35)];
        
        if (self.addressCount == self.orderDetailObject.exactAddrArr.count-1) {
            UIImage *tempImage = [UIImage stretchableWithImage:@"map_shadow_white.png" xPos:0.1 yPos:0.2];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:[self.orderDetailObject.exactAddrArr[self.addressCount] objectForKey:@"address"] forState:UIControlStateNormal];
            [button setTitleColor:hllNormalMiddelGrayTextColor forState:UIControlStateNormal];
            [button setBackgroundImage:tempImage forState:UIControlStateNormal];
            button.titleEdgeInsets = UIEdgeInsetsMake(-8, 0, 0, 0);
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            button.titleLabel.numberOfLines = 0;
            button.center = CGPointMake(newAnnotationView.frame.size.width*0.5, -button.bounds.size.height*0.5-15-20);
            button.bounds = CGRectMake(0, 0, SCREEN_WIDTH - 70,70);
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [newAnnotationView addSubview:button];
        }
    }

    

    return newAnnotationView;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
