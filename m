From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/5] Safer nfsd_cross_mnt()
Date: Wed, 22 Apr 2009 14:06:41 -0400
Message-ID: <20090422180641.GB9541@fieldses.org>
References: <E1LwNkj-0004WN-AZ@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38826 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbZDVSGl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 14:06:41 -0400
In-Reply-To: <E1LwNkj-0004WN-AZ@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 21, 2009 at 09:43:41PM +0000, Al Viro wrote:
> 
> AFAICS, we have a subtle bug there: if we have crossed mountpoint
> *and* it got mount --move'd away, we'll be holding only one
> reference to fs containing dentry - exp->ex_path.mnt.  IOW, we
> ought to dput() before exp_put().

OK.  So a dentry of its own doesn't hold any reference on its
filesystem?

--b.

> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  fs/nfsd/vfs.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index ab93fcf..46e6bd2 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -116,10 +116,15 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
>  	}
>  	if ((exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
>  		/* successfully crossed mount point */
> -		exp_put(exp);
> -		*expp = exp2;
> +		/*
> +		 * This is subtle: dentry is *not* under mnt at this point.
> +		 * The only reason we are safe is that original mnt is pinned
> +		 * down by exp, so we should dput before putting exp.
> +		 */
>  		dput(dentry);
>  		*dpp = mounts;
> +		exp_put(exp);
> +		*expp = exp2;
>  	} else {
>  		exp_put(exp2);
>  		dput(mounts);
> -- 
> 1.5.6.5
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
