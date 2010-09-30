Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-2.desy.de ([131.169.56.85]:60788 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755081Ab0I3H6v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 03:58:51 -0400
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id B272D11A7
	for <linux-nfs@vger.kernel.org>; Thu, 30 Sep 2010 09:58:50 +0200 (MEST)
Received: from adserv72.win.desy.de (adserv72.win.desy.de [131.169.97.58])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id A77BD11A6
	for <linux-nfs@vger.kernel.org>; Thu, 30 Sep 2010 09:58:50 +0200 (MEST)
Message-ID: <4CA44321.2080904@desy.de>
Date: Thu, 30 Sep 2010 09:58:25 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Benny Halevy <bhalevy@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: pnfs git tree status pnfs-all-2.6.36-rc6-2010-09-29
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com> <4CA34830.1040703@desy.de> <4CA34883.40005@desy.de> <4CA34B93.2010100@panasas.com> <4CA34F05.3020809@desy.de> <4CA35A59.9020303@panasas.com>
In-Reply-To: <4CA35A59.9020303@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  I recompiled kernel with debug symbols and problem is gone.
Crap!
Or, as Fred suspected, I did not apply you patch second time.

Regards,
    Tigran.

On 09/29/2010 05:25 PM, Benny Halevy wrote:
> On 2010-09-29 16:36, Tigran Mkrtchyan wrote:
>>    On 09/29/2010 04:22 PM, Benny Halevy wrote:
>>> On 2010-09-29 16:09, Tigran Mkrtchyan wrote:
>>>>     On 09/29/2010 04:07 PM, Tigran Mkrtchyan wrote:
>>>>> I am support to publish first kernel crash.....
>>>> sorry to publish....
>>>>
>>>>> this is
>>>>> pnfs-all-2.6.36-rc6-2010-09-29 git
>>>>> c2b3b75c6b1db1dfc3f236200de1763e14c514d8
>>>>>
>>>>> Regards,
>>>>>      Tigran.
>>>>>
>>>>>
>>> Thanks for testing!
>>> Does the following patch help?
>>>
>> No :(
>>
> Tigran, do you have a new trace maybe?
> I cross referenced the dump you sent to the
> disassembled code and it seems like it hit NULL dereference on
> size = fl->stripe_unit;
>
> I'm going to commit this patch anyway but I want to
> understand what else I missed...
>
> Benny
>
>>> git diff --stat -p -M
>>>    fs/nfs/nfs4filelayout.c |    2 ++
>>>    1 files changed, 2 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>> index 75e07c8..8fbb0db 100644
>>> --- a/fs/nfs/nfs4filelayout.c
>>> +++ b/fs/nfs/nfs4filelayout.c
>>> @@ -636,6 +636,8 @@ filelayout_get_stripesize(struct pnfs_layout_hdr *lo)
>>>
>>>    	/* Horrible hack...ideally upper layer would send lseg */
>>>    	lseg = pnfs_has_layout(lo,&range);
>>> +	if (!lseg)
>>> +		return 0;
>>>    	fl = container_of(lseg, struct nfs4_filelayout_segment, generic_hdr);
>>>    	size = fl->stripe_unit;
>>>    	put_lseg_locked(lseg);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

