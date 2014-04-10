Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:21453 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932847AbaDJAfX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Apr 2014 20:35:23 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH V2] NFS-RDMA: fix qp pointer validation checks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <f02a9959-4530-474f-8076-1139362aaea6@CMEXHTCAS1.ad.emulex.com>
Date: Wed, 9 Apr 2014 20:35:16 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <22067556-CC9F-45B3-8597-C801231FC04F@oracle.com>
References: <f02a9959-4530-474f-8076-1139362aaea6@CMEXHTCAS1.ad.emulex.com>
To: Devesh Sharma <devesh.sharma@emulex.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Devesh-


On Apr 9, 2014, at 7:54 PM, Devesh Sharma <devesh.sharma@emulex.com> wrote:

> If the rdma_create_qp fails to create qp due to device firmware being in invalid state
> xprtrdma still tries to destroy the non-existant qp and ends up in a NULL pointer reference
> crash.
> Adding proper checks for vaidating QP pointer avoids this to happen.
> 
> V0: Using IS_ERR() to check validity of qp pointer.
> V1: Use of IS_ERR() will not be able to catch NULL QP pointers as rdma_create_qp() returnes NULL in case
>    ib_create_qp verb is failed. Therefore, changed from usage of IS_ERR to null pointer check.
> V2: ib_post_send() should not abort after DECR_CQCOUNT() checking for NULL pointer was causing exit from functions
>    after decrementing CQCOUNT(). Fixed this in V2.
> 
> Signed-off-by: Devesh Sharma <devesh.sharma@emulex.com>
> ---
> net/sunrpc/xprtrdma/verbs.c |   92 ++++++++++++++++++++++++++-----------------
> 1 files changed, 56 insertions(+), 36 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 9372656..9e56baf 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -831,10 +831,12 @@ rpcrdma_ep_connect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
> 	if (ep->rep_connected != 0) {
> 		struct rpcrdma_xprt *xprt;
> retry:
> -		rc = rpcrdma_ep_disconnect(ep, ia);
> -		if (rc && rc != -ENOTCONN)
> -			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
> +		if (ia->ri_id->qp) {
> +			rc = rpcrdma_ep_disconnect(ep, ia);
> +			if (rc && rc != -ENOTCONN)
> +				dprintk("RPC:       %s: rpcrdma_ep_disconnect"
> 				" status %i\n", __func__, rc);
> +		}
> 		rpcrdma_clean_cq(ep->rep_cq);
> 
> 		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
> @@ -859,7 +861,8 @@ retry:
> 			goto out;
> 		}
> 		/* END TEMP */
> -		rdma_destroy_qp(ia->ri_id);
> +		if (ia->ri_id->qp)
> +			rdma_destroy_qp(ia->ri_id);
> 		rdma_destroy_id(ia->ri_id);
> 		ia->ri_id = id;
> 	}

Does your set up still panic if rpcrdma_ep_connect() is fixed as above, but the rest of these hunks are left unapplied?


