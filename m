Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:37342 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964965AbaDIU0k convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Apr 2014 16:26:40 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <D7AB2150-5F25-4BA2-80D9-94890AD11F8F@primarydata.com>
Date: Wed, 9 Apr 2014 16:26:34 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <F1C70AD6-BDD4-4534-8DC4-61D2767581D9@oracle.com>
References: <014738b6-698e-4ea1-82f9-287378bfec19@CMEXHTCAS2.ad.emulex.com> <D7AB2150-5F25-4BA2-80D9-94890AD11F8F@primarydata.com>
To: Devesh Sharma <devesh.sharma@emulex.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 9, 2014, at 4:22 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Hi Devesh,
> 
> This looks a lot better. I still have a couple of small suggestions, though.
> 
> On Apr 9, 2014, at 14:40, Devesh Sharma <devesh.sharma@emulex.com> wrote:
> 
>> If the rdma_create_qp fails to create qp due to device firmware being in invalid state
>> xprtrdma still tries to destroy the non-existant qp and ends up in a NULL pointer reference
>> crash.
>> Adding proper checks for vaidating QP pointer avoids this to happen.
>> 
>> Signed-off-by: Devesh Sharma <devesh.sharma@emulex.com>
>> ---
>> net/sunrpc/xprtrdma/verbs.c |   29 +++++++++++++++++++++++++----
>> 1 files changed, 25 insertions(+), 4 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 9372656..902ac78 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -831,10 +831,12 @@ rpcrdma_ep_connect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
>> 	if (ep->rep_connected != 0) {
>> 		struct rpcrdma_xprt *xprt;
>> retry:
>> -		rc = rpcrdma_ep_disconnect(ep, ia);
>> -		if (rc && rc != -ENOTCONN)
>> -			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
>> +		if (ia->ri_id->qp) {
>> +			rc = rpcrdma_ep_disconnect(ep, ia);
>> +			if (rc && rc != -ENOTCONN)
>> +				dprintk("RPC:       %s: rpcrdma_ep_disconnect"
>> 				" status %i\n", __func__, rc);
>> +		}
>> 		rpcrdma_clean_cq(ep->rep_cq);
>> 
>> 		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
>> @@ -859,7 +861,9 @@ retry:
>> 			goto out;
>> 		}
>> 		/* END TEMP */
>> -		rdma_destroy_qp(ia->ri_id);
>> +		if (ia->ri_id->qp) {
>> +			rdma_destroy_qp(ia->ri_id);
>> +		}
> 
> Nit: No need for braces here.
> 
>> 		rdma_destroy_id(ia->ri_id);
>> 		ia->ri_id = id;
>> 	}
>> @@ -1557,6 +1561,13 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
>> 	frmr_wr.wr.fast_reg.rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
>> 	DECR_CQCOUNT(&r_xprt->rx_ep);

I don’t think you can DECR_CQCOUNT, then exit without posting the send. That will screw up the completion counter and result in a transport hang, won’t it?

>> 
>> +	if (!ia->ri_is->qp) {
>> +		rc = -EINVAL;
>> +		while (i--)
>> +			rpcrdma_unmap_one(ia, --seg);
>> +		goto out;
>> +	}
> 
> Instead of duplicating the rpcrdma_unmap_one() cleanup here, why not just do
> 
> 	if (ia->ri_is->qp)
> 		rc = ib_post_send(…)
> 	else
> 		rc = -EINVAL;
> 
> BTW: can we not simply test for ia->ri_is->qp before we even call rpcrdma_map_one() and hence bail out before we have to do any cleanup?
> 
>> +
>> 	rc = ib_post_send(ia->ri_id->qp, post_wr, &bad_wr);
>> 
>> 	if (rc) {
>> @@ -1571,6 +1582,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
>> 		seg1->mr_len = len;
>> 	}
>> 	*nsegs = i;
>> +out:
>> 	return rc;
>> }
>> 
>> @@ -1592,6 +1604,9 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
>> 	invalidate_wr.ex.invalidate_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
>> 	DECR_CQCOUNT(&r_xprt->rx_ep);

Ditto.

>> 
>> +	if (!ia->ri_id->qp)
>> +		return -EINVAL;
>> +
>> 	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
>> 	if (rc)
>> 		dprintk("RPC:       %s: failed ib_post_send for invalidate,"
>> @@ -1923,6 +1938,9 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
>> 		send_wr.send_flags = IB_SEND_SIGNALED;
>> 	}

Ditto.

>> 
>> +	if (!ia->ri_id->qp)
>> +		return -EINVAL;
>> +
>> 	rc = ib_post_send(ia->ri_id->qp, &send_wr, &send_wr_fail);
>> 	if (rc)
>> 		dprintk("RPC:       %s: ib_post_send returned %i\n", __func__,
>> @@ -1951,6 +1969,9 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
>> 		rep->rr_iov.addr, rep->rr_iov.length, DMA_BIDIRECTIONAL);
>> 
>> 	DECR_CQCOUNT(ep);

And here.

>> +
>> +	if (!ia->ri_id->qp)
>> +		return -EINVAL;
>> 	rc = ib_post_recv(ia->ri_id->qp, &recv_wr, &recv_wr_fail);
>> 
>> 	if (rc)
>> -- 
>> 1.7.1
>> 
> 
> _________________________________
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



