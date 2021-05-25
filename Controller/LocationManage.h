//
//  LocationManage.h
//  DataHandler
//
//  Created by lbxia on 2021/5/25.
//  Copyright © 2021 LBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface LocationManage : NSObject<CLLocationManagerDelegate>

//存储Gps坐标，短时间内容，建议直接使用该坐标即可
@property(nonatomic,assign)double longtitude;
@property(nonatomic,assign)double latitude;

@property(nonatomic,strong) CLLocationManager *locationManager;

@property(nonatomic,copy)void(^success)(CLLocation* currentLocation);

@property(nonatomic,copy)void(^fail)(NSError* error);

/**
 @brief  单例
 @return 单例对象
 */
+ (instancetype)sharedManager;


/**
 @brief 系统GPS是否开启
 @return 状态
 */
+ (BOOL)isLocationServicesEnabled;



/**
 @brief 定位获取GPS坐标,返回GPS坐标后如果需要关闭GPS，请调用 stopGps 方法
 @param success 成功
 @param fail    失败
 */
- (void)startGps:(void(^)(CLLocation* currentLocation))success fail:(void(^)(NSError* error))fail;


/**
 @brief 转换GPS->地点
 @param currentLocation 当前坐标
 @param success         返回结果
 
 NSLog(@"name,%@",place.name);                       // 位置名,地址
 NSLog(@"thoroughfare,%@",place.thoroughfare);       // 街道
 NSLog(@"subThoroughfare,%@",place.subThoroughfare); // 子街道
 NSLog(@"locality,%@",place.locality);               // 市
 NSLog(@"subLocality,%@",place.subLocality);         // 区
 NSLog(@"country,%@",place.country);                 // 国家
 
 @param fail  转换失败
 */
+ (void)converseGps:(CLLocation*) currentLocation
            success:(void (^)(CLPlacemark *place))success
               fail:(void(^)(NSError* error))fail;


/**
 @brief  关闭GPS
 */
- (void)stopGps;


@end
