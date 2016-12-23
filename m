Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41726 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935217AbcLWJbY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2016 04:31:24 -0500
Date: Fri, 23 Dec 2016 01:31:23 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NFSD: cleanup dead codes and values in nfsd_write
Message-ID: <20161223093123.GA22770@infradead.org>
References: <5cd74fe8-37ac-ff17-3b17-c9b0032e3196@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5cd74fe8-37ac-ff17-3b17-c9b0032e3196@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 23, 2016 at 09:32:25AM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs3proc.c |  2 +-
>  fs/nfsd/nfsproc.c  |  2 +-
>  fs/nfsd/vfs.c      | 35 +++++++++++------------------------
>  fs/nfsd/vfs.h      |  4 ++--
>  4 files changed, 15 insertions(+), 28 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 69cd0f1..ec7a63f 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -193,7 +193,7 @@ nfsd3_proc_write(struct svc_rqst *rqstp, struct nfsd3_writeargs *argp,
>  
>  	fh_copy(&resp->fh, &argp->fh);
>  	resp->committed = argp->stable;
> -	nfserr = nfsd_write(rqstp, &resp->fh, NULL,
> +	nfserr = nfsd_write(rqstp, &resp->fh,
>  				   argp->offset,
>  				   rqstp->rq_vec, argp->vlen,
>  				   &cnt,

Maybe move one or two args up (and use normal two-tab line
continuations) to make this a bit more readable?

> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> index f157c7e..45ca598 100644
> --- a/fs/nfsd/nfsproc.c
> +++ b/fs/nfsd/nfsproc.c
> @@ -210,7 +210,7 @@ nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
>  		SVCFH_fmt(&argp->fh),
>  		argp->len, argp->offset);
>  
> -	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
> +	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh),
>  				   argp->offset,
>  				   rqstp->rq_vec, argp->vlen,
>  			           &cnt,

Same here?

Otherwise this looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>
