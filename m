Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24175 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164Ab1BPUI5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Feb 2011 15:08:57 -0500
Message-ID: <4D5C2ED8.1030200@panasas.com>
Date: Wed, 16 Feb 2011 15:08:56 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: andros@netapp.com, trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Andy Adamon <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Oleg Drokin <green@linuxhacker.ru>
Subject: Re: [PATCH pNFS wave 3 Version 2 10/18] NFSv4.1: shift pnfs_update_layout
 locations
References: <1297759143-2045-1-git-send-email-andros@netapp.com> <1297759143-2045-11-git-send-email-andros@netapp.com> <4D5C28B3.5010206@panasas.com> <3CAD00F0-0B5E-4A70-B3AA-265E75100DD6@netapp.com>
In-Reply-To: <3CAD00F0-0B5E-4A70-B3AA-265E75100DD6@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-16 14:55, Fred Isaman wrote:
> 
> On Feb 16, 2011, at 2:42 PM, Benny Halevy wrote:
> 
>> On 2011-02-15 03:38, andros@netapp.com wrote:
>>> From: Fred Isaman <iisaman@netapp.com>
>>>
>>> Move the pnfs_update_layout call location to nfs_pageio_do_add_request().
>>> Grab the lseg sent in the doio function to nfs_read_rpcsetup and attach
>>> it to each nfs_read_data so it can be sent to the layout driver.
>>>
>>> @@ -131,10 +132,12 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
>>> 		zero_user_segment(page, len, PAGE_CACHE_SIZE);
>>>
>>> 	nfs_list_add_request(new, &one_request);
>>> +	lseg = pnfs_update_layout(inode, ctx, IOMODE_READ);
>>> 	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
>>> -		nfs_pagein_multi(inode, &one_request, 1, len, 0);
>>> +		nfs_pagein_multi(inode, &one_request, 1, len, 0, lseg);
>>> 	else
>>> -		nfs_pagein_one(inode, &one_request, 1, len, 0);
>>> +		nfs_pagein_one(inode, &one_request, 1, len, 0, lseg);
>>> +	put_lseg(lseg);
>>> 	return 0;
>>> }
>>>
>>> @@ -160,7 +163,8 @@ static void nfs_readpage_release(struct nfs_page *req)
>>>  */
>>> static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
>>> 		const struct rpc_call_ops *call_ops,
>>> -		unsigned int count, unsigned int offset)
>>> +		unsigned int count, unsigned int offset,
>>> +		struct pnfs_layout_segment *lseg)
>>> {
>>> 	struct inode *inode = req->wb_context->path.dentry->d_inode;
>>> 	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
>>> @@ -183,6 +187,7 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
>>> 	data->req	  = req;
>>> 	data->inode	  = inode;
>>> 	data->cred	  = msg.rpc_cred;
>>> +	data->lseg	  = get_lseg(lseg);
>>>
>>> 	data->args.fh     = NFS_FH(inode);
>>> 	data->args.offset = req_offset(req) + offset;
>>> @@ -240,7 +245,7 @@ nfs_async_read_error(struct list_head *head)
>>>  * won't see the new data until our attribute cache is updated.  This is more
>>>  * or less conventional NFS client behavior.
>>>  */
>>> -static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
>>> +static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags, struct pnfs_layout_segment *lseg)
>>> {
>>> 	struct nfs_page *req = nfs_list_entry(head->next);
>>> 	struct page *page = req->wb_page;
>>> @@ -266,6 +271,8 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
>>> 	} while(nbytes != 0);
>>> 	atomic_set(&req->wb_complete, requests);
>>>
>>> +	/* We know lseg==NULL */

Can you provide more details?
If it's always NULL why bother to pass it in?

>>> +	lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_READ);
>>> 	ClearPageError(page);
>>> 	offset = 0;
>>> 	nbytes = count;
>>> @@ -280,12 +287,13 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
>>> 		if (nbytes < rsize)
>>> 			rsize = nbytes;
>>> 		ret2 = nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
>>> -				  rsize, offset);
>>> +					 rsize, offset, lseg);
>>> 		if (ret == 0)
>>> 			ret = ret2;
>>> 		offset += rsize;
>>> 		nbytes -= rsize;
>>> 	} while (nbytes != 0);
>>> +	put_lseg(lseg);
>>>
>>> 	return ret;
>>>
>>> @@ -300,7 +308,7 @@ out_bad:
>>> 	return -ENOMEM;
>>> }
>>>
>>> -static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
>>> +static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags, struct pnfs_layout_segment *lseg)
>>> {
>>> 	struct nfs_page		*req;
>>> 	struct page		**pages;
>>> @@ -320,9 +328,14 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
>>> 		*pages++ = req->wb_page;
>>> 	}
>>> 	req = nfs_list_entry(data->pages.next);
>>> +	if ((!lseg) && list_is_singular(&data->pages))
>>> +		lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_READ);

When is lseg NULL and why getting it here works better than in nfs_readpage_async?

>>>
>>> -	return nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0);
>>> +	ret = nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0, lseg);
>>> +	put_lseg(lseg);
>>
>> Shouldn't that be done only if pnfs_update_layout was called here?
>> Otherwise, the caller, nfs_readpage_async puts the lseg it passes down.
>>
> 
> You are right there is a problem.  But it needs to be fixed by removing the put_lseg from nfs_readpage_async.
> 
> 

If we can avoid getting the lseg in one place and putting it in another that would be better.

Benny

>>> +	return ret;
>>> out_bad:
>>> +	put_lseg(lseg);
>>
>> I'd unify the common exit path by doing nfs_async_read_error on the error path
>> and then goto out for the common code.
>>
> 
> OK.
> 
> Fred
> 
