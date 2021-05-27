//
//  GPSConvertViewController.m
//  DataHandler
//
//  Created by lbxia on 2021/5/25.
//  Copyright © 2021 LBX. All rights reserved.
//

#import "GPSConvertViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "LocationManage.h"
#import "KSCoordinateConverter.h"


@interface Service_Location_ResposeModel : NSObject
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) double longtitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, copy) NSString *country;//国家
@property (nonatomic, copy) NSString *province;//省
@property (nonatomic, copy) NSString *locality;//市
@property (nonatomic, copy) NSString *subLocality;//区

@property (nonatomic, copy) NSString *thoroughfare;//街道/路
@property (nonatomic, copy) NSString *subThoroughfare;//子街道/路
@property (nonatomic, copy) NSString *name;//名称，可能与thoroughfare以及subThoroughfare一样

//拼接地址
- (NSString*)address;

@end

@implementation Service_Location_ResposeModel




- (NSString*)address
{
    NSString *path = @"";
    NSString *tmp = self.country;
    if (tmp) {
        path = [NSString stringWithFormat:@"%@%@",path,tmp];
    }
    tmp = self.province;
    if (tmp) {
        path = [NSString stringWithFormat:@"%@%@",path,tmp];
    }
    tmp = self.locality;
    if (tmp) {
        path = [NSString stringWithFormat:@"%@%@",path,tmp];
    }
    tmp = self.subLocality;
    if (tmp) {
        path = [NSString stringWithFormat:@"%@%@",path,tmp];
    }
    tmp = self.thoroughfare;
    if (tmp) {
        path = [NSString stringWithFormat:@"%@%@",path,tmp];
    }
    tmp = self.subThoroughfare;
    if (tmp) {
        path = [NSString stringWithFormat:@"%@%@",path,tmp];
    }
    
    tmp = self.name;
    if (tmp
        && ( !self.thoroughfare || ( self.thoroughfare && ![tmp isEqualToString:self.thoroughfare] ) )
        && ( !self.subThoroughfare || ( self.subThoroughfare && ![tmp isEqualToString:self.subThoroughfare] ) ) )
    {
        path = [NSString stringWithFormat:@"%@%@",path,tmp];
    }
    
    
    return path;
}

@end

@interface GPSConvertViewController ()<MKMapViewDelegate>
@property (weak) IBOutlet MKMapView *mapView;
@property (weak) IBOutlet NSTextField *latitudeTextField;
@property (weak) IBOutlet NSTextField *longtitudeTextField;
@property (weak) IBOutlet NSTextField *labeAddress;
@property (weak) IBOutlet NSPopUpButton *mapType;

@property (nonatomic, strong) MKCircle *overlay;
@property (nonatomic, strong) MKPointAnnotation *annotation;
@end

@implementation GPSConvertViewController


//    WGS84坐标系    地球坐标系，国际通用坐标系，iOS采用
//    GCJ02坐标系    火星坐标系，WGS84坐标系加密后的坐标系；Google国内地图、高德、QQ地图 使用
//    BD09坐标系    百度坐标系，GCJ02坐标系加密后的坐标系 百度地图SDK获取的坐标
//    https://tool.lu/coordinate/ 在线转换
//https://blog.csdn.net/gudufuyun/article/details/106738942

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.mapView.delegate = self;
    
    [_mapType removeAllItems];
    
    [_mapType addItemWithTitle:@"Standard"];
    [_mapType addItemWithTitle:@"Satellite"];
    [_mapType addItemWithTitle:@"Hybrid"];
    [_mapType addItemWithTitle:@"SatelliteFlyover"];
    [_mapType addItemWithTitle:@"HybridFlyover"];
    [_mapType addItemWithTitle:@"MutedStandard"];
    
    
    self.latitudeTextField.stringValue = @"32.06757058624971";
    self.longtitudeTextField.stringValue = @"118.6524296354104";
}

