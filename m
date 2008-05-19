From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/05] svcrdma: Verify read-list fits within
	RPCSVC_MAXPAGES
Date: Mon, 19 May 2008 14:20:03 -0400
Message-ID: <20080519182003.GC11993@fieldses.org>
References: <12111560011694-git-send-email-tom@opengridcomputing.com> <12111560022506-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41819 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755341AbYESSUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 14:20:04 -0400
In-Reply-To: <12111560022506-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 18, 2008 at 07:13:17PM -0500, Tom Tucker wrote:
> A RDMA read-list cannot contain more elements than RPCSVC_MAXPAGES or
> it will overflow the DTO context. Verify this when processing the
> protocol header.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 6b16d8c..06ab484 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -306,6 +306,8 @@ static int rdma_read_xdr(struct svcxprt_rdma *xprt,
>  	ch_sge_ary = (struct chunk_sge *)tmp_ch_ctxt->sge;
>  
>  	svc_rdma_rcl_chunk_counts(ch, &ch_count, &byte_count);
> +	if (ch_count > RPCSVC_MAXPAGES)
> +		return -EINVAL;
>  	sge_count = rdma_rcl_to_sge(xprt, rqstp, hdr_ctxt, rmsgp,
>  				    sge, ch_sge_ary,
>  				    ch_count, byte_count);

If the ch_count is just the total number of bytes to be read into this
request, then don't we also need to know at what offset they're going to
be inserted?  (Shouldn't there be some check like ch->rc_position +
ch_count > RPCSVC_MAXPAGES ?)

Also, do we verify somewhere (before calling
svc_rdma_rcl_chunk_counts()) that rc_discrim is set on the last chunk?

--b.
