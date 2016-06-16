//
//  ViewController.m
//  download
//
//  Created by natsu on 16/1/25.
//  Copyright © 2016年 natsu. All rights reserved.
//

#import "ViewController.h"
#import "Area+CoreDataProperties.h"
#import "Province+CoreDataProperties.h"
#import "City+CoreDataProperties.h"
#import "CoreDataManager.h"

#define defaultURL @"http://moenatsu.github.io/store/city.txt"

@interface ViewController () <NSURLSessionDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickView;

@property (strong, nonatomic) NSMutableArray *provinces;

@property (strong, nonatomic) NSMutableArray *cities;

@property (strong, nonatomic) NSMutableArray *areas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pickView.dataSource = self;
    self.pickView.delegate = self;
    
    self.provinces = [NSMutableArray new];
    self.cities = [NSMutableArray new];
    self.areas = [NSMutableArray new];
    
    NSString *path = NSHomeDirectory();
    
    NSString *fullPath = [NSString stringWithFormat:@"%@/Documents/model.sqlite",path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        [self loadData];
        if (self.provinces.count == 0) {
            [self loadDataFromNet];
        }
    }
    else {
        [self loadDataFromNet];
    }
    
    
}

- (void)loadDataFromNet {
    NSURL *url = [NSURL URLWithString:defaultURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        if (err) {
            NSLog(@"err=%@",err);
        }
        
        [self savaData:dic];
        [self loadData];
//        NSLog(@"dic=%@",[NSString stringWithCString:[dic.description cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding]);
        
    }];
    [task resume];
}

- (void)savaData:(NSDictionary *)dic {
    
    NSArray *cities = dic[@"city"];
    NSArray *provinces = dic[@"pro"];
    NSArray *areas = dic[@"area"];
    for (NSDictionary *dict in cities) {
        City *city = [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:[CoreDataManager sharedCoreDataManager].managedObjContext];
        [city setValuesForKeysWithDictionary:dict];
        
    }
    for (NSDictionary *dict in provinces) {
        Province *province = [NSEntityDescription insertNewObjectForEntityForName:@"Province" inManagedObjectContext:[CoreDataManager sharedCoreDataManager].managedObjContext];
        [province setValuesForKeysWithDictionary:dict];
        
    }
    for (NSDictionary *dict in areas) {
        Area *area = [NSEntityDescription insertNewObjectForEntityForName:@"Area" inManagedObjectContext:[CoreDataManager sharedCoreDataManager].managedObjContext];
        [area setValuesForKeysWithDictionary:dict];
        
    }
    
    
    
    NSError *error = nil;
    
    //    托管对象准备好后，调用托管对象上下文的save方法将数据写入数据库
    BOOL isSaveSuccess = [[CoreDataManager sharedCoreDataManager].managedObjContext save:&error];
    if (!isSaveSuccess) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }else
    {
        NSLog(@"Save successFull");
    }
    
}

- (void)loadData {
    
    [self.provinces removeAllObjects];
    [self.provinces addObjectsFromArray:[self queryProvince]];
    
    Province *pro = [self.provinces firstObject];
    [self.cities removeAllObjects];
    [self.cities addObjectsFromArray:[self queryCity:pro.province_id]];
    
    City *city = [self.cities firstObject];
    
    [self.areas removeAllObjects];
    [self.areas addObjectsFromArray:[self queryArea:city.city_id]];

    [self.pickView reloadAllComponents];
}

- (NSArray *)queryProvince {
    
    CoreDataManager *manager = [CoreDataManager sharedCoreDataManager];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Province" inManagedObjectContext:manager.managedObjContext];

    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:NO];
    NSArray *sortDescriptions = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    
    NSError *error = nil;
    
    NSArray *fetchResult = [manager.managedObjContext executeFetchRequest:request error:&error];
    if (!fetchResult)
    {
        NSLog(@"error:%@,%@",error,[error userInfo]);
    }
    return fetchResult;
}

- (NSArray *)queryCity:(NSString *)province_id {
    
    CoreDataManager *manager = [CoreDataManager sharedCoreDataManager];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:manager.managedObjContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:NO];
    NSArray *sortDescriptions = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"province_id = %@ and status = 0", province_id];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchResult = [manager.managedObjContext executeFetchRequest:request error:&error];
    if (!fetchResult)
    {
        NSLog(@"error:%@,%@",error,[error userInfo]);
    }
    return fetchResult;
}

- (NSArray *)queryArea:(NSString *)city_id {
    CoreDataManager *manager = [CoreDataManager sharedCoreDataManager];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Area" inManagedObjectContext:manager.managedObjContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:NO];
    NSArray *sortDescriptions = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"city_id = %@ and status = 0", city_id];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchResult = [manager.managedObjContext executeFetchRequest:request error:&error];
    if (!fetchResult)
    {
        NSLog(@"error:%@,%@",error,[error userInfo]);
    }
    return fetchResult;
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return self.provinces.count;
            break;
        case 1:
            return self.cities.count;
            break;
        case 2:
            return self.areas.count;
            break;
        default:
            return 0;
            break;
    }
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            Province *pro = self.provinces[row];
            return pro.province_name;
            break;
        }
        case 1:{
            City *city = self.cities[row];
            return city.city_name;
            break;
        }
        case 2:{
            Area *area = self.areas[row];
            return area.area_name;
            break;
        }
        default:
            return @"mei";
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            Province *pro = self.provinces[row];
            [self.cities removeAllObjects];
            [self.cities addObjectsFromArray:[self queryCity:pro.province_id]];
            
            City *city = [self.cities firstObject];
            
            [self.areas removeAllObjects];
            [self.areas addObjectsFromArray:[self queryArea:city.city_id]];
            [self.pickView reloadComponent:1];
            [self.pickView reloadComponent:2];
            break;
        }
        case 1:{
            City *city = self.cities[row];
            
            [self.areas removeAllObjects];
            [self.areas addObjectsFromArray:[self queryArea:city.city_id]];
            [self.pickView reloadComponent:2];
            break;
        }
        default:
            break;
    }
    
    NSLog(@"%@ %@ %@",[self.provinces[[pickerView selectedRowInComponent:0]] province_name],[self.cities[[pickerView selectedRowInComponent:1]] city_name],[self.areas[[pickerView selectedRowInComponent:2]] area_name]);
}


@end
