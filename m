From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH] nfsd: Fix possible BUG_ON firing in set_change_info
Date: Thu, 02 Dec 2010 12:22:16 +0530
Message-ID: <4CF74220.9050109@suse.de>
References: <20101202111430.57275603@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
In-Reply-To: <20101202111430.57275603-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/02/2010 05:44 AM, Neil Brown wrote:
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

Perhaps, a dprintk here would help debugging?


Thanks,

-- 
Suresh Jayaraman
