From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/5] NFS: Add ability to send MOUNTPROC_UMNT to the
 kernel's mountd client
Date: Thu, 16 Jul 2009 14:42:20 -0400
Message-ID: <1247769740.12292.76.camel@heimdal.trondhjem.org>
References: <20090713191417.1951.75470.stgit@matisse.1015granger.net>
	 <20090713191731.1951.28069.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:35167 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932833AbZGPSm0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 14:42:26 -0400
In-Reply-To: <20090713191731.1951.28069.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-07-13 at 15:17 -0400, Chuck Lever wrote:
> After certain failure modes of an NFS mount, an NFS client should send
> a MOUNTPROC_UMNT request to remove the just-added mount entry from the
> server's mount table.  While no-one should rely on the accuracy of the
> server's mount table, this is just being a good neighbor.
> 
> Since NFS mount processing is handled in the kernel now, we will need
> a function in the kernel's mountd client that can post a MOUNTRPC_UMNT
> request, in order to handle these failure modes.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/internal.h   |    1 +
>  fs/nfs/mount_clnt.c |   60 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 61 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index fa9a0d0..d3823d7 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -102,6 +102,7 @@ struct nfs_mount_request {
>  };
>  
>  extern int nfs_mount(struct nfs_mount_request *info);
> +extern int nfs_umount(const struct nfs_mount_request *info);
>  
>  /* client.c */
>  extern struct rpc_program nfs_program;
> diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> index b5ed325..67148e4 100644
> --- a/fs/nfs/mount_clnt.c
> +++ b/fs/nfs/mount_clnt.c
> @@ -218,6 +218,52 @@ out_mnt_err:
>  	goto out;
>  }
>  
> +/**
> + * nfs_umount - Notify a server that we have unmounted this export
> + * @info: pointer to umount request arguments
> + *
> + * MOUNTPROC_UMNT is advisory, so we set a short timeout.
> + */
> +int nfs_umount(const struct nfs_mount_request *info)
> +{
> +	static const struct rpc_timeout nfs_umnt_timeout = {
> +		.to_initval = 1 * HZ,
> +		.to_maxval = 3 * HZ,
> +		.to_retries = 2,
> +	};

These values will never work with a TCP mount. Shouldn't we just enforce
this as UDP only?

> +	struct mountres	result;
> +	struct rpc_message msg	= {
> +		.rpc_argp	= info->dirpath,
> +		.rpc_resp	= &result,
> +	};
> +	struct rpc_clnt *clnt;
> +	int status;
> +
> +	clnt = nfs_mount_rpc_create(info, &nfs_umnt_timeout);
> +	if (IS_ERR(clnt))
> +		return PTR_ERR(clnt);

Why are we returning a status value here? I see no reason why we should
care if a umount call works or failed. It is certainly not going to
affect anything the client does.

> +
> +	dprintk("NFS: sending UMNT request for %s:%s\n",
> +		(info->hostname ? info->hostname : "server"),
> +			info->dirpath);
> +
> +	if (info->version == NFS_MNT3_VERSION)
> +		msg.rpc_proc = &clnt->cl_procinfo[MOUNTPROC3_UMNT];
> +	else
> +		msg.rpc_proc = &clnt->cl_procinfo[MOUNTPROC_UMNT];
> +
> +	status = rpc_call_sync(clnt, &msg, 0);
> +	rpc_shutdown_client(clnt);
> +
> +	if (status < 0) {
> +		dprintk("NFS: UMNT request failed, status=%d\n", status);
> +		return status;
> +	}
> +
> +	dprintk("NFS: UMNT request succeeded\n");
> +	return 0;
> +}

ditto concerning return values. Please just make this a void function.



