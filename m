Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:47443 "EHLO
	mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177AbcG0BSG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2016 21:18:06 -0400
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 3070BAC0107
	for <linux-nfs@vger.kernel.org>; Wed, 27 Jul 2016 10:06:41 +0900 (JST)
Subject: Re: [PATCH v2] Prevent rqstp->rq_pages[RPCSVC_MAXPAGES] overrun
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <28fb2e47-48ce-1af7-3135-15ca9b4e1726@jp.fujitsu.com>
 <20160726201947.GA8387@fieldses.org>
 <648c8dc8-85f9-0f90-0126-7316d7967691@jp.fujitsu.com>
 <20160727002635.GA12218@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>
From: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Message-ID: <0e15a2d7-f775-6d52-55a6-e64203793ca0@jp.fujitsu.com>
Date: Wed, 27 Jul 2016 10:06:07 +0900
MIME-Version: 1.0
In-Reply-To: <20160727002635.GA12218@fieldses.org>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2016-07-27 09:26, J. Bruce Fields wrote:
> On Wed, Jul 27, 2016 at 08:57:26AM +0900, Seiichi Ikarashi wrote:
>> Hi Bruce,
>>
>> On 2016-07-27 05:19, J. Bruce Fields wrote:
>>> Thanks for the report.
>>>
>>> On Tue, Jul 26, 2016 at 11:38:11AM +0900, Seiichi Ikarashi wrote:
>>>> If over-"RPCSVC_MAXPAGES" pages are sent from file system through pipe_buffer,
>>>> nfsd_splice_actor() corrupts struct svc_rqst and results in kernel panic. It
>>>> actually occurred with a parallel distributed file system. It needs boundary
>>>> checking.
>>>
>>> This check might be useful as defensive programming, but the bug was
>>> elsewhere.
>>
>> Yah, I think the main factor exists in file system and/or VFS splice sides.
>> But I also think that NFS should defend itself against overlimit pages
>> because the limit is decided by NFS/SUNRPC, not by file system and others.
>>
>>>
>>> In theory this should be prevented by the "maxcount" calculations in
>>> nfsd4_encode_read().
>>
>> The "maxcount" looks just limiting the read length from the file system.
>> Is my understanding correct?
> 
> Right.
> 
>>
>> And the number of pages provided from the file system is up to the file system.
>> The file system can split the read data into an arbitrary number of pages.
> 
> Oh, so if we ask the filesystem for 3 bytes it might potentially return
> those in 3 separate pages?  Is that at all legal?

I think the code actually permits such a split though I am not sure that
one-single-byte-per-page situation really happens. :-)
For example, on 4kB-page architecture, 1kB-data-per-page placement will result
in 4 times larger number of pages than expected.
I do not know whether it's legal or not.

I thought NFS needs to defend itself against such large numbers,
or, can somewhere in VFS splice merge such pages into a minimum set of pages?
I cannot find such code in VFS.

Opinions or suggestions?

Seiichi.

> 
>>> What version of the kernel did you see this happen on?  What was the
>>> client, and what was it doing?  Any other hints on reproducing?
>>
>> It was a NFSv3 read access from a client of maybe-Linux-based system
>> against the server of RHEL6 system exporting a file system that I cannot
>> access its source code. Sorry for lack of info.
> 
> OK, understood.
> 
> --b.
> 
>>
>>
>> Seiichi.
>>
>>
>>>
>>> --b.
>>>
>>>>
>>>> v2: Fix semicolon-missing bug.
>>>>
>>>> Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
>>>>
>>>> ---
>>>>  fs/nfsd/vfs.c | 8 ++++++++
>>>>  1 file changed, 8 insertions(+)
>>>>
>>>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>>>> index 6fbd81e..43393f3 100644
>>>> --- a/fs/nfsd/vfs.c
>>>> +++ b/fs/nfsd/vfs.c
>>>> @@ -811,12 +811,20 @@ nfsd_splice_actor(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
>>>>  	size = sd->len;
>>>>  
>>>>  	if (rqstp->rq_res.page_len == 0) {
>>>> +		if (rqstp->rq_next_page > &rqstp->rq_pages[RPCSVC_MAXPAGES-1]) {
>>>> +			WARN_ON(1);
>>>> +			return -ENOMEM;
>>>> +		}
>>>>  		get_page(page);
>>>>  		put_page(*rqstp->rq_next_page);
>>>>  		*(rqstp->rq_next_page++) = page;
>>>>  		rqstp->rq_res.page_base = buf->offset;
>>>>  		rqstp->rq_res.page_len = size;
>>>>  	} else if (page != pp[-1]) {
>>>> +		if (rqstp->rq_next_page > &rqstp->rq_pages[RPCSVC_MAXPAGES-1]) {
>>>> +			WARN_ON(1);
>>>> +			return -ENOMEM;
>>>> +		}
>>>>  		get_page(page);
>>>>  		if (*rqstp->rq_next_page)
>>>>  			put_page(*rqstp->rq_next_page);
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> .
>>>
> .
> 

