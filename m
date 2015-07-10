Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33645 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbbGJKzS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 06:55:18 -0400
Received: by pdbqm3 with SMTP id qm3so38764870pdb.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 03:55:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150709204227.26247.51111.stgit@manet.1015granger.net>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
	<20150709204227.26247.51111.stgit@manet.1015granger.net>
Date: Fri, 10 Jul 2015 16:25:17 +0530
Message-ID: <CANjDDBjKJKB3Z4=Gt_Sc3uPUnXen6OMRoCTkTkm9DPSr1gXT+g@mail.gmail.com>
Subject: Re: [PATCH v1 05/12] xprtrdma: Account for RPC/RDMA header size when
 deciding to inline
From: Devesh Sharma <devesh.sharma@avagotech.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good

Reveiwed-By: Devesh Sharma <devesh.sharma@avagotech.com>

On Fri, Jul 10, 2015 at 2:12 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> When marshaling RPC/RDMA requests, ensure the combined size of
> RPC/RDMA header and RPC header do not exceed the inline threshold.
> Endpoints typically reject RPC/RDMA messages that exceed the size
> of their receive buffers.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/rpc_rdma.c |   29 +++++++++++++++++++++++++++--
>  1 file changed, 27 insertions(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index 84ea37d..8cf9402 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -71,6 +71,31 @@ static const char transfertypes[][12] = {
>  };
>  #endif
>
> +/* The client can send a request inline as long as the RPCRDMA header
> + * plus the RPC call fit under the transport's inline limit. If the
> + * combined call message size exceeds that limit, the client must use
> + * the read chunk list for this operation.
> + */
> +static bool rpcrdma_args_inline(struct rpc_rqst *rqst)
> +{
> +       unsigned int callsize = RPCRDMA_HDRLEN_MIN + rqst->rq_snd_buf.len;
> +
> +       return callsize <= RPCRDMA_INLINE_WRITE_THRESHOLD(rqst);
> +}
> +
> +/* The client can’t know how large the actual reply will be. Thus it
> + * plans for the largest possible reply for that particular ULP
> + * operation. If the maximum combined reply message size exceeds that
> + * limit, the client must provide a write list or a reply chunk for
> + * this request.
> + */
> +static bool rpcrdma_results_inline(struct rpc_rqst *rqst)
> +{
> +       unsigned int repsize = RPCRDMA_HDRLEN_MIN + rqst->rq_rcv_buf.buflen;
> +
> +       return repsize <= RPCRDMA_INLINE_READ_THRESHOLD(rqst);
> +}
> +
>  /*
>   * Chunk assembly from upper layer xdr_buf.
>   *
> @@ -418,7 +443,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
>          * a READ, then use write chunks to separate the file data
>          * into pages; otherwise use reply chunks.
>          */
> -       if (rqst->rq_rcv_buf.buflen <= RPCRDMA_INLINE_READ_THRESHOLD(rqst))
> +       if (rpcrdma_results_inline(rqst))
>                 wtype = rpcrdma_noch;
>         else if (rqst->rq_rcv_buf.page_len == 0)
>                 wtype = rpcrdma_replych;
> @@ -441,7 +466,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
>          * implies the op is a write.
>          * TBD check NFSv4 setacl
>          */
> -       if (rqst->rq_snd_buf.len <= RPCRDMA_INLINE_WRITE_THRESHOLD(rqst))
> +       if (rpcrdma_args_inline(rqst))
>                 rtype = rpcrdma_noch;
>         else if (rqst->rq_snd_buf.page_len == 0)
>                 rtype = rpcrdma_areadch;
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
