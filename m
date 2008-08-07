From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] nfsd: permit unauthenticated stat of export root
Date: Thu, 07 Aug 2008 14:23:40 -0400
Message-ID: <489B3DAC.5060004@redhat.com>
References: <20080807181148.GK18904@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57145 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbYHGSXn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2008 14:23:43 -0400
In-Reply-To: <20080807181148.GK18904@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
>
> RFC 2623 section 2.3.2 permits the server to bypass gss authentication
> checks for certain operations that a client may perform when mounting.
> In the case of a client that doesn't have some form of credentials
> available to it on boot, this allows it to perform the mount unattended.
> (Presumably real file access won't be needed until a user with
> credentials logs in.)
>
> Being slightly more lenient allows lots of old clients to access
> krb5-only exports, with the only loss being a small amount of
> information leaked about the root directory of the export.
>
> This affects on v2 and v3; v4 still requires authentication for all
> access.
>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs3proc.c        |    5 +++--
>  fs/nfsd/nfsfh.c           |   30 ++++++++++++++++++++----------
>  fs/nfsd/nfsproc.c         |    6 ++++--
>  fs/nfsd/vfs.c             |    4 ++--
>  include/linux/nfsd/nfsd.h |    3 ++-
>  5 files changed, 31 insertions(+), 17 deletions(-)
>
> I intend to submit this for 2.6.28
>
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 4d617ea..1419142 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -530,7 +530,7 @@ nfsd3_proc_fsstat(struct svc_rqst * rqstp, struct nfsd_fhandle    *argp,
>  	dprintk("nfsd: FSSTAT(3)   %s\n",
>  				SVCFH_fmt(&argp->fh));
>  
> -	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats);
> +	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats, 0);
>  	fh_put(&argp->fh);
>  	RETURN_STATUS(nfserr);
>  }
> @@ -558,7 +558,8 @@ nfsd3_proc_fsinfo(struct svc_rqst * rqstp, struct nfsd_fhandle    *argp,
>  	resp->f_maxfilesize = ~(u32) 0;
>  	resp->f_properties = NFS3_FSF_DEFAULT;
>  
> -	nfserr = fh_verify(rqstp, &argp->fh, 0, NFSD_MAY_NOP);
> +	nfserr = fh_verify(rqstp, &argp->fh, 0,
> +			NFSD_MAY_NOP | NFSD_MAY_BYPASS_GSS_ON_ROOT);
>  
>  	/* Check special features of the file system. May request
>  	 * different read/write sizes for file systems known to have
>   

I would think that you might want to have nfsd3_proc_getattr()
in this list too.  Some clients may need to generate a GETATTR
if they need the attributes for the root node.

       ps

> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index f45451e..7c6847e 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -302,17 +302,27 @@ fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, int type, int access)
>  	if (error)
>  		goto out;
>  
> -	if (!(access & NFSD_MAY_LOCK)) {
> -		/*
> -		 * pseudoflavor restrictions are not enforced on NLM,
> -		 * which clients virtually always use auth_sys for,
> -		 * even while using RPCSEC_GSS for NFS.
> -		 */
> -		error = check_nfsd_access(exp, rqstp);
> -		if (error)
> -			goto out;
> -	}
> +	/*
> +	 * pseudoflavor restrictions are not enforced on NLM,
> +	 * which clients virtually always use auth_sys for,
> +	 * even while using RPCSEC_GSS for NFS.
> +	 */
> +	if (access & NFSD_MAY_LOCK)
> +		goto skip_pseudoflavor_check;
> +	/*
> +	 * Clients may expect to be able to use auth_sys during mount,
> +	 * even if they use gss for everything else; see section 2.3.2
> +	 * of rfc 2623.
> +	 */
> +	if (access & NFSD_MAY_BYPASS_GSS_ON_ROOT
> +			&& exp->ex_path.dentry == dentry)
> +		goto skip_pseudoflavor_check;
> +
> +	error = check_nfsd_access(exp, rqstp);
> +	if (error)
> +		goto out;
>  
> +skip_pseudoflavor_check:
>  	/* Finally, check access permissions. */
>  	error = nfsd_permission(rqstp, exp, dentry, access);
>  
> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> index 0766f95..5cffeca 100644
> --- a/fs/nfsd/nfsproc.c
> +++ b/fs/nfsd/nfsproc.c
> @@ -65,7 +65,8 @@ nfsd_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
>  	dprintk("nfsd: GETATTR  %s\n", SVCFH_fmt(&argp->fh));
>  
>  	fh_copy(&resp->fh, &argp->fh);
> -	nfserr = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
> +	nfserr = fh_verify(rqstp, &resp->fh, 0,
> +			NFSD_MAY_NOP | NFSD_MAY_BYPASS_GSS_ON_ROOT);
>  	return nfsd_return_attrs(nfserr, resp);
>  }
>  
> @@ -521,7 +522,8 @@ nfsd_proc_statfs(struct svc_rqst * rqstp, struct nfsd_fhandle   *argp,
>  
>  	dprintk("nfsd: STATFS   %s\n", SVCFH_fmt(&argp->fh));
>  
> -	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats);
> +	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats,
> +			NFSD_MAY_BYPASS_GSS_ON_ROOT);
>  	fh_put(&argp->fh);
>  	return nfserr;
>  }
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 0f4481e..f51bdf6 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1872,9 +1872,9 @@ out:
>   * N.B. After this call fhp needs an fh_put
>   */
>  __be32
> -nfsd_statfs(struct svc_rqst *rqstp, struct svc_fh *fhp, struct kstatfs *stat)
> +nfsd_statfs(struct svc_rqst *rqstp, struct svc_fh *fhp, struct kstatfs *stat, int access)
>  {
> -	__be32 err = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP);
> +	__be32 err = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP | access);
>  	if (!err && vfs_statfs(fhp->fh_dentry,stat))
>  		err = nfserr_io;
>  	return err;
> diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
> index a2861d9..47bea82 100644
> --- a/include/linux/nfsd/nfsd.h
> +++ b/include/linux/nfsd/nfsd.h
> @@ -39,6 +39,7 @@
>  #define NFSD_MAY_LOCK		32
>  #define NFSD_MAY_OWNER_OVERRIDE	64
>  #define NFSD_MAY_LOCAL_ACCESS	128 /* IRIX doing local access check on device special file*/
> +#define NFSD_MAY_BYPASS_GSS_ON_ROOT 256
>  
>  #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
>  #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
> @@ -126,7 +127,7 @@ int		nfsd_truncate(struct svc_rqst *, struct svc_fh *,
>  __be32		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
>  			     loff_t *, struct readdir_cd *, filldir_t);
>  __be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
> -				struct kstatfs *);
> +				struct kstatfs *, int access);
>  
>  int		nfsd_notify_change(struct inode *, struct iattr *);
>  __be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
>   

