Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50883 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759048Ab2DYWSK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 18:18:10 -0400
Date: Wed, 25 Apr 2012 18:18:09 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: bfields@fieldses.net, sandeen@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: trivial: use SEEK_SET instead of 0 in vfs_llseek
Message-ID: <20120425221809.GC3251@fieldses.org>
References: <1335382088-5463-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1335382088-5463-1-git-send-email-jlayton@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 25, 2012 at 03:28:08PM -0400, Jeff Layton wrote:
> They're equivalent, but SEEK_SET is more informative...

Applied, thanks.--b.

> 
> Cc: Eric Sandeen <sandeen@redhat.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/vfs.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 5686661..c8bd9c3 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -2039,7 +2039,7 @@ nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
>  	if (err)
>  		goto out;
>  
> -	offset = vfs_llseek(file, offset, 0);
> +	offset = vfs_llseek(file, offset, SEEK_SET);
>  	if (offset < 0) {
>  		err = nfserrno((int)offset);
>  		goto out_close;
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
