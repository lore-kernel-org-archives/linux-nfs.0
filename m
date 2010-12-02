Return-Path: <linux-nfs-owner@vger.kernel.org>
Message-ID: <4CF73AC6.4020105@suse.de>
Date: Thu, 02 Dec 2010 11:50:54 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
To: Neil Brown <neilb@suse.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix possible BUG_ON firing in set_change_info
References: <20101202111430.57275603@notabene.brown>
In-Reply-To: <20101202111430.57275603@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 12/02/2010 05:44 AM, Neil Brown wrote:
> 
> If vfs_getattr in fill_post_wcc returns an error, we don't
> set fh_post_change.
      ^^^ Did you mean fh_post_saved?

> For NFSv4, this can result in set_change_info triggering a BUG_ON.
> i.e. fh_post_saved being zero isn't really a bug.
> 
> So:
>  - instead of BUGging when fh_post_saved is zero, just clear ->atomic.
>  - if vfs_getattr fails in fill_post_wcc, take a copy of i_ctime anyway.
>    This will be used i seg_change_info, but not overly trusted.
>  - While we are there, remove the pointless 'if' statements in set_change_info.
>    There is no harm setting all the values.

The 'if' statement was introduced when ext4 i_version support was added
via commit c654b8a9. While there is no harm setting all the values, it
may not really be required.

>From the spec:

	"For a client to use the change_info4 information
appropriately and correctly, the server must report the pre- and
post-operation change attribute values atomically. When the server
is unable to report the before and after values atomically with
respect to the directory operation, the server must indicate that
fact in the change_info4 return value. When the information is not
atomically reported, the client should not assume that other clients
have not changed the directory."

Though the spec doesn't talk about the case we have specifically, it
appears to me that the proposed behavior is the best we could aim for.

> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> --
> 
> If you think the code is clearer with the if() structure, feel free
> to leave that part unchanged.
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


-- 
Suresh Jayaraman
