Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48660 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892Ab1IHXVV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Sep 2011 19:21:21 -0400
Date: Thu, 8 Sep 2011 14:20:24 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSD: Cleanup for nfsd4_path()
Message-ID: <20110908182024.GB16740@fieldses.org>
References: <20110902162210.32190.5880.stgit@matisse.1015granger.net>
 <20110902163823.32190.76856.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110902163823.32190.76856.stgit@matisse.1015granger.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 02, 2011 at 12:38:23PM -0400, Chuck Lever wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> The current code is sort of hackish in that it assumes a referral is always
> matched to an export. When we add support for junctions that may not be the
> case.
> We can replace nfsd4_path() with a function that encodes the components
> directly from the dentries. Since nfsd4_path is currently the only user of
> the 'ex_pathname' field in struct svc_export, this has the added benefit
> of allowing us to get rid of that.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfsd/export.c            |    4 +-
>  fs/nfsd/nfs4xdr.c           |  106 ++++++++++++++++++++++++++++++++-----------
>  include/linux/nfsd/export.h |    1 
>  3 files changed, 81 insertions(+), 30 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index f4cc1e2..d9a6611 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -1010,7 +1010,7 @@ rqst_exp_parent(struct svc_rqst *rqstp, struct path *path)
>  	return exp;
>  }
>  
> -static struct svc_export *find_fsidzero_export(struct svc_rqst *rqstp)
> +struct svc_export *rqst_find_fsidzero_export(struct svc_rqst *rqstp)
>  {
>  	u32 fsidv[2];
>  
> @@ -1030,7 +1030,7 @@ exp_pseudoroot(struct svc_rqst *rqstp, struct svc_fh *fhp)
>  	struct svc_export *exp;
>  	__be32 rv;
>  
> -	exp = find_fsidzero_export(rqstp);
> +	exp = rqst_find_fsidzero_export(rqstp);
>  	if (IS_ERR(exp))
>  		return nfserrno(PTR_ERR(exp));
>  	rv = fh_compose(fhp, exp, exp->ex_path.dentry, NULL);
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index c8bf405..f7b068e 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1697,36 +1697,89 @@ static __be32 nfsd4_encode_fs_location4(struct nfsd4_fs_location *location,
>  }
>  
>  /*
> - * Return the path to an export point in the pseudo filesystem namespace
> - * Returned string is safe to use as long as the caller holds a reference
> - * to @exp.
> + * Encode a path in RFC3530 'pathname4' format
>   */
> -static char *nfsd4_path(struct svc_rqst *rqstp, struct svc_export *exp, __be32 *stat)
> +static __be32 nfsd4_encode_path(const struct path *root,
> +		const struct path *path, __be32 **pp, int *buflen)
>  {
> -	struct svc_fh tmp_fh;
> -	char *path = NULL, *rootpath;
> -	size_t rootlen;
> +	struct path cur = {
> +		.mnt = path->mnt,
> +		.dentry = path->dentry,
> +	};
> +	__be32 *p = *pp;
> +	struct dentry **components = NULL;
> +	unsigned int ncomponents = 0;
> +	__be32 err = nfserr_resource;

I've been fixing nfsd to return nfserr_jukebox for allocation errors,
and reserving nfserr_resource (not even available in 4.1) for cases
where the error is permanent (e.g. I just can't process a compound with
1000 ops).

Patch looks fine otherwise.

--b.

>  
> -	fh_init(&tmp_fh, NFS4_FHSIZE);
> -	*stat = exp_pseudoroot(rqstp, &tmp_fh);
> -	if (*stat)
> -		return NULL;
> -	rootpath = tmp_fh.fh_export->ex_pathname;
> +	dprintk("nfsd4_encode_components(");
>  
> -	path = exp->ex_pathname;
> +	path_get(&cur);
> +	/* First walk the path up to the nfsd root, and store the
> +	 * dentries/path components in an array.
> +	 */
> +	for (;;) {
> +		if (cur.dentry == root->dentry && cur.mnt == root->mnt)
> +			break;
> +		if (cur.dentry == cur.mnt->mnt_root) {
> +			if (follow_up(&cur))
> +				continue;
> +			goto out_free;
> +		}
> +		if ((ncomponents & 15) == 0) {
> +			struct dentry **new;
> +			new = krealloc(components,
> +					sizeof(*new) * (ncomponents + 16),
> +					GFP_KERNEL);
> +			if (!new)
> +				goto out_free;
> +			components = new;
> +		}
> +		components[ncomponents++] = cur.dentry;
> +		cur.dentry = dget_parent(cur.dentry);
> +	}
>  
> -	rootlen = strlen(rootpath);
> -	if (strncmp(path, rootpath, rootlen)) {
> -		dprintk("nfsd: fs_locations failed;"
> -			"%s is not contained in %s\n", path, rootpath);
> -		*stat = nfserr_notsupp;
> -		path = NULL;
> -		goto out;
> +	*buflen -= 4;
> +	if (*buflen < 0)
> +		goto out_free;
> +	WRITE32(ncomponents);
> +
> +	while (ncomponents) {
> +		struct dentry *dentry = components[ncomponents - 1];
> +		unsigned int len = dentry->d_name.len;
> +
> +		*buflen -= 4 + (XDR_QUADLEN(len) << 2);
> +		if (*buflen < 0)
> +			goto out_free;
> +		WRITE32(len);
> +		WRITEMEM(dentry->d_name.name, len);
> +		dprintk("/%s", dentry->d_name.name);
> +		dput(dentry);
> +		ncomponents--;
>  	}
> -	path += rootlen;
> -out:
> -	fh_put(&tmp_fh);
> -	return path;
> +
> +	*pp = p;
> +	err = 0;
> +out_free:
> +	dprintk(")\n");
> +	while (ncomponents)
> +		dput(components[--ncomponents]);
> +	kfree(components);
> +	path_put(&cur);
> +	return err;
> +}
> +
> +static __be32 nfsd4_encode_fsloc_fsroot(struct svc_rqst *rqstp,
> +		const struct path *path, __be32 **pp, int *buflen)
> +{
> +	struct svc_export *exp_ps;
> +	__be32 res;
> +
> +	exp_ps = rqst_find_fsidzero_export(rqstp);
> +	if (IS_ERR(exp_ps))
> +		return nfserrno(PTR_ERR(exp_ps));
> +	res = nfsd4_encode_path(&exp_ps->ex_path, path, pp, buflen);
> +	exp_put(exp_ps);
> +	return res;
>  }
>  
>  /*
> @@ -1740,11 +1793,8 @@ static __be32 nfsd4_encode_fs_locations(struct svc_rqst *rqstp,
>  	int i;
>  	__be32 *p = *pp;
>  	struct nfsd4_fs_locations *fslocs = &exp->ex_fslocs;
> -	char *root = nfsd4_path(rqstp, exp, &status);
>  
> -	if (status)
> -		return status;
> -	status = nfsd4_encode_components('/', root, &p, buflen);
> +	status = nfsd4_encode_fsloc_fsroot(rqstp, &exp->ex_path, &p, buflen);
>  	if (status)
>  		return status;
>  	if ((*buflen -= 4) < 0)
> diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
> index 8a31a20..7ba3fd4 100644
> --- a/include/linux/nfsd/export.h
> +++ b/include/linux/nfsd/export.h
> @@ -137,6 +137,7 @@ struct svc_export *	rqst_exp_get_by_name(struct svc_rqst *,
>  					     struct path *);
>  struct svc_export *	rqst_exp_parent(struct svc_rqst *,
>  					struct path *);
> +struct svc_export *	rqst_find_fsidzero_export(struct svc_rqst *);
>  int			exp_rootfh(struct auth_domain *, 
>  					char *path, struct knfsd_fh *, int maxsize);
>  __be32			exp_pseudoroot(struct svc_rqst *, struct svc_fh *);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
