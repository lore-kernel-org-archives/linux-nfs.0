Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50102 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348AbcBHTVU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2016 14:21:20 -0500
Date: Mon, 8 Feb 2016 14:21:19 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/9] svcrdma: Do not send XDR roundup bytes for a
 write chunk
Message-ID: <20160208192119.GF17411@fieldses.org>
References: <20160208171756.13423.14384.stgit@klimt.1015granger.net>
 <20160208172430.13423.18896.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160208172430.13423.18896.stgit@klimt.1015granger.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 08, 2016 at 12:24:31PM -0500, Chuck Lever wrote:
> When the Linux server writes an odd-length data item into a Write
> chunk, it finishes with XDR pad bytes. If the data item is smaller
> than the Write chunk, the pad bytes are written at the end of the
> data item, but still inside the chunk. That can expose these zero
> bytes to the RPC consumer on the client.
> 
> XDR pad bytes are inserted in order to preserve the XDR alignment
> of the next XDR data item in an XDR stream. But Write chunks do not
> appear in the payload XDR stream, and only one data item is allowed
> in each chunk. So XDR padding is unneeded.
> 
> Thus the server should not write XDR pad bytes in Write chunks.
> 
> I believe this is not an operational problem. Short NFS READs that
> are returned in a Write chunk would be affected by this issue. But
> they happen only when the read request goes past the EOF. Those are
> zero bytes anyway, and there's no file data in the client's buffer
> past EOF.
> 
> Otherwise, current NFS clients provide a separate extra segment for
> catching XDR padding. If an odd-size data item fills the chunk,
> then the XDR pad will be written to the extra segment.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Reviewed-By: Devesh Sharma <devesh.sharma@broadcom.com>
> Tested-By: Devesh Sharma <devesh.sharma@broadcom.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index df57f3c..8591314 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -308,7 +308,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
>  			     struct svc_rqst *rqstp,
>  			     struct svc_rdma_req_map *vec)
>  {
> -	u32 xfer_len = rqstp->rq_res.page_len + rqstp->rq_res.tail[0].iov_len;
> +	u32 xfer_len = rqstp->rq_res.page_len;

Is this just unconditionally dropping the tail of the xdr_buf?

The tail isn't necessarily only padding.  For example, I believe that
the results of the GETATTR in a compound like:

	PUTFH
	READ
	GETATTR

will also go in the tail.

(But maybe you're sending the rest of the tail somewhere else, I'm not
very familiar with the RDMA code....)

--b.

>  	int write_len;
>  	u32 xdr_off;
>  	int chunk_off;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