- (void)convertToAddress
{
    if (@available(macOS 10.13, *))
    {
        // 获取当前所在的城市名
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:[self.latitudeTextField.stringValue doubleValue] longitude:[self.longtitudeTextField.stringValue doubleValue]];
        
        NSLocale *zhLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        
        [geocoder reverseGeocodeLocation:currentLocation preferredLocale:zhLocale completionHandler:^(NSArray<CLPlacemark *> * _Nullable array, NSError * _Nullable error) {
            
            if (array.count > 0)
            {
                CLPlacemark *place = [array objectAtIndex:0];
                
                NSLog(@"%@",place.addressDictionary);
                
                Service_Location_ResposeModel *resModel = [[Service_Location_ResposeModel alloc]init];
                resModel.country = place.country;
                resModel.province = place.administrativeArea;
                
                resModel.locality = place.locality;//市
                resModel.subLocality = place.subLocality;//区
                
                resModel.thoroughfare = place.thoroughfare;//路
                resModel.subThoroughfare = place.subThoroughfare;//子路
                resModel.name = place.name;//名称，可能和thoroughfare或subThoroughfare名字一样
                
                NSString* address =  [resModel address];

                    
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.labeAddress.stringValue = address;
                });
            }
            else
            {
                
            }
        }];
    }
    
}

- (IBAction)place:(id)sender {
    
    
    [self convertToAddress];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([self.latitudeTextField.stringValue doubleValue], [self.longtitudeTextField.stringValue doubleValue]);
    
    //gps转换火星坐标  https://github.com/skx926/KSCoordinateConverter
    center = [KSCoordinateConverter marsCoordinateFromGPSCoordinate:center];
    
    MKCoordinateSpan span =MKCoordinateSpanMake(0.2, 0.2);

    
    self.mapView.region = MKCoordinateRegionMake(center, span);
    
    
    self.mapView.mapType = (NSUInteger)_mapType.indexOfSelectedItem;
//
//    //向地址增加标记

    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    
    annotation.coordinate = center;
    
    annotation.title = @"当前大约位置";

//    annotation.subtitle = ""

    if (self.annotation) {
        [self.mapView removeAnnotation:self.annotation];
    }
    
    [self.mapView addAnnotation:annotation];
    self.annotation = annotation;
//
//    //创建一个新的圆形覆盖物

    MKCircle *overlay = [MKCircle circleWithCenterCoordinate:center radius:5000];
    
    if (self.overlay) {
        [self.mapView removeOverlay:self.overlay];

    }
    
    self.overlay = overlay;
    
    [self.mapView addOverlay:overlay];
}

- (void)placeWithLatitude:(double)latitidue longtitude:(double)longtitude
{
    NSNumber *dn_lati = [NSNumber numberWithDouble:latitidue];
    NSNumber *dn_longti = [NSNumber numberWithDouble:longtitude];

    
    self.latitudeTextField.stringValue = [dn_lati stringValue];
    self.longtitudeTextField.stringValue = [dn_longti stringValue];
    
    [self place:nil];
}

- (IBAction)placeCurPos:(id)sender
{
    [[LocationManage sharedManager]startGps:^(CLLocation *currentLocation) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CLLocationCoordinate2D coordinate = [currentLocation coordinate];
            
            //mapview采用的高德地图，GPS坐标系与高德地图坐标系不一致，显示的和苹果电脑定位位置有出入
            //https://blog.csdn.net/gudufuyun/article/details/106738942
            [self placeWithLatitude:coordinate.latitude longtitude:coordinate.longitude];
        });
        
    } fail:^(NSError *error) {
        
    }];
}

//覆盖物
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
//    let circleRenderer = MKCircleRenderer(overlay: overlay)
    
    MKCircleRenderer *circleRenderer =[[MKCircleRenderer alloc]initWithOverlay:overlay];
//
//    circleRenderer.strokeColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 0.5)
    
    circleRenderer.strokeColor = [NSColor colorWithRed:74/255. green:144/255. blue:226/255. alpha:0.2];
//
//    circleRenderer.fillColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 0.5)
    
    circleRenderer.fillColor = [NSColor colorWithRed:74/255. green:144/255. blue:226/255. alpha:0.2];
//
    return circleRenderer;
}

@end
