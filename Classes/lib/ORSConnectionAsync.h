// ORSConnectionAsync.h
// Asynchronous version of Connection class, using the standard Objective-C delegate pattern.
// Ryan Daigle
// Simon Woodside

@protocol ORSConnectionAsyncDelegate;
@class ORSResponse;

@interface ORSConnectionAsync : NSObject {
  id<ORSConnectionAsyncDelegate> _delegate;
  NSString * _user;
  NSString * _password;
  NSMutableData * _data;
  NSURLResponse * _response;
  float _timeoutInterval;
}
@property float timeoutInterval;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSString * password;

- (void)get:(NSString *)url;
- (void)put:(NSString *)body to:(NSString *)url;
- (void)post:(NSString *)body to:(NSString *)url;
- (void)delete:(NSString *)url;
- (void)cancel;

@end

@protocol ORSConnectionAsyncDelegate
- (void)oRSconnection:(ORSConnectionAsync*)connection didGetResponse:(ORSResponse*)response;
- (void)oRSconnection:(ORSConnectionAsync*)connection didFailWithError:(NSError *)error;
@end


