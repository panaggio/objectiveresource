// PersonTestAsync.h
// James Burka
// Simon Woodside

#import "GTMSenTestCase.h"
#import "ORSConnectionAsync.h"
#import "Person.h"

@interface PersonTestAsync : SenTestCase <ORSConnectionAsyncDelegate> {
  Person * _newPerson;
  BOOL _callbackReceived;
  int _currentTest;
}

@end
