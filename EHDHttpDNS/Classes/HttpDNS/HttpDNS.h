//
//  HttpDNS.h
//  HttpDNS
//
//  Created by luohs on 16/05/20.
//

#import <Foundation/Foundation.h>

#define ENABLE_HTTPDNS 1

@protocol HttpDNSDegradationDelegate <NSObject>
- (BOOL)shouldDegradeHTTPDNS:(NSString *)hostName;
@end

@protocol HttpDNSDegradationDelegate;
@interface HttpDNS : NSObject
@property (nonatomic, assign) NSInteger accountID;
@property (nonatomic, weak) id<HttpDNSDegradationDelegate> delegate;
+ (HttpDNS *)sharedInstance;
- (NSString *)ipWithHost:(NSString *)host;
@end
