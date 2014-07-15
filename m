Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33788 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbaGOO2c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 10:28:32 -0400
Date: Tue, 15 Jul 2014 10:28:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrdma: Add zero padding if the client doesn't send it
Message-ID: <20140715142831.GH17956@fieldses.org>
References: <20140715140417.23046.27242.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140715140417.23046.27242.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2014 at 10:11:34AM -0400, Chuck Lever wrote:
> See RFC 5666 section 3.7: clients don't have to send zero XDR
> padding.
> 
> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=246
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Hi Bruce-
> 
> This is an alternative solution to changing the sanity check in the
> XDR WRITE decoder. It adjusts the incoming xdr_buf to include a zero
> pad just after the transport has received each RPC request.
> 
> Thoughts?

That looks pretty simple.  So if this works then I think I'd be happier
doing this than worrying about other spots like the drc code where we
might have missed an assumption.

>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   30 ++++++++++++++++++++++++++++++
>  1 files changed, 30 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 8f92a61..9a3465d 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -43,6 +43,7 @@
>  #include <linux/sunrpc/debug.h>
>  #include <linux/sunrpc/rpc_rdma.h>
>  #include <linux/spinlock.h>
> +#include <linux/highmem.h>
>  #include <asm/unaligned.h>
>  #include <rdma/ib_verbs.h>
>  #include <rdma/rdma_cm.h>
> @@ -435,6 +436,34 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
>  	return ret;
>  }
>  
> +/*
> + * To avoid a separate RDMA READ just for a handful of zero bytes,
> + * RFC 5666 section 3.7 allows the client to omit the XDR zero pad
> + * in chunk lists.
> + */
> +static void
> +rdma_fix_xdr_pad(struct xdr_buf *buf)
> +{
> +	unsigned int page_len = buf->page_len;
> +	unsigned int size = (XDR_QUADLEN(page_len) << 2) - page_len;
> + 	unsigned int offset, pg_no;
> +	char *p;
> +
> +	if (size == 0)
> +		return;
> +
> +	offset = page_len & ~PAGE_MASK;
> +	pg_no = page_len >> PAGE_SHIFT;
> +
> +	p = kmap_atomic(buf->pages[pg_no]);
> +	memset(p + offset, 0, size);
> +	kunmap_atomic(p);

If these are pages alloc'd by svc_recv() with alloc_page(GFP_KERNEL)
then the kmap/kunmap shouldn't be necessary.

--b.

> +
> +	buf->page_len += size;
> +	buf->buflen += size;
> +	buf->len += size;
> +}
> +
>  static int rdma_read_complete(struct svc_rqst *rqstp,
>  			      struct svc_rdma_op_ctxt *head)
>  {
> @@ -449,6 +478,7 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
>  		rqstp->rq_pages[page_no] = head->pages[page_no];
>  	}
>  	/* Point rq_arg.pages past header */
> +	rdma_fix_xdr_pad(&head->arg);
>  	rqstp->rq_arg.pages = &rqstp->rq_pages[head->hdr_count];
>  	rqstp->rq_arg.page_len = head->arg.page_len;
>  	rqstp->rq_arg.page_base = head->arg.page_base;
> 
