//
//  Common.h
//  Flying witch
//
//  Created by José Gabriel Ferrer on 17/06/14.
//  Copyright (c) 2014 José Gabriel Ferrer. All rights reserved.
//

#ifndef Flying_witch_Common_h
#define Flying_witch_Common_h

#define DEVICE_SIZE [[[[UIApplication sharedApplication] keyWindow] rootViewController].view convertRect:[[UIScreen mainScreen] bounds] fromView:nil].size

static const uint32_t playerCategory        = 0x1 << 0;
static const uint32_t enemyCategory         = 0x1 << 1;
static const uint32_t starCategory          = 0x1 << 2;
static const uint32_t backgroundCategory    = 0x1 << 3;

#endif
