//
//  LocationManage.m
//  DataHandler
//
//  Created by lbxia on 2021/5/25.
//  Copyright © 2021 LBX. All rights reserved.
//

#import "LocationManage.h"



@implementation LocationManage


+ (instancetype)sharedManager
{
    static LocationManage* _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LocationManage alloc] init];
    });
    
    return _sharedInstance;
}

+ (BOOL)isLocationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}


- (BOOL)isGpsPermissionDenied
{
    if ((![CLLocationManager locationServicesEnabled])
        || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied))
    {
        return YES;
    }
    
    return NO;
}


//GPS
- (void)startGps:(void(^)(CLLocation* currentLocation))success fail:(void(^)(NSError* error))fail
{
    self.success = nil;
    self.fail = nil;
 
    if (![[self class]isLocationServicesEnabled] || [self isGpsPermissionDenied] ) {
        
         if (fail) {
            fail(nil);
        }
        return;
    }

    
    self.success = success;
    self.fail = fail;
    
    [self startGps];
}

- (void)startGps
{
    
    if ( self.locationManager != nil ) {
        [self stopGps];
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
    
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        BOOL hasAlwaysKey = [[NSBundle mainBundle]
                             objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
        BOOL hasWhenInUseKey =
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] !=
        nil;
        
        BOOL hasAwaysOrInUse =   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"] !=
        nil;
        
        if (@available(macOS 10.15, *))
        {
            if (hasAlwaysKey || hasAwaysOrInUse) {
                [_locationManager requestAlwaysAuthorization];
            } else if (hasWhenInUseKey) {
                [_locationManager requestWhenInUseAuthorization];
            }
        }
    }
    
    [self.locationManager startUpdatingLocation];
}

- (void)stopGps
{
    if ( self.locationManager )
    {
        [_locationManager stopUpdatingLocation];
        self.locationManager = nil;
        
        self.success = nil;
        self.fail = nil;
    }
}

//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation
//{
//    //CLLocationCoordinate2D coordinate = [newLocation coordinate];
//
//   //调用者负责停止GPS
//   // [self stopGps];
//
//    CLLocationCoordinate2D coordinate = [newLocation coordinate];
//    _latitude = coordinate.latitude;
//    _longtitude = coordinate.longitude;
//
//    NSLog(@"%f,%f",_longtitude,_latitude);
//
//    if (_success)
//    {
//        _success(newLocation);
//    }
//}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *mostRecentLocation = [locations lastObject];
    
    
    CLLocationCoordinate2D coordinate = [mostRecentLocation coordinate];
    _latitude = coordinate.latitude;
    _longtitude = coordinate.longitude;
    
    NSLog(@"%f,%f",_longtitude,_latitude);
    
    if (_success)
    {
        _success(mostRecentLocation);
    }
}


////------------------位置反编码---5.0之后使用-----------------
//CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//[geocoder reverseGeocodeLocation:newLocation
//               completionHandler:^(NSArray *placemarks, NSError *error){
//
//                   for (CLPlacemark *place in placemarks) {
//                       UILabel *label = (UILabel *)[self.window viewWithTag:101];
//                       label.text = place.name;
//                       NSLog(@"name,%@",place.name);                       // 位置名
//                       //                           NSLog(@"thoroughfare,%@",place.thoroughfare);       // 街道
//                       //                           NSLog(@"subThoroughfare,%@",place.subThoroughfare); // 子街道
//                       //                           NSLog(@"locality,%@",place.locality);               // 市
//                       //                           NSLog(@"subLocality,%@",place.subLocality);         // 区
//                       //                           NSLog(@"country,%@",place.country);                 // 国家
//                   }
//
//               }];

/**
 @brief 转换GPS->城市名称
 @param currentLocation 当前坐标
 @param success         返回结果
 */
+ (void)converseGps:(CLLocation*) currentLocation
         success:(void (^)(CLPlacemark *placemark))success
               fail:(void(^)(NSError* error))fail
{
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    if (@available(macOS 10.13,*)) {
        
        NSLocale *zhLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];

        [geocoder reverseGeocodeLocation:currentLocation preferredLocale:zhLocale completionHandler:^(NSArray<CLPlacemark *> * _Nullable array, NSError * _Nullable error) {
            
            if (array.count > 0)
            {
                CLPlacemark *placemark = [array objectAtIndex:0];
                                
                if (success) {
                    success(placemark);
                }
            }
            else
            {
                if (fail) {
                    fail(error);
                }
            }
        }];
    }
    else
    {
        // 强制 成 简体中文
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-hans",nil]
                                                  forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        //根据经纬度反向地理编译出地址信息
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
         {
            if (array.count > 0)
            {
                CLPlacemark *placemark = [array objectAtIndex:0];
                
                if (success) {
                    success(placemark);
                }
            }
            else
            {
                if (fail) {
                    fail(error);
                }
            }
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"GPS error:%@",error);
    
    if (_fail) {
        _fail(error);
    }
}
@end
