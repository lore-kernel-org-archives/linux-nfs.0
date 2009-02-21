From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting a server.
Date: Sat, 21 Feb 2009 17:09:43 -0500
Message-ID: <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com>
References: <4977C580.4040805@candelatech.com> <633CA802-DD5A-4082-B771-C524D367241F@oracle.com> <497805A7.4070205@candelatech.com> <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com> <4978AD75.9090900@candelatech.com> <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com> <499FB08B.1070200@candelatech.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:42365 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753823AbZBUWJ7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Feb 2009 17:09:59 -0500
In-Reply-To: <499FB08B.1070200@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben-

On Feb 21, 2009, at Feb 21, 2009, 2:43 AM, Ben Greear wrote:
> I re-worked the kernel nfs local-address-binding logic against  
> 2.6.29-rc5.  In quick testing,
> this works with IPv4 and NFSv3 at least.  I changed the attribute to  
> be called 'bindaddr'
> as previously suggested.
>
> I didn't actually make any further changes to the mount.nfs tool and  
> it took the bindaddr=a.b.c.d
> just fine, so maybe there are no changes at all needed in user-space.

You probably want the code in support/nfs/getport.c to send requests  
from your bindaddr, if the mount command has to contact the server to  
renegotiate mount options.

> Comments & suggestions welcome.
>
> Thanks,
> Ben
>
> Signed-Off-By:  Ben Greear<greearb@candelatech.com>
>
> -- 
> Ben Greear <greearb@candelatech.com> Candela Technologies Inc  http://www.candelatech.com
>
>
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 3e634f2..1c7011e 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -213,7 +213,7 @@ static int nfs_callback_authenticate(struct  
> svc_rqst *rqstp)
> 	int ret = SVC_OK;
>
> 	/* Don't talk to strangers */
> -	clp = nfs_find_client(svc_addr(rqstp), 4);
> +	clp = nfs_find_client(svc_daddr(rqstp), svc_addr(rqstp), 4);

It's not clear to me why the callback server needs to be aware of the  
mount point's bind address.  Can you explain this a little more?  I  
would think the bind address would be pertinent for sending callback  
service replies, but I don't see code here to do that.

Would lockd also need to have this information too (passed in via  
nlmclnt_inet)?

Would we also want kernel rpcbind requests to be sensitive to the  
passed-in bind address?

