//
//  TLV8_Bridge.h
//  homekit-emulator
//
//  Created by d. nye on 7/2/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef HomeKit_Bridge_h
#define HomeKit_Bridge_h

@interface newHomeKit : NSObject
-(int) newObject;
-(NSDictionary *) processHTTP:(NSData*)stream;
-(void) reset;
@end

#endif /* HomeKit_Bridge_h */
