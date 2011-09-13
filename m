Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61655 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753416Ab1IMNNh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 09:13:37 -0400
Date: Tue, 13 Sep 2011 09:16:54 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] NFSD: Add a cache for fs_locations information
Message-ID: <20110913091654.698e04b4@corrin.poochiereds.net>
In-Reply-To: <20110912233726.5080.20512.stgit@matisse.1015granger.net>
References: <20110912232149.5080.95084.stgit@matisse.1015granger.net>
	<20110912233726.5080.20512.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 12 Sep 2011 19:37:26 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> [ cel: since this is server-side, use nfsd4_ prefix instead of nfs4_ prefix. ]
> [ cel: implement S_ISVTX filter in bfields-normal form ]
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

	^^^^^^^^^^^^^^^^^^
Minor nit: it's more likely that a directory will have the execute bit
set everywhere than the sticky bit. Checking for the sticky bit first
seems like it might cut out some unnecessary checks for S_IXUGO.

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

Other than that, this (and the previous patches) look fine...
-- 
Jeff Layton <jlayton@redhat.com>
