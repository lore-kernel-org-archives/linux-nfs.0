From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/3] NFSD: Add a cache for fs_locations information
Date: Tue, 13 Sep 2011 22:44:47 -0400
Message-ID: <20110914024447.GB28357@fieldses.org>
References: <20110912232149.5080.95084.stgit@matisse.1015granger.net>
 <20110912233726.5080.20512.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54806 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754044Ab1INCot (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 22:44:49 -0400
In-Reply-To: <20110912233726.5080.20512.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 12, 2011 at 07:37:26PM -0400, Chuck Lever wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> [ cel: since this is server-side, use nfsd4_ prefix instead of nfs4_ prefix. ]
> [ cel: implement S_ISVTX filter in bfields-normal form ]

Hm.--b.

> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfsd/nfsd.h |    7 +++++++
>  fs/nfsd/vfs.c  |   18 ++++++++++++++++++
>  2 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index 7ecfa24..d314812 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -335,6 +335,13 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
>  #define NFSD_SUPPATTR_EXCLCREAT_WORD2 \
>  	NFSD_WRITEABLE_ATTRS_WORD2
>  
> +extern int nfsd4_is_junction(struct dentry *dentry);
> +#else
> +static inline int nfsd4_is_junction(struct dentry *dentry)
> +{
> +	return 0;
> +}
> +
>  #endif /* CONFIG_NFSD_V4 */
>  
>  #endif /* LINUX_NFSD_NFSD_H */
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index fd0acca..d1d4d5e 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -168,6 +168,8 @@ int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
>  {
>  	if (d_mountpoint(dentry))
>  		return 1;
> +	if (nfsd4_is_junction(dentry))
> +		return 1;
>  	if (!(exp->ex_flags & NFSEXP_V4ROOT))
>  		return 0;
>  	return dentry->d_inode != NULL;
> @@ -592,6 +594,22 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct nfs4_ac
>  	return error;
>  }
>  
> +#define NFSD_XATTR_JUNCTION_PREFIX XATTR_TRUSTED_PREFIX "junction."
> +#define NFSD_XATTR_JUNCTION_TYPE NFSD_XATTR_JUNCTION_PREFIX "type"
> +int nfsd4_is_junction(struct dentry *dentry)
> +{
> +	struct inode *inode = dentry->d_inode;
> +
> +	if (inode == NULL)
> +		return 0;
> +	if (inode->i_mode & S_IXUGO)
> +		return 0;
> +	if (!(inode->i_mode & S_ISVTX))
> +		return 0;
> +	if (vfs_getxattr(dentry, NFSD_XATTR_JUNCTION_TYPE, NULL, 0) <= 0)
> +		return 0;
> +	return 1;
> +}
>  #endif /* defined(CONFIG_NFSD_V4) */
>  
>  #ifdef CONFIG_NFSD_V3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
