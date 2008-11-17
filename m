From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 18/85] nfs41: sessions client infrastructure
Date: Mon, 17 Nov 2008 15:44:25 +0200
Message-ID: <49217539.2000902@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348459-7784-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:9018 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751689AbYKQNo3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:44:29 -0500
In-Reply-To: <1226348459-7784-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:20 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> NFSv4.1 Sessions basic data types, initialization, and destruction.
> 
> The session is always associated with a struct nfs_client that holds
> the exchange_id results. Add an nfs_client struct backpointer to the session
> and refactor the session recovery routines to only require a struct
> nfs4_sessions parameter.
> 
> Signed-off-by: Rahul Iyer <iyer@netapp.com>
> Signed-off-by: Andy Adamson<andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/client.c              |   40 +++++++++++++++++++++++++++++++++++++
>  fs/nfs/internal.h            |    1 +
>  fs/nfs/nfs4_fs.h             |    4 +++
>  fs/nfs/nfs4proc.c            |   35 ++++++++++++++++++++++++++++++++
>  include/linux/nfs4_session.h |   45 ++++++++++++++++++++++++++++++++++++++++++
>  include/linux/nfs_fs_sb.h    |    5 ++++
>  6 files changed, 130 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/nfs4_session.h
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 0a8a082..80091dc 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -37,6 +37,9 @@
>  #include <linux/in6.h>
>  #include <net/ipv6.h>
>  #include <linux/nfs_xdr.h>
> +#if defined(CONFIG_NFS_V4_1)
> +#include <linux/nfs4_session.h>
> +#endif /* CONFIG_NFS_V4_1 */
>  
>  #include <asm/system.h>
>  
> @@ -884,6 +887,11 @@ void nfs_free_server(struct nfs_server *server)
>  	list_del(&server->master_link);
>  	spin_unlock(&nfs_client_lock);
>  
> +#ifdef CONFIG_NFS_V4_1
> +	if (server->nfs_client->cl_session != NULL)
> +		nfs4_put_session(&server->nfs_client->cl_session);
> +#endif /* CONFIG_NFS_V4_1 */
> +
>  	if (server->destroy != NULL)
>  		server->destroy(server);
>  
> @@ -1110,6 +1118,34 @@ error:
>  }
>  
>  /*
> + * Allocate and initialize a session if required
> + */
> +int nfs4_init_session(struct nfs_client *clp, struct rpc_clnt *clnt)
> +{
> +	int error = 0;
> +
> +#if defined(CONFIG_NFS_V4_1)
> +	if (clp->cl_minorversion) {
> +		struct nfs4_session *session = NULL;
> +		/*
> +		 * Create the session and mark it expired.
> +		 * When a SEQUENCE operation encounters the expired session
> +		 * it will do session recovery to initialize it.
> +		 */
> +		session = nfs4_alloc_session();
> +		if (!session)
> +			error = -ENOMEM;
> +		else {
> +			session->clnt = clnt;
> +			session->clp = clp;
> +		}
> +		clp->cl_session = session;
> +	}
> +#endif /* CONFIG_NFS_V4_1 */
> +	return error;
> +}
> +
> +/*
>   * Create a version 4 volume record
>   * - keyed on server and FSID
>   */
> @@ -1139,6 +1175,10 @@ retry:
>  	BUG_ON(!server->nfs_client->rpc_ops);
>  	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
>  
> +	error = nfs4_init_session(server->nfs_client, server->client);
> +	if (error)
> +		goto error;
> +
>  	/* Probe the root fh to retrieve its FSID */
>  	error = nfs4_path_walk(server, mntfh, data->nfs_server.export_path);
>  	if (error < 0)
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 8386e99..9b2228f 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -82,6 +82,7 @@ extern void nfs_free_server(struct nfs_server *server);
>  extern struct nfs_server *nfs_clone_server(struct nfs_server *,
>  					   struct nfs_fh *,
>  					   struct nfs_fattr *);
> +extern int nfs4_init_session(struct nfs_client *clp, struct rpc_clnt *clnt);
>  #ifdef CONFIG_PROC_FS
>  extern int __init nfs_fs_proc_init(void);
>  extern void nfs_fs_proc_exit(void);
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 5fb7382..4b13945 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -188,6 +188,10 @@ extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
>  
>  extern struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops;
>  extern struct nfs4_state_recovery_ops nfs4_network_partition_recovery_ops;
> +#if defined(CONFIG_NFS_V4_1)
> +extern void nfs4_put_session(struct nfs4_session **session);
> +extern struct nfs4_session *nfs4_alloc_session(void);
> +#endif /* CONFIG_NFS_V4_1 */
>  
>  extern const u32 nfs4_fattr_bitmap[2];
>  extern const u32 nfs4_statfs_bitmap[2];
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index f87d4de..8e373e9 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -53,6 +53,9 @@
>  #include "delegation.h"
>  #include "internal.h"
>  #include "iostat.h"
> +#if defined(CONFIG_NFS_V4_1)
> +#include <linux/nfs4_session.h>
> +#endif /* CONFIG_NFS_V4_1 */
>  
>  #define NFSDBG_FACILITY		NFSDBG_PROC
>  
> @@ -3679,6 +3682,38 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
>  	return status;
>  }
>  
> +#ifdef CONFIG_NFS_V4_1
> +struct nfs4_session *nfs4_alloc_session(void)
> +{
> +	struct nfs4_session *session;
> +
> +	session = kzalloc(sizeof(struct nfs4_session), GFP_ATOMIC);
> +	if (!session)
> +		return NULL;
> +
> +	atomic_set(&session->ref_count, 1);
> +
> +	return session;
> +}
> +
> +static void nfs4_free_session(struct nfs4_session *session)
> +{
> +	dprintk("%s: freeing session %p\n", __func__, session);
> +	kfree(session);
> +}
> +
> +void nfs4_put_session(struct nfs4_session **session)

