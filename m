Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56892 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932860AbaJ3Pma (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Oct 2014 11:42:30 -0400
Message-ID: <54525C63.9010003@RedHat.com>
Date: Thu, 30 Oct 2014 11:42:27 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: building upstream nfs-utils on EL6 fails
References: <E823B0AB-32D7-45C5-B5C2-69B165A2CEAC@oracle.com> <alpine.LRH.2.11.1410291919090.20279@sh-el6.eng.rdu2.redhat.com> <0953ACF5-C77F-4568-9952-FAF0C126B4AD@oracle.com> <alpine.LRH.2.11.1410301022140.20279@sh-el6.eng.rdu2.redhat.com>
In-Reply-To: <alpine.LRH.2.11.1410301022140.20279@sh-el6.eng.rdu2.redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/30/2014 10:53 AM, Benjamin Coddington wrote:
> 
> On Wed, 29 Oct 2014, Chuck Lever wrote:
> 
>> Hi Ben-
>>
>> On Oct 29, 2014, at 7:27 PM, Benjamin Coddington <bcodding@redhat.com> wrote:
>>
>>> Hi Chuck, I'll jump in here if you don't mind.
>>>
>>> How's this work for missing keyctl_invalidate:
>>>
>>> diff --git a/configure.ac b/configure.ac
>>> index 59fd14d..8295bed 100644
>>> --- a/configure.ac
>>> +++ b/configure.ac
>>> @@ -270,6 +270,9 @@ AC_CHECK_LIB([crypt], [crypt], [LIBCRYPT="-lcrypt"])
>>>
>>> AC_CHECK_LIB([dl], [dlclose], [LIBDL="-ldl"])
>>>
>>> +AC_CHECK_LIB([keyutils], [keyctl_invalidate], ,[
>>> +       AC_DEFINE([MISSING_KEYCTL_INVALIDATE], [1], [Define to use
>>> keyctl_revoke instead])])
>>
>> Nit: I would just add
>>
>>  AC_CHECK_FUNCS([keyctl_invalidate])
>>
>> in aclocal/keyutils.m4 to define HAVE_KEYCTL_INVALIDATE .
> 
> Yes, that is better.
> 
>>> +
>>> if test "$enable_nfsv4" = yes; then
>>>   dnl check for libevent libraries and headers
>>>   AC_LIBEVENT
>>> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
>>> index e0d31e7..ab4b10c 100644
>>> --- a/utils/nfsidmap/nfsidmap.c
>>> +++ b/utils/nfsidmap/nfsidmap.c
>>> @@ -14,6 +14,7 @@
>>> #include <unistd.h>
>>> #include "xlog.h"
>>> #include "conffile.h"
>>> +#include “config.h"
>>>
>>> int verbose = 0;
>>> char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key
>>> desc]";
>>> @@ -23,6 +24,10 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] ||
>>> [-t timeout] key desc]";
>>> #define USER  1
>>> #define GROUP 0
>>>
>>> +#ifdef MISSING_KEYCTL_INVALIDATE
>>> +#define keyctl_invalidate(key) keyctl_revoke(key)
>>> +#endif
>>> +
>>> #define PROCKEYS "/proc/keys"
>>> #ifndef DEFAULT_KEYRING
>>> #define DEFAULT_KEYRING "id_resolver"
>>>
>>> ^^^ that's a little ugly -- it doesn't try to figure out what should be
>>> done in the kernel to clean up keys.  It assumes that if your
>>> libkeyutils has keyctl_invalidate then that's what you should use.
>>
>> This looks like it fixes the build issue. I think we do
>> want late-model nfs-utils to build correctly on older
>> distributions.
>>
>> I’m not sure keyctl_revoke and keyctl_invalidate do
>> precisely the same thing, though? On older systems can
>> we expect a change from one to the other to have no
>> impact? (Just beginning to explore this issue).
> 
> For EL6 kernels, you should be good with keyctl_revoke.  That's the only
> thing you can do - there's no key_invalidate.
> 
> But on later kernels, you'd want to use key_invalidate. The details of the
> kernel changes are here:
> 
> 0c7774abb41bd00d KEYS: Allow special keys (eg. DNS results) to be
> invalidated by CAP_SYS_ADMIN
> 
> The summary is that permission changes in later kernels cause
> keyctl_revoke to be unable to clean up keys that are not in possession.
> This specific commit allows that once more for CAP_SYS_ADMIN, so
> really, it should work fine if you have this.  However:
> 
> keyctl_revoke waits key_gc_timeout to clean up the key, and access
> attempts return -EKEYREVOKED.
> 
> keyctl_invalidate immediately removes all references to the key.
> 
> The latter is the preferred operation for nfsidmap, since this code path
> exists to allow the admin to flush out a specific key from the idmapper
> cache.
> 
> It might be a good idea to just update your libkeyutils along with the kernel
> and nfs-utils.  Maybe we should make a version dependency for
> libkeyutils in nfs-utils.  Steve, what do you think?
Today we have a dependency on keyutils which I thought 
would take care of this... but looking at the code it
appears you might have a point... Lets open a bz and 
take a look at it... 

steved.

> 
>>> EL6 systems should be able to do both the request-key (nfsidmap)
>>> and the rpc.idmapd upcall.  I believe that EL6 kernels try both - if the
>>> nfsidmap request-key doesn't work they fall back to the upcall, however
>>> the nfsidmap request-key interface really is the one that should be
>>> used.
>>
>> I have several EL6 systems here, and at least one of them
>> had rpc.idmapd configured off. I couldn’t remember if I had
>> done that, or it came that way off the installation media.
> 
> I think rpc.idmapd being on/off changed a couple of times in EL6.. I
> don't recall the specifics.
> 
>> When installing a newer kernel causes a fallback to rpc.idmapd,
>> is there any risk of an ID mapper behavior change? Loss of
>> functionality, for example?
> 
> The functionality should be equivalent - I think they end up in the same
> library after making it through the callout/callup interface.
> 
> The newer kernels only do the request-key callout, and rpc.idmapd
> won't ever be consulted.
> 
> Ben