> @@ -1555,22 +1558,30 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
> 				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
> 				IB_ACCESS_REMOTE_READ);
> 	frmr_wr.wr.fast_reg.rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
> -	DECR_CQCOUNT(&r_xprt->rx_ep);
> 
> -	rc = ib_post_send(ia->ri_id->qp, post_wr, &bad_wr);
> +	if (!ia->ri_is->qp) {

You mean “if (ia->ri_id->qp) {”

> +		DECR_CQCOUNT(&r_xprt->rx_ep);
> +		rc = ib_post_send(ia->ri_id->qp, post_wr, &bad_wr);
> 
> -	if (rc) {
> -		dprintk("RPC:       %s: failed ib_post_send for register,"
> -			" status %i\n", __func__, rc);
> -		while (i--)
> -			rpcrdma_unmap_one(ia, --seg);
> +		if (rc) {
> +			dprintk("RPC:       %s: failed ib_post_send for register,"
> +				" status %i\n", __func__, rc);
> +			goto out;
> +		} else {
> +			seg1->mr_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
> +			seg1->mr_base = seg1->mr_dma + pageoff;
> +			seg1->mr_nsegs = i;
> +			seg1->mr_len = len;
> +		}
> 	} else {
> -		seg1->mr_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
> -		seg1->mr_base = seg1->mr_dma + pageoff;
> -		seg1->mr_nsegs = i;
> -		seg1->mr_len = len;
> +		rc = -EINVAL;
> +		goto out;
> 	}
> +
> 	*nsegs = i;
> +out:
> +	while (i--)
> +		rpcrdma_unmap_one(ia, --seg);
> 	return rc;
> }
> 
> @@ -1590,12 +1601,16 @@ rpcrdma_deregister_frmr_external(struct rpcrdma_mr_seg *seg,
> 	invalidate_wr.opcode = IB_WR_LOCAL_INV;
> 	invalidate_wr.send_flags = IB_SEND_SIGNALED;
> 	invalidate_wr.ex.invalidate_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
> -	DECR_CQCOUNT(&r_xprt->rx_ep);
> 
> -	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
> -	if (rc)
> -		dprintk("RPC:       %s: failed ib_post_send for invalidate,"
> -			" status %i\n", __func__, rc);
> +	if (ia->ri_id->qp) {
> +		DECR_CQCOUNT(&r_xprt->rx_ep);
> +		rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
> +		if (rc)
> +			dprintk("RPC:       %s: failed ib_post_send for invalidate,"
> +				" status %i\n", __func__, rc);
> +	} else
> +		rc = -EINVAL;
> +
> 	return rc;
> }
> 
> @@ -1916,17 +1931,19 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
> 		req->rl_send_iov[0].addr, req->rl_send_iov[0].length,
> 		DMA_TO_DEVICE);
> 
> -	if (DECR_CQCOUNT(ep) > 0)
> -		send_wr.send_flags = 0;
> -	else { /* Provider must take a send completion every now and then */
> -		INIT_CQCOUNT(ep);
> -		send_wr.send_flags = IB_SEND_SIGNALED;
> -	}
> -
> -	rc = ib_post_send(ia->ri_id->qp, &send_wr, &send_wr_fail);
> -	if (rc)
> -		dprintk("RPC:       %s: ib_post_send returned %i\n", __func__,
> -			rc);
> +	if (ia->ri_id->qp) {
> +		if (DECR_CQCOUNT(ep) > 0)
> +			send_wr.send_flags = 0;
> +		else { /* Provider must take a send completion every now and then */
> +			INIT_CQCOUNT(ep);
> +			send_wr.send_flags = IB_SEND_SIGNALED
> +		}
> +		rc = ib_post_send(ia->ri_id->qp, &send_wr, &send_wr_fail);
> +		if (rc)
> +			dprintk("RPC:       %s: ib_post_send returned %i\n", __func__,
> +				rc);
> +	} else
> +		rc = -EINVAL;
> out:
> 	return rc;
> }
> @@ -1950,11 +1967,14 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
> 	ib_dma_sync_single_for_cpu(ia->ri_id->device,
> 		rep->rr_iov.addr, rep->rr_iov.length, DMA_BIDIRECTIONAL);
> 
> -	DECR_CQCOUNT(ep);
> -	rc = ib_post_recv(ia->ri_id->qp, &recv_wr, &recv_wr_fail);
> +	if (ia->ri_id->qp) {
> +		DECR_CQCOUNT(ep);
> +		rc = ib_post_recv(ia->ri_id->qp, &recv_wr, &recv_wr_fail);
> +		if (rc)
> +			dprintk("RPC:       %s: ib_post_recv returned %i\n", __func__,
> +				rc);
> +	} else
> +		rc = -EINVAL;
> 
> -	if (rc)
> -		dprintk("RPC:       %s: ib_post_recv returned %i\n", __func__,
> -			rc);
> 	return rc;
> }
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



