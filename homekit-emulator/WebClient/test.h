//
//  test.h
//  Homekit
//
//  Created by d. nye on 6/27/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

#ifndef test_h
#define test_h

#include <string>

struct TCPClient {
    int write(const char * buffer) { return 1; };
    int write(const char buffer) { return 1; };
    int write(const int buffer) { return 1; };
    int available( void ) { return (index < 125); };
    char read( void ) { return stream[index++]; };
    char read(const char * buffer) { return 'a'; };
    int read(char * buffer, int len) { memcpy(buffer, &stream[index+1], len); return len;};
    long millis( void ) { return 60; };
    
    char * stream;
    int index = 0;
    
};

#endif /* test_h */