>
> 	if (clp == NULL)
> 		return SVC_DROP;
>
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index bb25d21..94fd8b4 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -39,6 +39,7 @@ struct cb_compound_hdr_res {
>
> struct cb_getattrargs {
> 	struct sockaddr *addr;
> +	struct sockaddr *bindaddr;
> 	struct nfs_fh fh;
> 	uint32_t bitmap[2];
> };
> @@ -54,6 +55,7 @@ struct cb_getattrres {
>
> struct cb_recallargs {
> 	struct sockaddr *addr;
> +	struct sockaddr *bindaddr;
> 	struct nfs_fh fh;
> 	nfs4_stateid stateid;
> 	uint32_t truncate;
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index f7e83e2..cd75849 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -25,7 +25,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs  
> *args, struct cb_getattrres *
>
> 	res->bitmap[0] = res->bitmap[1] = 0;
> 	res->status = htonl(NFS4ERR_BADHANDLE);
> -	clp = nfs_find_client(args->addr, 4);
> +	clp = nfs_find_client(args->bindaddr, args->addr, 4);
> 	if (clp == NULL)
> 		goto out;
>
> @@ -68,7 +68,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs  
> *args, void *dummy)
> 	__be32 res;
> 	
> 	res = htonl(NFS4ERR_BADHANDLE);
> -	clp = nfs_find_client(args->addr, 4);
> +	clp = nfs_find_client(args->bindaddr, args->addr, 4);
> 	if (clp == NULL)
> 		goto out;
>
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index dd0ef34..a342e8e 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -177,6 +177,7 @@ static __be32 decode_getattr_args(struct  
> svc_rqst *rqstp, struct xdr_stream *xdr
> 	if (unlikely(status != 0))
> 		goto out;
> 	args->addr = svc_addr(rqstp);
> +	args->bindaddr = svc_daddr(rqstp);
> 	status = decode_bitmap(xdr, args->bitmap);
> out:
> 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
> @@ -189,6 +190,7 @@ static __be32 decode_recall_args(struct svc_rqst  
> *rqstp, struct xdr_stream *xdr,
> 	__be32 status;
>
> 	args->addr = svc_addr(rqstp);
> +	args->bindaddr = svc_daddr(rqstp);
> 	status = decode_stateid(xdr, &args->stateid);
> 	if (unlikely(status != 0))
> 		goto out;
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 9b728f3..6cd8bd5 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -98,6 +98,7 @@ struct rpc_program		nfsacl_program = {
> struct nfs_client_initdata {
> 	const char *hostname;
> 	const struct sockaddr *addr;
> +	const struct sockaddr *bindaddr;
> 	size_t addrlen;
> 	const struct nfs_rpc_ops *rpc_ops;
> 	int proto;
> @@ -130,7 +131,8 @@ static struct nfs_client *nfs_alloc_client(const  
> struct nfs_client_initdata *cl_
>
> 	memcpy(&clp->cl_addr, cl_init->addr, cl_init->addrlen);
> 	clp->cl_addrlen = cl_init->addrlen;
> -
> +	memcpy(&clp->bindaddr, cl_init->bindaddr, cl_init->addrlen);
> +	
> 	if (cl_init->hostname) {
> 		clp->cl_hostname = kstrdup(cl_init->hostname, GFP_KERNEL);
> 		if (!clp->cl_hostname)
> @@ -276,7 +278,8 @@ static int nfs_sockaddr_match_ipaddr(const  
> struct sockaddr *sa1,
>  * Find a client by IP address and protocol version
>  * - returns NULL if no such client
>  */
> -struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32  
> nfsversion)
> +struct nfs_client *nfs_find_client(const struct sockaddr *bindaddr,
> +				   const struct sockaddr *addr, u32 nfsversion)
> {
> 	struct nfs_client *clp;
>
> @@ -293,6 +296,8 @@ struct nfs_client *nfs_find_client(const struct  
> sockaddr *addr, u32 nfsversion)
> 			continue;
>
> 		/* Match only the IP address, not the port number */
> +		if (!nfs_sockaddr_match_ipaddr(bindaddr, (const struct sockaddr*) 
> (&clp->bindaddr)))
> +			continue;
> 		if (!nfs_sockaddr_match_ipaddr(addr, clap))
> 			continue;
>
> @@ -357,6 +362,11 @@ static struct nfs_client  
> *nfs_match_client(const struct nfs_client_initdata *dat
> 		if (clp->cl_proto != data->proto)
> 			continue;
>
> +		/* Check to make sure local-IP bindings match, but just the IP- 
> addr. */
> +		if (!nfs_sockaddr_match_ipaddr((const struct sockaddr*)(&clp- 
> >bindaddr),
> +					       data->bindaddr))
> +			continue;
> +		
> 		/* Match the full socket address */
> 		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
> 			continue;
> @@ -493,6 +503,7 @@ static int nfs_create_rpc_client(struct  
> nfs_client *clp,
> 	struct rpc_clnt		*clnt = NULL;
> 	struct rpc_create_args args = {
> 		.protocol	= clp->cl_proto,
> +		.saddress	= (struct sockaddr *)&clp->bindaddr,
> 		.address	= (struct sockaddr *)&clp->cl_addr,
> 		.addrsize	= clp->cl_addrlen,
> 		.timeout	= timeparms,
> @@ -670,6 +681,7 @@ static int nfs_init_server(struct nfs_server  
> *server,
> 		.hostname = data->nfs_server.hostname,
> 		.addr = (const struct sockaddr *)&data->nfs_server.address,
> 		.addrlen = data->nfs_server.addrlen,
> +		.bindaddr = (const struct sockaddr *)&data->bindaddr.address,
> 		.rpc_ops = &nfs_v2_clientops,
> 		.proto = data->nfs_server.protocol,
> 	};
> @@ -1035,6 +1047,7 @@ static int nfs4_set_client(struct nfs_server  
> *server,
> 		const struct sockaddr *addr,
> 		const size_t addrlen,
> 		const char *ip_addr,
> +		const struct sockaddr* bindaddr,
> 		rpc_authflavor_t authflavour,
> 		int proto, const struct rpc_timeout *timeparms)
> {
> @@ -1042,6 +1055,7 @@ static int nfs4_set_client(struct nfs_server  
> *server,
> 		.hostname = hostname,
> 		.addr = addr,
> 		.addrlen = addrlen,
> +		.bindaddr = bindaddr,
> 		.rpc_ops = &nfs_v4_clientops,
> 		.proto = proto,
> 	};
> @@ -1096,6 +1110,7 @@ static int nfs4_init_server(struct nfs_server  
> *server,
> 			(const struct sockaddr *)&data->nfs_server.address,
> 			data->nfs_server.addrlen,
> 			data->client_address,
> +			(const struct sockaddr *)&data->bindaddr.address,
> 			data->auth_flavors[0],
> 			data->nfs_server.protocol,
> 			&timeparms);
> @@ -1214,6 +1229,7 @@ struct nfs_server  
> *nfs4_create_referral_server(struct nfs_clone_mount *data,
> 				data->addr,
> 				data->addrlen,
> 				parent_client->cl_ipaddr,
> +				(const struct sockaddr *)(&parent_client->bindaddr),
> 				data->authflavor,
> 				parent_server->client->cl_xprt->prot,
> 				parent_server->client->cl_timeout);
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 340ede8..330d10f 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -41,6 +41,12 @@ struct nfs_parsed_mount_data {
> 	unsigned int		auth_flavor_len;
> 	rpc_authflavor_t	auth_flavors[1];
> 	char			*client_address;
> +	
> +	struct {
> +		struct sockaddr_storage	address;
> +		size_t			addrlen;
> +		char			*hostname;
> +	} bindaddr;
>
> 	struct {
> 		struct sockaddr_storage	address;
> @@ -66,6 +72,7 @@ struct nfs_parsed_mount_data {
> /* mount_clnt.c */
> struct nfs_mount_request {
> 	struct sockaddr		*sap;
> +	struct sockaddr		*bindaddr;
> 	size_t			salen;
> 	char			*hostname;
> 	char			*dirpath;
> @@ -81,7 +88,8 @@ extern int nfs_mount(struct nfs_mount_request  
> *info);
> extern struct rpc_program nfs_program;
>
> extern void nfs_put_client(struct nfs_client *);
> -extern struct nfs_client *nfs_find_client(const struct sockaddr *,  
> u32);
> +extern struct nfs_client *nfs_find_client(const struct sockaddr *,
> +					  const struct sockaddr *, u32);
> extern struct nfs_client *nfs_find_client_next(struct nfs_client *);
> extern struct nfs_server *nfs_create_server(
> 					const struct nfs_parsed_mount_data *,
> diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> index ca905a5..89acb0c 100644
> --- a/fs/nfs/mount_clnt.c
> +++ b/fs/nfs/mount_clnt.c
> @@ -44,6 +44,7 @@ int nfs_mount(struct nfs_mount_request *info)
> 	};
> 	struct rpc_create_args args = {
> 		.protocol	= info->protocol,
> +		.saddress	= info->bindaddr,
> 		.address	= info->sap,
> 		.addrsize	= info->salen,
> 		.servername	= info->hostname,
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index d6686f4..90f29bd 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -91,7 +91,7 @@ enum {
>
> 	/* Mount options that take string arguments */
> 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
> -	Opt_addr, Opt_mountaddr, Opt_clientaddr,
> +	Opt_addr, Opt_mountaddr, Opt_clientaddr, Opt_bindaddr,
> 	Opt_lookupcache,
>
> 	/* Special mount options */
> @@ -155,6 +155,7 @@ static const match_table_t  
> nfs_mount_option_tokens = {
> 	{ Opt_mountproto, "mountproto=%s" },
> 	{ Opt_addr, "addr=%s" },
> 	{ Opt_clientaddr, "clientaddr=%s" },
> +	{ Opt_bindaddr, "bindaddr=%s" },
> 	{ Opt_mounthost, "mounthost=%s" },
> 	{ Opt_mountaddr, "mountaddr=%s" },
>
> @@ -563,6 +564,15 @@ static void nfs_show_mount_options(struct  
> seq_file *m, struct nfs_server *nfss,
> 	if (clp->rpc_ops->version == 4)
> 		seq_printf(m, ",clientaddr=%s", clp->cl_ipaddr);
> #endif
> +
> +	if (clp->bindaddr.ss_family == AF_INET6) {
> +		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)(&clp- 
> >bindaddr);
> +		seq_printf(m, ",bindaddr=%pI6", &sin6->sin6_addr);
> +	}
> +	else {
> +		struct sockaddr_in *sin = (struct sockaddr_in *)(&clp->bindaddr);
> +		seq_printf(m, ",bindaddr=%pI4", &sin->sin_addr.s_addr);
> +	}
> }
>
> /*
> @@ -1251,6 +1261,16 @@ static int nfs_parse_mount_options(char *raw,
> 			kfree(mnt->client_address);
> 			mnt->client_address = string;
> 			break;
> +		case Opt_bindaddr:
> +			string = match_strdup(args);
> +			if (string == NULL)
> +				goto out_nomem;
> +			nfs_parse_ip_address(string, strlen(string),
> +					     (struct sockaddr *)&mnt->bindaddr.address,
> +					     &mnt->bindaddr.addrlen);
> +			kfree(mnt->bindaddr.hostname);
> +			mnt->bindaddr.hostname = string;

You don't appear to use bindaddr.hostname anywhere, and I don't think  
it is adequate to free it only here.

Maybe you don't need it at all?

> +			break;
> 		case Opt_mounthost:
> 			string = match_strdup(args);
> 			if (string == NULL)
> @@ -1340,6 +1360,8 @@ static int nfs_try_mount(struct  
> nfs_parsed_mount_data *args,
> 	struct nfs_mount_request request = {
> 		.sap		= (struct sockaddr *)
> 						&args->mount_server.address,
> +		.bindaddr	= (struct sockaddr *)&args->bindaddr.address,
> +		.salen		= args->mount_server.addrlen,
> 		.dirpath	= args->nfs_server.export_path,
> 		.protocol	= args->mount_server.protocol,
> 		.fh		= root_fh,
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 9bb81ae..ebe612f 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -64,6 +64,9 @@ struct nfs_client {
> 	char			cl_ipaddr[48];
> 	unsigned char		cl_id_uniquifier;
> #endif
> +
> +	/* If we should bind to a local IP, it should be specified below. */
> +	struct sockaddr_storage	bindaddr;
> };
>
> /*

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




