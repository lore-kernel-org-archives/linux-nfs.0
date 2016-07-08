Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33052 "EHLO
	mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbcGHLCa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 07:02:30 -0400
Received: by mail-qt0-f193.google.com with SMTP id f89so5173801qtd.0
        for <linux-nfs@vger.kernel.org>; Fri, 08 Jul 2016 04:02:30 -0700 (PDT)
Message-ID: <1467975747.24149.16.camel@poochiereds.net>
Subject: Re: [PATCH] nfsd: Make creates return EEXIST correctly instead of
 EPERM
From: Jeff Layton <jlayton@poochiereds.net>
To: Oleg Drokin <green@linuxhacker.ru>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Fri, 08 Jul 2016 07:02:27 -0400
In-Reply-To: <1467942466-3081422-1-git-send-email-green@linuxhacker.ru>
References: <1467942466-3081422-1-git-send-email-green@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-07-07 at 21:47 -0400, Oleg Drokin wrote:
> It looks like we are bit overzealous about failing mkdir/create/mknod
> with permission denied if the parent dir is not writeable.
> Need to make sure the name does not exist first, because we need to
> return EEXIST in that case.
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
> A very similar problem exists with symlinks, but the patch is more
> involved, so assuming this one is ok, I'll send a symlink one separately.
>  fs/nfsd/nfs4proc.c |  6 +++++-
>  fs/nfsd/vfs.c      | 11 ++++++++++-
>  2 files changed, 15 insertions(+), 2 deletions(-)
> 


nit: subject says EPERM, but I think you mean EACCES. The mnemonic I've
always used is that EPERM is "permanent". IOW, changing permissions
won't ever allow the user to do something. For instance, unprivileged
users can never chown a file, so they should get back EPERM there. When
a directory isn't writeable on a create they should get EACCES since
they could do the create if the directory were writeable.


> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index de1ff1d..0067520 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -605,8 +605,12 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  
>  	fh_init(&resfh, NFS4_FHSIZE);
>  
> +	/*
> +	 * We just check thta parent is accessible here, nfsd_* do their
> +	 * own access permission checks
> +	 */
>  	status = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
> -			   NFSD_MAY_CREATE);
> +			   NFSD_MAY_EXEC);
>  	if (status)
>  		return status;
>  
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 6fbd81e..6a45ec6 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1161,7 +1161,11 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	if (isdotent(fname, flen))
>  		goto out;
>  
> -	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> +	/*
> +	 * Even though it is a create, first we see if we are even allowed
> +	 * to peek inside the parent
> +	 */
> +	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
>  	if (err)
>  		goto out;
>  
> @@ -1211,6 +1215,11 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		goto out; 
>  	}
>  
> +	/* Now let's see if we actually have permissions to create */
> +	err = nfsd_permission(rqstp, fhp->fh_export, dentry, NFSD_MAY_CREATE);
> +	if (err)
> +		goto out;
> +
>  	if (!(iap->ia_valid & ATTR_MODE))
>  		iap->ia_mode = 0;
>  	iap->ia_mode = (iap->ia_mode & S_IALLUGO) | type;


Ouch. This means two nfsd_permission calls per create operation. If
it's necessary for correctness then so be it, but is it actually
documented anywhere (POSIX perhaps?) that we must prefer EEXIST over
EACCES in this situation?

-- 

Jeff Layton <jlayton@poochiereds.net>
