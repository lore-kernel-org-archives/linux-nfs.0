Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47480 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759100Ab1FAUJV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 16:09:21 -0400
Received: by wya21 with SMTP id 21so123773wya.19
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jun 2011 13:09:20 -0700 (PDT)
Message-ID: <4DE69C6A.3010204@panasas.com>
Date: Wed, 01 Jun 2011 23:09:14 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Weston Andros Adamson <dros@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>, trond@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: filelayout should use nfs_generic_pg_test
References: <1306898310-9229-1-git-send-email-dros@netapp.com>		 <4DE5D287.603@panasas.com>		 <09816808-BA7B-4EAF-A18A-866B5A98BF25@netapp.com>		 <4DE65202.2010502@panasas.com>	 <1306951621.3873.45.camel@lade.trondhjem.org>	 <4DE68F47.5080802@panasas.com> <1306956591.3873.69.camel@lade.trondhjem.org>
In-Reply-To: <1306956591.3873.69.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-01 22:29, Trond Myklebust wrote:
> On Wed, 2011-06-01 at 22:13 +0300, Benny Halevy wrote: 
>> On 2011-06-01 21:07, Trond Myklebust wrote:
>>> On Wed, 2011-06-01 at 17:51 +0300, Benny Halevy wrote: 
>>>> I think the following should work:
>>>>
>>>> Benny
>>>>
>>>> git diff --stat -p -M
>>>>  fs/nfs/nfs4filelayout.c |   10 ++++++++++
>>>>  1 files changed, 10 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>>> index 4269088..9f1d445 100644
>>>> --- a/fs/nfs/nfs4filelayout.c
>>>> +++ b/fs/nfs/nfs4filelayout.c
>>>> @@ -661,6 +661,16 @@ filelayout_pg_test(struct nfs_pageio_descriptor
>>>> *pgio, struct nfs_page *prev,
>>>>  	u64 p_stripe, r_stripe;
>>>>  	u32 stripe_unit;
>>>>
>>>> +	/*
>>>> +	 * FIXME: ideally we should be able to coalesce all requests
>>>> +	 * that are not block boundary aligned, but currently this
>>>> +	 * is problematic for the case of bsize < PAGE_CACHE_SIZE,
>>>> +	 * since nfs_flush_multi and nfs_pagein_multi assume you
>>>> +	 * can have only one struct nfs_page.
>>>> +	 */
>>>> +	if (desc->pg_bsize < PAGE_SIZE)
>>>> +		return 0;
>>>> +
>>>>  	if (!pnfs_generic_pg_test(pgio, prev, req))
>>>>  		return 0;
>>>
>>> So, there are several things that bother me about pnfs_generic_pg_test()
>>> too now that I'm looking more closely at it:
>>>
>>>      1. If the intention is to coalesce 'prev' and 'req', shouldn't we
>>>         be asking for a layout with req_offset(prev) instead of
>>>         req_offset(req)? 
>>>      2. If we're only requesting a layout of length pg_count, don't we
>>>         still need to test the layout length that the server actually
>>>         returned before we can allow the coalescing? 
>>>      3. if (!pgio->lseg), shouldn't we be returning an error of some
>>>         sort? Right now we're returning 'true', and allowing the
>>>         coalesce to occur. 
>>>      4. Furthermore, shouldn't that test guarding the
>>>         pnfs_update_layout() call rather be an 'if (pgio->pg_lseg ==
>>>         NULL)' instead of looking at the values of pg_count and
>>>         prev->wb_bytes?
>>>
>>
>> or rather we get the layout for the first page in
>> nfs_pageio_do_add_request when desc->pg_count == 0?
> 
> I can live with a desc->pg_init() callback or rather, converting
> pg_test() and pg_doio() into a
> 
> struct nfs_pageio_ops {
> 	int (*pg_init)(struct nfs_pageio_descriptor *desc, struct nfs_page *req);
> 	bool (*pg_test)(struct nfs_pageio_descriptor *desc, struct nfs_page *prev, struct nfs_page *req);
> 	int (*pg_doio)(struct nfs_pageio_descriptor *desc);
> };
> 
> and then replacing the two callback functions in the existing struct
> nfs_pageio_descriptor with a single pointer to a 'const struct
> nfs_pageio_ops'...
> 

looks like a good way to do this!

>> Then, this lseg would be useful for nfs_flush_multi
>> if we failed to coalesce, or we failed to get a layout
>> altogether we go the nfs path and can reset pg_test to
>> nfs_generic_pg_test.
> 
> It would presumably also get rid of all those pnfs_update_layout() calls
> in read.c and write.c.
> 

Yup.
