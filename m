Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:56866 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481Ab1FISoD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 14:44:03 -0400
Received: by ywe9 with SMTP id 9so955699ywe.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2011 11:44:01 -0700 (PDT)
Message-ID: <4DF11464.60802@panasas.com>
Date: Thu, 09 Jun 2011 14:43:48 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSv4.1: Fix some issues with pnfs_generic_pg_test
References: <1307399551-17489-1-git-send-email-Trond.Myklebust@netapp.com>		 <4DEEC808.40205@panasas.com> <1307495548.12587.5.camel@lade.trondhjem.org>	 <4DEEDD59.5030902@panasas.com> <1307637069.20245.8.camel@lade.trondhjem.org>
In-Reply-To: <1307637069.20245.8.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-09 12:31, Trond Myklebust wrote:
> On Tue, 2011-06-07 at 22:24 -0400, Benny Halevy wrote: 
>> On 2011-06-07 21:12, Trond Myklebust wrote:
>>> On Tue, 2011-06-07 at 20:53 -0400, Benny Halevy wrote: 
>>>> On 2011-06-06 18:32, Trond Myklebust wrote:
>>>>> 1. If the intention is to coalesce requests 'prev' and 'req' then we
>>>>>    have to ensure at least that we have a layout starting at
>>>>>    req_offset(prev).
>>>>>
>>>>> 2. If we're only requesting a minimal layout of length desc->pg_count,
>>>>>    we need to test the length actually returned by the server before
>>>>>    we allow the coalescing to occur.
>>>>>
>>>>> 3. We need to deal correctly with (pgio->lseg == NULL)
>>>>>
>>>>> 4. Fixup the test guarding the pnfs_update_layout.
>>>>>
>>>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>>>> ---
>>>>>  fs/nfs/objlayout/objio_osd.c |    3 +++
>>>>>  fs/nfs/pnfs.c                |   12 +++++++-----
>>>>>  2 files changed, 10 insertions(+), 5 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
>>>>> index 9cf208d..4c41a60 100644
>>>>> --- a/fs/nfs/objlayout/objio_osd.c
>>>>> +++ b/fs/nfs/objlayout/objio_osd.c
>>>>> @@ -1001,6 +1001,9 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
>>>>>  	if (!pnfs_generic_pg_test(pgio, prev, req))
>>>>>  		return false;
>>>>>  
>>>>> +	if (pgio->pg_lseg == NULL)
>>>>> +		return true;
>>>>> +
>>>>>  	return pgio->pg_count + req->wb_bytes <=
>>>>>  			OBJIO_LSEG(pgio->pg_lseg)->max_io_size;
>>>>>  }
>>>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>>>> index 8c1309d..12b53ef 100644
>>>>> --- a/fs/nfs/pnfs.c
>>>>> +++ b/fs/nfs/pnfs.c
>>>>> @@ -1059,19 +1059,21 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>>>>>  		gfp_flags = GFP_NOFS;
>>>>>  	}
>>>>>  
>>>>> -	if (pgio->pg_count == prev->wb_bytes) {
>>>>> +	if (pgio->pg_lseg == NULL) {
>>>>> +		if (pgio->pg_count != prev->wb_bytes)
>>>>> +			return true;
>>>>>  		/* This is first coelesce call for a series of nfs_pages */
>>>>>  		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
>>>>>  						   prev->wb_context,
>>>>> -						   req_offset(req),
>>>>> +						   req_offset(prev),
>>>>>  						   pgio->pg_count,
>>>>>  						   access_type,
>>>>>  						   gfp_flags);
>>>>> -		return true;
>>>>> +		if (pgio->pg_lseg == NULL)
>>>>> +			return true;
>>>>>  	}
>>>>>  
>>>>> -	if (pgio->pg_lseg &&
>>>>> -	    req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
>>>>> +	if (req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
>>>>
>>>> One more issue to fix: the condition should be for ">=", not ">"
>>>
>>> Hmm.... Shouldn't it rather be:
>>>
>>> if (end_offset(req_offset(req), req->wb_bytes) > end_offset(pgio->pg_lseg->pls_range.offset,
>>> 		pgio->pg_lseg->pls_range.length))
>>> 	return false;
>>>
>>> Otherwise you don't know if the entire request fits in this layout
>>> segment...
>>
>> True.
>> Though since we make sure the layout segments are page aligned
>> having the first offset covered is enough, this is the correct
>> way to express the condition.
> 
> Ugh... That definitely would require a comment, and probably deserves a
> helper function of its own.
> 

Agreed. I'm totally with you on your proposal.

> Also, the name 'end_offset()' is rather confusing. It really is the
> offset of the first byte that lies _outside_ the actual layout segment.
> 

Correct. I do not mind changing it to a better name if you have something
in mind.

Benny
