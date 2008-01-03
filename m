From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/4] NFS: Invoke nlmclnt_init during NFS mount
	processing
Date: Thu, 03 Jan 2008 16:56:12 -0500
Message-ID: <1199397372.1913.17.camel@heimdal.trondhjem.org>
References: <20071220200412.3358.36945.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:40155 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488AbYACV4Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2008 16:56:16 -0500
In-Reply-To: <20071220200412.3358.36945.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-12-20 at 15:04 -0500, Chuck Lever wrote:
> Cache an appropriate nlm_host structure in the NFS client's mount point
> metadata for later use.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

ACK this, but please resend after fixing up the first 2 patches.

> ---
> 
>  fs/nfs/client.c           |   25 ++++++++++++++++++-------
>  include/linux/nfs_fs_sb.h |    2 ++
>  2 files changed, 20 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 33a5678..1d7d606 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -439,7 +439,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
>  static void nfs_destroy_server(struct nfs_server *server)
>  {
>  	if (!(server->flags & NFS_MOUNT_NONLM))
> -		lockd_down();	/* release rpc.lockd */
> +		nlmclnt_done(server->nlm_host);
>  }
>  
>  /*
> @@ -447,18 +447,29 @@ static void nfs_destroy_server(struct nfs_server *server)
>   */
>  static int nfs_start_lockd(struct nfs_server *server)
>  {
> +	struct nfs_client *clp = server->nfs_client;
> +	u32 nfs_version = clp->rpc_ops->version;
> +	unsigned short protocol;
> +	struct nlm_host *host;
>  	int error = 0;
>  
> -	if (server->nfs_client->rpc_ops->version > 3)
> +	if (nfs_version > 3)
>  		goto out;
>  	if (server->flags & NFS_MOUNT_NONLM)
>  		goto out;
> -	error = lockd_up((server->flags & NFS_MOUNT_TCP) ?
> -			IPPROTO_TCP : IPPROTO_UDP);
> -	if (error < 0)
> +
> +	protocol = server->flags & NFS_MOUNT_TCP ?  IPPROTO_TCP : IPPROTO_UDP;
> +	host = nlmclnt_init((struct sockaddr *)&clp->cl_addr, clp->cl_addrlen,
> +			    clp->cl_hostname, nfs_version, protocol);
> +	if (IS_ERR(host)) {
> +		error = PTR_ERR(host);
>  		server->flags |= NFS_MOUNT_NONLM;
> -	else
> -		server->destroy = nfs_destroy_server;
> +		goto out;
> +	}
> +
> +	server->nlm_host = host;
> +	server->destroy = nfs_destroy_server;
> +
>  out:
>  	return error;
>  }
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 383abe0..d75cf0a 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -5,6 +5,7 @@
>  #include <linux/backing-dev.h>
>  
>  struct nfs_iostats;
> +struct nlm_host;
>  
>  /*
>   * The nfs_client identifies our client state to the server.
> @@ -80,6 +81,7 @@ struct nfs_server {
>  	struct list_head	master_link;	/* link in master servers list */
>  	struct rpc_clnt *	client;		/* RPC client handle */
>  	struct rpc_clnt *	client_acl;	/* ACL RPC client handle */
> +	struct nlm_host		*nlm_host;	/* NLM client handle */
>  	struct nfs_iostats *	io_stats;	/* I/O statistics */
>  	struct backing_dev_info	backing_dev_info;
>  	atomic_long_t		writeback;	/* number of writeback pages */
> 

