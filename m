Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:40453 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbaKCOzK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2014 09:55:10 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: building upstream nfs-utils on EL6 fails
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <alpine.LRH.2.11.1411030939280.20279@sh-el6.eng.rdu2.redhat.com>
Date: Mon, 3 Nov 2014 09:55:02 -0500
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FC03266E-C9ED-42AC-9F96-78C431446FC9@oracle.com>
References: <E823B0AB-32D7-45C5-B5C2-69B165A2CEAC@oracle.com> <alpine.LRH.2.11.1410291919090.20279@sh-el6.eng.rdu2.redhat.com> <0953ACF5-C77F-4568-9952-FAF0C126B4AD@oracle.com> <alpine.LRH.2.11.1410301022140.20279@sh-el6.eng.rdu2.redhat.com> <88A2F169-8D62-4F15-BAAE-42732903DE46@oracle.com> <alpine.LRH.2.11.1410301152390.20279@sh-el6.eng.rdu2.redhat.com> <0CF508F8-8222-4555-A3E0-CDA435CF994D@oracle.com> <alpine.LRH.2.11.1410301229380.20279@sh-el6.eng.rdu2.redhat.com> <0ED5691C-39ED-4132-B6C9-5B6FB40D4CF1@oracle.com> <alpine.LRH.2.11.1411030939280.20279@sh-el6.eng.rdu2.redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 3, 2014, at 9:44 AM, Benjamin Coddington <bcodding@redhat.com> wrote:

