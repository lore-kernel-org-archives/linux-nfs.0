From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 19/85] nfs41: share client sessions across mounts
Date: Mon, 17 Nov 2008 15:45:18 +0200
Message-ID: <4921756E.3080408@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348470-7818-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:17151 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751732AbYKQNpV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:45:21 -0500
In-Reply-To: <1226348470-7818-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:21 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Do not create a new session for each new mount (FSID).
> 
> Call nfs4_get_session to bump the reference count for each cloned nfs4 server
> which now share the struct nfs_client session.
> 
> nfs41: check minorversion on nfs41_get_session
> 
> Signed-off-by: Andy Adamson<andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/client.c   |    4 ++++
>  fs/nfs/nfs4_fs.h  |    1 +
>  fs/nfs/nfs4proc.c |    5 +++++
>  3 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 80091dc..62bdf31 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1336,6 +1336,10 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
>  	if (!IS_ERR(source->client_acl))
>  		nfs_init_server_aclclient(server);
>  
> +#ifdef CONFIG_NFS_V4_1

review 11-14: check for clp->cl_session != NULL

> +	nfs4_get_session(server->nfs_client);
> +#endif /* CONFIG_NFS_V4_1 */
> +
>  	/* probe the filesystem info for this server filesystem */
>  	error = nfs_probe_fsinfo(server, fh, &fattr_fsinfo);
>  	if (error < 0)
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 4b13945..a28427f 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -190,6 +190,7 @@ extern struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops;
>  extern struct nfs4_state_recovery_ops nfs4_network_partition_recovery_ops;
>  #if defined(CONFIG_NFS_V4_1)
>  extern void nfs4_put_session(struct nfs4_session **session);
> +extern void nfs4_get_session(struct nfs_client *clp);
>  extern struct nfs4_session *nfs4_alloc_session(void);
>  #endif /* CONFIG_NFS_V4_1 */
>  
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8e373e9..d0b6ca1 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3712,6 +3712,11 @@ void nfs4_put_session(struct nfs4_session **session)
>  	dprintk("<-- nfs4_put_session()\n");
>  }
>  
> +void nfs4_get_session(struct nfs_client *clp)

review 11-14: just pass a session*

> +{
> +	if (clp->cl_minorversion == 1)
> +		atomic_inc(&clp->cl_session->ref_count);
> +}
>  #endif /* CONFIG_NFS_V4_1 */
>  
>  struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
