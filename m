Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43988 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221Ab2H3Ub2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Aug 2012 16:31:28 -0400
Date: Thu, 30 Aug 2012 16:31:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: viro@zeniv.linux.org.uk, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Vivek Trivedi <vtrivedi018@gmail.com>
Subject: Re: [PATCH] exportfs: add FILEID_INVALID to indicate invalid
 fid_type
Message-ID: <20120830203125.GA23478@fieldses.org>
References: <1346249410-3515-1-git-send-email-linkinjeon@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1346249410-3515-1-git-send-email-linkinjeon@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 29, 2012 at 10:10:10AM -0400, Namjae Jeon wrote:
> This commit adds FILEID_INVALID = 0xff in fid_type to
> indicate invalid fid_type

OK, applying for 3.7.

Looks like this shows up in a lot of filesystems too as just "255".  Are
you planning to patch up the filesystems afterwards?

--b.

> 
> It avoids using magic number 255
> 
> Signed-off-by: Namjae Jeon <linkinjeon@gmail.com>
> Signed-off-by: Vivek Trivedi <vtrivedi018@gmail.com>
> ---
>  fs/exportfs/expfs.c      |    4 ++--
>  fs/fhandle.c             |    2 +-
>  fs/nfsd/nfsfh.c          |    4 ++--
>  include/linux/exportfs.h |    5 +++++
>  4 files changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
> index 29ab099..f1f1c59 100644
> --- a/fs/exportfs/expfs.c
> +++ b/fs/exportfs/expfs.c
> @@ -322,10 +322,10 @@ static int export_encode_fh(struct inode *inode, struct fid *fid,
>  
>  	if (parent && (len < 4)) {
>  		*max_len = 4;
> -		return 255;
> +		return FILEID_INVALID;
>  	} else if (len < 2) {
>  		*max_len = 2;
> -		return 255;
> +		return FILEID_INVALID;
>  	}
>  
>  	len = 2;
> diff --git a/fs/fhandle.c b/fs/fhandle.c
> index a48e4a1..78a7879 100644
> --- a/fs/fhandle.c
> +++ b/fs/fhandle.c
> @@ -52,7 +52,7 @@ static long do_sys_name_to_handle(struct path *path,
>  	handle_bytes = handle_dwords * sizeof(u32);
>  	handle->handle_bytes = handle_bytes;
>  	if ((handle->handle_bytes > f_handle.handle_bytes) ||
> -	    (retval == 255) || (retval == -ENOSPC)) {
> +	    (retval == FILEID_INVALID) || (retval == -ENOSPC)) {
>  		/* As per old exportfs_encode_fh documentation
>  		 * we could return ENOSPC to indicate overflow
>  		 * But file system returned 255 always. So handle
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index 032af38..814afaa 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -572,7 +572,7 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
>  
>  		if (inode)
>  			_fh_update(fhp, exp, dentry);
> -		if (fhp->fh_handle.fh_fileid_type == 255) {
> +		if (fhp->fh_handle.fh_fileid_type == FILEID_INVALID) {
>  			fh_put(fhp);
>  			return nfserr_opnotsupp;
>  		}
> @@ -603,7 +603,7 @@ fh_update(struct svc_fh *fhp)
>  			goto out;
>  
>  		_fh_update(fhp, fhp->fh_export, dentry);
> -		if (fhp->fh_handle.fh_fileid_type == 255)
> +		if (fhp->fh_handle.fh_fileid_type == FILEID_INVALID)
>  			return nfserr_opnotsupp;
>  	}
>  out:
> diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
> index 12291a7..0e14525 100644
> --- a/include/linux/exportfs.h
> +++ b/include/linux/exportfs.h
> @@ -83,6 +83,11 @@ enum fid_type {
>  	 * 64 bit parent inode number.
>  	 */
>  	FILEID_NILFS_WITH_PARENT = 0x62,
> +
> +	/*
> +	 * Filesystems must not use 0xff file ID.
> +	 */
> +	FILEID_INVALID = 0xff,
>  };
>  
>  struct fid {
> -- 
> 1.7.9.5
> 
