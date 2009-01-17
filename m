From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sat, 17 Jan 2009 23:04:06 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0901172301380.14505@fbirervta.pbzchgretzou.qr>
References: <1232223441.3966.22.camel@localhost.localdomain> <1232228261.27094.0.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>,
	Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	linux-media@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
	dbrownell@users.sourceforge.net,
	spi-devel-general@lists.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1232228261.27094.0.camel@macbook.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Saturday 2009-01-17 22:37, David Woodhouse wrote:
>On Sun, 2009-01-18 at 01:47 +0530, Jaswinder Singh Rajput wrote:
>> --- a/include/linux/dvb/audio.h
>> +++ b/include/linux/dvb/audio.h
>> @@ -24,9 +24,8 @@
>>  #ifndef _DVBAUDIO_H_
>>  #define _DVBAUDIO_H_
>>  
>> -#ifdef __KERNEL__
>>  #include <linux/types.h>
>> -#else
>> +#ifndef __KERNEL__
>>  #include <stdint.h>
>>  #endif
>
>That patch looks wrong, and unnecessary. It was fine before.

What itches my eye is

#ifndef __KERNEL__
#include <stdint.h>
#endif

I am not sure how much Linux header files are supposed to be usable
from C++, but in case someone does, <cstdint> should be used in C++0x
mode. Testing for C++0x with macros however looks even more out of
place in such header files.
Thoughts?
