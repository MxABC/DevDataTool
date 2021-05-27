//
//  KSGeometry.m
//  KSGeometry
//
//  Created by Kyle Sun on 19/12/2016.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import "KSCoordinateConverter.h"
#include <math.h>
//#import <UIKit/UIKit.h>

const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;

void bd_encrypt(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon)
{
    double x = gg_lon, y = gg_lat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    *bd_lon = z * cos(theta) + 0.0065;
    *bd_lat = z * sin(theta) + 0.006;
}

void bd_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon)
{
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    *gg_lon = z * cos(theta);
    *gg_lat = z * sin(theta);
}

@implementation KSCoordinateConverter

+ (CLLocationCoordinate2D)bdCoordinateFromGPSCoordinate:(CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D marsCoordinate = [self marsCoordinateFromGPSCoordinate:coordinate];
	return [self bdCoordinateFromMarsCoordinate:marsCoordinate];
}

+ (CLLocationCoordinate2D)gpsCoordinateFromBDCoordinate:(CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D marsCoordinate = [self marsCoordinateFromBDCoordinate:coordinate];
    return [self gpsCoordinateFromMarsCoordinate:marsCoordinate];
}

+ (CLLocationCoordinate2D)gpsCoordinateFromMarsCoordinate:(CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D marsCoordinate = [self marsCoordinateFromGPSCoordinate:coordinate];
    double latitude = marsCoordinate.latitude - coordinate.latitude;
    double longitude = marsCoordinate.longitude - coordinate.longitude;
    latitude = coordinate.latitude - latitude;
    longitude = coordinate.longitude - longitude;

    return CLLocationCoordinate2DMake(latitude, longitude);
}

+ (CLLocationCoordinate2D)marsCoordinateFromGPSCoordinate:(CLLocationCoordinate2D)coordinate {

    const double a = 6378245.0;
    const double ee = 0.00669342162296594323;

    if ([self isLocationOutOfChina:coordinate])  {
        return coordinate;
    }

    double dLat = [self transformLatitudeWithX:coordinate.longitude - 105.0 andY:coordinate.latitude - 35.0];
    double dLon = [self transformLongitudeWithX:coordinate.longitude - 105.0 andY:coordinate.latitude - 35.0];
    double radLat = coordinate.latitude / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    coordinate.latitude = coordinate.latitude + dLat;
    coordinate.longitude = coordinate.longitude + dLon;

    return coordinate;
}

+ (CLLocationCoordinate2D)bdCoordinateFromMarsCoordinate:(CLLocationCoordinate2D)coordinate {
	double latitude, longitude;
    bd_encrypt(coordinate.latitude, coordinate.longitude, &latitude, &longitude);
    return CLLocationCoordinate2DMake(latitude, longitude);
}

+ (CLLocationCoordinate2D)marsCoordinateFromBDCoordinate:(CLLocationCoordinate2D)coordinate {
	double latitude, longitude;
    bd_decrypt(coordinate.latitude, coordinate.longitude, &latitude, &longitude);
	return CLLocationCoordinate2DMake(latitude, longitude);
}

