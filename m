Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29830 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755602Ab2CLPRm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 11:17:42 -0400
Message-ID: <4F5E1372.4010809@netapp.com>
Date: Mon, 12 Mar 2012 11:17:06 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Fix a number of sparse warnings
References: <1331487939-12415-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1331487939-12415-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/11/2012 01:45 PM, Trond Myklebust wrote:

> Fix a number of "warning: symbol 'foo' was not declared. Should it be
> static?" conditions.
> 
> fs/nfs/delegation.c:263:31: warning: restricted fmode_t degrades to integer
>   - We want to allow upgrades to a WRITE delegation, but should otherwise
>     consider servers that hand out duplicate delegations to be borken.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/callback.c            |    4 ++--
>  fs/nfs/client.c              |    5 ++---
>  fs/nfs/delegation.c          |    5 ++++-
>  fs/nfs/dns_resolve.c         |    1 +
>  fs/nfs/idmap.c               |    8 ++++----
>  fs/nfs/nfs4filelayout.c      |   10 +++++-----
>  fs/nfs/nfs4filelayoutdev.c   |    4 ++--
>  fs/nfs/nfs4proc.c            |   23 ++++++++++++-----------
>  fs/nfs/nfs4state.c           |    3 ++-
>  fs/nfs/objlayout/objlayout.c |    2 +-
>  fs/nfs/pnfs_dev.c            |    2 +-
>  fs/nfs/unlink.c              |    2 +-
>  12 files changed, 37 insertions(+), 32 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 2afe233..eb95f50 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -101,7 +101,7 @@ nfs4_callback_svc(void *vrqstp)
>  /*
>   * Prepare to bring up the NFSv4 callback service
>   */
> -struct svc_rqst *
> +static struct svc_rqst *
>  nfs4_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
>  {
>  	int ret;
> @@ -172,7 +172,7 @@ nfs41_callback_svc(void *vrqstp)
>  /*
>   * Bring up the NFSv4.1 callback service
>   */
> -struct svc_rqst *
> +static struct svc_rqst *
>  nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
>  {
>  	struct svc_rqst *rqstp;
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index d30dcbf..f1f047c 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -443,9 +443,8 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
>  }
>  
>  /* Common match routine for v4.0 and v4.1 callback services */
> -bool
> -nfs4_cb_match_client(const struct sockaddr *addr, struct nfs_client *clp,
> -		     u32 minorversion)
> +static bool nfs4_cb_match_client(const struct sockaddr *addr,
> +		struct nfs_client *clp, u32 minorversion)
>  {
>  	struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;


Now that this function is static, gcc gives me this warning: 
  CC [M]  fs/nfs/client.o
fs/nfs/client.c:446:13: warning: 'nfs4_cb_match_client' defined but not used [-Wunused-function]

It looks like the only user of this function is nfs4_find_client_sessionid, so when v4.1 isn't enabled the function isn't used.  Would you like me to send in a separate patch for this?

- Bryan

>  
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 12de883..89af1d2 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -256,11 +256,14 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
>  		/*
>  		 * Deal with broken servers that hand out two
>  		 * delegations for the same file.
> +		 * Allow for upgrades to a WRITE delegation, but
> +		 * nothing else.
>  		 */
>  		dfprintk(FILE, "%s: server %s handed out "
>  				"a duplicate delegation!\n",
>  				__func__, clp->cl_hostname);
> -		if (delegation->type <= old_delegation->type) {
> +		if (delegation->type == old_delegation->type ||
> +		    !(delegation->type & FMODE_WRITE)) {
>  			freeme = delegation;
>  			delegation = NULL;
>  			goto out;
> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
> index fcd8f1d..b3924b8 100644
> --- a/fs/nfs/dns_resolve.c
> +++ b/fs/nfs/dns_resolve.c
> @@ -10,6 +10,7 @@
>  
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/dns_resolver.h>
> +#include "dns_resolve.h"
>  
>  ssize_t nfs_dns_resolve_name(struct net *net, char *name, size_t namelen,
>  		struct sockaddr *sa, size_t salen)
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index f72c1fc..f9f89fc 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -54,8 +54,8 @@
>  
>  /* Default cache timeout is 10 minutes */
>  unsigned int nfs_idmap_cache_timeout = 600;
> -const struct cred *id_resolver_cache;
> -struct key_type key_type_id_resolver_legacy;
> +static const struct cred *id_resolver_cache;
> +static struct key_type key_type_id_resolver_legacy;
>  
>  
>  /**
> @@ -160,7 +160,7 @@ static int nfs_map_numeric_to_string(__u32 id, char *buf, size_t buflen)
>  	return snprintf(buf, buflen, "%u", id);
>  }
>  
> -struct key_type key_type_id_resolver = {
> +static struct key_type key_type_id_resolver = {
>  	.name		= "id_resolver",
>  	.instantiate	= user_instantiate,
>  	.match		= user_match,
> @@ -381,7 +381,7 @@ static const struct rpc_pipe_ops idmap_upcall_ops = {
>  	.destroy_msg	= idmap_pipe_destroy_msg,
>  };
>  
> -struct key_type key_type_id_resolver_legacy = {
> +static struct key_type key_type_id_resolver_legacy = {
>  	.name		= "id_resolver",
>  	.instantiate	= user_instantiate,
>  	.match		= user_match,
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 716fac6..379a085 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -323,21 +323,21 @@ static void filelayout_commit_release(void *data)
>  	nfs_commitdata_release(wdata);
>  }
>  
> -struct rpc_call_ops filelayout_read_call_ops = {
> +static const struct rpc_call_ops filelayout_read_call_ops = {
>  	.rpc_call_prepare = filelayout_read_prepare,
>  	.rpc_call_done = filelayout_read_call_done,
>  	.rpc_count_stats = filelayout_read_count_stats,
>  	.rpc_release = filelayout_read_release,
>  };
>  
> -struct rpc_call_ops filelayout_write_call_ops = {
> +static const struct rpc_call_ops filelayout_write_call_ops = {
>  	.rpc_call_prepare = filelayout_write_prepare,
>  	.rpc_call_done = filelayout_write_call_done,
>  	.rpc_count_stats = filelayout_write_count_stats,
>  	.rpc_release = filelayout_write_release,
>  };
>  
> -struct rpc_call_ops filelayout_commit_call_ops = {
> +static const struct rpc_call_ops filelayout_commit_call_ops = {
>  	.rpc_call_prepare = filelayout_write_prepare,
>  	.rpc_call_done = filelayout_write_call_done,
>  	.rpc_count_stats = filelayout_write_count_stats,
> @@ -723,7 +723,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>  	return (p_stripe == r_stripe);
>  }
>  
> -void
> +static void
>  filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
>  			struct nfs_page *req)
>  {
> @@ -740,7 +740,7 @@ filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
>  		nfs_pageio_reset_read_mds(pgio);
>  }
>  
> -void
> +static void
>  filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
>  			 struct nfs_page *req)
>  {
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 41677f0..a866bbd 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -45,7 +45,7 @@
>   *   - incremented when a device id maps a data server already in the cache.
>   *   - decremented when deviceid is removed from the cache.
>   */
> -DEFINE_SPINLOCK(nfs4_ds_cache_lock);
> +static DEFINE_SPINLOCK(nfs4_ds_cache_lock);
>  static LIST_HEAD(nfs4_data_server_cache);
>  
>  /* Debug routines */
> @@ -108,7 +108,7 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
>  	return false;
>  }
>  
> -bool
> +static bool
>  _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
>  			       const struct list_head *dsaddrs2)
>  {
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 3bf5593..36a7cda 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -677,12 +677,12 @@ static void nfs41_call_sync_done(struct rpc_task *task, void *calldata)
>  	nfs41_sequence_done(task, data->seq_res);
>  }
>  
> -struct rpc_call_ops nfs41_call_sync_ops = {
> +static const struct rpc_call_ops nfs41_call_sync_ops = {
>  	.rpc_call_prepare = nfs41_call_sync_prepare,
>  	.rpc_call_done = nfs41_call_sync_done,
>  };
>  
> -struct rpc_call_ops nfs41_call_priv_sync_ops = {
> +static const struct rpc_call_ops nfs41_call_priv_sync_ops = {
>  	.rpc_call_prepare = nfs41_call_priv_sync_prepare,
>  	.rpc_call_done = nfs41_call_sync_done,
>  };
> @@ -4770,7 +4770,7 @@ static void nfs4_release_lockowner_release(void *calldata)
>  	kfree(calldata);
>  }
>  
> -const struct rpc_call_ops nfs4_release_lockowner_ops = {
> +static const struct rpc_call_ops nfs4_release_lockowner_ops = {
>  	.rpc_release = nfs4_release_lockowner_release,
>  };
>  
> @@ -4910,7 +4910,8 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
>  	return status;
>  }
>  
> -int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
> +static int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name,
> +		struct nfs4_secinfo_flavors *flavors)
>  {
>  	struct nfs4_exception exception = { };
>  	int err;
> @@ -5096,7 +5097,7 @@ static void nfs4_get_lease_time_done(struct rpc_task *task, void *calldata)
>  	dprintk("<-- %s\n", __func__);
>  }
>  
> -struct rpc_call_ops nfs4_get_lease_time_ops = {
> +static const struct rpc_call_ops nfs4_get_lease_time_ops = {
>  	.rpc_call_prepare = nfs4_get_lease_time_prepare,
>  	.rpc_call_done = nfs4_get_lease_time_done,
>  };
> @@ -6319,7 +6320,7 @@ static bool nfs4_match_stateid(const nfs4_stateid *s1,
>  }
>  
>  
> -struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
> +static const struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
>  	.owner_flag_bit = NFS_OWNER_RECLAIM_REBOOT,
>  	.state_flag_bit	= NFS_STATE_RECLAIM_REBOOT,
>  	.recover_open	= nfs4_open_reclaim,
> @@ -6329,7 +6330,7 @@ struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
>  };
>  
>  #if defined(CONFIG_NFS_V4_1)
> -struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
> +static const struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
>  	.owner_flag_bit = NFS_OWNER_RECLAIM_REBOOT,
>  	.state_flag_bit	= NFS_STATE_RECLAIM_REBOOT,
>  	.recover_open	= nfs4_open_reclaim,
> @@ -6340,7 +6341,7 @@ struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
>  };
>  #endif /* CONFIG_NFS_V4_1 */
>  
> -struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
> +static const struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
>  	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
>  	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
>  	.recover_open	= nfs4_open_expired,
> @@ -6350,7 +6351,7 @@ struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
>  };
>  
>  #if defined(CONFIG_NFS_V4_1)
> -struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
> +static const struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
>  	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
>  	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
>  	.recover_open	= nfs41_open_expired,
> @@ -6360,14 +6361,14 @@ struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
>  };
>  #endif /* CONFIG_NFS_V4_1 */
>  
> -struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
> +static const struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
>  	.sched_state_renewal = nfs4_proc_async_renew,
>  	.get_state_renewal_cred_locked = nfs4_get_renew_cred_locked,
>  	.renew_lease = nfs4_proc_renew,
>  };
>  
>  #if defined(CONFIG_NFS_V4_1)
> -struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
> +static const struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
>  	.sched_state_renewal = nfs41_proc_async_sequence,
>  	.get_state_renewal_cred_locked = nfs4_get_machine_cred_locked,
>  	.renew_lease = nfs4_proc_sequence,
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 5fa43cd..7c58607 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -876,7 +876,8 @@ int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl)
>  	if (fl->fl_flags & FL_POSIX)
>  		lsp = nfs4_get_lock_state(state, fl->fl_owner, 0, NFS4_POSIX_LOCK_TYPE);
>  	else if (fl->fl_flags & FL_FLOCK)
> -		lsp = nfs4_get_lock_state(state, 0, fl->fl_pid, NFS4_FLOCK_LOCK_TYPE);
> +		lsp = nfs4_get_lock_state(state, NULL, fl->fl_pid,
> +				NFS4_FLOCK_LOCK_TYPE);
>  	else
>  		return -EINVAL;
>  	if (lsp == NULL)
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index 2bd1852..157c47e 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> @@ -156,7 +156,7 @@ last_byte_offset(u64 start, u64 len)
>  	return end > start ? end - 1 : NFS4_MAX_UINT64;
>  }
>  
> -void _fix_verify_io_params(struct pnfs_layout_segment *lseg,
> +static void _fix_verify_io_params(struct pnfs_layout_segment *lseg,
>  			   struct page ***p_pages, unsigned *p_pgbase,
>  			   u64 offset, unsigned long count)
>  {
> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> index 4f359d2..6b4cd38 100644
> --- a/fs/nfs/pnfs_dev.c
> +++ b/fs/nfs/pnfs_dev.c
> @@ -92,7 +92,7 @@ _lookup_deviceid(const struct pnfs_layoutdriver_type *ld,
>   * @clp nfs_client associated with deviceid
>   * @id deviceid to look up
>   */
> -struct nfs4_deviceid_node *
> +static struct nfs4_deviceid_node *
>  _find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
>  		   const struct nfs_client *clp, const struct nfs4_deviceid *id,
>  		   long hash)
> diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
> index 490613b..fae71c9 100644
> --- a/fs/nfs/unlink.c
> +++ b/fs/nfs/unlink.c
> @@ -108,7 +108,7 @@ static void nfs_async_unlink_release(void *calldata)
>  }
>  
>  #if defined(CONFIG_NFS_V4_1)
> -void nfs_unlink_prepare(struct rpc_task *task, void *calldata)
> +static void nfs_unlink_prepare(struct rpc_task *task, void *calldata)
>  {
>  	struct nfs_unlinkdata *data = calldata;
>  	struct nfs_server *server = NFS_SERVER(data->dir);


