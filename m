Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51680 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750987AbdGaPPc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 31 Jul 2017 11:15:32 -0400
Subject: Re: [Libtirpc-devel] [PATCH] Replace bzero() calls with equivalent
 memset() calls
To: Joshua Kinard <kumba@gentoo.org>,
        Chuck Lever <chucklever@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
References: <47646199-1784-f1ac-23ae-eedaf3a24c95@gentoo.org>
 <C52540F1-EF74-4D0F-BA55-43F094AC8D8E@gmail.com>
 <dde02052-0832-ade8-ff38-b1a52f26b78d@gentoo.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <f83878fe-371b-03b9-9d5b-cd91a934ed66@RedHat.com>
Date: Mon, 31 Jul 2017 11:15:30 -0400
MIME-Version: 1.0
In-Reply-To: <dde02052-0832-ade8-ff38-b1a52f26b78d@gentoo.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/31/2017 11:05 AM, Joshua Kinard wrote:
> On 07/31/2017 10:35, Chuck Lever wrote:
>>
>>> On Jul 31, 2017, at 12:25 AM, Joshua Kinard <kumba@gentoo.org> wrote:
>>>
>>> As annotated in the bzero(3) man page, bzero() was marked as LEGACY in
>>> POSIX.1-2001 and removed in POSIX.1-2008, and should be replaced with
>>> memset() calls to write zeros to a memory region.  The attached patch
>>> replaces two bzero() calls and one __bzero() call in libtirpc with
>>> equivalent memset() calls.  The latter replacement fixes a compile error
>>> under uclibc-ng, which lacks a definition for __bzero()
>>
>> OK. Nits below.
>>
>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>>
>>
>>> Signed-off-by: Joshua Kinard <kumba@gentoo.org>
>>> ---
>>>
>>> src/auth_time.c    |    2 +-
>>> src/des_impl.c     |    2 +-
>>> src/svc_auth_des.c |    2 +-
>>> 3 files changed, 3 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/src/auth_time.c b/src/auth_time.c
>>> index 7f83ab4..210d251 100644
>>> --- a/src/auth_time.c
>>> +++ b/src/auth_time.c
>>> @@ -317,7 +317,7 @@ __rpc_get_time_offset(td, srv, thost, uaddr, netid)
>>> 	sprintf(ipuaddr, "%d.%d.%d.%d.0.111", a1, a2, a3, a4);
>>> 	useua = &ipuaddr[0];
>>>
>>> -	bzero((char *)&sin, sizeof(sin));
>>> +	memset((char *)&sin, 0, sizeof(sin));
>>
>> The type cast is likely to be unnecessary, and
>> could be removed in this patch.
> 
> Wasn't trying to solve all of the problems at once.  Figured it was better to
> go for the straight replace.  I'll update the patch and resend with this change.
> 
> 
> 
>>> 	if (uaddr_to_sockaddr(useua, &sin)) {
>>> 		msg("unable to translate uaddr to sockaddr.");
>>> 		if (needfree)
>>> diff --git a/src/des_impl.c b/src/des_impl.c
>>> index 9dbccaf..15bec2a 100644
>>> --- a/src/des_impl.c
>>> +++ b/src/des_impl.c
>>> @@ -588,7 +588,7 @@ _des_crypt (char *buf, unsigned len, struct desparams *desp)
>>>     }
>>>   tin0 = tin1 = tout0 = tout1 = xor0 = xor1 = 0;
>>>   tbuf[0] = tbuf[1] = 0;
>>> -  __bzero (schedule, sizeof (schedule));
>>> +  memset (schedule, 0, sizeof (schedule));
>>
>> You should fix the white space damage here
>> (space before left paren, x2).
> 
> IMHO, I think that, for now, the whitespace damage should be left as-is.
> Similar damage is prolific in the entire source file, so it should be fixed all
> at once in a separate patch to keep the change history consistent.  I can send
> something in for just this file later on, but after this patch is applied.
I agree... leave as is.. 

> 
> 
>>>   return (1);
>>> }
>>> diff --git a/src/svc_auth_des.c b/src/svc_auth_des.c
>>> index 2e90146..64a7682 100644
>>> --- a/src/svc_auth_des.c
>>> +++ b/src/svc_auth_des.c
>>> @@ -356,7 +356,7 @@ cache_init()
>>>
>>> 	authdes_cache = (struct cache_entry *)
>>> 		mem_alloc(sizeof(struct cache_entry) * AUTHDES_CACHESZ);	
>>> -	bzero((char *)authdes_cache, 
>>> +	memset((char *)authdes_cache, 0,
>>> 		sizeof(struct cache_entry) * AUTHDES_CACHESZ);
>>
>> Type cast is unnecessary.
> 
> Will be updated in a v2 later on.
Sounds like a plan... better sooner vs later.. ;-)

steved.

> 
> Thanks for the review!
> 
