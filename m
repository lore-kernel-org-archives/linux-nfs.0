Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47352 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756378Ab0LKAP7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 19:15:59 -0500
Date: Fri, 10 Dec 2010 19:15:58 -0500
From: "J.Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH] nfsd: Fix possible BUG_ON firing in set_change_info
Message-ID: <20101211001558.GE18141@fieldses.org>
References: <20101202111430.57275603@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101202111430.57275603@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 02, 2010 at 11:14:30AM +1100, Neil Brown wrote:
> 
> If vfs_getattr in fill_post_wcc returns an error, we don't
> set fh_post_change.
> For NFSv4, this can result in set_change_info triggering a BUG_ON.
> i.e. fh_post_saved being zero isn't really a bug.
> 
> So:
>  - instead of BUGging when fh_post_saved is zero, just clear ->atomic.
>  - if vfs_getattr fails in fill_post_wcc, take a copy of i_ctime anyway.
>    This will be used i seg_change_info, but not overly trusted.
>  - While we are there, remove the pointless 'if' statements in set_change_info.
>    There is no harm setting all the values.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> --
> 
> If you think the code is clearer with the if() structure, feel free
> to leave that part unchanged.

Looks fine to me as-is; planning to submit for 2.6.37 and -stable unless
I hear otherwise.

--b.

> 
> NeilBrown
> 
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index 2a533a0..7e84a85 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -260,9 +260,11 @@ void fill_post_wcc(struct svc_fh *fhp)
>  	err = vfs_getattr(fhp->fh_export->ex_path.mnt, fhp->fh_dentry,
>  			&fhp->fh_post_attr);
>  	fhp->fh_post_change = fhp->fh_dentry->d_inode->i_version;
> -	if (err)
> +	if (err) {
>  		fhp->fh_post_saved = 0;
> -	else
> +		/* Grab the ctime anyway - set_change_info might use it */
> +		fhp->fh_post_attr.ctime = fhp->fh_dentry->d_inode->i_ctime;
> +	} else
>  		fhp->fh_post_saved = 1;
>  }
>  
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 4d476ff..60fce3d 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -484,18 +484,17 @@ static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
>  static inline void
>  set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
>  {
> -	BUG_ON(!fhp->fh_pre_saved || !fhp->fh_post_saved);
> -	cinfo->atomic = 1;
> +	BUG_ON(!fhp->fh_pre_saved);
> +	cinfo->atomic = fhp->fh_post_saved;
>  	cinfo->change_supported = IS_I_VERSION(fhp->fh_dentry->d_inode);
> -	if (cinfo->change_supported) {
> -		cinfo->before_change = fhp->fh_pre_change;
> -		cinfo->after_change = fhp->fh_post_change;
> -	} else {
> -		cinfo->before_ctime_sec = fhp->fh_pre_ctime.tv_sec;
> -		cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
> -		cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
> -		cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
> -	}
> +
> +	cinfo->before_change = fhp->fh_pre_change;
> +	cinfo->after_change = fhp->fh_post_change;
> +	cinfo->before_ctime_sec = fhp->fh_pre_ctime.tv_sec;
> +	cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
> +	cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
> +	cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
> +
>  }
>  
>  int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
