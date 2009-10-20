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

- (id)initWithUser:(NSString*)user password:(NSString*)password delegate:(id<ORSConnectionAsyncDelegate>)delegate;
- (id)initWithDelegate:(id<ORSConnectionAsyncDelegate>)delegate;
  
- (void)get:(NSString *)url;
- (void)put:(NSString *)body to:(NSString *)url;
- (void)post:(NSString *)body to:(NSString *)url;
- (void)delete:(NSString *)url;
- (void)cancel;

@end

@protocol ORSConnectionAsyncDelegate
- (void)orsConnection:(ORSConnectionAsync*)connection didGetResponse:(ORSResponse*)response;
- (void)orsConnection:(ORSConnectionAsync*)connection didFailWithError:(NSError *)error;
@end


