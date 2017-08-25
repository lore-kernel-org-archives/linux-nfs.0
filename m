Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37982 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757411AbdHYRqa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Aug 2017 13:46:30 -0400
Date: Fri, 25 Aug 2017 13:46:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 2/3] nfsd: Incoming xdr_bufs may have content in tail
 buffer
Message-ID: <20170825174630.GC28124@fieldses.org>
References: <20170818150957.26571.12169.stgit@klimt.1015granger.net>
 <20170818151227.26571.61022.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170818151227.26571.61022.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 18, 2017 at 11:12:27AM -0400, Chuck Lever wrote:
> Since the beginning, svcsock has built a received RPC Call message
> by populating the xdr_buf's head, then placing the remaining
> message bytes in the xdr_buf's page list. The xdr_buf's tail is
> never populated.
> 
> This means that an NFSv4 COMPOUND containing an NFS WRITE operation
> plus trailing operations has a page list that contains the WRITE
> data payload followed by the trailing operations. NFSv4 XDR decoders
> will not look in the xdr_buf's tail, ever, because svcsock never put
> anything there.
> 
> To support transports that can pass the write payload in the
> xdr_buf's pagelist and trailing content in the xdr_buf's tail,
> introduce logic in READ_BUF that switches to the xdr_buf's tail vec
> when the decoder runs out of content in rq_arg.pages.

This is very specialized: it assumes an xdr buffer will never cross the
boundary from pages into the tail, for example.  But, I guess we do in
fact get that kind of guarantee from the rdma code, so fine.  Might be
worth a comment.

> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfs4xdr.c |   20 ++++++++++++++++++++
>  fs/nfsd/xdr4.h    |    1 +
>  2 files changed, 21 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 7c48d68..a9f88cf 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -159,6 +159,25 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
>  	 */
>  	unsigned int avail = (char *)argp->end - (char *)argp->p;
>  	__be32 *p;
> +
> +	if (argp->pagelen == 0) {
> +		struct kvec *vec = &argp->rqstp->rq_arg.tail[0];
> +
> +		if (!argp->tail) {

I think we may have other code that does this by checking whether
argp->p is in the range covered by that iovec, but your approach is
probably cleaner, OK.

--b.

> +			argp->tail = true;
> +			avail = vec->iov_len;
> +			argp->p = vec->iov_base;
> +			argp->end = vec->iov_base + avail;
> +		}
> +
> +		if (avail < nbytes)
> +			return NULL;
> +
> +		p = argp->p;
> +		argp->p += XDR_QUADLEN(nbytes);
> +		return p;
> +	}
> +
>  	if (avail + argp->pagelen < nbytes)
>  		return NULL;
>  	if (avail + PAGE_SIZE < nbytes) /* need more than a page !! */
> @@ -4573,6 +4592,7 @@ void nfsd4_release_compoundargs(struct svc_rqst *rqstp)
>  	args->end = rqstp->rq_arg.head[0].iov_base + rqstp->rq_arg.head[0].iov_len;
>  	args->pagelist = rqstp->rq_arg.pages;
>  	args->pagelen = rqstp->rq_arg.page_len;
> +	args->tail = false;
>  	args->tmpp = NULL;
>  	args->to_free = NULL;
>  	args->ops = args->iops;
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 72c6ad1..bac91b1 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -614,6 +614,7 @@ struct nfsd4_compoundargs {
>  	__be32 *			end;
>  	struct page **			pagelist;
>  	int				pagelen;
> +	bool				tail;
>  	__be32				tmp[8];
>  	__be32 *			tmpp;
>  	struct svcxdr_tmpbuf		*to_free;
