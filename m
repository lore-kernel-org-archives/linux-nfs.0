Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:33117 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752339AbdLEPg0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Dec 2017 10:36:26 -0500
Subject: Re: [PATCH v1 2/4] nfs: Referrals should use the same proto setting
 as their parent
To: Chuck Lever <chuck.lever@oracle.com>
CC: <linux-rdma@vger.kernel.org>, <linux-nfs@vger.kernel.org>
References: <20171204190904.18629.70341.stgit@manet.1015granger.net>
 <20171204191338.18629.29071.stgit@manet.1015granger.net>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <396baae6-8372-e7bc-97e4-d5c27b341f8d@Netapp.com>
Date: Tue, 5 Dec 2017 10:36:20 -0500
MIME-Version: 1.0
In-Reply-To: <20171204191338.18629.29071.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 12/04/2017 02:13 PM, Chuck Lever wrote:
> Helen Chao <helen.chao@oracle.com> noticed that when a user
> traverses a referral on an NFS/RDMA mount, the resulting submount
> always uses TCP.
> 
> This behavior does not match the vers= setting when traversing
> a referral (vers=4.1 is preserved). It also does not match the
> behavior of crossing from the pseudofs into a real filesystem
> (proto=rdma is preserved in that case).
> 
> The Linux NFS client does not currently support the
> fs_locations_info attribute. The situation is similar for all
> NFSv4 servers I know of. Therefore until the community has broad
> support for fs_locations_info, when following a referral:
> 
>  - First try to connect with RPC-over-RDMA. This will fail quickly
>    if the client has no RDMA-capable interfaces.
> 
>  - If connecting with RPC-over-RDMA fails, or the RPC-over-RDMA
>    transport is not available, use TCP.

Won't this have the opposite problem if the client and server have RDMA interfaces, but are currently mounted over TCP instead?

Anna

> 
> Reported-by: Helen Chao <helen.chao@oracle.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfs/nfs4client.c    |   23 ++++++++++++++++++++---
>  fs/nfs/nfs4namespace.c |    2 --
>  2 files changed, 20 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 12bbab0..a3d5592 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -1114,19 +1114,36 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
>  	/* Initialise the client representation from the parent server */
>  	nfs_server_copy_userdata(server, parent_server);
>  
> -	/* Get a client representation.
> -	 * Note: NFSv4 always uses TCP, */
> +	/* Get a client representation */
> +#ifdef CONFIG_SUNRPC_XPRT_RDMA
> +	rpc_set_port(data->addr, NFS_RDMA_PORT);
>  	error = nfs4_set_client(server, data->hostname,
>  				data->addr,
>  				data->addrlen,
>  				parent_client->cl_ipaddr,
> -				rpc_protocol(parent_server->client),
> +				XPRT_TRANSPORT_RDMA,
> +				parent_server->client->cl_timeout,
> +				parent_client->cl_mvops->minor_version,
> +				parent_client->cl_net);
> +	if (!error)
> +		goto init_server;
> +#endif	/* CONFIG_SUNRPC_XPRT_RDMA */
> +
> +	rpc_set_port(data->addr, NFS_PORT);
> +	error = nfs4_set_client(server, data->hostname,
> +				data->addr,
> +				data->addrlen,
> +				parent_client->cl_ipaddr,
> +				XPRT_TRANSPORT_TCP,
>  				parent_server->client->cl_timeout,
>  				parent_client->cl_mvops->minor_version,
>  				parent_client->cl_net);
>  	if (error < 0)
>  		goto error;
>  
> +#ifdef CONFIG_SUNRPC_XPRT_RDMA
> +init_server:
> +#endif
>  	error = nfs_init_server_rpcclient(server, parent_server->client->cl_timeout, data->authflavor);
>  	if (error < 0)
>  		goto error;
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index 8c3f327..24f06dc 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -270,8 +270,6 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
>  		if (mountdata->addrlen == 0)
>  			continue;
>  
> -		rpc_set_port(mountdata->addr, NFS_PORT);
> -
>  		memcpy(page2, buf->data, buf->len);
>  		page2[buf->len] = '\0';
>  		mountdata->hostname = page2;
> 
