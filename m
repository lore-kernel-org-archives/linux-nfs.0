Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59299 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979AbbGHVpf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jul 2015 17:45:35 -0400
Date: Wed, 8 Jul 2015 17:45:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/5] nfsd: Add macro NFS_ACL_MASK for ACL
Message-ID: <20150708214534.GI19084@fieldses.org>
References: <559672B7.4010802@gmail.com>
 <55967456.3080908@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55967456.3080908@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 03, 2015 at 07:39:02PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

OK, thanks.--b.

> ---
>  fs/nfsd/nfs2acl.c           | 10 ++++------
>  fs/nfsd/nfs3acl.c           |  4 ++--
>  include/uapi/linux/nfsacl.h |  1 +
>  3 files changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
> index d54701f..1580ea6 100644
> --- a/fs/nfsd/nfs2acl.c
> +++ b/fs/nfsd/nfs2acl.c
> @@ -44,13 +44,13 @@ static __be32 nfsacld_proc_getacl(struct svc_rqst * rqstp,
>  
>  	inode = d_inode(fh->fh_dentry);
>  
> -	if (argp->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT))
> +	if (argp->mask & ~NFS_ACL_MASK)
>  		RETURN_STATUS(nfserr_inval);
>  	resp->mask = argp->mask;
>  
>  	nfserr = fh_getattr(fh, &resp->stat);
>  	if (nfserr)
> -		goto fail;
> +		RETURN_STATUS(nfserr);
>  
>  	if (resp->mask & (NFS_ACL|NFS_ACLCNT)) {
>  		acl = get_acl(inode, ACL_TYPE_ACCESS);
> @@ -202,7 +202,7 @@ static int nfsaclsvc_decode_setaclargs(struct svc_rqst *rqstp, __be32 *p,
>  	if (!p)
>  		return 0;
>  	argp->mask = ntohl(*p++);
> -	if (argp->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT) ||
> +	if (argp->mask & ~NFS_ACL_MASK ||
>  	    !xdr_argsize_check(rqstp, p))
>  		return 0;
>  
> @@ -293,9 +293,7 @@ static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
>  				  resp->acl_default,
>  				  resp->mask & NFS_DFACL,
>  				  NFS_ACL_DEFAULT);
> -	if (n <= 0)
> -		return 0;
> -	return 1;
> +	return (n > 0);
>  }
>  
>  static int nfsaclsvc_encode_attrstatres(struct svc_rqst *rqstp, __be32 *p,
> diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
> index 882b1a1..01df4cd 100644
> --- a/fs/nfsd/nfs3acl.c
> +++ b/fs/nfsd/nfs3acl.c
> @@ -41,7 +41,7 @@ static __be32 nfsd3_proc_getacl(struct svc_rqst * rqstp,
>  
>  	inode = d_inode(fh->fh_dentry);
>  
> -	if (argp->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT))
> +	if (argp->mask & ~NFS_ACL_MASK)
>  		RETURN_STATUS(nfserr_inval);
>  	resp->mask = argp->mask;
>  
> @@ -148,7 +148,7 @@ static int nfs3svc_decode_setaclargs(struct svc_rqst *rqstp, __be32 *p,
>  	if (!p)
>  		return 0;
>  	args->mask = ntohl(*p++);
> -	if (args->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT) ||
> +	if (args->mask & ~NFS_ACL_MASK ||
>  	    !xdr_argsize_check(rqstp, p))
>  		return 0;
>  
> diff --git a/include/uapi/linux/nfsacl.h b/include/uapi/linux/nfsacl.h
> index 9bb9771..5527266 100644
> --- a/include/uapi/linux/nfsacl.h
> +++ b/include/uapi/linux/nfsacl.h
> @@ -22,6 +22,7 @@
>  #define NFS_ACLCNT		0x0002
>  #define NFS_DFACL		0x0004
>  #define NFS_DFACLCNT		0x0008
> +#define NFS_ACL_MASK		0x000f
>  
>  /* Flag for Default ACL entries */
>  #define NFS_ACL_DEFAULT		0x1000
> -- 
> 2.4.3