+ (double)transformLatitudeWithX:(double)x andY:(double)y {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

+ (double)transformLongitudeWithX:(double)x andY:(double)y {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

/**
 *  判断是不是在中国
 *  用引射线法判断 点是否在多边形内部
 *  算法参考：http://www.cnblogs.com/luxiaoxun/p/3722358.html
 */

+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location {
    CGPoint point = CGPointMake(location.latitude, location.longitude);
    BOOL oddFlag = NO;
    NSInteger j = [self polygonOfChina].count - 1;
    for (NSInteger i = 0; i < [self polygonOfChina].count; i++) {
        CGPoint polygonPointi = [[self polygonOfChina][i] pointValue];
        CGPoint polygonPointj = [[self polygonOfChina][j] pointValue];
        if (((polygonPointi.y < point.y && polygonPointj.y >= point.y) ||
             (polygonPointj.y < point.y && polygonPointi.y >= point.y)) &&
            (polygonPointi.x <= point.x || polygonPointj.x <= point.x)) {
            oddFlag ^= (polygonPointi.x +
                        (point.y - polygonPointi.y) /
                        (polygonPointj.y - polygonPointi.y) *
                        (polygonPointj.x - polygonPointi.x) <
                        point.x);
        }
        j = i;
    }
    return !oddFlag;
}

//  中国大陆多边形，用于判断坐标是否在中国
//  因为港澳台地区使用WGS-84坐标，所以多边形不包含港澳台地区
+ (NSMutableArray *)polygonOfChina {
    static NSMutableArray *polygonOfChina = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        polygonOfChina = [[NSMutableArray alloc] init];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(49.1506690000,
                                                         87.4150810000)]];
        
        
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(48.3664501790,
                                                         85.7527085300)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(47.0253058185,
                                                         85.3847443554)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(45.2406550000,
                                                         82.5214000000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(44.8957121295,
                                                         79.9392351487)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(43.1166843846,
                                                         80.6751253982)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(41.8701690000,
                                                         79.6882160000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(39.2896190000,
                                                         73.6171080000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(34.2303430000,
                                                         78.9155300000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(31.0238860000,
                                                         79.0627080000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(27.9989800000,
                                                         88.7028920000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(27.1793590000,
                                                         88.9972480000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(28.0969170000,
                                                         89.7331400000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(26.9157800000,
                                                         92.1615830000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(28.1947640000,
                                                         96.0986050000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(27.4094760000,
                                                         98.6742270000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(23.9085500000,
                                                         97.5703890000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(24.0775830000,
                                                         98.7846100000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(22.1375640000,
                                                         99.1893510000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(21.1398950000,
                                                         101.7649720000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(22.2746220000,
                                                         101.7281780000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(23.2641940000,
                                                         105.3708430000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(22.7191200000,
                                                         106.6954480000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(21.9945711661,
                                                         106.7256731791)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(21.4847050000,
                                                         108.0200530000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(20.4478440000,
                                                         109.3814530000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(18.6689850000,
                                                         108.2408210000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(17.4017340000,
                                                         109.9333720000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(19.5085670000,
                                                         111.4051560000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(21.2716775175,
                                                         111.2514995205)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(21.9936323233,
                                                         113.4625292629)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(22.1818312942,
                                                         113.4258358111)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(22.2249729295,
                                                         113.5913115000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(22.4501912753,
                                                         113.8946844490)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(22.5959159322,
                                                         114.3623797842)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(22.4334610000,
                                                         114.5194740000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(22.9680954377,
                                                         116.8326939975)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(25.3788220000,
                                                         119.9667980000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(28.3261276204,
                                                         121.7724402562)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(31.9883610000,
                                                         123.8808230000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(39.8759700000,
                                                         124.4695370000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(41.7350890000,
                                                         126.9531720000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(41.5142160000,
                                                         128.3145720000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(42.9842081790,
                                                         131.0676468344)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(45.2690810000,
                                                         131.8468530000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(45.0608370000,
                                                         133.0610740000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(48.4480260000,
                                                         135.0111880000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(48.0054800000,
                                                         131.6628800000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(50.2270740000,
                                                         127.6890640000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(53.3516070000,
                                                         125.3710040000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(53.4176040000,
                                                         119.9254040000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(47.5590810000,
                                                         115.1421070000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(47.1339370000,
                                                         119.1159230000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(44.8256460000,
                                                         111.2786750000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(42.5293560000,
                                                         109.2549720000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(43.2598160000,
                                                         97.2967290000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(45.4247620000,
                                                         90.9680590000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(47.8075570000,
                                                         90.6737020000)]];
        [polygonOfChina
         addObject:[NSValue valueWithPoint:CGPointMake(49.1506690000,
                                                         87.4150810000)]];
    });
    return polygonOfChina;
}

@end
