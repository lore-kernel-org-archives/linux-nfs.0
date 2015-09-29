Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37201 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752635AbbI2UsL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Sep 2015 16:48:11 -0400
Date: Tue, 29 Sep 2015 16:48:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>
Subject: Re: [PATCH 2/2] nfsd: switch unsigned char flags in svc_fh to bools
Message-ID: <20150929204807.GH3190@fieldses.org>
References: <1442492919-31842-1-git-send-email-jeff.layton@primarydata.com>
 <1442492919-31842-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1442492919-31842-2-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK; applying these both for 4.4.--b.

On Thu, Sep 17, 2015 at 08:28:39AM -0400, Jeff Layton wrote:
> ...just for clarity.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfsd/nfs3xdr.c |  4 ++--
>  fs/nfsd/nfsfh.c   |  5 +----
>  fs/nfsd/nfsfh.h   | 18 +++++++++---------
>  fs/nfsd/vfs.c     |  4 ++--
>  fs/nfsd/vfs.h     |  4 ++--
>  fs/nfsd/xdr4.h    |  2 +-
>  6 files changed, 17 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index f6e7cbabac5a..00575d776d91 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -262,11 +262,11 @@ void fill_post_wcc(struct svc_fh *fhp)
>  	err = fh_getattr(fhp, &fhp->fh_post_attr);
>  	fhp->fh_post_change = d_inode(fhp->fh_dentry)->i_version;
>  	if (err) {
> -		fhp->fh_post_saved = 0;
> +		fhp->fh_post_saved = false;
>  		/* Grab the ctime anyway - set_change_info might use it */
>  		fhp->fh_post_attr.ctime = d_inode(fhp->fh_dentry)->i_ctime;
>  	} else
> -		fhp->fh_post_saved = 1;
> +		fhp->fh_post_saved = true;
>  }
>  
>  /*
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index 350041a40fe5..c1681ce894c5 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -631,10 +631,7 @@ fh_put(struct svc_fh *fhp)
>  		fh_unlock(fhp);
>  		fhp->fh_dentry = NULL;
>  		dput(dentry);
> -#ifdef CONFIG_NFSD_V3
> -		fhp->fh_pre_saved = 0;
> -		fhp->fh_post_saved = 0;
> -#endif
> +		fh_clear_wcc(fhp);
>  	}
>  	fh_drop_write(fhp);
>  	if (exp) {
> diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
> index b1edd6bf40e1..2087bae17582 100644
> --- a/fs/nfsd/nfsfh.h
> +++ b/fs/nfsd/nfsfh.h
> @@ -30,12 +30,12 @@ typedef struct svc_fh {
>  	struct dentry *		fh_dentry;	/* validated dentry */
>  	struct svc_export *	fh_export;	/* export pointer */
>  
> -	unsigned char		fh_locked;	/* inode locked by us */
> -	unsigned char		fh_want_write;	/* remount protection taken */
> +	bool			fh_locked;	/* inode locked by us */
> +	bool			fh_want_write;	/* remount protection taken */
>  
>  #ifdef CONFIG_NFSD_V3
> -	unsigned char		fh_post_saved;	/* post-op attrs saved */
> -	unsigned char		fh_pre_saved;	/* pre-op attrs saved */
> +	bool			fh_post_saved;	/* post-op attrs saved */
> +	bool			fh_pre_saved;	/* pre-op attrs saved */
>  
>  	/* Pre-op attributes saved during fh_lock */
>  	__u64			fh_pre_size;	/* size before operation */
> @@ -213,8 +213,8 @@ static inline bool fh_fsid_match(struct knfsd_fh *fh1, struct knfsd_fh *fh2)
>  static inline void
>  fh_clear_wcc(struct svc_fh *fhp)
>  {
> -	fhp->fh_post_saved = 0;
> -	fhp->fh_pre_saved = 0;
> +	fhp->fh_post_saved = false;
> +	fhp->fh_pre_saved = false;
>  }
>  
>  /*
> @@ -231,7 +231,7 @@ fill_pre_wcc(struct svc_fh *fhp)
>  		fhp->fh_pre_ctime = inode->i_ctime;
>  		fhp->fh_pre_size  = inode->i_size;
>  		fhp->fh_pre_change = inode->i_version;
> -		fhp->fh_pre_saved = 1;
> +		fhp->fh_pre_saved = true;
>  	}
>  }
>  
> @@ -267,7 +267,7 @@ fh_lock_nested(struct svc_fh *fhp, unsigned int subclass)
>  	inode = d_inode(dentry);
>  	mutex_lock_nested(&inode->i_mutex, subclass);
>  	fill_pre_wcc(fhp);
> -	fhp->fh_locked = 1;
> +	fhp->fh_locked = true;
>  }
>  
>  static inline void
> @@ -285,7 +285,7 @@ fh_unlock(struct svc_fh *fhp)
>  	if (fhp->fh_locked) {
>  		fill_post_wcc(fhp);
>  		mutex_unlock(&d_inode(fhp->fh_dentry)->i_mutex);
> -		fhp->fh_locked = 0;
> +		fhp->fh_locked = false;
>  	}
>  }
>  
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 45c04979e7b3..994d66fbb446 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1631,7 +1631,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>  	/* cannot use fh_lock as we need deadlock protective ordering
>  	 * so do it by hand */
>  	trap = lock_rename(tdentry, fdentry);
> -	ffhp->fh_locked = tfhp->fh_locked = 1;
> +	ffhp->fh_locked = tfhp->fh_locked = true;
>  	fill_pre_wcc(ffhp);
>  	fill_pre_wcc(tfhp);
>  
> @@ -1681,7 +1681,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>  	fill_post_wcc(ffhp);
>  	fill_post_wcc(tfhp);
>  	unlock_rename(tdentry, fdentry);
> -	ffhp->fh_locked = tfhp->fh_locked = 0;
> +	ffhp->fh_locked = tfhp->fh_locked = false;
>  	fh_drop_write(ffhp);
>  
>  out:
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index fee2451ae248..fcfc48cbe136 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -112,14 +112,14 @@ static inline int fh_want_write(struct svc_fh *fh)
>  	int ret = mnt_want_write(fh->fh_export->ex_path.mnt);
>  
>  	if (!ret)
> -		fh->fh_want_write = 1;
> +		fh->fh_want_write = true;
>  	return ret;
>  }
>  
>  static inline void fh_drop_write(struct svc_fh *fh)
>  {
>  	if (fh->fh_want_write) {
> -		fh->fh_want_write = 0;
> +		fh->fh_want_write = false;
>  		mnt_drop_write(fh->fh_export->ex_path.mnt);
>  	}
>  }
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 9f991007a578..ce7362c88b48 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -632,7 +632,7 @@ static inline void
>  set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
>  {
>  	BUG_ON(!fhp->fh_pre_saved);
> -	cinfo->atomic = fhp->fh_post_saved;
> +	cinfo->atomic = (u32)fhp->fh_post_saved;
>  	cinfo->change_supported = IS_I_VERSION(d_inode(fhp->fh_dentry));
>  
>  	cinfo->before_change = fhp->fh_pre_change;
> -- 
> 2.4.3
