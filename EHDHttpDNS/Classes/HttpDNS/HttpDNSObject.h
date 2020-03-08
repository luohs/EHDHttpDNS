//
//  HttpDNSObject.h
//  HttpDNS
//
//  Created by luohs on 16/05/20.
//

#import <Foundation/Foundation.h>

@interface HttpDNSObject : NSObject

@property(nonatomic, copy, readonly) NSString *host;
@property(nonatomic, copy, readonly) NSArray *ips;
@property(nonatomic, assign, readonly) NSInteger ttl;
@property(nonatomic, assign, readonly) NSTimeInterval query;

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary;

- (BOOL)isExpired;

@end
