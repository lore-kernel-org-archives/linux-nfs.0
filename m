From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 17/85] nfs41: fallback to lower minorversion if	nfs4_create_server
 fails
Date: Mon, 17 Nov 2008 15:43:22 +0200
Message-ID: <492174FA.6080608@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348448-7751-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:12012 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751680AbYKQNnZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:43:25 -0500
In-Reply-To: <1226348448-7751-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:20 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> retry nfs4_create_server with lower minorversion on minorvers_mismatch error
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 11-14: move logic to reclaimer();

> ---
>  fs/nfs/client.c |   12 +++++++++++-
>  1 files changed, 11 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 11c845d..0a8a082 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1118,15 +1118,17 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
>  {
>  	struct nfs_fattr fattr;
>  	struct nfs_server *server;
> +	int minorvers = data->minorversion;
>  	int error;
>  
>  	dprintk("--> nfs4_create_server()\n");
>  
> +retry:
>  	server = nfs_alloc_server();
>  	if (!server)
>  		return ERR_PTR(-ENOMEM);
>  
> -	server->minorversion = data->minorversion;
> +	server->minorversion = minorvers;
>  
>  	/* set up the general RPC client */
>  	error = nfs4_init_server(server, data);
> @@ -1168,7 +1170,15 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
>  	return server;
>  
>  error:
> +	if (server->nfs_client && server->nfs_client->cl_recovery_status)
> +		error = server->nfs_client->cl_recovery_status;
>  	nfs_free_server(server);
> +	if (minorvers > 0 && error == -NFS4ERR_MINOR_VERS_MISMATCH) {
> +		minorvers--;
> +		dprintk("%s: error %d retrying with minorvers=%d\n",
> +			__func__, error, minorvers);
> +		goto retry;
> +	}
>  	dprintk("<-- nfs4_create_server() = error %d\n", error);
>  	return ERR_PTR(error);
>  }
