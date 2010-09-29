Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:18240 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753452Ab0I2PZQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 11:25:16 -0400
Message-ID: <4CA35A59.9020303@panasas.com>
Date: Wed, 29 Sep 2010 17:25:13 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: pnfs git tree status pnfs-all-2.6.36-rc6-2010-09-29
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com> <4CA34830.1040703@desy.de> <4CA34883.40005@desy.de> <4CA34B93.2010100@panasas.com> <4CA34F05.3020809@desy.de>
In-Reply-To: <4CA34F05.3020809@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-29 16:36, Tigran Mkrtchyan wrote:
>   On 09/29/2010 04:22 PM, Benny Halevy wrote:
>> On 2010-09-29 16:09, Tigran Mkrtchyan wrote:
>>>    On 09/29/2010 04:07 PM, Tigran Mkrtchyan wrote:
>>>> I am support to publish first kernel crash.....
>>> sorry to publish....
>>>
>>>> this is
>>>> pnfs-all-2.6.36-rc6-2010-09-29 git
>>>> c2b3b75c6b1db1dfc3f236200de1763e14c514d8
>>>>
>>>> Regards,
>>>>     Tigran.
>>>>
>>>>
>> Thanks for testing!
>> Does the following patch help?
>>
> 
> No :(
> 

Tigran, do you have a new trace maybe?
I cross referenced the dump you sent to the
disassembled code and it seems like it hit NULL dereference on 
size = fl->stripe_unit;

I'm going to commit this patch anyway but I want to
understand what else I missed...

Benny

>> git diff --stat -p -M
>>   fs/nfs/nfs4filelayout.c |    2 ++
>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index 75e07c8..8fbb0db 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -636,6 +636,8 @@ filelayout_get_stripesize(struct pnfs_layout_hdr *lo)
>>
>>   	/* Horrible hack...ideally upper layer would send lseg */
>>   	lseg = pnfs_has_layout(lo,&range);
>> +	if (!lseg)
>> +		return 0;
>>   	fl = container_of(lseg, struct nfs4_filelayout_segment, generic_hdr);
>>   	size = fl->stripe_unit;
>>   	put_lseg_locked(lseg);
> 
