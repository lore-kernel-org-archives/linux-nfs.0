Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63494 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312Ab1AEVwO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 16:52:14 -0500
Subject: Re: [PATCH_V8 07/13] NFS implement v4.0 callback_ident
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <1294260690-3095-8-git-send-email-andros@netapp.com>
References: <1294260690-3095-1-git-send-email-andros@netapp.com>
	 <1294260690-3095-2-git-send-email-andros@netapp.com>
	 <1294260690-3095-3-git-send-email-andros@netapp.com>
	 <1294260690-3095-4-git-send-email-andros@netapp.com>
	 <1294260690-3095-5-git-send-email-andros@netapp.com>
	 <1294260690-3095-6-git-send-email-andros@netapp.com>
	 <1294260690-3095-7-git-send-email-andros@netapp.com>
	 <1294260690-3095-8-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Jan 2011 16:52:11 -0500
Message-ID: <1294264331.2952.7.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-05 at 15:51 -0500, andros@netapp.com wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> Use the small id to pointer translator service to provide a unique callback
> identifier per SETCLIENTID call used to identify the v4.0 callback service
> associated with the clientid.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/client.c           |   26 ++++++++++++++++++++++++++
>  fs/nfs/inode.c            |    1 +
>  fs/nfs/internal.h         |    2 ++
>  fs/nfs/nfs4proc.c         |    7 +++++++
>  fs/nfs/nfs4state.c        |    1 +
>  include/linux/nfs_fs_sb.h |    1 +
>  include/linux/nfs_xdr.h   |    1 +
>  7 files changed, 39 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 855add6..251c78f 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -56,6 +56,8 @@ static DEFINE_SPINLOCK(nfs_client_lock);
>  static LIST_HEAD(nfs_client_list);
>  static LIST_HEAD(nfs_volume_list);
>  static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
> +/* NFSv4.0 callback identifier */
> +static DEFINE_IDR(cb_ident_idr);
>  
>  /*
>   * RPC cruft for NFS
> @@ -359,6 +361,30 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
>  	return 0;
>  }
>  
> +/* idr_remove_all is not needed as all id's are removed by nfs_put_client */
> +void nfs_cleanup_cb_ident_idr(void)
> +{
> +	idr_destroy(&cb_ident_idr);
> +}
> +
> +/*
> + * Get a unique NFSv4.0 callback identifier which will be used
> + * by the V4.0 callback service to lookup the nfs_client struct
> + */
> +int nfs_get_cb_ident(struct nfs_client *clp, int *cb_ident)
> +{
> +	int ret;
> +retry:
> +	if (!idr_pre_get(&cb_ident_idr, GFP_KERNEL))
> +		return -ENOMEM;
> +	spin_lock(&nfs_client_lock);
> +	ret = idr_get_new(&cb_ident_idr, clp, cb_ident);
> +	spin_unlock(&nfs_client_lock);
> +	if (ret == -EAGAIN)
> +		goto retry;
> +	return ret;
> +}
> +
>  /*
>   * Find a client by IP address and protocol version
>   * - returns NULL if no such client
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index e67e31c..c7782b2 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1612,6 +1612,7 @@ static void __exit exit_nfs_fs(void)
>  #ifdef CONFIG_PROC_FS
>  	rpc_proc_unregister("nfs");
>  #endif
> +	nfs_cleanup_cb_ident_idr();
>  	unregister_nfs_fs();
>  	nfs_fs_proc_exit();
>  	nfsiod_stop();
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 435eae3..7a6c05f 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -128,6 +128,8 @@ extern void nfs_umount(const struct nfs_mount_request *info);
>  /* client.c */
>  extern struct rpc_program nfs_program;
>  
> +extern void nfs_cleanup_cb_ident_idr(void);
> +extern int nfs_get_cb_ident(struct nfs_client *, int *);
>  extern void nfs_put_client(struct nfs_client *);
>  extern struct nfs_client *nfs_find_client(const struct sockaddr *, u32);
>  extern struct nfs_client *nfs_find_client_next(struct nfs_client *);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 78b0899..1cbc99d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3489,6 +3489,11 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
>  	int loop = 0;
>  	int status;
>  
> +	/* get a unique callback identifier */
> +	status = nfs_get_cb_ident(clp, &setclientid.sc_cb_ident);

This needs to be done when we set up the nfs_client, then the identifier
needs to be released when we destroy it.

As it is now, you are leaking callback identifiers on each call to
setclientid.

> +	if (status)
> +		return status;
> +
>  	p = (__be32*)sc_verifier.data;
>  	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
>  	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
> @@ -3522,6 +3527,8 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
>  			if (++clp->cl_id_uniquifier == 0)
>  				break;
>  	}
> +	if (status == NFS_OK)
> +		res->cb_ident = setclientid.sc_cb_ident;
>  	return status;
>  }
>  
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index f575a31..fe61422 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -79,6 +79,7 @@ int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
>  	if (status != 0)
>  		goto out;
>  	clp->cl_clientid = clid.clientid;
> +	clp->cl_cb_ident = clid.cb_ident;
>  	nfs4_schedule_state_renewal(clp);
>  out:
>  	return status;
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 452d964..1eaa054 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -71,6 +71,7 @@ struct nfs_client {
>  	 */
>  	char			cl_ipaddr[48];
>  	unsigned char		cl_id_uniquifier;
> +	u32			cl_cb_ident;	/* v4.0 callback identifier */
>  	const struct nfs4_minor_version_ops *cl_mvops;
>  #endif /* CONFIG_NFS_V4 */
>  
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 236e7e4..d325def 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -869,6 +869,7 @@ struct nfs4_setclientid {
>  struct nfs4_setclientid_res {
>  	u64				clientid;
>  	nfs4_verifier			confirm;
> +	u32				cb_ident;
>  };
>  
>  struct nfs4_statfs_arg {

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

