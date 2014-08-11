Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59492 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752591AbaHKTPv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Aug 2014 15:15:51 -0400
Date: Mon, 11 Aug 2014 15:15:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSD: Treat rq_reserved when initializing xdr_buf
Message-ID: <20140811191550.GF9095@fieldses.org>
References: <53E2EE27.5010603@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53E2EE27.5010603@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 07, 2014 at 11:10:31AM +0800, Kinglong Mee wrote:
> After calling svc_reserve() with a small length,
> nfsd does't treat it in svcxdr_init_encode().
> 
> So, when testing conflock, got message as,
> 
> [  970.127216] RPC request reserved 88 but used 116

rq_reserved should always be set no smaller than the maximum possible
size of the reply, given everything we know about the request.

So the bug is that rq_reserved was set to small.

The risk of returning a reply larger than rq_reserved is a relatively
rare deadlock, so I'd rather just stick to the log warning than convert
it to a hard error.

The solution in this case is to fix the incorrect estimate.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4proc.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 5e0dc52..084e46e 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1245,17 +1245,20 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  	struct xdr_stream *xdr = &resp->xdr;
>  	struct xdr_buf *buf = &rqstp->rq_res;
>  	struct kvec *head = buf->head;
> +	int tlen = 0;
>  
>  	xdr->buf = buf;
>  	xdr->iov = head;
>  	xdr->p   = head->iov_base + head->iov_len;
> -	xdr->end = head->iov_base + PAGE_SIZE - rqstp->rq_auth_slack;
> +	tlen = PAGE_SIZE - rqstp->rq_auth_slack;
> +	xdr->end = head->iov_base + min(tlen, rqstp->rq_reserved);
>  	/* Tail and page_len should be zero at this point: */
>  	buf->len = buf->head[0].iov_len;
>  	xdr->scratch.iov_len = 0;
>  	xdr->page_ptr = buf->pages - 1;
> -	buf->buflen = PAGE_SIZE * (1 + rqstp->rq_page_end - buf->pages)
> +	tlen = PAGE_SIZE * (1 + rqstp->rq_page_end - buf->pages)
>  		- rqstp->rq_auth_slack;
> +	buf->buflen = min(tlen, rqstp->rq_reserved);
>  }
>  
>  /*
> -- 
> 1.9.3
> 
