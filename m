Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:32361 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161Ab3KMOjD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 09:39:03 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH v2 3/3] nfs: check if gssd is running before attempting to use krb5i auth in SETCLIENTID call
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1384353053-30002-4-git-send-email-jlayton@redhat.com>
Date: Wed, 13 Nov 2013 09:38:54 -0500
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org, neilb@suse.de,
        steved@redhat.com
Message-Id: <DF1DECB2-B736-4B70-87DC-52CD695C44F3@oracle.com>
References: <1384353053-30002-1-git-send-email-jlayton@redhat.com> <1384353053-30002-4-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 13, 2013, at 9:30 AM, Jeff Layton <jlayton@redhat.com> wrote:

> Currently, the client will attempt to use krb5i in the SETCLIENTID call
> even if rpc.gssd is running. If that fails, it'll then fall back to
> RPC_AUTH_UNIX. This introduced a delay when mounting if rpc.gssd isn't
> running, and causes warning messages to pop up in the ring buffer.
> 
> Check to see if rpc.gssd is running before even attempting to use krb5i
> auth, and just silently skip trying to do so if it isn't.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfs/client.c                 |  5 +++--
> fs/nfs/internal.h               |  4 ++--
> fs/nfs/nfs4client.c             |  8 ++++++--
> include/linux/nfs_xdr.h         |  2 +-
> include/linux/sunrpc/auth_gss.h | 10 ++++++++++
> net/sunrpc/auth_gss/auth_gss.c  |  3 ++-
> 6 files changed, 24 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 1d09289..fbee354 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -501,7 +501,8 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
> 					&nn->nfs_client_list);
> 			spin_unlock(&nn->nfs_client_lock);
> 			new->cl_flags = cl_init->init_flags;
> -			return rpc_ops->init_client(new, timeparms, ip_addr);
> +			return rpc_ops->init_client(new, timeparms, ip_addr,
> +							cl_init->net);
> 		}
> 
> 		spin_unlock(&nn->nfs_client_lock);
> @@ -700,7 +701,7 @@ EXPORT_SYMBOL_GPL(nfs_init_server_rpcclient);
>  */
> struct nfs_client *nfs_init_client(struct nfs_client *clp,
> 		    const struct rpc_timeout *timeparms,
> -		    const char *ip_addr)
> +		    const char *ip_addr, struct net *net)
> {
> 	int error;
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index bca6a3e..69d3d1c 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -273,7 +273,7 @@ extern struct rpc_procinfo nfs4_procedures[];
> void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
> extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
> 			   const struct rpc_timeout *timeparms,
> -			   const char *ip_addr);
> +			   const char *ip_addr, struct net *net);
> 
> /* dir.c */
> extern unsigned long nfs_access_cache_count(struct shrinker *shrink,
> @@ -462,7 +462,7 @@ extern ssize_t nfs_dreq_bytes_left(struct nfs_direct_req *dreq);
> extern void __nfs4_read_done_cb(struct nfs_read_data *);
> extern struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> 			    const struct rpc_timeout *timeparms,
> -			    const char *ip_addr);
> +			    const char *ip_addr, struct net *net);
> extern int nfs40_walk_client_list(struct nfs_client *clp,
> 				struct nfs_client **result,
> 				struct rpc_cred *cred);
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index b4a160a..988aebf 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -8,6 +8,7 @@
> #include <linux/nfs_mount.h>
> #include <linux/sunrpc/addr.h>
> #include <linux/sunrpc/auth.h>
> +#include <linux/sunrpc/auth_gss.h>
> #include <linux/sunrpc/xprt.h>
> #include <linux/sunrpc/bc_xprt.h>
> #include "internal.h"
> @@ -351,7 +352,7 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
>  */
> struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> 				    const struct rpc_timeout *timeparms,
> -				    const char *ip_addr)
> +				    const char *ip_addr, struct net *net)
> {
> 	char buf[INET6_ADDRSTRLEN + 1];
> 	struct nfs_client *old;
> @@ -370,7 +371,10 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
> 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
> 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
> -	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
> +
> +	error = -EINVAL;
> +	if (gssd_running(net))
> +		error = nfs_create_rpc_client(clp, timeparms,RPC_AUTH_GSS_KRB5I);
> 	if (error == -EINVAL)
> 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);

This feels like a layering violation.  Why wouldn't you put a gssd_running check in gss_create(), for example, and have rpcauth_create() return -EINVAL?


> 	if (error < 0)
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 3ccfcec..e75b2cc 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1486,7 +1486,7 @@ struct nfs_rpc_ops {
> 	struct nfs_client *(*alloc_client) (const struct nfs_client_initdata *);
> 	struct nfs_client *
> 		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
> -				const char *);
> +				const char *, struct net *);
> 	void	(*free_client) (struct nfs_client *);
> 	struct nfs_server *(*create_server)(struct nfs_mount_info *, struct nfs_subversion *);
> 	struct nfs_server *(*clone_server)(struct nfs_server *, struct nfs_fh *,
> diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
> index f1cfd4c..cecf684 100644
> --- a/include/linux/sunrpc/auth_gss.h
> +++ b/include/linux/sunrpc/auth_gss.h
> @@ -86,6 +86,16 @@ struct gss_cred {
> 	unsigned long		gc_upcall_timestamp;
> };
> 
> +#if IS_ENABLED(CONFIG_SUNRPC_GSS)
> +extern bool gssd_running(struct net *net);
> +#else /* !CONFIG_SUNRPC_GSS */
> +static inline bool
> +gssd_running(struct net *net)
> +{
> +	return false;
> +}
> +#endif /* CONFIG_SUNRPC_GSS */
> +
> #endif /* __KERNEL__ */
> #endif /* _LINUX_SUNRPC_AUTH_GSS_H */
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 399390e..0cc2174 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -592,13 +592,14 @@ out:
> 	return err;
> }
> 
> -static bool
> +bool
> gssd_running(struct net *net)
> {
> 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
> 
> 	return rpc_pipe_is_open(sn->gssd_dummy);
> }
> +EXPORT_SYMBOL_GPL(gssd_running);
> 
> static inline int
> gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
> -- 
> 1.8.3.1
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




