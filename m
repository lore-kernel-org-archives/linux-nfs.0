Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30986 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbbKLOrX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Nov 2015 09:47:23 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Fwd: [PATCH] svcrdma: Do not send XDR roundup bytes for a write chunk
From: Chuck Lever <chuck.lever@oracle.com>
Date: Thu, 12 Nov 2015 09:47:13 -0500
Cc: Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <648A8847-9836-42EC-9D62-77C01C6E9ACF@oracle.com>
References: <20151112144433.13507.34603.stgit@klimt.1015granger.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I wish git send-mail had an address book. I’m really tired
of misspelling the to/cc addresses on patches.

Resending so there is one thread for all replies. Apologies
for the noise.


> Begin forwarded message:
> 
> From: Chuck Lever <chuck.lever@oracle.com>
> Subject: [PATCH] svcrdma: Do not send XDR roundup bytes for a write chunk
> Date: November 12, 2015 at 9:44:33 AM EST
> To: bfields@fieldses.org
> Cc: linux-nfs@vger.kernel.org, linux-rmda@vger.kernel.org
> 
> Minor optimization: when dealing with write chunk XDR roundup, do
> not post a Write WR for the zero bytes in the pad. Simply update
> the write segment in the RPC-over-RDMA header to reflect the extra
> pad bytes.
> 
> The Reply chunk is also a write chunk, but the server does not use
> send_write_chunks() to send the Reply chunk. That's OK in this case:
> the server Upper Layer typically marshals the Reply chunk contents
> in a single contiguous buffer, without a separate tail for the XDR
> pad.
> 
> The comments and the variable naming refer to "chunks" but what is
> really meant is "segments." The existing code sends only one
> xdr_write_chunk per RPC reply.
> 
> The fix assumes this as well. When the XDR pad in the first write
> chunk is reached, the assumption is the Write list is complete and
> send_write_chunks() returns.
> 
> That will remain a valid assumption until the server Upper Layer can
> support multiple bulk payload results per RPC.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> net/sunrpc/xprtrdma/svc_rdma_sendto.c |    7 +++++++
> 1 file changed, 7 insertions(+)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 1dfae83..6c48901 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -342,6 +342,13 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
> 						arg_ch->rs_handle,
> 						arg_ch->rs_offset,
> 						write_len);
> +
> +		/* Do not send XDR pad bytes */
> +		if (chunk_no && write_len < 4) {
> +			chunk_no++;
> +			break;
> +		}
> +
> 		chunk_off = 0;
> 		while (write_len) {
> 			ret = send_write(xprt, rqstp,
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




