Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:20683 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757313Ab2ADXLA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 18:11:00 -0500
Subject: Re: [PATCH] NFS: Cache state owners after files are closed
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1325716037-27762-1-git-send-email-Trond.Myklebust@netapp.com>
Date: Wed, 4 Jan 2012 18:10:54 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <1BAE6B51-55DB-4114-B34E-C7B51143D1F0@oracle.com>
References: <C0783437-7D8F-4A45-913A-B49692D37AC2@oracle.com> <1325716037-27762-1-git-send-email-Trond.Myklebust@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 4, 2012, at 5:27 PM, Trond Myklebust wrote:

> From: Chuck Lever <chuck.lever@oracle.com>
> 
> Servers have a finite amount of memory to store NFSv4 open and lock
> owners.  Moreover, servers may have a difficult time determining when
> they can reap their state owner table, thanks to gray areas in the
> NFSv4 protocol specification.  Thus clients should be careful to reuse
> state owners when possible.
> 
> Currently Linux is not too careful.  When a user has closed all her
> files on one mount point, the state owner's reference count goes to
> zero, and it is released.  The next OPEN allocates a new one.  A
> workload that serially opens and closes files can run through a large
> number of open owners this way.
> 
> When a state owner's reference count goes to zero, slap it onto a free
> list for that nfs_server, with an expiry time.  Garbage collect before

^before$^when

You get the idea.

