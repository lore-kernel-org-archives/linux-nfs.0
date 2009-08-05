From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/4] NFS: Add ability to send MOUNTPROC_UMNT to the
 kernel's mountd client
Date: Wed, 05 Aug 2009 08:21:01 -0400
Message-ID: <1249474861.5385.5.camel@heimdal.trondhjem.org>
References: <20090804135425.2287.3313.stgit@matisse.1015granger.net>
	 <20090804135854.2287.13193.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:47166 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933564AbZHEMVE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Aug 2009 08:21:04 -0400
In-Reply-To: <20090804135854.2287.13193.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-04 at 09:58 -0400, Chuck Lever wrote:
> After certain failure modes of an NFS mount, an NFS client should send
> a MOUNTPROC_UMNT request to remove the just-added mount entry from the
> server's mount table.  While no-one should rely on the accuracy of the
> server's mount table, sending a UMNT is simply being a good internet
> neighbor.
> 
> Since NFS mount processing is handled in the kernel now, we will need
> a function in the kernel's mountd client that can post a MOUNTRPC_UMNT
> request, in order to handle these failure modes.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/internal.h   |    1 +
>  fs/nfs/mount_clnt.c |   80 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 81 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 7dd90a6..8d2b71d 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -102,6 +102,7 @@ struct nfs_mount_request {
>  };
>  
>  extern int nfs_mount(struct nfs_mount_request *info);
> +extern void nfs_umount(const struct nfs_mount_request *info);
>  
>  /* client.c */
>  extern struct rpc_program nfs_program;
> diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> index 38ef9ea..e51bf9a 100644
> --- a/fs/nfs/mount_clnt.c
> +++ b/fs/nfs/mount_clnt.c
> @@ -209,6 +209,72 @@ out_mnt_err:
>  	goto out;
>  }
>  
> +/**
> + * nfs_umount - Notify a server that we have unmounted this export
> + * @info: pointer to umount request arguments
> + *
> + * MOUNTPROC_UMNT is advisory, so we set a short timeout, and always
> + * use UDP.
> + */
> +void nfs_umount(const struct nfs_mount_request *info)
> +{
> +	static const struct rpc_timeout nfs_umnt_timeout = {
> +		.to_initval = 1 * HZ,
> +		.to_maxval = 3 * HZ,
> +		.to_retries = 2,
> +	};
> +	struct rpc_create_args args = {
> +		.protocol	= IPPROTO_UDP,
> +		.address	= info->sap,
> +		.addrsize	= info->salen,
> +		.timeout	= &nfs_umnt_timeout,
> +		.servername	= info->hostname,
> +		.program	= &mnt_program,
> +		.version	= info->version,
> +		.authflavor	= RPC_AUTH_UNIX,
> +		.flags		= RPC_CLNT_CREATE_NOPING,
> +	};
> +	struct mountres	result;
> +	struct rpc_message msg	= {
> +		.rpc_argp	= info->dirpath,
> +		.rpc_resp	= &result,
> +	};
> +	struct rpc_clnt *clnt;
> +	int status;
> +
> +	if (info->noresvport)
> +		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
> +
> +	clnt = rpc_create(&args);
> +	if (unlikely(IS_ERR(clnt)))
> +		goto out_clnt_err;
> +
> +	dprintk("NFS: sending UMNT request for %s:%s\n",
> +		(info->hostname ? info->hostname : "server"), info->dirpath);
> +
> +	if (info->version == NFS_MNT3_VERSION)
> +		msg.rpc_proc = &clnt->cl_procinfo[MOUNTPROC3_UMNT];
> +	else
> +		msg.rpc_proc = &clnt->cl_procinfo[MOUNTPROC_UMNT];
> +
> +	status = rpc_call_sync(clnt, &msg, 0);
> +	rpc_shutdown_client(clnt);
> +
> +	if (unlikely(status < 0))
> +		goto out_call_err;
> +
> +	return;
> +
> +out_clnt_err:
> +	dprintk("NFS: failed to create UMNT RPC client, status=%ld\n",
> +			PTR_ERR(clnt));
> +	return;
> +
> +out_call_err:
> +	dprintk("NFS: UMNT request failed, status=%d\n", status);
> +	return;

Ehem.... I'm removing this.

> +}
> +
>  /*
>   * XDR encode/decode functions for MOUNT
>   */
> @@ -407,6 +473,13 @@ static struct rpc_procinfo mnt_procedures[] = {
>  		.p_statidx	= MOUNTPROC_MNT,
>  		.p_name		= "MOUNT",
>  	},
> +	[MOUNTPROC_UMNT] = {
> +		.p_proc		= MOUNTPROC_UMNT,
> +		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
> +		.p_arglen	= MNT_enc_dirpath_sz,
> +		.p_statidx	= MOUNTPROC_UMNT,
> +		.p_name		= "UMOUNT",
> +	},
>  };
>  
>  static struct rpc_procinfo mnt3_procedures[] = {
> @@ -419,6 +492,13 @@ static struct rpc_procinfo mnt3_procedures[] = {
>  		.p_statidx	= MOUNTPROC3_MNT,
>  		.p_name		= "MOUNT",
>  	},
> +	[MOUNTPROC3_UMNT] = {
> +		.p_proc		= MOUNTPROC3_UMNT,
> +		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
> +		.p_arglen	= MNT_enc_dirpath_sz,
> +		.p_statidx	= MOUNTPROC3_UMNT,
> +		.p_name		= "UMOUNT",
> +	},
>  };
>  
> 
> 


