Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:62187 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968AbbGNQBd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 12:01:33 -0400
Subject: Re: [PATCH v1 10/12] xprtrdma: Fix large NFS SYMLINK calls
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
 <20150709204315.26247.47851.stgit@manet.1015granger.net>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <55A53259.8090606@gmail.com>
Date: Tue, 14 Jul 2015 12:01:29 -0400
MIME-Version: 1.0
In-Reply-To: <20150709204315.26247.47851.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

On 07/09/2015 04:43 PM, Chuck Lever wrote:
> Repair how rpcrdma_marshal_req() chooses which RDMA message type
> to use for large non-WRITE operations so that it picks RDMA_NOMSG
> in the correct situations, and sets up the marshaling logic to
> SEND only the RPC/RDMA header.
> 
> Large NFSv2 SYMLINK requests now use RDMA_NOMSG calls. The Linux NFS
> server XDR decoder for NFSv2 SYMLINK does not handle having the
> pathname argument arrive in a separate buffer. The decoder could be
> fixed, but this is simpler and RDMA_NOMSG can be used in a variety
> of other situations.
> 
> Ensure that the Linux client continues to use "RDMA_MSG + read
> list" when sending large NFSv3 SYMLINK requests, which is more
> efficient than using RDMA_NOMSG.
> 
> Large NFSv4 CREATE(NF4LNK) requests are changed to use "RDMA_MSG +
> read list" just like NFSv3 (see Section 5 of RFC 5667). Before,
> these did not work at all.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfs/nfs3xdr.c               |    1 +
>  fs/nfs/nfs4xdr.c               |    1 +
>  net/sunrpc/xprtrdma/rpc_rdma.c |   21 ++++++++++++---------
>  3 files changed, 14 insertions(+), 9 deletions(-)

It might be better to split this into separate patches for nfs and sunrpc, since Trond might want to accept the nfs changes separately.

Anna

> 
> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> index 9b04c2e..267126d 100644
> --- a/fs/nfs/nfs3xdr.c
> +++ b/fs/nfs/nfs3xdr.c
> @@ -1103,6 +1103,7 @@ static void nfs3_xdr_enc_symlink3args(struct rpc_rqst *req,
>  {
>  	encode_diropargs3(xdr, args->fromfh, args->fromname, args->fromlen);
>  	encode_symlinkdata3(xdr, args);
> +	xdr->buf->flags |= XDRBUF_WRITE;
>  }
>  
>  /*
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 558cd65d..03a20ec 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1155,6 +1155,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
>  		p = reserve_space(xdr, 4);
>  		*p = cpu_to_be32(create->u.symlink.len);
>  		xdr_write_pages(xdr, create->u.symlink.pages, 0, create->u.symlink.len);
> +		xdr->buf->flags |= XDRBUF_WRITE;
>  		break;
>  
>  	case NF4BLK: case NF4CHR:
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index 2e721f2..64fc4b4 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -484,21 +484,24 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
>  	 *
>  	 * o If the total request is under the inline threshold, all ops
>  	 *   are sent as inline.
> -	 * o Large non-write ops are sent with the entire message as a
> -	 *   single read chunk (protocol 0-position special case).
>  	 * o Large write ops transmit data as read chunk(s), header as
>  	 *   inline.
> +	 * o Large non-write ops are sent with the entire message as a
> +	 *   single read chunk (protocol 0-position special case).
>  	 *
> -	 * Note: the NFS code sending down multiple argument segments
> -	 * implies the op is a write.
> -	 * TBD check NFSv4 setacl
> +	 * This assumes that the upper layer does not present a request
> +	 * that both has a data payload, and whose non-data arguments
> +	 * by themselves are larger than the inline threshold.
>  	 */
> -	if (rpcrdma_args_inline(rqst))
> +	if (rpcrdma_args_inline(rqst)) {
>  		rtype = rpcrdma_noch;
> -	else if (rqst->rq_snd_buf.page_len == 0)
> -		rtype = rpcrdma_areadch;
> -	else
> +	} else if (rqst->rq_snd_buf.flags & XDRBUF_WRITE) {
>  		rtype = rpcrdma_readch;
> +	} else {
> +		headerp->rm_type = htonl(RDMA_NOMSG);
> +		rtype = rpcrdma_areadch;
> +		rpclen = 0;
> +	}
>  
>  	/* The following simplification is not true forever */
>  	if (rtype != rpcrdma_noch && wtype == rpcrdma_replych)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

