Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:40694 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055Ab1FHCYV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 22:24:21 -0400
Received: by vxi39 with SMTP id 39so46634vxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2011 19:24:21 -0700 (PDT)
Message-ID: <4DEEDD59.5030902@panasas.com>
Date: Tue, 07 Jun 2011 22:24:25 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSv4.1: Fix some issues with pnfs_generic_pg_test
References: <1307399551-17489-1-git-send-email-Trond.Myklebust@netapp.com>	 <4DEEC808.40205@panasas.com> <1307495548.12587.5.camel@lade.trondhjem.org>
In-Reply-To: <1307495548.12587.5.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-07 21:12, Trond Myklebust wrote:
> On Tue, 2011-06-07 at 20:53 -0400, Benny Halevy wrote: 
>> On 2011-06-06 18:32, Trond Myklebust wrote:
>>> 1. If the intention is to coalesce requests 'prev' and 'req' then we
>>>    have to ensure at least that we have a layout starting at
>>>    req_offset(prev).
>>>
>>> 2. If we're only requesting a minimal layout of length desc->pg_count,
>>>    we need to test the length actually returned by the server before
>>>    we allow the coalescing to occur.
>>>
>>> 3. We need to deal correctly with (pgio->lseg == NULL)
>>>
>>> 4. Fixup the test guarding the pnfs_update_layout.
>>>
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> ---
>>>  fs/nfs/objlayout/objio_osd.c |    3 +++
>>>  fs/nfs/pnfs.c                |   12 +++++++-----
>>>  2 files changed, 10 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
>>> index 9cf208d..4c41a60 100644
>>> --- a/fs/nfs/objlayout/objio_osd.c
>>> +++ b/fs/nfs/objlayout/objio_osd.c
>>> @@ -1001,6 +1001,9 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
>>>  	if (!pnfs_generic_pg_test(pgio, prev, req))
>>>  		return false;
>>>  
>>> +	if (pgio->pg_lseg == NULL)
>>> +		return true;
>>> +
>>>  	return pgio->pg_count + req->wb_bytes <=
>>>  			OBJIO_LSEG(pgio->pg_lseg)->max_io_size;
>>>  }
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index 8c1309d..12b53ef 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -1059,19 +1059,21 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>>>  		gfp_flags = GFP_NOFS;
>>>  	}
>>>  
>>> -	if (pgio->pg_count == prev->wb_bytes) {
>>> +	if (pgio->pg_lseg == NULL) {
>>> +		if (pgio->pg_count != prev->wb_bytes)
>>> +			return true;
>>>  		/* This is first coelesce call for a series of nfs_pages */
>>>  		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
>>>  						   prev->wb_context,
>>> -						   req_offset(req),
>>> +						   req_offset(prev),
>>>  						   pgio->pg_count,
>>>  						   access_type,
>>>  						   gfp_flags);
>>> -		return true;
>>> +		if (pgio->pg_lseg == NULL)
>>> +			return true;
>>>  	}
>>>  
>>> -	if (pgio->pg_lseg &&
>>> -	    req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
>>> +	if (req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
>>
>> One more issue to fix: the condition should be for ">=", not ">"
> 
> Hmm.... Shouldn't it rather be:
> 
> if (end_offset(req_offset(req), req->wb_bytes) > end_offset(pgio->pg_lseg->pls_range.offset,
> 		pgio->pg_lseg->pls_range.length))
> 	return false;
> 
> Otherwise you don't know if the entire request fits in this layout
> segment...

True.
Though since we make sure the layout segments are page aligned
having the first offset covered is enough, this is the correct
way to express the condition.

Benny

> 
> Cheers
>   Trond
