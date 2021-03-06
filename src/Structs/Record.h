//
//  Record.h
//  myFans
//
//  Created by wonliao on 13/1/26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Record : NSManagedObject

@property (nonatomic, retain) NSString * row;
@property (nonatomic, retain) NSString * index;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * file_name;
@property (nonatomic, retain) NSString * file;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * downloaded;

@end
