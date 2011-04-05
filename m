Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:60531 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab1DECwb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2011 22:52:31 -0400
Date: Mon, 4 Apr 2011 21:52:28 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Rob Landley <rlandley@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        containers@lists.linux-foundation.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Tim Spriggs <tims@uahirise.org>, Kir Kolyshkin <kir@parallels.com>,
        Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 1/3] Add network context to struct nfs_client and make
 NFSv3 use it.
Message-ID: <20110405025228.GA6764@hallyn.com>
References: <4D94318A.5050202@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D94318A.5050202@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Quoting Rob Landley (rlandley@parallels.com):
> From: Rob Landley <rlandley@parallels.com>
> 
> This patch:
> 
>   Adds struct net *cl_net to struct nfs_client.
>   Intializes it from mount process context.
>   Copies it down through nfs_client_initdata and similar.
>   Replaces existing init_net uses with cl_net.
>   Adds net_eq() checks to nfs_match_client() and nfs_compare_super_address().
> 
> Remount copies the existing network context rather than any associated with
> the new mount process.  NFSv4 is still using init_net.  Reference counting
> for struct net follows the struct nfs_client object lifetimes (pinned by
> task context outside of that).
> 
> Signed-off-by: Rob Landley <rlandley@parallels.com>

Sorry for the delay.  Took me two long readings to feel like I've got
it.

Acked-by: Serge Hallyn <serge.hallyn@ubuntu.com>

Do you have any testcases coded up for this?

thanks,
-serge