review 11-14: pass a struct nfs4_session* (not **)
do not set *session to NULL

> +{
> +	dprintk("--> nfs4_put_session()\n");
> +	if (atomic_dec_and_test(&((*session)->ref_count))) {
> +		nfs4_free_session(*session);
> +		*session = NULL;
> +	}
> +	dprintk("<-- nfs4_put_session()\n");
> +}
> +
> +#endif /* CONFIG_NFS_V4_1 */
> +
>  struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
>  	.recover_open	= nfs4_open_reclaim,
>  	.recover_lock	= nfs4_lock_reclaim,
> diff --git a/include/linux/nfs4_session.h b/include/linux/nfs4_session.h
> new file mode 100644
> index 0000000..36c0f94
> --- /dev/null
> +++ b/include/linux/nfs4_session.h

review 11-14: move to fs/nfs/nfs4_fs.h

> @@ -0,0 +1,45 @@
> +#ifndef _NFS4_SESSIONS_H
> +#define _NFS4_SESSIONS_H
> +
> +#if defined(CONFIG_NFS_V4_1)
> +
> +#include <linux/nfs4.h>
> +#include <linux/smp_lock.h>
> +#include <linux/sunrpc/sched.h>
> +
> +struct nfs4_channel_attrs {
> +	u32			headerpadsz;
> +	u32			max_rqst_sz;
> +	u32			max_resp_sz;
> +	u32			max_resp_sz_cached;
> +	u32			max_ops;
> +	u32			max_reqs;
> +	u32			rdma_attrs;

review 11-14: weed out unused fields

> +};
> +
> +struct nfs4_channel {
> +	struct nfs4_channel_attrs 	chan_attrs;
> +	struct rpc_clnt 		*rpc_client;

review 11-14: unused, no need for this struct

> +};
> +
> +/*
> + * Session related parameters
> + */
> +struct nfs4_session {
> +	nfs41_sessionid			sess_id;
> +	u32				flags;

review 11-14: remove until used

> +	unsigned long			session_state;
> +	u32				hash_alg;
> +	u32				ssv_len;

review 11-14: take these out for now.

> +
> +	/* The fore and back channel */
> +	struct nfs4_channel		fore_channel;

review 11-14: s/nfs4_channel/nfs4_channel_attrs/

> +	struct nfs4_channel		back_channel;
> +
> +	atomic_t			ref_count;
> +	struct rpc_clnt			*clnt;

review 11-14: use clp->cl_rpcclient instead

> +	struct nfs_client		*clp;
> +};
> +
> +#endif	/* CONFIG_NFS_V4_1 */
> +#endif
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 80e0fc3..15c0aa5 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -7,6 +7,7 @@
>  
>  #include <asm/atomic.h>
>  
> +struct nfs4_session;
>  struct nfs_iostats;
>  struct nlm_host;
>  
> @@ -72,6 +73,10 @@ struct nfs_client {
>  	unsigned char		cl_id_uniquifier;
>  	u32			cl_minorversion;
>  #endif /* CONFIG_NFS_V4 */
> +
> +#ifdef CONFIG_NFS_V4_1
> +	struct nfs4_session	*cl_session; 	/* sharred session */
> +#endif /* CONFIG_NFS_V4_1 */
>  };
>  
>  #ifdef CONFIG_NFS_V4
