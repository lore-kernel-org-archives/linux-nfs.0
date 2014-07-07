Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55091 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809AbaGGSif (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2014 14:38:35 -0400
Date: Mon, 7 Jul 2014 14:38:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: add a nfserrno mapping for -E2BIG to nfserr_fbig
Message-ID: <20140707183834.GE8630@fieldses.org>
References: <1404414954-5227-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404414954-5227-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applied.--b.

On Thu, Jul 03, 2014 at 03:15:54PM -0400, Jeff Layton wrote:
> I saw this pop up with some pynfs testing:
> 
>     [  123.609992] nfsd: non-standard errno: -7
> 
> ...and -7 is -E2BIG. I think what happened is that XFS returned -E2BIG
> due to some xattr operations with the ACL10 pynfs TEST (I guess it has
> limited xattr size?).
> 
> Add a better mapping for that error since it's possible that we'll need
> it. How about we convert it to NFSERR_FBIG? As Bruce points out, they
> both have "BIG" in the name so it must be good.
> 
> Also, turn the printk in this function into a WARN() so that we can get
> a bit more information about situations that don't have proper mappings.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfsproc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> index eff49552cdc8..b19c7e8bf64c 100644
> --- a/fs/nfsd/nfsproc.c
> +++ b/fs/nfsd/nfsproc.c
> @@ -717,6 +717,7 @@ nfserrno (int errno)
>  		{ nfserr_noent, -ENOENT },
>  		{ nfserr_io, -EIO },
>  		{ nfserr_nxio, -ENXIO },
> +		{ nfserr_fbig, -E2BIG },
>  		{ nfserr_acces, -EACCES },
>  		{ nfserr_exist, -EEXIST },
>  		{ nfserr_xdev, -EXDEV },
> @@ -751,7 +752,7 @@ nfserrno (int errno)
>  		if (nfs_errtbl[i].syserr == errno)
>  			return nfs_errtbl[i].nfserr;
>  	}
> -	printk (KERN_INFO "nfsd: non-standard errno: %d\n", errno);
> +	WARN(1, "nfsd: non-standard errno: %d\n", errno);
>  	return nfserr_io;
>  }
>  
> -- 
> 1.9.3
> 
