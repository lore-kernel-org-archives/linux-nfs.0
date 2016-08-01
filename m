Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mgwym01.jp.fujitsu.com ([211.128.242.40]:34720 "EHLO
	mgwym01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbcHAKOi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2016 06:14:38 -0400
Subject: Re: [PATCH v2] Prevent rqstp->rq_pages[RPCSVC_MAXPAGES] overrun
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <28fb2e47-48ce-1af7-3135-15ca9b4e1726@jp.fujitsu.com>
 <20160726201947.GA8387@fieldses.org>
 <648c8dc8-85f9-0f90-0126-7316d7967691@jp.fujitsu.com>
 <20160727002635.GA12218@fieldses.org>
 <0e15a2d7-f775-6d52-55a6-e64203793ca0@jp.fujitsu.com>
 <20160728182511.GA30034@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
From: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Message-ID: <af764780-6220-14ac-16eb-ec0623af4ccc@jp.fujitsu.com>
Date: Mon, 1 Aug 2016 18:43:11 +0900
MIME-Version: 1.0
In-Reply-To: <20160728182511.GA30034@fieldses.org>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2016-07-29 03:25, J. Bruce Fields wrote:
> On Wed, Jul 27, 2016 at 10:06:07AM +0900, Seiichi Ikarashi wrote:
>> On 2016-07-27 09:26, J. Bruce Fields wrote:
>>> On Wed, Jul 27, 2016 at 08:57:26AM +0900, Seiichi Ikarashi wrote:
>>>> Hi Bruce,
>>>>
>>>> On 2016-07-27 05:19, J. Bruce Fields wrote:
>>>>> Thanks for the report.
>>>>>
>>>>> On Tue, Jul 26, 2016 at 11:38:11AM +0900, Seiichi Ikarashi wrote:
>>>>>> If over-"RPCSVC_MAXPAGES" pages are sent from file system through pipe_buffer,
>>>>>> nfsd_splice_actor() corrupts struct svc_rqst and results in kernel panic. It
>>>>>> actually occurred with a parallel distributed file system. It needs boundary
>>>>>> checking.
>>>>>
>>>>> This check might be useful as defensive programming, but the bug was
>>>>> elsewhere.
>>>>
>>>> Yah, I think the main factor exists in file system and/or VFS splice sides.
>>>> But I also think that NFS should defend itself against overlimit pages
>>>> because the limit is decided by NFS/SUNRPC, not by file system and others.
>>>>
>>>>>
>>>>> In theory this should be prevented by the "maxcount" calculations in
>>>>> nfsd4_encode_read().
>>>>
>>>> The "maxcount" looks just limiting the read length from the file system.
>>>> Is my understanding correct?
>>>
>>> Right.
>>>
>>>>
>>>> And the number of pages provided from the file system is up to the file system.
>>>> The file system can split the read data into an arbitrary number of pages.
>>>
>>> Oh, so if we ask the filesystem for 3 bytes it might potentially return
>>> those in 3 separate pages?  Is that at all legal?
>>
>> I think the code actually permits such a split though I am not sure that
>> one-single-byte-per-page situation really happens. :-)
>> For example, on 4kB-page architecture, 1kB-data-per-page placement will result
>> in 4 times larger number of pages than expected.
>> I do not know whether it's legal or not.
>>
>> I thought NFS needs to defend itself against such large numbers,
>> or, can somewhere in VFS splice merge such pages into a minimum set of pages?
>> I cannot find such code in VFS.
>>
>> Opinions or suggestions?
> 
> I don't know the splice interface well, but suspect the filesystem's in
> the wrong here.
> 
> Checking for overflow of the page array isn't sufficient to catch any
> such problems; if the filesystem gives us a smaller number of partial
> pages, I'd guess (not having tested) that nfsd is just going to assume
> the full page should be used, and end up sending uninitialized data back
> to the client.

I see. Now I understood why nfsd_splice_actor() ignores buf->offset if
rqstp->rq_res.page_len != 0. It premises consecutive, non-sparse data
filling in multi-pages through pipe_buffer.

I agree that checking for the overflow only is definitely insufficient.

> 
> So I wouldn't necessarily be opposed to a simple check for a misbehaving
> filesystem here, but if the required checks are more complicated and if
> we've only ever seen it against an out-of-tree filesystem then I'm less
> interested.

Yah, it was an independent file system case.

Seeing the linus tree, most file systems are just using generic_file_splice_read()
as splice_read method. So the call sequence will be...

...
=> splice_direct_to_actor()
   => do_splice_to()
      => generic_file_splice_read()
        => __generic_file_splice_read()

Here __generic_file_splice_read() looks permitting partial pages.
So it might be possible theoretically with one of in-tree file systems,
but I'm no sure...

Any comment from file system guys are welcome :-)

Seiichi.



