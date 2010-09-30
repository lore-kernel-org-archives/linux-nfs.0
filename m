From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: Re: pnfs git tree status pnfs-all-2.6.36-rc6-2010-09-29
Date: Thu, 30 Sep 2010 11:12:02 +0200
Message-ID: <4CA45462.1070503@desy.de>
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com> <4CA34830.1040703@desy.de> <4CA34883.40005@desy.de> <4CA34B93.2010100@panasas.com> <4CA44AAA.4030803@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:58338 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965Ab0I3JM2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 05:12:28 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id 517681777
	for <linux-nfs@vger.kernel.org>; Thu, 30 Sep 2010 11:12:27 +0200 (MEST)
Received: from adserv71.win.desy.de (adserv71.win.desy.de [131.169.97.57])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 4B17C13EFC
	for <linux-nfs@vger.kernel.org>; Thu, 30 Sep 2010 11:12:27 +0200 (MEST)
In-Reply-To: <4CA44AAA.4030803@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  On 09/30/2010 10:30 AM, Benny Halevy wrote:
> On 2010-09-29 16:22, Benny Halevy wrote:
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
> Applied.
>
did you applied to pnfs-submit as well?
> Benny
>
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
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

