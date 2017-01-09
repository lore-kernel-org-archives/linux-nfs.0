Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32262 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762113AbdAIPGC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2017 10:06:02 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] svcrdma: avoid duplicate dma unmapping during error recovery
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170109064224.GA3820@yuval-lap>
Date: Mon, 9 Jan 2017 10:05:48 -0500
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Yuval Shaia <yuval.shaia@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        List Linux RDMA Mailing <linux-rdma@vger.kernel.org>
Message-Id: <5761AF19-DF8B-44CE-B744-C21464958041@oracle.com>
References: <20170109103044.5590-1-sriharsha.basavapatna@broadcom.com> <20170109064224.GA3820@yuval-lap>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 9, 2017, at 1:42 AM, Yuval Shaia <yuval.shaia@oracle.com> wrote:
> 
> On Mon, Jan 09, 2017 at 04:00:44PM +0530, Sriharsha Basavapatna wrote:
>> In rdma_read_chunk_frmr() when ib_post_send() fails, the error code path
>> invokes ib_dma_unmap_sg() to unmap the sg list. It then invokes
>> svc_rdma_put_frmr() which in turn tries to unmap the same sg list through
>> ib_dma_unmap_sg() again. This second unmap is invalid and could lead to
>> problems when the iova being unmapped is subsequently reused. Remove
>> the call to unmap in rdma_read_chunk_frmr() and let svc_rdma_put_frmr()
>> handle it.
>> 
>> Fixes: 412a15c0fe53 ("svcrdma: Port to new memory registration API")
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c | 2 --
>> 1 file changed, 2 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> index 57d35fbb1c28..172b537f8cfc 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> @@ -347,8 +347,6 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
>> 	atomic_inc(&rdma_stat_read);
>> 	return ret;
>>  err:
>> -	ib_dma_unmap_sg(xprt->sc_cm_id->device,
>> -			frmr->sg, frmr->sg_nents, frmr->direction);
>> 	svc_rdma_put_context(ctxt, 0);
>> 	svc_rdma_put_frmr(xprt, frmr);
>> 	return ret;
> 
> Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>

Hi Bruce-

Is it possible to take this in v4.10-rc ?


--
Chuck Lever



