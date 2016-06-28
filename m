Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48149 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbcF1Uxg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2016 16:53:36 -0400
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v3 01/25] xprtrdma: Remove FMRs from the unmap list after unmapping
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <bf577252-3786-9ee8-be3b-036922eb0507@Netapp.com>
Date: Tue, 28 Jun 2016 16:53:28 -0400
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <406CAA3A-1C5A-4761-956F-C17CE1CA34F9@oracle.com>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net> <20160620160843.10809.96379.stgit@manet.1015granger.net> <bf577252-3786-9ee8-be3b-036922eb0507@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 27, 2016, at 1:47 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
> Hi Chuck,
> 
>> On 06/20/2016 12:08 PM, Chuck Lever wrote:
>> ib_unmap_fmr() takes a list of FMRs to unmap. However, it does not
>> remove the FMRs from this list as it processes them. Other
>> ib_unmap_fmr() call sites are careful to remove FMRs from the list
>> after ib_unmap_fmr() returns.
>> 
>> Since commit 7c7a5390dc6c8 ("xprtrdma: Add ro_unmap_sync method for FMR")
>> fmr_op_unmap_sync passes more than one FMR to ib_unmap_fmr(), but
>> it didn't bother to remove the FMRs from that list once the call was
>> complete.
>> 
>> I've noticed some instability that could be related to list
>> tangling by the new fmr_op_unmap_sync() logic. In an abundance
>> of caution, add some defensive logic to clean up properly after
>> ib_unmap_fmr().
>> 
>> Fixes: 7c7a5390dc6c8 ("xprtrdma: Add ro_unmap_sync method for FMR")
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/xprtrdma/fmr_ops.c |   10 ++++++++--
>> 1 file changed, 8 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
>> index 6326ebe..958c792 100644
>> --- a/net/sunrpc/xprtrdma/fmr_ops.c
>> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
>> @@ -63,9 +63,12 @@ static int
>> __fmr_unmap(struct rpcrdma_mw *mw)
>> {
>>    LIST_HEAD(l);
>> +    int rc;
>> 
>>    list_add(&mw->fmr.fmr->list, &l);
>> -    return ib_unmap_fmr(&l);
>> +    rc = ib_unmap_fmr(&l);
>> +    list_del_init(&mw->fmr.fmr->list);
>> +    return rc;
>> }
>> 
>> /* Deferred reset of a single FMR. Generate a fresh rkey by
>> @@ -149,6 +152,7 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
>>        r->fmr.fmr = ib_alloc_fmr(pd, mr_access_flags, &fmr_attr);
>>        if (IS_ERR(r->fmr.fmr))
>>            goto out_fmr_err;
>> +        INIT_LIST_HEAD(&r->fmr.fmr->list);
> 
> I'm a little surprised to see that ib_alloc_fmr() isn't initializing this list.  Do you know of any plans to add the INIT_LIST_HEAD() into the infiniband code, that way it's always initialized when an ib_fmr is allocated?

I don't know of any plans to change the ib_alloc_fmr() API.
AFAICT, the list field is a consumer-visible part of the FMR,
so it is the consumer's responsibility to manage that field
properly.

I suspect that INIT_LIST_HEAD is unnecessary anyway
and could be dropped from this patch.


> Anna
> 
>> 
>>        r->mw_xprt = r_xprt;
>>        list_add(&r->mw_list, &buf->rb_mws);
>> @@ -267,7 +271,7 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
>>        seg = &req->rl_segments[i];
>>        mw = seg->rl_mw;
>> 
>> -        list_add(&mw->fmr.fmr->list, &unmap_list);
>> +        list_add_tail(&mw->fmr.fmr->list, &unmap_list);
>> 
>>        i += seg->mr_nsegs;
>>    }
>> @@ -280,7 +284,9 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
>>     */
>>    for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
>>        seg = &req->rl_segments[i];
>> +        mw = seg->rl_mw;
>> 
>> +        list_del_init(&mw->fmr.fmr->list);
>>        __fmr_dma_unmap(r_xprt, seg);
>>        rpcrdma_put_mw(r_xprt, seg->rl_mw);
>> 
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

