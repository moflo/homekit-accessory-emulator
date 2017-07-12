//
//  HAPController.hpp
//  homekit-wolfssl
//
//  Created by d. nye on 6/30/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

#ifndef HAPController_H
#define HAPController_H

#include <stdlib.h>
#include <string.h>

#define WOLFSSL_SHA512
#define WOLFCRYPT_HAVE_SRP

#include "srp.h"

class HAPControllerClass
{
private:
    
public:
    HAPControllerClass();
    ~HAPControllerClass();

    int SRPClientInit(Srp *cli);

    int getChallenge(uint8_t **salt,uint32_t *salt_len, uint8_t **key, uint32_t *key_len);
    int getChallengeTest(uint8_t **salt,uint32_t *salt_len, uint8_t **key, uint32_t *key_len);
    
};


#endif /* HAPController_hpp */
