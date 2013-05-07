Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33419 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753119Ab3EGVFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 May 2013 17:05:03 -0400
Date: Tue, 7 May 2013 17:05:00 -0400
To: Zhao Hongjiang <zhaohongjiang@huawei.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: get rid of the unused functions in vfs
Message-ID: <20130507210500.GG32743@fieldses.org>
References: <51838C98.2090205@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51838C98.2090205@huawei.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 3.11.

--b.

On Fri, May 03, 2013 at 06:08:24PM +0800, Zhao Hongjiang wrote:
> The fh_lock_parent(), nfsd_truncate(), nfsd_notify_change() and nfsd_sync_dir()
> fuctions were never implement and used, just remove them.
> 
> Signed-off-by: Zhao Hongjiang <zhaohongjiang@huawei.com>
> ---
>  fs/nfsd/vfs.h |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index 5b58941..8d2b40d 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -39,7 +39,6 @@
>  typedef int (*nfsd_dirop_t)(struct inode *, struct dentry *, int, int);
>  
>  /* nfsd/vfs.c */
> -int		fh_lock_parent(struct svc_fh *, struct dentry *);
>  int		nfsd_racache_init(int);
>  void		nfsd_racache_shutdown(void);
>  int		nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
> @@ -92,17 +91,13 @@ __be32		nfsd_remove(struct svc_rqst *,
>  				struct svc_fh *, char *, int);
>  __be32		nfsd_unlink(struct svc_rqst *, struct svc_fh *, int type,
>  				char *name, int len);
> -int		nfsd_truncate(struct svc_rqst *, struct svc_fh *,
> -				unsigned long size);
>  __be32		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
>  			     loff_t *, struct readdir_cd *, filldir_t);
>  __be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
>  				struct kstatfs *, int access);
>  
> -int		nfsd_notify_change(struct inode *, struct iattr *);
>  __be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
>  				struct dentry *, int);
> -int		nfsd_sync_dir(struct dentry *dp);
>  
>  #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
>  struct posix_acl *nfsd_get_posix_acl(struct svc_fh *, int);
> -- 
> 1.7.1
> 
