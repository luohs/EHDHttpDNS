//
//  HttpDNS.m
//  HttpDNS
//
//  Created by luohs on 16/05/20.
//

#import "HttpDNS.h"
#import "HttpDNSObject.h"
#import <AlicloudHttpDNS/AlicloudHttpDNS.h>

#define ALI_HTTPDNS

static NSString * const ServerIP = @"203.107.1.1";

@interface HttpDNS()
@property (nonatomic, strong, readonly) NSMutableDictionary *hostCache;
@property (nonatomic, strong, readonly) NSMutableSet *downloadingHosts;
@property (nonatomic, strong, readonly) NSURLSession *session;
@end

@implementation HttpDNS

- (instancetype)init
{
    self = [super init];
    if (self) {
        _accountID = 146849;
        _hostCache = [[NSMutableDictionary alloc] init];
        _downloadingHosts = [NSMutableSet set];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        configuration.timeoutIntervalForRequest = 30;
        _session = [NSURLSession sessionWithConfiguration:configuration];
#ifdef ALI_HTTPDNS
        HttpDnsService *service = [[HttpDnsService alloc] initWithAccountID:(int)_accountID];
        service.delegate = nil;
        [service setExpiredIPEnabled:YES];
#ifdef DEBUG
        [service setLogEnabled:YES];
#else
        [service setLogEnabled:NO];
#endif
        
#endif
    }
    
    return self;
}

+ (HttpDNS *)sharedInstance
{
    static HttpDNS *instance = nil;
#if ENABLE_HTTPDNS
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HttpDNS alloc] init];
    });
#endif
    return instance;
}

- (NSString *)ipWithHost:(NSString *)host
{
#ifdef ALI_HTTPDNS
    HttpDnsService *service = [HttpDnsService sharedInstance];
    return [service getIpByHostAsync:host];
#else
    if ([self.delegate shouldDegradeHTTPDNS:host]) {
        return nil;
    }
    
    if (host.length == 0) {
        return nil;
    }
    
    HttpDNSObject *object = self.hostCache[host];
    if (!object || [object isExpired]) {
        [self downloadWithHost:host];
    }
    
    return object.ips.firstObject;
#endif
}

#pragma mark - download

- (void)downloadWithHost:(NSString *)host
{
    if ([self.downloadingHosts containsObject:host]) {
        return;
    }
    
    [self.downloadingHosts addObject:host];
    
    NSInteger accountID = self.accountID;
    NSString *path = [NSString stringWithFormat:@"http://%@/%@/d?host=%@", ServerIP, @(accountID), host];
    NSURL *url = [NSURL URLWithString:path];

    NSURLSessionDataTask *task = nil;
    __weak typeof (self) weakSelf = self;
    task = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([NSThread isMainThread]) {
            [weakSelf downloadCompleteWithHost:host data:data response:response];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf downloadCompleteWithHost:host data:data response:response];
            });
        }
    }];
    [task resume];
}

- (void)downloadCompleteWithHost:(NSString *)host data:(NSData *)data response:(NSURLResponse *)response
{
    [self.downloadingHosts removeObject:host];
    
    NSHTTPURLResponse *httpResponse = nil;
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        httpResponse = (NSHTTPURLResponse *)response;
    }
    
    NSDictionary *dictionary = nil;
    if (httpResponse.statusCode == 200 && data) {
        dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableLeaves
                                                       error:nil];
    }
    
    HttpDNSObject *object = [HttpDNSObject objectWithDictionary:dictionary];
    if (object) {
        self.hostCache[host] = object;
    }
}

@end
