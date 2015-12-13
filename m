Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa12-02.prod.phx3.secureserver.net ([68.178.252.231]:47560
	"EHLO p3plsmtpa12-02.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751297AbbLMDOJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Dec 2015 22:14:09 -0500
Subject: Re: [PATCH v3 1/6] svcrdma: Do not send XDR roundup bytes for a write
 chunk
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20151207203851.12988.97804.stgit@klimt.1015granger.net>
 <20151207204231.12988.59287.stgit@klimt.1015granger.net>
From: Tom Talpey <tom@talpey.com>
Message-ID: <566CE288.6000808@talpey.com>
Date: Sat, 12 Dec 2015 19:14:16 -0800
MIME-Version: 1.0
In-Reply-To: <20151207204231.12988.59287.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two small comments.

On 12/7/2015 12:42 PM, Chuck Lever wrote:
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
>   net/sunrpc/xprtrdma/svc_rdma_sendto.c |    7 +++++++
>   1 file changed, 7 insertions(+)
>
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 969a1ab..bad5eaa 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -342,6 +342,13 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
>   						arg_ch->rs_handle,
>   						arg_ch->rs_offset,
>   						write_len);
> +
> +		/* Do not send XDR pad bytes */

It might be clearer to say "marshal" instead of "send".

> +		if (chunk_no && write_len < 4) {

Why is it necessary to check for chunk_no == 0? It is not
possible for leading data to ever be padding, nor is a leading
data element ever less than 4 bytes long. Right?

Tom.

> +			chunk_no++;
> +			break;
> +		}
> +
>   		chunk_off = 0;
>   		while (write_len) {
>   			ret = send_write(xprt, rqstp,
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
