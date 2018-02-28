Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:13083 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935042AbeB1Vve (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Feb 2018 16:51:34 -0500
Subject: Re: [PATCH 7/8] xprtrdma: Chain Send to FastReg WRs
To: Chuck Lever <chuck.lever@oracle.com>
CC: <linux-rdma@vger.kernel.org>, <linux-nfs@vger.kernel.org>
References: <20180228202916.25968.21750.stgit@manet.1015granger.net>
 <20180228203059.25968.28807.stgit@manet.1015granger.net>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <37357f5c-25c5-b862-4e4f-7f84a38a29b2@Netapp.com>
Date: Wed, 28 Feb 2018 16:51:11 -0500
MIME-Version: 1.0
In-Reply-To: <20180228203059.25968.28807.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/28/2018 03:30 PM, Chuck Lever wrote:
> With FRWR, the client transport can perform memory registration and
> post a Send with just a single ib_post_send.
> 
> This reduces contention between the send_request path and the Send
> Completion handlers, and reduces the overhead of registering a chunk
> that has multiple segments.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/fmr_ops.c   |   11 ++++++++
>  net/sunrpc/xprtrdma/frwr_ops.c  |   51 +++++++++++++++++++++++++++------------
>  net/sunrpc/xprtrdma/verbs.c     |    3 +-
>  net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
>  4 files changed, 49 insertions(+), 18 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
> index 629e539..5cc68a8 100644
> --- a/net/sunrpc/xprtrdma/fmr_ops.c
> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
> @@ -251,6 +251,16 @@ enum {
>  	return ERR_PTR(-EIO);
>  }
>  
> +/* Post Send WR containing the RPC Call message.
> + */
> +static int
> +fmr_op_send(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
> +{
> +	struct ib_send_wr *bad_wr;
> +
> +	return ib_post_send(ia->ri_id->qp, &req->rl_sendctx->sc_wr, &bad_wr);

I wish there was a bad_wr null-check in ib_post_send() (or in the infiniband drivers) so you don't have to declare a variable that's never used again.  Coordinating that might be more work than it's worth, though.

Anna

> +}
> +
>  /* Invalidate all memory regions that were registered for "req".
>   *
>   * Sleeps until it is safe for the host CPU to access the
> @@ -305,6 +315,7 @@ enum {
>  
>  const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
>  	.ro_map				= fmr_op_map,
> +	.ro_send			= fmr_op_send,
>  	.ro_unmap_sync			= fmr_op_unmap_sync,
>  	.ro_recover_mr			= fmr_op_recover_mr,
>  	.ro_open			= fmr_op_open,
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index e21781c..c5743a0 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -357,8 +357,7 @@
>  	struct rpcrdma_mr *mr;
>  	struct ib_mr *ibmr;
>  	struct ib_reg_wr *reg_wr;
> -	struct ib_send_wr *bad_wr;
> -	int rc, i, n;
> +	int i, n;
>  	u8 key;
>  
>  	mr = NULL;
> @@ -407,22 +406,12 @@
>  	ib_update_fast_reg_key(ibmr, ++key);
>  
>  	reg_wr = &frwr->fr_regwr;
> -	reg_wr->wr.next = NULL;
> -	reg_wr->wr.opcode = IB_WR_REG_MR;
> -	frwr->fr_cqe.done = frwr_wc_fastreg;
> -	reg_wr->wr.wr_cqe = &frwr->fr_cqe;
> -	reg_wr->wr.num_sge = 0;
> -	reg_wr->wr.send_flags = 0;
>  	reg_wr->mr = ibmr;
>  	reg_wr->key = ibmr->rkey;
>  	reg_wr->access = writing ?
>  			 IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
>  			 IB_ACCESS_REMOTE_READ;
>  
> -	rc = ib_post_send(ia->ri_id->qp, &reg_wr->wr, &bad_wr);
> -	if (rc)
> -		goto out_senderr;
> -
>  	mr->mr_handle = ibmr->rkey;
>  	mr->mr_length = ibmr->length;
>  	mr->mr_offset = ibmr->iova;
> @@ -442,11 +431,40 @@
>  	       frwr->fr_mr, n, mr->mr_nents);
>  	rpcrdma_mr_defer_recovery(mr);
>  	return ERR_PTR(-EIO);
> +}
>  
> -out_senderr:
> -	pr_err("rpcrdma: FRWR registration ib_post_send returned %i\n", rc);
> -	rpcrdma_mr_defer_recovery(mr);
> -	return ERR_PTR(-ENOTCONN);
> +/* Post Send WR containing the RPC Call message.
> + *
> + * For FRMR, chain any FastReg WRs to the Send WR. Only a
> + * single ib_post_send call is needed to register memory
> + * and then post the Send WR.
> + */
> +static int
> +frwr_op_send(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
> +{
> +	struct ib_send_wr *post_wr, *bad_wr;
> +	struct rpcrdma_mr *mr;
> +
> +	post_wr = &req->rl_sendctx->sc_wr;
> +	list_for_each_entry(mr, &req->rl_registered, mr_list) {
> +		struct rpcrdma_frwr *frwr;
> +
> +		frwr = &mr->frwr;
> +
> +		frwr->fr_cqe.done = frwr_wc_fastreg;
> +		frwr->fr_regwr.wr.next = post_wr;
> +		frwr->fr_regwr.wr.wr_cqe = &frwr->fr_cqe;
> +		frwr->fr_regwr.wr.num_sge = 0;
> +		frwr->fr_regwr.wr.opcode = IB_WR_REG_MR;
> +		frwr->fr_regwr.wr.send_flags = 0;
> +
> +		post_wr = &frwr->fr_regwr.wr;
> +	}
> +
> +	/* If ib_post_send fails, the next ->send_request for
> +	 * @req will queue these MWs for recovery.
> +	 */
> +	return ib_post_send(ia->ri_id->qp, post_wr, &bad_wr);
>  }
>  
>  /* Handle a remotely invalidated mr on the @mrs list
> @@ -561,6 +579,7 @@
>  
>  const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
>  	.ro_map				= frwr_op_map,
> +	.ro_send			= frwr_op_send,
>  	.ro_reminv			= frwr_op_reminv,
>  	.ro_unmap_sync			= frwr_op_unmap_sync,
>  	.ro_recover_mr			= frwr_op_recover_mr,
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index ab86724..626fd30 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1535,7 +1535,6 @@ struct rpcrdma_regbuf *
>  		struct rpcrdma_req *req)
>  {
>  	struct ib_send_wr *send_wr = &req->rl_sendctx->sc_wr;
> -	struct ib_send_wr *send_wr_fail;
>  	int rc;
>  
>  	if (req->rl_reply) {
> @@ -1554,7 +1553,7 @@ struct rpcrdma_regbuf *
>  		--ep->rep_send_count;
>  	}
>  
> -	rc = ib_post_send(ia->ri_id->qp, send_wr, &send_wr_fail);
> +	rc = ia->ri_ops->ro_send(ia, req);
>  	trace_xprtrdma_post_send(req, rc);
>  	if (rc)
>  		return -ENOTCONN;
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 29ea0b4..3d3b423 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -472,6 +472,8 @@ struct rpcrdma_memreg_ops {
>  			(*ro_map)(struct rpcrdma_xprt *,
>  				  struct rpcrdma_mr_seg *, int, bool,
>  				  struct rpcrdma_mr **);
> +	int		(*ro_send)(struct rpcrdma_ia *ia,
> +				   struct rpcrdma_req *req);
>  	void		(*ro_reminv)(struct rpcrdma_rep *rep,
>  				     struct list_head *mrs);
>  	void		(*ro_unmap_sync)(struct rpcrdma_xprt *,
> 
