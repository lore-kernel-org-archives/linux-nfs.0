Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:58201 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab1BPC67 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 21:58:59 -0500
Message-ID: <4D5B3D70.5010700@panasas.com>
Date: Tue, 15 Feb 2011 21:58:56 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: andros@netapp.com
CC: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/16] NFS move nfs_client initialization into nfs_get_client
References: <1297711116-3139-1-git-send-email-andros@netapp.com> <1297711116-3139-4-git-send-email-andros@netapp.com>
In-Reply-To: <1297711116-3139-4-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-14 14:18, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Now nfs_get_client returns an nfs_client ready to be used no matter if it was
> found or created.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/client.c |   67 ++++++++++++++++++++++++++++++++++++++----------------
>  1 files changed, 47 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index bd3ca32..75b236f 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -81,6 +81,15 @@ retry:
>  }
>  #endif /* CONFIG_NFS_V4 */
>  
> +static int nfs4_init_client(struct nfs_client *clp,
> +		const struct rpc_timeout *timeparms,
> +		const char *ip_addr,
> +		rpc_authflavor_t authflavour,
> +		int noresvport);
> +static int nfs_init_client(struct nfs_client *clp,
> +			   const struct rpc_timeout *timeparms,
> +			   int noresvport);
> +
>  /*
>   * RPC cruft for NFS
>   */
> @@ -481,7 +490,12 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
>   * Look up a client by IP address and protocol version
>   * - creates a new record if one doesn't yet exist
>   */
> -static struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
> +static struct nfs_client *
> +nfs_get_client(const struct nfs_client_initdata *cl_init,
> +	       const struct rpc_timeout *timeparms,
> +	       const char *ip_addr,
> +	       rpc_authflavor_t authflavour,
> +	       int noresvport)
>  {
>  	struct nfs_client *clp, *new = NULL;
>  	int error;
> @@ -512,6 +526,17 @@ install_client:
>  	clp = new;
>  	list_add(&clp->cl_share_link, &nfs_client_list);
>  	spin_unlock(&nfs_client_lock);
> +
> +	if (cl_init->rpc_ops->version == 4)
> +		error = nfs4_init_client(clp, timeparms, ip_addr, authflavour,
> +					 noresvport);
> +	else
> +		error = nfs_init_client(clp, timeparms, noresvport);

To make that cleaner your could have both get the same parameters
and put nfs_init_client in struct nfs_rpc_ops, then call it via cl_init->rpc_ops

Benny

> +
> +	if (error < 0) {
> +		nfs_put_client(clp);
> +		return ERR_PTR(error);
> +	}
>  	dprintk("--> nfs_get_client() = %p [new]\n", clp);
>  	return clp;
>  
> @@ -769,7 +794,7 @@ static int nfs_init_server_rpcclient(struct nfs_server *server,
>   */
>  static int nfs_init_client(struct nfs_client *clp,
>  			   const struct rpc_timeout *timeparms,
> -			   const struct nfs_parsed_mount_data *data)
> +			   int noresvport)
>  {
>  	int error;
>  
> @@ -784,7 +809,7 @@ static int nfs_init_client(struct nfs_client *clp,
>  	 * - RFC 2623, sec 2.3.2
>  	 */
>  	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX,
> -				      0, data->flags & NFS_MOUNT_NORESVPORT);
> +				      0, noresvport);
>  	if (error < 0)
>  		goto error;
>  	nfs_mark_client_ready(clp, NFS_CS_READY);
> @@ -820,19 +845,17 @@ static int nfs_init_server(struct nfs_server *server,
>  		cl_init.rpc_ops = &nfs_v3_clientops;
>  #endif
>  
> +	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
> +			data->timeo, data->retrans);
> +
>  	/* Allocate or find a client reference we can use */
> -	clp = nfs_get_client(&cl_init);
> +	clp = nfs_get_client(&cl_init, &timeparms, NULL, RPC_AUTH_UNIX,
> +			     data->flags & NFS_MOUNT_NORESVPORT);
>  	if (IS_ERR(clp)) {
>  		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
>  		return PTR_ERR(clp);
>  	}
>  
> -	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
> -			data->timeo, data->retrans);
> -	error = nfs_init_client(clp, &timeparms, data);
> -	if (error < 0)
> -		goto error;
> -
>  	server->nfs_client = clp;
>  
>  	/* Initialise the client representation from the mount data */
> @@ -1311,7 +1334,7 @@ static int nfs4_init_client(struct nfs_client *clp,
>  		const struct rpc_timeout *timeparms,
>  		const char *ip_addr,
>  		rpc_authflavor_t authflavour,
> -		int flags)
> +		int noresvport)
>  {
>  	int error;
>  
> @@ -1325,7 +1348,7 @@ static int nfs4_init_client(struct nfs_client *clp,
>  	clp->rpc_ops = &nfs_v4_clientops;
>  
>  	error = nfs_create_rpc_client(clp, timeparms, authflavour,
> -				      1, flags & NFS_MOUNT_NORESVPORT);
> +				      1, noresvport);
>  	if (error < 0)
>  		goto error;
>  	strlcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
> @@ -1378,22 +1401,16 @@ static int nfs4_set_client(struct nfs_server *server,
>  	dprintk("--> nfs4_set_client()\n");
>  
>  	/* Allocate or find a client reference we can use */
> -	clp = nfs_get_client(&cl_init);
> +	clp = nfs_get_client(&cl_init, timeparms, ip_addr, authflavour,
> +			     server->flags & NFS_MOUNT_NORESVPORT);
>  	if (IS_ERR(clp)) {
>  		error = PTR_ERR(clp);
>  		goto error;
>  	}
> -	error = nfs4_init_client(clp, timeparms, ip_addr, authflavour,
> -					server->flags);
> -	if (error < 0)
> -		goto error_put;
>  
>  	server->nfs_client = clp;
>  	dprintk("<-- nfs4_set_client() = 0 [new %p]\n", clp);
>  	return 0;
> -
> -error_put:
> -	nfs_put_client(clp);
>  error:
>  	dprintk("<-- nfs4_set_client() = xerror %d\n", error);
>  	return error;
> @@ -1611,6 +1628,16 @@ error:
>  	return ERR_PTR(error);
>  }
>  
> +#else /* CONFIG_NFS_V4 */
> +static int nfs4_init_client(struct nfs_client *clp,
> +			    const struct rpc_timeout *timeparms,
> +			    const char *ip_addr,
> +			    rpc_authflavor_t authflavour,
> +			    int noresvport)
> +{
> +	return -EPROTONOSUPPORT;
> +}
> +
>  #endif /* CONFIG_NFS_V4 */
>  
>  /*
