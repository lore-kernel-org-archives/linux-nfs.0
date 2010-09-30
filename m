Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:4599 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751480Ab0I3JR6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 05:17:58 -0400
Message-ID: <4CA455C4.4030705@panasas.com>
Date: Thu, 30 Sep 2010 11:17:56 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: pnfs git tree status pnfs-all-2.6.36-rc6-2010-09-29
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com> <4CA34830.1040703@desy.de> <4CA34883.40005@desy.de> <4CA34B93.2010100@panasas.com> <4CA44AAA.4030803@panasas.com> <4CA45462.1070503@desy.de>
In-Reply-To: <4CA45462.1070503@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-30 11:12, Tigran Mkrtchyan wrote:
>   On 09/30/2010 10:30 AM, Benny Halevy wrote:
>> On 2010-09-29 16:22, Benny Halevy wrote:
>>> On 2010-09-29 16:09, Tigran Mkrtchyan wrote:
>>>>    On 09/29/2010 04:07 PM, Tigran Mkrtchyan wrote:
>>>>> I am support to publish first kernel crash.....
>>>> sorry to publish....
>>>>
>>>>> this is
>>>>> pnfs-all-2.6.36-rc6-2010-09-29 git
>>>>> c2b3b75c6b1db1dfc3f236200de1763e14c514d8
>>>>>
>>>>> Regards,
>>>>>     Tigran.
>>>>>
>>>>>
>>> Thanks for testing!
>>> Does the following patch help?
>>>
>> Applied.
>>
> did you applied to pnfs-submit as well?

Not yet.  It's in pnfs-all-latest until the next rebase.
I planned to do it tomorrow before I leave for Boston in case more patches
are required, unless folks want to test pnfs-submit / pnfs-submit-all with
these fixes right now.

Benny

>> Benny
>>
>>> git diff --stat -p -M
>>>   fs/nfs/nfs4filelayout.c |    2 ++
>>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>> index 75e07c8..8fbb0db 100644
>>> --- a/fs/nfs/nfs4filelayout.c
>>> +++ b/fs/nfs/nfs4filelayout.c
>>> @@ -636,6 +636,8 @@ filelayout_get_stripesize(struct pnfs_layout_hdr *lo)
>>>
>>>   	/* Horrible hack...ideally upper layer would send lseg */
>>>   	lseg = pnfs_has_layout(lo,&range);
>>> +	if (!lseg)
>>> +		return 0;
>>>   	fl = container_of(lseg, struct nfs4_filelayout_segment, generic_hdr);
>>>   	size = fl->stripe_unit;
>>>   	put_lseg_locked(lseg);
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