> 
> 
> On Thu, 30 Oct 2014, Chuck Lever wrote:
> 
>> 
>> On Oct 30, 2014, at 12:52 PM, Benjamin Coddington <bcodding@redhat.com> wrote:
>> 
>>> 
>>> 
>>> On Thu, 30 Oct 2014, Chuck Lever wrote:
>>> 
>>>> 
>>>> On Oct 30, 2014, at 12:08 PM, Benjamin Coddington <bcodding@redhat.com> wrote:
>>>> 
>>>>> 
>>>>> 
>>>>> On Thu, 30 Oct 2014, Chuck Lever wrote:
>>>>> 
>>>>>> 
>>>>>> On Oct 30, 2014, at 10:53 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
>>>>>> 
>>>>>>> 
>>>>>>> On Wed, 29 Oct 2014, Chuck Lever wrote:
>>>>>>> 
>>>>>>>> Hi Ben-
>>>>>>>> 
>>>>>>>> On Oct 29, 2014, at 7:27 PM, Benjamin Coddington <bcodding@redhat.com> wrote:
>>>>>>>> 
>>>>>>>>> Hi Chuck, I'll jump in here if you don't mind.
>>>>>>>>> 
>>>>>>>>> How's this work for missing keyctl_invalidate:
>>>>>>>>> 
>>>>>>>>> diff --git a/configure.ac b/configure.ac
>>>>>>>>> index 59fd14d..8295bed 100644
>>>>>>>>> --- a/configure.ac
>>>>>>>>> +++ b/configure.ac
>>>>>>>>> @@ -270,6 +270,9 @@ AC_CHECK_LIB([crypt], [crypt], [LIBCRYPT="-lcrypt"])
>>>>>>>>> 
>>>>>>>>> AC_CHECK_LIB([dl], [dlclose], [LIBDL="-ldl"])
>>>>>>>>> 
>>>>>>>>> +AC_CHECK_LIB([keyutils], [keyctl_invalidate], ,[
>>>>>>>>> +       AC_DEFINE([MISSING_KEYCTL_INVALIDATE], [1], [Define to use
>>>>>>>>> keyctl_revoke instead])])
>>>>>>>> 
>>>>>>>> Nit: I would just add
>>>>>>>> 
>>>>>>>> AC_CHECK_FUNCS([keyctl_invalidate])
>>>>>>>> 
>>>>>>>> in aclocal/keyutils.m4 to define HAVE_KEYCTL_INVALIDATE .
>>>>>>> 
>>>>>>> Yes, that is better.
>>>>>>> 
>>>>>>>>> +
>>>>>>>>> if test "$enable_nfsv4" = yes; then
>>>>>>>>> dnl check for libevent libraries and headers
>>>>>>>>> AC_LIBEVENT
>>>>>>>>> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
>>>>>>>>> index e0d31e7..ab4b10c 100644
>>>>>>>>> --- a/utils/nfsidmap/nfsidmap.c
>>>>>>>>> +++ b/utils/nfsidmap/nfsidmap.c
>>>>>>>>> @@ -14,6 +14,7 @@
>>>>>>>>> #include <unistd.h>
>>>>>>>>> #include "xlog.h"
>>>>>>>>> #include "conffile.h"
>>>>>>>>> +#include “config.h"
>>>>>>>>> 
>>>>>>>>> int verbose = 0;
>>>>>>>>> char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key
>>>>>>>>> desc]";
>>>>>>>>> @@ -23,6 +24,10 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] ||
>>>>>>>>> [-t timeout] key desc]";
>>>>>>>>> #define USER  1
>>>>>>>>> #define GROUP 0
>>>>>>>>> 
>>>>>>>>> +#ifdef MISSING_KEYCTL_INVALIDATE
>>>>>>>>> +#define keyctl_invalidate(key) keyctl_revoke(key)
>>>>>>>>> +#endif
>>>>>>>>> +
>>>>>>>>> #define PROCKEYS "/proc/keys"
>>>>>>>>> #ifndef DEFAULT_KEYRING
>>>>>>>>> #define DEFAULT_KEYRING "id_resolver"
>>>>>>>>> 
>>>>>>>>> ^^^ that's a little ugly -- it doesn't try to figure out what should be
>>>>>>>>> done in the kernel to clean up keys.  It assumes that if your
>>>>>>>>> libkeyutils has keyctl_invalidate then that's what you should use.
>>>>>>>> 
>>>>>>>> This looks like it fixes the build issue. I think we do
>>>>>>>> want late-model nfs-utils to build correctly on older
>>>>>>>> distributions.
>>>>>>>> 
>>>>>>>> I’m not sure keyctl_revoke and keyctl_invalidate do
>>>>>>>> precisely the same thing, though? On older systems can
>>>>>>>> we expect a change from one to the other to have no
>>>>>>>> impact? (Just beginning to explore this issue).
>>>>>>> 
>>>>>>> For EL6 kernels, you should be good with keyctl_revoke.  That's the only
>>>>>>> thing you can do - there's no key_invalidate.
>>>>>>> 
>>>>>>> But on later kernels, you'd want to use key_invalidate.
>>>>>> 
>>>>>> I realize that EL6 user space is not designed to support
>>>>>> newer kernels, but some distributions allow continuous
>>>>>> upgrades of kernels. If the kernel API changes over time,
>>>>>> then IMO user space tools need to be sensitive to what
>>>>>> kernel is running.
>>>>> 
>>>>> It would be a lot of work to continually backport adjustments to
>>>>> utilities across the supported/released platforms to allow
>>>>> compatilibilty with upstream kernels; it also reduces the stability
>>>>> of those releases.
>>>>> 
>>>>> It would be nice if it always just worked, but /most/ RHEL customers
>>>>> don't try to run upstream kernels in older releases.
>>>> 
>>>> Just an example:
>>>> 
>>>> Oracle Linux provides updated kernels via the Unbreakable
>>>> Enterprise Kernel releases. The latest release is UEK3, which
>>>> is 3.8-based. It installs on EL6.
>>>> 
>>>> My point of posting here, just to be clear, is that upstream
>>>> nfs-utils no longer builds on systems that have an older
>>>> keyutils. The details particular to EL6 can be resolved, as
>>>> Steve suggested, in an RH bz.
>>>> 
>>>> In the nfsidmap case, I think the extra logic in nfsidmap to
>>>> do the right keyctl call is simple to add and test. That would
>>>> make nfsidmap “just work”.
>>>> 
>>>>>>> The details of the kernel changes are here:
>>>>>>> 
>>>>>>> 0c7774abb41bd00d KEYS: Allow special keys (eg. DNS results) to be
>>>>>>> invalidated by CAP_SYS_ADMIN
>>>>>> 
>>>>>> I think this means the EL6 nfsidmap no longer works quite
>>>>>> right when running 3.17. I’m still studying the problem.
>>>>>> See below.
>>>>>> 
>>>>>>> The summary is that permission changes in later kernels cause
>>>>>>> keyctl_revoke to be unable to clean up keys that are not in possession.
>>>>>>> This specific commit allows that once more for CAP_SYS_ADMIN, so
>>>>>>> really, it should work fine if you have this.  However:
>>>>>>> 
>>>>>>> keyctl_revoke waits key_gc_timeout to clean up the key, and access
>>>>>>> attempts return -EKEYREVOKED.
>>>>>>> 
>>>>>>> keyctl_invalidate immediately removes all references to the key.
>>>>>> 
>>>>>> This change means keyctl_set_timeout fails, since
>>>>>> lookup_user_key returns -EKEYREVOKED, for example, when a
>>>>>> key is revoked instead of invalidated. The key timeouts
>>>>>> are then set to 0 (the default).
>>>>>> 
>>>>>> There is at least one other bug which breaks nfsidmap in
>>>>>> 3.13 and newer kernels. I will post a proposed fix later
>>>>>> today.
>>>>>> 
>>>>>>> The latter is the preferred operation for nfsidmap, since this code path
>>>>>>> exists to allow the admin to flush out a specific key from the idmapper
>>>>>>> cache.
>>>>>> 
>>>>>> EL6 libkeyutils doesn’t have keyctl_invalidate. That
>>>>>> seems to be the crux of the problem (for EL6).
>>>>>> 
>>>>>>> It might be a good idea to just update your libkeyutils along with the kernel
>>>>>>> and nfs-utils.  Maybe we should make a version dependency for
>>>>>>> libkeyutils in nfs-utils.  Steve, what do you think?
>>>>>> 
>>>>>> I don’t know the history of the kernel API, but one
>>>>>> assumes that 2.6.32-vintage kernels don’t have
>>>>>> keyctl_invalidate, since it is missing from older
>>>>>> libkeyutils as well.
>>>>>> 
>>>>>> I think nfs-utils needs both to build with
>>>>>> keyctl_invalidate support if that exists on the build
>>>>>> system, and it needs to pick which of keyctl_revoke
>>>>>> or keyctl_invalidate it will invoke based on the kernel
>>>>>> version where it’s running. That’s pretty easy to do
>>>>>> in nfs-utils.
>>>>>> 
>>>>>> Is keyctl_revoke expected to go away at some point?
>>>>> 
>>>>> I think that it serves an important role in marking keys as existing,
>>>>> but revoked - this can provide a useful type of negative cache to
>>>>> communicate the state of an object. I haven't expected it to go away.
>>>>> 
>>>>>>>>> EL6 systems should be able to do both the request-key (nfsidmap)
>>>>>>>>> and the rpc.idmapd upcall.  I believe that EL6 kernels try both - if the
>>>>>>>>> nfsidmap request-key doesn't work they fall back to the upcall, however
>>>>>>>>> the nfsidmap request-key interface really is the one that should be
>>>>>>>>> used.
>>>>>>>> 
>>>>>>>> I have several EL6 systems here, and at least one of them
>>>>>>>> had rpc.idmapd configured off. I couldn’t remember if I had
>>>>>>>> done that, or it came that way off the installation media.
>>>>>>> 
>>>>>>> I think rpc.idmapd being on/off changed a couple of times in EL6.. I
>>>>>>> don't recall the specifics.
>>>>>> 
>>>>>> Makes sense. My EL6 installs are of various vintages.
>>>>>> 
>>>>>> But that could be a problem when installing a kernel that
>>>>>> causes nfsidmap to fail because the kernel API has changed.
>>>>>> Without the fallback in place, ID mapping will not work.
>>>>> 
>>>>> Ah, but those later kernels will not try the fallback.  :/  Or, maybe
>>>>> there is a set of kernels that are broken that will try the fallback,
>>>>> but later ones won't.
>>>>> 
>>>>> I used to do this when using later kernels with EL6: if it didn't
>>>>> work with EL6 userspace then use upstream nfs-utils, keylibs... etc.  As
>>>>> long as you didn't get into dep-hell, it seemed the simplest path to
>>>>> getting a working system.
>>>> 
>>>> Except that EL6 libkeyutil doesn’t have keyctl_invalidate. So
>>>> there’s no way to build a working nfsidmap without installing
>>>> a newer keyutils. That seems like a step along the path to
>>>> dep-hell that could be prevented with a few careful lines of
>>>> code in nfs-utils.
>>>> 
>>>> I’d like to be able to pull an upstream nfs-utils and build it
>>>> on EL6, at the very least.
>>> 
>>> Yes, I agree.  It occurs to me that you can also call these through the
>>> syscall keyctl(), and pass the function number - so we can bypass a
>>> non-compatible libkeyutils with something like (the untested):
>>> 
>>> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
>>> index e0d31e7..99ae07e 100644
>>> --- a/utils/nfsidmap/nfsidmap.c
>>> +++ b/utils/nfsidmap/nfsidmap.c
>>> @@ -209,10 +209,17 @@ static int key_invalidate(char *keystr, int keymask)
>>>               *(strchr(buf, ' ')) = '\0';
>>>               sscanf(buf, "%x", &key);
>>> 
>>> -               if (keyctl_invalidate(key) < 0) {
>>> -                       xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
>>> -                       fclose(fp);
>>> -                       return 1;
>>> +/* older libkeyutils compatibility */
>>> +#ifndef KEYCTL_INVALIDATE
>>> +#define KEYCTL_INVALIDATE 21      /* invalidate a key */
>>> +#endif
>>> +               if (keyctl(KEYCTL_INVALIDATE, key) < 0 && errno == EOPNOTSUPP) {
>>> +                       /* older kernel compatibility attempt: */
>>> +                       if (keyctl_revoke(key) < 0) {
>>> +                               xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
>>> +                               fclose(fp);
>>> +                               return 1;
>>> +                       }
>>>               }
>>> 
>>>               keymask &= ~mask;
>>> 
>>> This should try to do the keyctl_invalidate if the kernel has it instead
>>> of relying on the stub in libkeyutils.
>> 
>> I tested this with upstream 3.17, 2.6.39-400.209.1.el6uek.x86_64 (UEK2),
>> and 2.6.32-504.el6.x86_64. I think this approach can work.
>> 
>> Upstream 3.17 worked as expected.
>> 
>> UEK2 seems to use only the rpc.idmapd interface, no keys were created,
>> and the test workload ran normally.
>> 
>> 2.6.32-504.el6.x86_64 almost worked.
>> 
>> Oct 30 13:01:58 dali nfsidmap_new[2321]: key: 0x249ea9d9 type: uid value: cel@oracle.com timeout 600
>> Oct 30 13:01:58 dali nfsidmap_new[2321]: nfs4_name_to_uid: calling nsswitch->name_to_uid
>> Oct 30 13:01:58 dali nfsidmap_new[2321]: nss_getpwnam: name 'cel@oracle.com' domain 'oracle.com': resulting localname 'cel'
>> Oct 30 13:01:58 dali nfsidmap_new[2321]: nfs4_name_to_uid: nsswitch->name_to_uid returned 0
>> Oct 30 13:01:58 dali nfsidmap_new[2321]: nfs4_name_to_uid: final return value is 0
>> Oct 30 13:01:58 dali nfsidmap_new[2323]: key: 0x2944b451 type: gid value: users@oracle.com timeout 600
>> Oct 30 13:01:58 dali nfsidmap_new[2323]: nfs4_name_to_gid: calling nsswitch->name_to_gid
>> Oct 30 13:01:58 dali nfsidmap_new[2323]: nfs4_name_to_gid: nsswitch->name_to_gid returned 0
>> Oct 30 13:01:58 dali nfsidmap_new[2323]: nfs4_name_to_gid: final return value is 0
>> 
>> Golden. But nfsidmap_new was not able to set the key timeouts:
>> 
>> [root@dali ~]# cat /proc/keys
>> 020d3315 I--Q--     3 perm 1f3f0000     0    -1 keyring   _uid.0: empty
>> 0bf90e2d I--Q--     5 perm 1f3f0000     0     0 keyring   _ses: 1/4
>> 1a94e9ce I--Q--     1 perm 1f3f0000     0    -1 keyring   _uid_ses.0: 1/4
>> 1f77c0ad I--Q--     1 perm 3f050000     0     0 id_resolv gid:root@oracle.com: 2
>> 249ea9d9 I--Q--     1 perm 3f050000     0     0 id_resolv uid:cel@oracle.com: 5
>> 2944b451 I--Q--     1 perm 3f050000     0     0 id_resolv gid:users@oracle.com: 4
>> 3641d485 I-----     1 perm 1f030000     0     0 keyring   .id_resolver: 4/4
>> 3b10283e I--Q--     1 perm 3f050000     0     0 id_resolv uid:root@oracle.com: 2
>> 
>> I’m not sure if that’s normal for EL6 kernels, since I haven’t
>> used one of the stock EL6 kernels in a while.
> 
> It looks like this problem is unrelated to the above patch and exists
> upstream as well.

Indeed it does.

AFAICT keyctl_set_timeout invokes lookup_user_key(), which now
returns -EKEYREVOKED if keyctl_revoke was used to delete the key.

> Probably the default key permissions do not allow
> nfsidmap to set the timeout during instantiation.  I think that the
> reason it works with EL6 nfsidmap is because EL6 links keys to child
> keyrings to work around the keyring limit, and KEY_POS_SETATTR then
> allows the timeout to be set.  I'll look into it.
> 
> Ben

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



