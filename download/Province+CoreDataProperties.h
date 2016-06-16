//
//  Province+CoreDataProperties.h
//  download
//
//  Created by natsu on 16/6/13.
//  Copyright © 2016年 natsu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Province.h"

NS_ASSUME_NONNULL_BEGIN

@interface Province (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *province_id;
@property (nullable, nonatomic, retain) NSString *province_name;
@property (nullable, nonatomic, retain) NSString *sort;
@property (nullable, nonatomic, retain) NSString *status;

@end

NS_ASSUME_NONNULL_END
