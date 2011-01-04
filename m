Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23235 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab1ADUxf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 15:53:35 -0500
Subject: Re: [PATCH_V7 04/12] NFS register and unregister back channel
 transport
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <1294173766-5573-5-git-send-email-andros@netapp.com>
References: <1294173766-5573-1-git-send-email-andros@netapp.com>
	 <1294173766-5573-2-git-send-email-andros@netapp.com>
	 <1294173766-5573-3-git-send-email-andros@netapp.com>
	 <1294173766-5573-4-git-send-email-andros@netapp.com>
	 <1294173766-5573-5-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 04 Jan 2011 15:53:33 -0500
Message-ID: <1294174414.5896.13.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-04 at 15:42 -0500, andros@netapp.com wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/callback.c              |   20 +++++++++++++++++++-
>  fs/nfs/callback.h              |    2 ++
>  fs/nfs/inode.c                 |    4 ++++
>  include/linux/sunrpc/svcsock.h |    3 ++-
>  net/sunrpc/svcsock.c           |   13 +++++++++++++
>  5 files changed, 40 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 93a8b3b..241ab70 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -221,7 +221,17 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
>  	if (minorversion)
>  		xprt->bc_serv = cb_info->serv;
>  }
> -#else
> +
> +void nfs_init_bc_xprt(void)
> +{
> +	svc_init_bc_xprt_sock();
> +}
> +
> +void nfs_cleanup_bc_xprt(void)
> +{
> +	svc_cleanup_bc_xprt_sock();
> +}
> +#else /* CONFIG_NFS_V4_1 */
>  static inline int nfs_minorversion_callback_svc_setup(u32 minorversion,
>  		struct svc_serv *serv, struct rpc_xprt *xprt,
>  		struct svc_rqst **rqstpp, int (**callback_svc)(void *vrqstp))
> @@ -233,6 +243,14 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
>  		struct nfs_callback_data *cb_info)
>  {
>  }
> +
> +void nfs_init_bc_xprt(void)
> +{
> +}
> +
> +void nfs_cleanup_bc_xprt(void)
> +{
> +}
>  #endif /* CONFIG_NFS_V4_1 */
>  
>  /*
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index 85a7cfd..9206a2d 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -149,5 +149,7 @@ extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
>  extern unsigned int nfs_callback_set_tcpport;
>  extern unsigned short nfs_callback_tcpport;
>  extern unsigned short nfs_callback_tcpport6;
> +extern void nfs_init_bc_xprt(void);
> +extern void nfs_cleanup_bc_xprt(void);
>  
>  #endif /* __LINUX_FS_NFS_CALLBACK_H */
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index e67e31c..28afea2 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1571,6 +1571,9 @@ static int __init init_nfs_fs(void)
>  #endif
>  	if ((err = register_nfs_fs()) != 0)
>  		goto out;
> +
> +	nfs_init_bc_xprt();
> +

I'm not sure that I understand. Why would we want to do this in the NFS
layer? Doesn't the above just belong in svc_init_xprt_sock()?

> 	return 0;
>  out:
>  #ifdef CONFIG_PROC_FS
> @@ -1612,6 +1615,7 @@ static void __exit exit_nfs_fs(void)
>  #ifdef CONFIG_PROC_FS
>  	rpc_proc_unregister("nfs");
>  #endif
> +	nfs_cleanup_bc_xprt();

Ditto.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

