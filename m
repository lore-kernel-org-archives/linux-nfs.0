Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:54885 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751187AbaJTRd0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2014 13:33:26 -0400
Message-ID: <54454762.8020506@Netapp.com>
Date: Mon, 20 Oct 2014 13:33:22 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 13/16] NFS: Add sidecar RPC client support
References: <20141016192919.13414.3151.stgit@manet.1015granger.net> <20141016194000.13414.83844.stgit@manet.1015granger.net>
In-Reply-To: <20141016194000.13414.83844.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/16/14 15:40, Chuck Lever wrote:
> So far, TCP is the only transport that supports bi-directional RPC.
>
> When mounting with NFSv4.1 using a transport that does not support
> bi-directional RPC, establish a TCP sidecar connection to handle
> backchannel traffic for a session. The sidecar transport does not
> use its forward channel except for sending BIND_CONN_TO_SESSION
> operations.
>
> This commit adds logic to create and destroy the sidecar transport.
> Subsequent commits add logic to use the transport.

I thought NFS v4.0 also uses a separate connection for the backchannel?  Can any of that code be reused here, rather than creating new sidecar structures?

Anna

>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfs/client.c           |    1 +
>  fs/nfs/nfs4client.c       |   54 +++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/nfs_fs_sb.h |    2 ++
>  3 files changed, 57 insertions(+)
>
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 6a4f366..19f49bf 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -78,6 +78,7 @@ const struct rpc_program nfs_program = {
>  	.stats			= &nfs_rpcstat,
>  	.pipe_dir_name		= NFS_PIPE_DIRNAME,
>  };
> +EXPORT_SYMBOL_GPL(nfs_program);
>  
>  struct rpc_stat nfs_rpcstat = {
>  	.program		= &nfs_program
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 5f4b818..b1cc35e 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -213,6 +213,8 @@ static void nfs4_destroy_callback(struct nfs_client *clp)
>  {
>  	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
>  		nfs_callback_down(clp->cl_mvops->minor_version, clp->cl_net);
> +	if (clp->cl_bc_rpcclient)
> +		rpc_shutdown_client(clp->cl_bc_rpcclient);
>  }
>  
>  static void nfs4_shutdown_client(struct nfs_client *clp)
> @@ -291,6 +293,53 @@ int nfs40_init_client(struct nfs_client *clp)
>  
>  #if defined(CONFIG_NFS_V4_1)
>  
> +/*
> + * Create a separate rpc_clnt using TCP that can provide a
> + * backchannel service.
> + */
> +static int nfs41_create_sidecar_rpc_client(struct nfs_client *clp)
> +{
> +	struct sockaddr_storage address;
> +	struct sockaddr *sap = (struct sockaddr *)&address;
> +	struct rpc_create_args args = {
> +		.net		= clp->cl_net,
> +		.protocol	= XPRT_TRANSPORT_TCP,
> +		.address	= sap,
> +		.addrsize	= clp->cl_addrlen,
> +		.servername	= clp->cl_hostname,
> +		.program	= &nfs_program,
> +		.version	= clp->rpc_ops->version,
> +		.flags		= (RPC_CLNT_CREATE_DISCRTRY |
> +				  RPC_CLNT_CREATE_NOPING),
> +	};
> +	struct rpc_clnt *clnt;
> +	struct rpc_cred *cred;
> +
> +	if (rpc_xprt_is_bidirectional(clp->cl_rpcclient))
> +		return 0;
> +
> +	if (test_bit(NFS_CS_NORESVPORT, &clp->cl_flags))
> +		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
> +	memcpy(sap, &clp->cl_addr, clp->cl_addrlen);
> +	rpc_set_port(sap, NFS_PORT);
> +	cred = nfs4_get_clid_cred(clp);
> +	if (cred) {
> +		args.authflavor = cred->cr_auth->au_flavor;
> +		put_rpccred(cred);
> +	} else
> +		args.authflavor = RPC_AUTH_UNIX;
> +
> +	clnt = rpc_create(&args);
> +	if (IS_ERR(clnt)) {
> +		dprintk("%s: cannot create side-car RPC client. Error = %ld\n",
> +			__func__, PTR_ERR(clnt));
> +		return PTR_ERR(clnt);
> +	}
> +
> +	clp->cl_bc_rpcclient = clnt;
> +	return 0;
> +}
> +
>  /**
>   * nfs41_init_client - nfs_client initialization tasks for NFSv4.1+
>   * @clp - nfs_client to initialize
> @@ -300,6 +349,11 @@ int nfs40_init_client(struct nfs_client *clp)
>  int nfs41_init_client(struct nfs_client *clp)
>  {
>  	struct nfs4_session *session = NULL;
> +	int ret;
> +
> +	ret = nfs41_create_sidecar_rpc_client(clp);
> +	if (ret)
> +		return ret;
>  
>  	/*
>  	 * Create the session and mark it expired.
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 922be2e..159d703 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -87,6 +87,8 @@ struct nfs_client {
>  
>  	/* The sequence id to use for the next CREATE_SESSION */
>  	u32			cl_seqid;
> +	/* The optional sidecar backchannel transport */
> +	struct rpc_clnt		*cl_bc_rpcclient;
>  	/* The flags used for obtaining the clientid during EXCHANGE_ID */
>  	u32			cl_exchange_flags;
>  	struct nfs4_session	*cl_session;	/* shared session */
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

