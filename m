Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36712 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934668AbaJ3Pe7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Oct 2014 11:34:59 -0400
Message-ID: <54525AA1.8020109@RedHat.com>
Date: Thu, 30 Oct 2014 11:34:57 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        Benjamin Coddington <bcodding@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: building upstream nfs-utils on EL6 fails
References: <E823B0AB-32D7-45C5-B5C2-69B165A2CEAC@oracle.com> <alpine.LRH.2.11.1410291919090.20279@sh-el6.eng.rdu2.redhat.com> <0953ACF5-C77F-4568-9952-FAF0C126B4AD@oracle.com>
In-Reply-To: <0953ACF5-C77F-4568-9952-FAF0C126B4AD@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/29/2014 08:24 PM, Chuck Lever wrote:
> Hi Ben-
> 
> On Oct 29, 2014, at 7:27 PM, Benjamin Coddington <bcodding@redhat.com> wrote:
> 
>> Hi Chuck, I'll jump in here if you don't mind.
>>
>> How's this work for missing keyctl_invalidate:
>>
>> diff --git a/configure.ac b/configure.ac
>> index 59fd14d..8295bed 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -270,6 +270,9 @@ AC_CHECK_LIB([crypt], [crypt], [LIBCRYPT="-lcrypt"])
>>
>> AC_CHECK_LIB([dl], [dlclose], [LIBDL="-ldl"])
>>
>> +AC_CHECK_LIB([keyutils], [keyctl_invalidate], ,[
>> +       AC_DEFINE([MISSING_KEYCTL_INVALIDATE], [1], [Define to use
>> keyctl_revoke instead])])
> 
> Nit: I would just add
> 
>   AC_CHECK_FUNCS([keyctl_invalidate])
> 
> in aclocal/keyutils.m4 to define HAVE_KEYCTL_INVALIDATE .
> 
>> +
>> if test "$enable_nfsv4" = yes; then
>>   dnl check for libevent libraries and headers
>>   AC_LIBEVENT
>> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
>> index e0d31e7..ab4b10c 100644
>> --- a/utils/nfsidmap/nfsidmap.c
>> +++ b/utils/nfsidmap/nfsidmap.c
>> @@ -14,6 +14,7 @@
>> #include <unistd.h>
>> #include "xlog.h"
>> #include "conffile.h"
>> +#include “config.h"
>>
>> int verbose = 0;
>> char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key
>> desc]";
>> @@ -23,6 +24,10 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] ||
>> [-t timeout] key desc]";
>> #define USER  1
>> #define GROUP 0
>>
>> +#ifdef MISSING_KEYCTL_INVALIDATE
>> +#define keyctl_invalidate(key) keyctl_revoke(key)
>> +#endif
>> +
>> #define PROCKEYS "/proc/keys"
>> #ifndef DEFAULT_KEYRING
>> #define DEFAULT_KEYRING "id_resolver"
>>
>> ^^^ that's a little ugly -- it doesn't try to figure out what should be
>> done in the kernel to clean up keys.  It assumes that if your
>> libkeyutils has keyctl_invalidate then that's what you should use.
> 
> This looks like it fixes the build issue. I think we do
> want late-model nfs-utils to build correctly on older
> distributions.
> 
> I’m not sure keyctl_revoke and keyctl_invalidate do
> precisely the same thing, though? On older systems can
> we expect a change from one to the other to have no
> impact? (Just beginning to explore this issue).
> 
>> EL6 systems should be able to do both the request-key (nfsidmap)
>> and the rpc.idmapd upcall.  I believe that EL6 kernels try both - if the
>> nfsidmap request-key doesn't work they fall back to the upcall, however
>> the nfsidmap request-key interface really is the one that should be
>> used.
> 
> I have several EL6 systems here, and at least one of them
> had rpc.idmapd configured off. I couldn’t remember if I had
> done that, or it came that way off the installation media.
In RHEL6.5, on the client, we moved from using rpc.idmapd to
id mappings to nfsidmap (key ring based). 

The main reason is the kernel first tries an upcall it nfsidmap. 
If that fails then an upcall is made to rpc.idmapd. So in the 
early RHEL release we were doing to upcalls for every id mapping... 

Actually this was an issue that Ben pointed out...

So I disabled rpc.idmap and started installing nfsidmap.

> 
> When installing a newer kernel causes a fallback to rpc.idmapd,
> is there any risk of an ID mapper behavior change? Loss of
> functionality, for example?
The short answer No. The long answer... It might with a very
large number of id mappings... 

It turns out the kernel key ring default size in RHEL6 kernels 
is not large enough for enterprise installations. So when I made 
the switch it broke a bunch of people... It does sucks to be 
me sometimes... ;-) 

This was fixed in RHEL6.6 with a patch from Ben that taught
nfsidmap to used multiple key rings and we bumped up the
default key ring size.

steved.

> 
>> Ben
>>
>> On Wed, 29 Oct 2014, Chuck Lever wrote:
>>
>>> Hi Steve-
>>>
>>> libtool: link: gcc -Wall -Wextra -Wstrict-prototypes -pipe -D_FILE_OFFSET_BITS=64 -Wp,-D_FORTIFY_SOURCE=2 -Os -Wall -Wextra -pedantic -std=c99 -Wformat=2 -Wmissing-include-dirs -Wunused -Wconversion -Wlogical-op -Wmissing-prototypes -Wmissing-declarations -Wstrict-prototypes -Wmissing-noreturn -Wshadow -Wunreachable-code -Winline -Wdisabled-optimization -Wstrict-aliasing=2 -Wstrict-overflow=4 -Wstack-protector -fstrict-aliasing -fstrict-overflow -fexceptions -fstack-protector -fasynchronous-unwind-tables -fpie -pie -o nfsidmap nfsidmap.o  /usr/lib64/libnfsidmap.so -ldl -lkeyutils ../../support/nfs/libnfs.a
>>> nfsidmap.o: In function `key_invalidate':
>>> nfsidmap.c:(.text+0x141): undefined reference to `keyctl_invalidate'
>>> collect2: ld returned 1 exit status
>>> make[2]: *** [nfsidmap] Error 1
>>> make[1]: *** [all-recursive] Error 1
>>> make: *** [all-recursive] Error 1
>>> [cel@dali nfs-utils]$
>>>
>>> I think this could be due to
>>>
>>> commit 2ae0763a618d30037ebb2520f6292f80d838a440
>>> Author: Steve Dickson <steved@redhat.com>
>>> Date:   Tue Mar 25 10:56:58 2014 -0400
>>>
>>>   nfsidmap: Keys need to be invalidated instead of revoked
>>>
>>> Probably need to have some autoconf logic to pick which keyctl_
>>> API is available on the build system.
>>>
>>> But I’d like to run recent kernels on EL6 systems. It looks like
>>> the current upstream kernel ID mapping interface isn’t compatible
>>> with the EL6 user space (/usr/sbin/nfsidmap).
>>>
>>> I see both sets of infrastructure on EL6: nfsidmap is installed
>>> and so is rpc.idmapd. Which one is supposed to be used?
>>>
>>> --
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>>
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