> ---
> 
>  fs/nfs/client.c           |   13 ++++++++++++-
>  fs/nfs/internal.h         |    2 ++
>  fs/nfs/mount_clnt.c       |    4 ++--
>  fs/nfs/super.c            |   15 +++++++++++++++
>  include/linux/nfs_fs_sb.h |    1 +
>  5 files changed, 32 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 139be96..99bfaa6 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -130,6 +130,7 @@ struct rpc_program		nfsacl_program = {
>  
>  struct nfs_client_initdata {
>  	const char *hostname;
> +	struct net *net;
>  	const struct sockaddr *addr;
>  	size_t addrlen;
>  	const struct nfs_rpc_ops *rpc_ops;
> @@ -157,6 +158,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  	atomic_set(&clp->cl_count, 1);
>  	clp->cl_cons_state = NFS_CS_INITING;
>  
> +	clp->cl_net = get_net(cl_init->net);
>  	memcpy(&clp->cl_addr, cl_init->addr, cl_init->addrlen);
>  	clp->cl_addrlen = cl_init->addrlen;
>  
> @@ -196,6 +198,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  	return clp;
>  
>  error_cleanup:
> +	put_net(clp->cl_net);
>  	kfree(clp);
>  error_0:
>  	return ERR_PTR(err);
> @@ -290,6 +293,9 @@ static void nfs_free_client(struct nfs_client *clp)
>  	if (clp->cl_machine_cred != NULL)
>  		put_rpccred(clp->cl_machine_cred);
>  
> +	if (clp->cl_net)
> +		put_net(clp->cl_net);
> +
>  	kfree(clp->cl_hostname);
>  	kfree(clp);
>  
> @@ -473,6 +479,8 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
>  		if (clp->cl_minorversion != data->minorversion)
>  			continue;
>  		/* Match the full socket address */
> +		if (!net_eq(clp->cl_net, data->net))
> +			continue;
>  		if (!nfs_sockaddr_cmp(sap, clap))
>  			continue;
>  
> @@ -636,7 +644,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
>  {
>  	struct rpc_clnt		*clnt = NULL;
>  	struct rpc_create_args args = {
> -		.net		= &init_net,
> +		.net		= clp->cl_net,
>  		.protocol	= clp->cl_proto,
>  		.address	= (struct sockaddr *)&clp->cl_addr,
>  		.addrsize	= clp->cl_addrlen,
> @@ -821,6 +829,7 @@ static int nfs_init_server(struct nfs_server *server,
>  {
>  	struct nfs_client_initdata cl_init = {
>  		.hostname = data->nfs_server.hostname,
> +		.net = data->net,
>  		.addr = (const struct sockaddr *)&data->nfs_server.address,
>  		.addrlen = data->nfs_server.addrlen,
>  		.rpc_ops = &nfs_v2_clientops,
> @@ -1386,6 +1395,7 @@ static int nfs4_set_client(struct nfs_server *server,
>  {
>  	struct nfs_client_initdata cl_init = {
>  		.hostname = hostname,
> +		.net = &init_net,
>  		.addr = addr,
>  		.addrlen = addrlen,
>  		.rpc_ops = &nfs_v4_clientops,
> @@ -1438,6 +1448,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
>  {
>  	struct nfs_client_initdata cl_init = {
>  		.addr = ds_addr,
> +		.net = &init_net,
>  		.addrlen = ds_addrlen,
>  		.rpc_ops = &nfs_v4_clientops,
>  		.proto = ds_proto,
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 72e0bdd..006ab1a 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -86,6 +86,7 @@ struct nfs_parsed_mount_data {
>  	unsigned int		version;
>  	unsigned int		minorversion;
>  	char			*fscache_uniq;
> +	struct net		*net;
>  
>  	struct {
>  		struct sockaddr_storage	address;
> @@ -111,6 +112,7 @@ struct nfs_parsed_mount_data {
>  /* mount_clnt.c */
>  struct nfs_mount_request {
>  	struct sockaddr		*sap;
> +	struct net		*net;
>  	size_t			salen;
>  	char			*hostname;
>  	char			*dirpath;
> diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> index d4c2d6b..4fbe3a8 100644
> --- a/fs/nfs/mount_clnt.c
> +++ b/fs/nfs/mount_clnt.c
> @@ -153,7 +153,7 @@ int nfs_mount(struct nfs_mount_request *info)
>  		.rpc_resp	= &result,
>  	};
>  	struct rpc_create_args args = {
> -		.net		= &init_net,
> +		.net		= info->net,
>  		.protocol	= info->protocol,
>  		.address	= info->sap,
>  		.addrsize	= info->salen,
> @@ -225,7 +225,7 @@ void nfs_umount(const struct nfs_mount_request *info)
>  		.to_retries = 2,
>  	};
>  	struct rpc_create_args args = {
> -		.net		= &init_net,
> +		.net		= info->net,
>  		.protocol	= IPPROTO_UDP,
>  		.address	= info->sap,
>  		.addrsize	= info->salen,
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 2b8e9a5..b0d869f 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -53,6 +53,7 @@
>  #include <linux/nfs_xdr.h>
>  #include <linux/magic.h>
>  #include <linux/parser.h>
> +#include <linux/user_namespace.h>
>  
>  #include <asm/system.h>
>  #include <asm/uaccess.h>
> @@ -1572,6 +1573,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
>  	struct nfs_mount_request request = {
>  		.sap		= (struct sockaddr *)
>  						&args->mount_server.address,
> +		.net		= args->net,
>  		.dirpath	= args->nfs_server.export_path,
>  		.protocol	= args->mount_server.protocol,
>  		.fh		= root_fh,
> @@ -1726,6 +1728,11 @@ static int nfs_validate_mount_data(void *options,
>  	if (data == NULL)
>  		goto out_no_data;
>  
> +	/* Grab network context from mount process. We'll increment the
> +	   reference count when we copy it to nfs_client->cl_net. */
> +
> +	args->net = current->nsproxy->net_ns;
> +
>  	switch (data->version) {
>  	case 1:
>  		data->namlen = 0;
> @@ -1971,6 +1978,9 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
>  	memcpy(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
>  		data->nfs_server.addrlen);
>  
> +	/* Use original mount's network context, not remount process's */
> +	data->net = nfss->nfs_client->cl_net;
> +
>  	/* overwrite those values with any that were specified */
>  	error = nfs_parse_mount_options((char *)options, data);
>  	if (error < 0)
> @@ -2119,6 +2129,9 @@ static int nfs_compare_super_address(struct nfs_server *server1,
>  	if (sap1->sa_family != sap2->sa_family)
>  		return 0;
>  
> +	if (!net_eq(server1->nfs_client->cl_net, server2->nfs_client->cl_net))
> +		return 0;
> +
>  	switch (sap1->sa_family) {
>  	case AF_INET: {
>  		struct sockaddr_in *sin1 = (struct sockaddr_in *)sap1;
> @@ -2478,6 +2491,8 @@ static int nfs4_validate_mount_data(void *options,
>  	if (data == NULL)
>  		goto out_no_data;
>  
> +	args->net = &init_net;
> +
>  	switch (data->version) {
>  	case 1:
>  		if (data->host_addrlen > sizeof(args->nfs_server.address))
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 216cea5..45286dc 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -33,6 +33,7 @@ struct nfs_client {
>  #define NFS_CS_STOP_RENEW	4		/* no more state to renew */
>  #define NFS_CS_CHECK_LEASE_TIME	5		/* need to check lease time */
>  	struct sockaddr_storage	cl_addr;	/* server identifier */
> +	struct net *		cl_net;		/* network context */
>  	size_t			cl_addrlen;
>  	char *			cl_hostname;	/* hostname of server */
>  	struct list_head	cl_share_link;	/* link in global client list */
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
