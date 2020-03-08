//
//  HttpDNSObject.m
//  HttpDNS
//
//  Created by luohs on 16/05/20.
//

#import "HttpDNSObject.h"

static NSString * const hostKey = @"host";
static NSString * const ttlKey = @"ttl";
static NSString * const ipsKey = @"ips";
static const NSInteger ttlDefaultValue = 30;

@implementation HttpDNSObject

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary
{
    HttpDNSObject *object = [[HttpDNSObject alloc] initWithDictionary:dictionary];
    if (object.host && object.ips.count) {
        return object;
    }
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    dictionary = [dictionary isKindOfClass:NSDictionary.class] ? dictionary : nil;
    
    NSString *host = dictionary[hostKey];
    _host = [host isKindOfClass:NSString.class] ? host : nil;
    
    NSNumber *ttl = dictionary[ttlKey];
    NSInteger ttlValue = 0;
    if ([ttl respondsToSelector:@selector(integerValue)]) {
        ttlValue = [ttl integerValue];
    }
    if (ttlValue <= 0) {
        ttlValue = ttlDefaultValue;
    }
    _ttl = ttlValue;
    _query = [[NSDate date] timeIntervalSince1970];
    
    NSArray *ips = dictionary[ipsKey];
    _ips = [ips isKindOfClass:NSArray.class] ? ips : nil;
    
    return self;
}

-(BOOL)isExpired
{
    return self.query + self.ttl < [[NSDate date] timeIntervalSince1970];
}

@end
