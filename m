Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26152 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1043450AbdDVDhu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Apr 2017 23:37:50 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] xprtrdma: use offset_in_page() macro
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1b5bf5bd903ad97138a3a86aa6bcb9b2fc142c6e.1492762974.git.geliangtang@gmail.com>
Date: Fri, 21 Apr 2017 23:37:31 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sagi Grimberg <sagi@grimberg.me>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <DB24E2C7-5CA1-49B7-A748-B3DE435018F5@oracle.com>
References: <4dbc77ccaaed98b183cf4dba58a4fa325fd65048.1492758503.git.geliangtang@gmail.com> <1b5bf5bd903ad97138a3a86aa6bcb9b2fc142c6e.1492762974.git.geliangtang@gmail.com>
To: Geliang Tang <geliangtang@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 21, 2017, at 9:21 PM, Geliang Tang <geliangtang@gmail.com> wrote:
> 
> Use offset_in_page() macro instead of open-coding.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
> net/sunrpc/xprtrdma/rpc_rdma.c        | 4 ++--
> net/sunrpc/xprtrdma/svc_rdma_sendto.c | 3 +--
> 2 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index a044be2..429beea 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -540,7 +540,7 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
> 			goto out;
> 
> 		page = virt_to_page(xdr->tail[0].iov_base);
> -		page_base = (unsigned long)xdr->tail[0].iov_base & ~PAGE_MASK;
> +		page_base = offset_in_page(xdr->tail[0].iov_base);
> 
> 		/* If the content in the page list is an odd length,
> 		 * xdr_write_pages() has added a pad at the beginning
> @@ -587,7 +587,7 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
> 	 */
> 	if (xdr->tail[0].iov_len) {
> 		page = virt_to_page(xdr->tail[0].iov_base);
> -		page_base = (unsigned long)xdr->tail[0].iov_base & ~PAGE_MASK;
> +		page_base = offset_in_page(xdr->tail[0].iov_base);
> 		len = xdr->tail[0].iov_len;
> 
> map_tail:

There are several other sites that use PAGE_MASK in
rpc_rdma.c. Should those be included in this patch?

Do you have a way to test this change? If not I
can take it (once the above comment is addressed),
run it through the usual battery of NFS/RDMA
testing, and then pass it along to Anna.


> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 1736337..60b3f29 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -306,12 +306,11 @@ static int svc_rdma_dma_map_buf(struct svcxprt_rdma *rdma,
> 				unsigned char *base,
> 				unsigned int len)
> {
> -	unsigned long offset = (unsigned long)base & ~PAGE_MASK;
> 	struct ib_device *dev = rdma->sc_cm_id->device;
> 	dma_addr_t dma_addr;
> 
> 	dma_addr = ib_dma_map_page(dev, virt_to_page(base),
> -				   offset, len, DMA_TO_DEVICE);
> +				   offset_in_page(base), len, DMA_TO_DEVICE);
> 	if (ib_dma_mapping_error(dev, dma_addr))
> 		return -EIO;
> 

This hunk conflicts with a rewrite of svc_rdma_sendto.c that
Bruce has already accepted for v4.12. I would prefer this
be dropped.

The rewritten code also has this issue. I can submit a patch
separately that adds offset_in_page in the appropriate place.


--
Chuck Lever



