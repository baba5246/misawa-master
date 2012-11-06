@interface HttpClient : NSObject {
}

+ (void)request:(NSURLRequest *)request success:(void (^)(NSData *))onSuccess error:(void (^)(NSError *))onError;

@end