//
//  KSGeometry.h
//  KSGeometry
//
//  Created by Kyle Sun on 19/12/2016.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface KSCoordinateConverter : NSObject

/**
 GPS坐标（WGS-84）转火星坐标（GCJ-02）

 @param coordinate GPS坐标（WGS-84）
 @return 火星坐标（GCJ-02）
 */
+ (CLLocationCoordinate2D)marsCoordinateFromGPSCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 火星坐标（GCJ-02）转GPS坐标（WGS-84）

 @param coordinate 火星坐标（GCJ-02）
 @return GPS坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)gpsCoordinateFromMarsCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 GPS坐标（WGS-84）转百度坐标（BD-09）

 @param coordinate GPS坐标（WGS-84）
 @return 百度坐标（BD-09）
 */
+ (CLLocationCoordinate2D)bdCoordinateFromGPSCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 百度坐标（BD-09）转GPS坐标（WGS-84）

 @param coordinate 百度坐标（BD-09）
 @return GPS坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)gpsCoordinateFromBDCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 火星坐标（GCJ-02）转百度坐标（BD-09）

 @param coordinate 火星坐标（GCJ-02）
 @return 百度坐标（BD-09）
 */
+ (CLLocationCoordinate2D)bdCoordinateFromMarsCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 百度坐标（BD-09）转火星坐标（GCJ-02）

 @param coordinate 百度坐标（BD-09）
 @return 火星坐标（GCJ-02）
 */
+ (CLLocationCoordinate2D)marsCoordinateFromBDCoordinate:(CLLocationCoordinate2D)coordinate;

@end
