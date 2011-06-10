Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46448 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab1FJQOX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 12:14:23 -0400
Message-ID: <4DF242D7.4030607@panasas.com>
Date: Fri, 10 Jun 2011 09:14:15 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] NFSv4.1: Add an initialisation callback for pNFS
References: <1307669462-15764-1-git-send-email-Trond.Myklebust@netapp.com> <1307669462-15764-2-git-send-email-Trond.Myklebust@netapp.com> <1307669462-15764-3-git-send-email-Trond.Myklebust@netapp.com> <1307669462-15764-4-git-send-email-Trond.Myklebust@netapp.com> <4DF1871C.1070001@panasas.com> <4DF19841.5030904@panasas.com> <4DF19D7B.2060308@panasas.com> <4DF1A106.3070205@panasas.com>
In-Reply-To: <4DF1A106.3070205@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/09/2011 09:43 PM, Benny Halevy wrote:
> On 2011-06-10 00:28, Boaz Harrosh wrote:
>> On 06/09/2011 09:06 PM, Benny Halevy wrote:
>>> On 2011-06-09 22:53, Boaz Harrosh wrote:
>>>> On 06/09/2011 06:31 PM, Trond Myklebust wrote:
>>>> <snip>
>>>>> +void
>>>>> +pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
>>>>> +{
>>>>> +	BUG_ON(pgio->pg_lseg != NULL);
>>>>> +
>>>>> +	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
>>>>> +					   req->wb_context,
>>>>> +					   req_offset(req),
>>>>> +					   req->wb_bytes,
>>>>> +					   IOMODE_READ,
>>>>> +					   GFP_KERNEL);
>>>>> +}
>>>>> +EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
>>>>> +
>>>>> +void
>>>>> +pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
>>>>> +{
>>>>> +	BUG_ON(pgio->pg_lseg != NULL);
>>>>> +
>>>>> +	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
>>>>> +					   req->wb_context,
>>>>> +					   req_offset(req),
>>>>> +					   req->wb_bytes,
>>>>> +					   IOMODE_RW,
>>>>> +					   GFP_NOFS);
>>>>> +}
>>>>> +EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
>>>>> +
>>>>
>>>> These two above are identical except the IOMODE_{READ,RW} variable.
>>>
>>> And the respective gfp flags...
>>>
>>
>> So is that "we should" or should-not?
>>
> 
> That doesn't make much sense when you've defined separate vectors
> for read and write.

So what the same function is set at both vectors, and the few callers (1)
passes a flag.

If you ask me we could do with one vector and a flag throughout this
stack. Actually don't make the flag as function parameter but as a member
of nfs_pageio_descriptor. For example in osd we want to know if we are
reading or writing in the raid5 case it produces different results.

> And in any case, since pg_init is not pnfs specific the caller shouldn't
> pass IOMODE_* values but rather a generic value that will require translation anyway.
> In this case I'd just consider using a common function to be called
> respectively from both methods:
> 
> static void
> pnfs_pg_update_layout(struct nfs_pageio_descriptor *pgio, struct nfs_page *req,
> 		      enum pnfs_iomode iomode, gfp_t gfp_flags)
> {
> 	BUG_ON(pgio->pg_lseg != NULL);
> 
> 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
> 					   req->wb_context,
> 					   req_offset(req),
> 					   req->wb_bytes,
> 					   iomode,
> 					   gfp_flags);
> }
> 

That makes it even more complicated for a do nothing function. We dont do
a different function for each different parameter. We can just do a 
"bool write" and unify the dam thing

Boaz
