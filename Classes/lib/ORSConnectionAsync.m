// ORSConnectionAsync.m
// Asynchronous version of Connection class, using the standard Objective-C delegate pattern.
// Ryan Daigle
// Simon Woodside

#import "ORSConnectionAsync.h"
#import "ORSResponse.h"
#import "NSData+Additions.h"
#import "NSMutableURLRequest+ResponseType.h"

//#define debugLog(...) NSLog(__VA_ARGS__)
#ifndef debugLog(...)
#define debugLog(...)
#endif


@implementation ORSConnectionAsync
@synthesize timeoutInterval = _timeoutInterval, user = _user, password = _password;
// TODO where / how is _timeoutInterval to be used???

// Create a new connection that's ready to give an HTTP verb & a URL
// Normally, delegate should be set to self, and you should adopt the ORSConnectionAsyncDelegate protocol
// in order to get the results.
- (id)initWithUser:(NSString*)user password:(NSString*)password delegate:(id<ORSConnectionAsyncDelegate>)delegate; {
  self = [super init];
  if( !self ) { return nil; }
  _user = user; _password = password;
  _delegate = delegate;
  _data = [[NSMutableData data] retain];
  _timeoutInterval = 5.0; // TODO used how? that's pretty short...
  return self;
}

// Use this one if you don't need to send user and password credentials
- (id)initWithDelegate:(id<ORSConnectionAsyncDelegate>)delegate; {
  return [self initWithUser:nil password:nil delegate:delegate];
}


#pragma mark Logging
- (void)logRequest:(NSURLRequest *)request to:(NSString *)url {
  debugLog(@"%@ -> %@", [request HTTPMethod], url);
  if([request HTTPBody]) {
    debugLog([[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] autorelease]);
  }
}


# pragma mark Network connection
- (void)sendRequest:(NSMutableURLRequest *)request; { // withUser:(NSString *)user andPassword:(NSString *)password {
  // Lots of servers fail to implement http basic authentication correctly,
  // so we pass the credentials even if they are not asked for.
  // Modify the request to include user & password header and modify the URL
  NSURL * url = [request URL];
  if( _user && _password ) {
    NSString * authString = [[[NSString stringWithFormat:@"%@:%@", _user, _password] dataUsingEncoding:NSUTF8StringEncoding] base64Encoding];
    [request addValue:[NSString stringWithFormat:@"Basic %@", authString] forHTTPHeaderField:@"Authorization"]; 
    // TODO it would be easier to simply insert the user & password into the user rather than rebuild it:
    NSString * escapedUser = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)_user, NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
    NSString * escapedPassword = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)_password, NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
    NSMutableString * urlString = [NSMutableString stringWithFormat:@"%@://%@:%@@%@", [url scheme], escapedUser, escapedPassword, [url host], nil];
    if( [url port] ) { [urlString appendFormat:@":%@",[url port],nil]; }
    [urlString appendString:[url path]];
    if( [url query] ) { [urlString appendFormat:@"?%@",[url query],nil]; }
    [request setURL:[NSURL URLWithString:urlString]];
    [escapedUser release];
    [escapedPassword release];
  }
  // Initiate connection:
  [self logRequest:request to:[url absoluteString]];
  NSURLConnection * connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
  if( !connection ) {
    NSError * error = [NSError errorWithDomain:@"" code:0 userInfo:@"NSURLConnection returned a nil object."];
    [_delegate orsConnection:self didFailWithError:error];
  }
}



#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response; {
  // This could be called multiple times (e.g. redirect), so only act on the final response
  if( _response ) { [_response release]; }
  _response = [response retain]; // Only keep the last one
  [_data setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data; {
  [_data appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error; {
  [connection release];
  [_delegate orsConnection:self didFailWithError:error];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection; {
  ORSResponse * response = [ORSResponse responseFrom:(NSHTTPURLResponse *)_response withBody:_data andError:nil];
  [response log];
  [_data release]; // could be invalid ...
  [_delegate orsConnection:self didGetResponse:response];
}


#pragma mark User methods
- (void)get:(NSString *)url; {
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithUrl:[NSURL URLWithString:url] andMethod:@"GET"];
  [self sendRequest:request];
}

- (void)put:(NSString *)body to:(NSString *)url; {
  NSMutableURLRequest * request = [NSMutableURLRequest requestWithUrl:[NSURL URLWithString:url] andMethod:@"PUT"];
  [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
  [self sendRequest:request];
}

- (void)post:(NSString *)body to:(NSString *)url; {
  NSMutableURLRequest * request = [NSMutableURLRequest requestWithUrl:[NSURL URLWithString:url] andMethod:@"POST"];
  [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
  [self sendRequest:request];
}

- (void)delete:(NSString *)url; {
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithUrl:[NSURL URLWithString:url] andMethod:@"DELETE"];
  [self sendRequest:request];
}

- (void)cancel; {
  // TODO stop the active connection ... ?
}

@end