> looking for a state owner.  This makes state owners for active users
> available for re-use.
> 
> Now that there can be unused state owners remaining at umount time,
> purge the state owner free list when a server is destroyed.  Also be
> sure not to reclaim unused state owners during state recovery.
> 
> This change has benefits for the client as well.  For some workloads,
> this approach drops the number of OPEN_CONFIRM calls from the same as
> the number of OPEN calls, down to just one.  This reduces wire traffic
> and thus open(2) latency.  Before this patch, untarring a kernel
> source tarball shows the OPEN_CONFIRM call counter steadily increasing
> through the test.  With the patch, the OPEN_CONFIRM count remains at 1
> throughout the entire untar.
> 
> As long as the expiry time is kept short, I don't think garbage
> collection should be terribly expensive, although it does bounce the
> clp->cl_lock around a bit.
> 
> [ At some point we should rationalize the use of the nfs_server
> ->destroy method. ]
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> [Trond: Fixed a garbage collection race and a few efficiency issues]
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/client.c           |    8 ++++
> fs/nfs/nfs4_fs.h          |    3 ++
> fs/nfs/nfs4state.c        |   88 ++++++++++++++++++++++++++++++++++++++++-----
> include/linux/nfs_fs_sb.h |    1 +
> 4 files changed, 91 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 32ea371..41bd67f 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -250,6 +250,11 @@ static void pnfs_init_server(struct nfs_server *server)
> 	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
> }
> 
> +static void nfs4_destroy_server(struct nfs_server *server)
> +{
> +	nfs4_purge_state_owners(server);
> +}
> +
> #else
> static void nfs4_shutdown_client(struct nfs_client *clp)
> {
> @@ -1065,6 +1070,7 @@ static struct nfs_server *nfs_alloc_server(void)
> 	INIT_LIST_HEAD(&server->master_link);
> 	INIT_LIST_HEAD(&server->delegations);
> 	INIT_LIST_HEAD(&server->layouts);
> +	INIT_LIST_HEAD(&server->state_owners_lru);
> 
> 	atomic_set(&server->active, 0);
> 
> @@ -1538,6 +1544,7 @@ static int nfs4_server_common_setup(struct nfs_server *server,
> 
> 	nfs_server_insert_lists(server);
> 	server->mount_time = jiffies;
> +	server->destroy = nfs4_destroy_server;
> out:
> 	nfs_free_fattr(fattr);
> 	return error;
> @@ -1719,6 +1726,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
> 
> 	/* Copy data from the source */
> 	server->nfs_client = source->nfs_client;
> +	server->destroy = source->destroy;
> 	atomic_inc(&server->nfs_client->cl_count);
> 	nfs_server_copy_userdata(server, source);
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 693ae22..4d7d0ae 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -94,6 +94,8 @@ struct nfs_unique_id {
> struct nfs4_state_owner {
> 	struct nfs_unique_id so_owner_id;
> 	struct nfs_server    *so_server;
> +	struct list_head     so_lru;
> +	unsigned long        so_expires;
> 	struct rb_node	     so_server_node;
> 
> 	struct rpc_cred	     *so_cred;	 /* Associated cred */
> @@ -319,6 +321,7 @@ static inline void nfs4_schedule_session_recovery(struct nfs4_session *session)
> 
> extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *);
> extern void nfs4_put_state_owner(struct nfs4_state_owner *);
> +extern void nfs4_purge_state_owners(struct nfs_server *);
> extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
> extern void nfs4_put_open_state(struct nfs4_state *);
> extern void nfs4_close_state(struct nfs4_state *, fmode_t);
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 6354e4f..8aadb38 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -49,6 +49,7 @@
> #include <linux/ratelimit.h>
> #include <linux/workqueue.h>
> #include <linux/bitops.h>
> +#include <linux/jiffies.h>
> 
> #include "nfs4_fs.h"
> #include "callback.h"
> @@ -388,6 +389,8 @@ nfs4_find_state_owner_locked(struct nfs_server *server, struct rpc_cred *cred)
> 		else if (cred > sp->so_cred)
> 			p = &parent->rb_right;
> 		else {
> +			if (!list_empty(&sp->so_lru))
> +				list_del_init(&sp->so_lru);
> 			atomic_inc(&sp->so_count);
> 			return sp;
> 		}
> @@ -412,6 +415,8 @@ nfs4_insert_state_owner_locked(struct nfs4_state_owner *new)
> 		else if (new->so_cred > sp->so_cred)
> 			p = &parent->rb_right;
> 		else {
> +			if (!list_empty(&sp->so_lru))
> +				list_del_init(&sp->so_lru);
> 			atomic_inc(&sp->so_count);
> 			return sp;
> 		}
> @@ -453,6 +458,7 @@ nfs4_alloc_state_owner(void)
> 	spin_lock_init(&sp->so_sequence.lock);
> 	INIT_LIST_HEAD(&sp->so_sequence.list);
> 	atomic_set(&sp->so_count, 1);
> +	INIT_LIST_HEAD(&sp->so_lru);
> 	return sp;
> }
> 
> @@ -470,6 +476,37 @@ nfs4_drop_state_owner(struct nfs4_state_owner *sp)
> 	}
> }
> 
> +static void nfs4_free_state_owner(struct nfs4_state_owner *sp)
> +{
> +	rpc_destroy_wait_queue(&sp->so_sequence.wait);
> +	put_rpccred(sp->so_cred);
> +	kfree(sp);
> +}
> +
> +static void nfs4_gc_state_owners(struct nfs_server *server)
> +{
> +	struct nfs_client *clp = server->nfs_client;
> +	struct nfs4_state_owner *sp, *tmp;
> +	unsigned long now = jiffies;
> +	LIST_HEAD(doomed);
> +
> +	spin_lock(&clp->cl_lock);
> +	list_for_each_entry_safe(sp, tmp, &server->state_owners_lru, so_lru) {
> +		/* NB: LRU is sorted so that oldest is at the head */
> +		if (time_in_range(now, sp->so_expires,
> +				sp->so_expires + clp->cl_lease_time))
> +			break;
> +		list_move(&sp->so_lru, &doomed);
> +		nfs4_remove_state_owner_locked(sp);
> +	}
> +	spin_unlock(&clp->cl_lock);
> +
> +	list_for_each_entry_safe(sp, tmp, &doomed, so_lru) {
> +		list_del_init(&sp->so_lru);
> +		nfs4_free_state_owner(sp);
> +	}
> +}
> +
> /**
>  * nfs4_get_state_owner - Look up a state owner given a credential
>  * @server: nfs_server to search
> @@ -487,10 +524,10 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
> 	sp = nfs4_find_state_owner_locked(server, cred);
> 	spin_unlock(&clp->cl_lock);
> 	if (sp != NULL)
> -		return sp;
> +		goto out;
> 	new = nfs4_alloc_state_owner();
> 	if (new == NULL)
> -		return NULL;
> +		goto out;
> 	new->so_server = server;
> 	new->so_cred = cred;
> 	spin_lock(&clp->cl_lock);
> @@ -502,26 +539,58 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
> 		rpc_destroy_wait_queue(&new->so_sequence.wait);
> 		kfree(new);
> 	}
> +out:
> +	nfs4_gc_state_owners(server);
> 	return sp;
> }
> 
> /**
>  * nfs4_put_state_owner - Release a nfs4_state_owner
>  * @sp: state owner data to release
> - *
>  */
> void nfs4_put_state_owner(struct nfs4_state_owner *sp)
> {
> -	struct nfs_client *clp = sp->so_server->nfs_client;
> -	struct rpc_cred *cred = sp->so_cred;
> +	struct nfs_server *server = sp->so_server;
> +	struct nfs_client *clp = server->nfs_client;
> 
> 	if (!atomic_dec_and_lock(&sp->so_count, &clp->cl_lock))
> 		return;
> -	nfs4_remove_state_owner_locked(sp);
> +
> +	if (!RB_EMPTY_NODE(&sp->so_server_node)) {
> +		sp->so_expires = jiffies;
> +		list_move_tail(&sp->so_lru, &server->state_owners_lru);
> +		spin_unlock(&clp->cl_lock);
> +	} else {
> +		nfs4_remove_state_owner_locked(sp);
> +		spin_unlock(&clp->cl_lock);
> +		nfs4_free_state_owner(sp);
> +	}
> +}
> +
> +/**
> + * nfs4_purge_state_owners - Release all cached state owners
> + * @server: nfs_server with cached state owners to release
> + *
> + * Called at umount time.  Remaining state owners will be on
> + * the LRU with ref count of zero.
> + */
> +void nfs4_purge_state_owners(struct nfs_server *server)
> +{
> +	struct nfs_client *clp = server->nfs_client;
> +	struct nfs4_state_owner *sp, *tmp;
> +	LIST_HEAD(doomed);
> +
> +	spin_lock(&clp->cl_lock);
> +	list_for_each_entry_safe(sp, tmp, &server->state_owners_lru, so_lru) {
> +		list_move(&sp->so_lru, &doomed);
> +		nfs4_remove_state_owner_locked(sp);
> +	}
> 	spin_unlock(&clp->cl_lock);
> -	rpc_destroy_wait_queue(&sp->so_sequence.wait);
> -	put_rpccred(cred);
> -	kfree(sp);
> +
> +	list_for_each_entry_safe(sp, tmp, &doomed, so_lru) {
> +		list_del_init(&sp->so_lru);
> +		nfs4_free_state_owner(sp);
> +	}
> }
> 
> static struct nfs4_state *
> @@ -1393,6 +1462,7 @@ static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recov
> restart:
> 	rcu_read_lock();
> 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
> +		nfs4_purge_state_owners(server);
> 		spin_lock(&clp->cl_lock);
> 		for (pos = rb_first(&server->state_owners);
> 		     pos != NULL;
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index b5479df..ba4d765 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -153,6 +153,7 @@ struct nfs_server {
> 	struct rb_root		openowner_id;
> 	struct rb_root		lockowner_id;
> #endif
> +	struct list_head	state_owners_lru;
> 	struct list_head	layouts;
> 	struct list_head	delegations;
> 	void (*destroy)(struct nfs_server *);
> -- 
> 1.7.7.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




