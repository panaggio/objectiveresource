// PersonTestAsync.m
// Simon Woodside
// Test the asynchronous methods. Incomplete.

#import "PersonAsyncTest.h"

@implementation PersonTestAsync

- (void)setUp {
  [ObjectiveResourceConfig setSite:@"http://localhost:36313/"];
  [ObjectiveResourceConfig setResponseType:JSONResponse];
  [ObjectiveResourceConfig setUser:nil];
  [ObjectiveResourceConfig setPassword:nil];
  [ObjectiveResourceConfig setDelegate:self];
}


// Wait until Objective Resource Async calls back to the delegate.
// OR runs in the default run loop.
- (void)waitForCallback; {
  _callbackReceived = NO;
  while( _callbackReceived == NO ) { // spin until done
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
}

#pragma mark Test Cases
- (void)testPersonCreate {
  _newPerson = [[Person alloc] init];
  _newPerson.name = @"Fluffy Farwinkel";
  [_newPerson createRemoteAsync];
  [self waitForCallback];
}
- (void)verifyPersonCreated:(ORSResponse*)response; {
  [_newPerson updateFromResponse:response];
  // Check really added using synchronous find:
  BOOL found = NO;
  NSArray * people = [Person findAllRemote];
  for( Person * person in people ) {
    if( [_newPerson isEqualToRemote:person] ) { found = YES; }
  }
  STAssertTrue( found, @"Did not find the new person : %@", _newPerson.name );
}


- (void)testFindPerson; {
  [Person findAllRemoteAsync];
  [self waitForCallback];
}
- (void)verifyPeopleFound:(ORSResponse*)response; {
  NSArray * people = [Person performSelector:[Person getRemoteParseDataMethod] withObject:response.body];
  //NSLog(@"=============== people = %@", [people description]);
  Person * toFind = (Person *)[people objectAtIndex:0];
  STAssertTrue( [toFind isEqualToRemote:[Person findRemote:toFind.personId]], @"Should of returned %@",toFind.name );
}




#pragma mark ORSConnectionAsync Delegate Methods
- (void)orsConnection:(ORSConnectionAsync*)connection didGetResponse:(ORSResponse*)response; {
  STAssertNotNil( connection, nil );
  STAssertNotNil( response, nil );
  STAssertTrue( [response isSuccess], nil );
  NSString * currentTest = NSStringFromSelector(currentSelector_); // This could break if SenTest changes its internal variable name
  if( [currentTest isEqualToString:@"testPersonCreate"] ) {
    [self verifyPersonCreated:response];
  } else if( [currentTest isEqualToString:@"testFindPerson"] ) {
    [self verifyPeopleFound:response];
  } else {
    STAssertTrue( NO, @"orsConnection:didGetResponse: but current test / selector is unknown." );
  }
  _callbackReceived = YES;
}
- (void)orsConnection:(ORSConnectionAsync*)connection didFailWithError:(NSError *)error; {
  STAssertTrue( NO, @"Async connection failed" );
  _callbackReceived = YES;
}






//- (void)testPersonDelete {
//  int count = [[Person findAllRemote] count];
//  Person * person = [Person findRemote:[NSString stringWithFormat:@"%i",PERSON_DESTROY]];
//  STAssertTrue( [person destroyRemote], @"Should have been true" );
//  NSArray * people = [Person findAllRemote];
//  STAssertTrue( (count-1) == [people count], @"Should have %i people , %d found" ,count ,[people count] );
//}
//
//- (void)testPersonUpdate {
//  BOOL found = NO;
//  Person * toUpdate = [Person findRemote:[NSString stringWithFormat:@"%i",PERSON]];
//  toUpdate.name = @"America Shaftoe";
//  STAssertTrue(  [toUpdate saveRemote], @"Should have been true");  
//  NSArray * people = [Person findAllRemote];
//  for( Person *person in people ) {
//    if( [toUpdate isEqualToRemote:person] && [toUpdate.name isEqualToString:person.name] ) {
//      found = YES;
//    }
//  }
//  STAssertTrue(found, @"");  
//}
//
//- (void)testPrefixedPerson; {
//  NSArray *people = [Person findAllRemote];
//  int shouldBe = [people count];
//  [ObjectiveResourceConfig setLocalClassesPrefix:@"Prefixed"];
//  people = [PrefixedPerson findAllRemote];
//  STAssertTrue( shouldBe == [people count], @"Should have %i people , %d found", shouldBe, [people count] );
//  [ObjectiveResourceConfig setLocalClassesPrefix:nil];
//}


@end
