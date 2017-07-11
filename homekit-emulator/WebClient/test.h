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

// Callback function to test data writes
typedef void (*write_callback_t)(char * buffer,int len);

// Stub TCPClient to emulate Particle / Arduino native TCP client protocols
struct TCPClient {
    int write(char * buffer, int len) { callback(buffer, len); return 0; };
    int write(const char *buffer) { callback((char *)buffer, (int)strlen(buffer)); return 0; };
    int write(const char buffer) { callback((char *)&buffer, 1); return 0;};
    int write( int number) {
        char output[3];
        sprintf( output, "%03d", number);
        callback( output, 3);
        return 0;
    }
    int available( void ) { return (index < 125); };
    char read( void ) { return stream[index++]; };
    char read(const char * buffer) { return 'a'; };
    int read(char * buffer, int len) { memcpy(buffer, &stream[index], len); return len;};
    long millis( void ) { return 60; };
    
    char * stream;
    int index = 0;
    
    write_callback_t callback = NULL;
    
};

#endif /* test_h */
