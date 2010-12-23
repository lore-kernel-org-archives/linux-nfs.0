Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:37671 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab0LWWvT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Dec 2010 17:51:19 -0500
Subject: Re: [PATCH 2/4] NFS: Move cl_state_owners and related fields to the nfs_server struct
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1293141874.9718.1.camel@heimdal.trondhjem.org>
Date: Thu, 23 Dec 2010 17:49:20 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <9834C79C-8BB1-4C77-90A1-89545CAA7D4A@oracle.com>
References: <20101223214503.2344.79300.stgit@matisse.1015granger.net> <20101223215425.2344.36322.stgit@matisse.1015granger.net> <1293141874.9718.1.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 23, 2010, at 5:04 PM, Trond Myklebust wrote:

> On Thu, 2010-12-23 at 16:54 -0500, Chuck Lever wrote:
>> NFSv4 migration needs to reassociate state owners from the source to
>> the destination nfs_server data structures.  To make that easier, move
>> the cl_state_owners field to the nfs_server struct.  cl_openowner_id
>> and cl_lockowner_id accompany this move, as they are used in
>> conjunction with cl_state_owners.
>> 
>> The cl_lock field in the parent nfs_client continues to protect all
>> three of these fields.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> fs/nfs/nfs4_fs.h          |    2 
>> fs/nfs/nfs4state.c        |  239 ++++++++++++++++++++++++++++++++-------------
>> include/linux/nfs_fs_sb.h |    9 +-
>> 3 files changed, 177 insertions(+), 73 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>> index 7a6eecf..fa5c5d3 100644
>> --- a/fs/nfs/nfs4_fs.h
>> +++ b/fs/nfs/nfs4_fs.h
>> @@ -109,7 +109,7 @@ struct nfs_unique_id {
>> struct nfs4_state_owner {
>> 	struct nfs_unique_id so_owner_id;
>> 	struct nfs_server    *so_server;
>> -	struct rb_node	     so_client_node;
>> +	struct rb_node	     so_server_node;
>> 
>> 	struct rpc_cred	     *so_cred;	 /* Associated cred */
>> 
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index f575a31..fbcfe72 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -105,14 +105,17 @@ static void nfs4_clear_machine_cred(struct nfs_client *clp)
>> 		put_rpccred(cred);
>> }
>> 
>> -struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
>> +static struct rpc_cred *
>> +nfs4_get_renew_cred_server_locked(struct nfs_server *server)
>> {
>> +	struct rpc_cred *cred = NULL;
>> 	struct nfs4_state_owner *sp;
>> 	struct rb_node *pos;
>> -	struct rpc_cred *cred = NULL;
>> 
>> -	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
>> -		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
>> +	for (pos = rb_first(&server->state_owners);
>> +	     pos != NULL;
>> +	     pos = rb_next(pos)) {
>> +		sp = rb_entry(pos, struct nfs4_state_owner, so_server_node);
>> 		if (list_empty(&sp->so_states))
>> 			continue;
>> 		cred = get_rpccred(sp->so_cred);
>> @@ -121,6 +124,28 @@ struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
>> 	return cred;
>> }
>> 
>> +/**
>> + * nfs4_get_renew_cred_locked - Acquire credential for a renew operation
>> + * @clp: client state handle
>> + *
>> + * Returns an rpc_cred with reference count bumped, or NULL.
>> + * Caller must hold clp->cl_lock.

Here's a case where clp->cl_lock will always be held before we invoke rcu_read_lock().  This is why I tried to take cl_lock first, then invoke rcu_read_lock().  I guess that's not a valid concern.

>> + */
>> +struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
>> +{
>> +	struct rpc_cred *cred = NULL;
>> +	struct nfs_server *server;
>> +
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>> +		cred = nfs4_get_renew_cred_server_locked(server);
>> +		if (cred != NULL)
>> +			break;
>> +	}
>> +	rcu_read_unlock();
>> +	return cred;
>> +}
>> +
>> #if defined(CONFIG_NFS_V4_1)
>> 
>> static int nfs41_setup_state_renewal(struct nfs_client *clp)
>> @@ -210,21 +235,45 @@ struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp)
>> 
>> #endif /* CONFIG_NFS_V4_1 */
>> 
>> -struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
>> +static struct rpc_cred *
>> +nfs4_get_setclientid_cred_server_locked(struct nfs_server *server)
>> {
>> +	struct rpc_cred *cred = NULL;
>> 	struct nfs4_state_owner *sp;
>> 	struct rb_node *pos;
>> +
>> +	pos = rb_first(&server->state_owners);
>> +	if (pos != NULL) {
>> +		sp = rb_entry(pos, struct nfs4_state_owner, so_server_node);
>> +		cred = get_rpccred(sp->so_cred);
>> +	}
>> +	return cred;
>> +}
>> +
>> +/**
>> + * nfs4_get_setclientid_cred - Acquire credential for a setclientid operation
>> + * @clp: client state handle
>> + *
>> + * Returns an rpc_cred with reference count bumped, or NULL.
>> + */
>> +struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
>> +{
>> +	struct nfs_server *server;
>> 	struct rpc_cred *cred;
>> 
>> 	spin_lock(&clp->cl_lock);
>> 	cred = nfs4_get_machine_cred_locked(clp);
>> 	if (cred != NULL)
>> 		goto out;
>> -	pos = rb_first(&clp->cl_state_owners);
>> -	if (pos != NULL) {
>> -		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
>> -		cred = get_rpccred(sp->so_cred);
>> +
>> +	rcu_read_lock();
> 
> Here's another rcu_read_lock() nested inside a spin locked section.

In this case, we're already holding cl_lock in order to call nfs4_get_machine_cred_locked().  Is it worth the extra logic to release the lock and then grab it repeatedly in the loop?

> 
>> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>> +		cred = nfs4_get_setclientid_cred_server_locked(server);
>> +		if (cred != NULL)
>> +			break;
>> 	}
>> +	rcu_read_unlock();
>> +
>> out:
>> 	spin_unlock(&clp->cl_lock);
>> 	return cred;
>> @@ -286,16 +335,15 @@ static void nfs_free_unique_id(struct rb_root *root, struct nfs_unique_id *id)
>> }
>> 
>> static struct nfs4_state_owner *
>> -nfs4_find_state_owner(struct nfs_server *server, struct rpc_cred *cred)
>> +nfs4_find_state_owner_locked(struct nfs_server *server, struct rpc_cred *cred)
>> {
>> -	struct nfs_client *clp = server->nfs_client;
>> -	struct rb_node **p = &clp->cl_state_owners.rb_node,
>> +	struct rb_node **p = &server->state_owners.rb_node,
>> 		       *parent = NULL;
>> 	struct nfs4_state_owner *sp, *res = NULL;
>> 
>> 	while (*p != NULL) {
>> 		parent = *p;
>> -		sp = rb_entry(parent, struct nfs4_state_owner, so_client_node);
>> +		sp = rb_entry(parent, struct nfs4_state_owner, so_server_node);
>> 
>> 		if (server < sp->so_server) {
>> 			p = &parent->rb_left;
>> @@ -319,24 +367,17 @@ nfs4_find_state_owner(struct nfs_server *server, struct rpc_cred *cred)
>> }
>> 
>> static struct nfs4_state_owner *
>> -nfs4_insert_state_owner(struct nfs_client *clp, struct nfs4_state_owner *new)
>> +nfs4_insert_state_owner_locked(struct nfs4_state_owner *new)
>> {
>> -	struct rb_node **p = &clp->cl_state_owners.rb_node,
>> +	struct nfs_server *server = new->so_server;
>> +	struct rb_node **p = &server->state_owners.rb_node,
>> 		       *parent = NULL;
>> 	struct nfs4_state_owner *sp;
>> 
>> 	while (*p != NULL) {
>> 		parent = *p;
>> -		sp = rb_entry(parent, struct nfs4_state_owner, so_client_node);
>> +		sp = rb_entry(parent, struct nfs4_state_owner, so_server_node);
>> 
>> -		if (new->so_server < sp->so_server) {
>> -			p = &parent->rb_left;
>> -			continue;
>> -		}
>> -		if (new->so_server > sp->so_server) {
>> -			p = &parent->rb_right;
>> -			continue;
>> -		}
>> 		if (new->so_cred < sp->so_cred)
>> 			p = &parent->rb_left;
>> 		else if (new->so_cred > sp->so_cred)
>> @@ -346,18 +387,20 @@ nfs4_insert_state_owner(struct nfs_client *clp, struct nfs4_state_owner *new)
>> 			return sp;
>> 		}
>> 	}
>> -	nfs_alloc_unique_id(&clp->cl_openowner_id, &new->so_owner_id, 1, 64);
>> -	rb_link_node(&new->so_client_node, parent, p);
>> -	rb_insert_color(&new->so_client_node, &clp->cl_state_owners);
>> +	nfs_alloc_unique_id(&server->openowner_id, &new->so_owner_id, 1, 64);
>> +	rb_link_node(&new->so_server_node, parent, p);
>> +	rb_insert_color(&new->so_server_node, &server->state_owners);
>> 	return new;
>> }
>> 
>> static void
>> -nfs4_remove_state_owner(struct nfs_client *clp, struct nfs4_state_owner *sp)
>> +nfs4_remove_state_owner_locked(struct nfs4_state_owner *sp)
>> {
>> -	if (!RB_EMPTY_NODE(&sp->so_client_node))
>> -		rb_erase(&sp->so_client_node, &clp->cl_state_owners);
>> -	nfs_free_unique_id(&clp->cl_openowner_id, &sp->so_owner_id);
>> +	struct nfs_server *server = sp->so_server;
>> +
>> +	if (!RB_EMPTY_NODE(&sp->so_server_node))
>> +		rb_erase(&sp->so_server_node, &server->state_owners);
>> +	nfs_free_unique_id(&server->openowner_id, &sp->so_owner_id);
>> }
>> 
>> /*
>> @@ -386,23 +429,32 @@ nfs4_alloc_state_owner(void)
>> static void
>> nfs4_drop_state_owner(struct nfs4_state_owner *sp)
>> {
>> -	if (!RB_EMPTY_NODE(&sp->so_client_node)) {
>> -		struct nfs_client *clp = sp->so_server->nfs_client;
>> +	if (!RB_EMPTY_NODE(&sp->so_server_node)) {
>> +		struct nfs_server *server = sp->so_server;
>> +		struct nfs_client *clp = server->nfs_client;
>> 
>> 		spin_lock(&clp->cl_lock);
>> -		rb_erase(&sp->so_client_node, &clp->cl_state_owners);
>> -		RB_CLEAR_NODE(&sp->so_client_node);
>> +		rb_erase(&sp->so_server_node, &server->state_owners);
>> +		RB_CLEAR_NODE(&sp->so_server_node);
>> 		spin_unlock(&clp->cl_lock);
>> 	}
>> }
>> 
>> -struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server, struct rpc_cred *cred)
>> +/**
>> + * nfs4_get_state_owner - Look up a state owner given a credential
>> + * @server: nfs_server to search
>> + * @cred: RPC credential to match
>> + *
>> + * Returns a pointer to an instantiated nfs4_state_owner struct, or NULL.
>> + */
>> +struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
>> +					      struct rpc_cred *cred)
>> {
>> 	struct nfs_client *clp = server->nfs_client;
>> 	struct nfs4_state_owner *sp, *new;
>> 
>> 	spin_lock(&clp->cl_lock);
>> -	sp = nfs4_find_state_owner(server, cred);
>> +	sp = nfs4_find_state_owner_locked(server, cred);
>> 	spin_unlock(&clp->cl_lock);
>> 	if (sp != NULL)
>> 		return sp;
>> @@ -412,7 +464,7 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server, struct
>> 	new->so_server = server;
>> 	new->so_cred = cred;
>> 	spin_lock(&clp->cl_lock);
>> -	sp = nfs4_insert_state_owner(clp, new);
>> +	sp = nfs4_insert_state_owner_locked(new);
>> 	spin_unlock(&clp->cl_lock);
>> 	if (sp == new)
>> 		get_rpccred(cred);
>> @@ -423,6 +475,11 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server, struct
>> 	return sp;
>> }
>> 
>> +/**
>> + * nfs4_put_state_owner - Release a nfs4_state_owner
>> + * @sp: state owner data to release
>> + *
>> + */
>> void nfs4_put_state_owner(struct nfs4_state_owner *sp)
>> {
>> 	struct nfs_client *clp = sp->so_server->nfs_client;
>> @@ -430,7 +487,7 @@ void nfs4_put_state_owner(struct nfs4_state_owner *sp)
>> 
>> 	if (!atomic_dec_and_lock(&sp->so_count, &clp->cl_lock))
>> 		return;
>> -	nfs4_remove_state_owner(clp, sp);
>> +	nfs4_remove_state_owner_locked(sp);
>> 	spin_unlock(&clp->cl_lock);
>> 	rpc_destroy_wait_queue(&sp->so_sequence.wait);
>> 	put_rpccred(cred);
>> @@ -633,7 +690,8 @@ __nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_p
>> static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_pid, unsigned int type)
>> {
>> 	struct nfs4_lock_state *lsp;
>> -	struct nfs_client *clp = state->owner->so_server->nfs_client;
>> +	struct nfs_server *server = state->owner->so_server;
>> +	struct nfs_client *clp = server->nfs_client;
>> 
>> 	lsp = kzalloc(sizeof(*lsp), GFP_NOFS);
>> 	if (lsp == NULL)
>> @@ -657,7 +715,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
>> 		return NULL;
>> 	}
>> 	spin_lock(&clp->cl_lock);
>> -	nfs_alloc_unique_id(&clp->cl_lockowner_id, &lsp->ls_id, 1, 64);
>> +	nfs_alloc_unique_id(&server->lockowner_id, &lsp->ls_id, 1, 64);
>> 	spin_unlock(&clp->cl_lock);
>> 	INIT_LIST_HEAD(&lsp->ls_locks);
>> 	return lsp;
>> @@ -665,10 +723,11 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
>> 
>> static void nfs4_free_lock_state(struct nfs4_lock_state *lsp)
>> {
>> -	struct nfs_client *clp = lsp->ls_state->owner->so_server->nfs_client;
>> +	struct nfs_server *server = lsp->ls_state->owner->so_server;
>> +	struct nfs_client *clp = server->nfs_client;
>> 
>> 	spin_lock(&clp->cl_lock);
>> -	nfs_free_unique_id(&clp->cl_lockowner_id, &lsp->ls_id);
>> +	nfs_free_unique_id(&server->lockowner_id, &lsp->ls_id);
>> 	spin_unlock(&clp->cl_lock);
>> 	rpc_destroy_wait_queue(&lsp->ls_sequence.wait);
>> 	kfree(lsp);
>> @@ -1114,25 +1173,40 @@ static void nfs4_clear_open_state(struct nfs4_state *state)
>> 	}
>> }
>> 
>> -static void nfs4_state_mark_reclaim_helper(struct nfs_client *clp, int (*mark_reclaim)(struct nfs_client *clp, struct nfs4_state *state))
>> +static void nfs4_reset_seqids_locked(struct nfs_server *server,
>> +	int (*mark_reclaim)(struct nfs_client *clp, struct nfs4_state *state))
>> {
>> 	struct nfs4_state_owner *sp;
>> 	struct rb_node *pos;
>> 	struct nfs4_state *state;
>> 
>> -	/* Reset all sequence ids to zero */
>> -	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
>> -		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
>> +	for (pos = rb_first(&server->state_owners);
>> +	     pos != NULL;
>> +	     pos = rb_next(pos)) {
>> +		sp = rb_entry(pos, struct nfs4_state_owner, so_server_node);
>> 		sp->so_seqid.flags = 0;
>> 		spin_lock(&sp->so_lock);
>> 		list_for_each_entry(state, &sp->so_states, open_states) {
>> -			if (mark_reclaim(clp, state))
>> +			if (mark_reclaim(server->nfs_client, state))
>> 				nfs4_clear_open_state(state);
>> 		}
>> 		spin_unlock(&sp->so_lock);
>> 	}
>> }
>> 
>> +static void nfs4_state_mark_reclaim_helper(struct nfs_client *clp,
>> +	int (*mark_reclaim)(struct nfs_client *clp, struct nfs4_state *state))
>> +{
>> +	struct nfs_server *server;
>> +
>> +	spin_lock(&clp->cl_lock);
>> +	rcu_read_lock();
> 
> Ditto.

One begins to wonder if we should have a per-nfs_server lock for the state_owners fields, instead of re-using cl_lock.  Such a lock would probably have to protect sp->so_cred as well.

> 
>> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
>> +		nfs4_reset_seqids_locked(server, mark_reclaim);
>> +	rcu_read_unlock();
>> +	spin_unlock(&clp->cl_lock);
>> +}
>> +
>> static void nfs4_state_start_reclaim_reboot(struct nfs_client *clp)
>> {
>> 	/* Mark all delegations for reclaim */
>> @@ -1148,26 +1222,42 @@ static void nfs4_reclaim_complete(struct nfs_client *clp,
>> 		(void)ops->reclaim_complete(clp);
>> }
>> 
>> -static int nfs4_state_clear_reclaim_reboot(struct nfs_client *clp)
>> +static void nfs4_clear_reclaim_server_locked(struct nfs_server *server)
>> {
>> 	struct nfs4_state_owner *sp;
>> 	struct rb_node *pos;
>> 	struct nfs4_state *state;
>> 
>> -	if (!test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
>> -		return 0;
>> -
>> -	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
>> -		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
>> +	for (pos = rb_first(&server->state_owners);
>> +	     pos != NULL;
>> +	     pos = rb_next(pos)) {
>> +		sp = rb_entry(pos, struct nfs4_state_owner, so_server_node);
>> 		spin_lock(&sp->so_lock);
>> 		list_for_each_entry(state, &sp->so_states, open_states) {
>> -			if (!test_and_clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags))
>> +			if (!test_and_clear_bit(NFS_STATE_RECLAIM_REBOOT,
>> +						&state->flags))
>> 				continue;
>> -			nfs4_state_mark_reclaim_nograce(clp, state);
>> +			nfs4_state_mark_reclaim_nograce(server->nfs_client,
>> +							state);
>> 		}
>> 		spin_unlock(&sp->so_lock);
>> 	}
>> 
>> +}
>> +
>> +static int nfs4_state_clear_reclaim_reboot(struct nfs_client *clp)
>> +{
>> +	struct nfs_server *server;
>> +
>> +	if (!test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
>> +		return 0;
>> +
>> +	spin_lock(&clp->cl_lock);
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
>> +		nfs4_clear_reclaim_server_locked(server);
>> +	rcu_read_unlock();
> 
> Ditto
> 
>> +	spin_unlock(&clp->cl_lock);
>> 	nfs_delegation_reap_unclaimed(clp);
>> 	return 1;
>> }
>> @@ -1238,26 +1328,39 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
>> 
>> static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recovery_ops *ops)
>> {
>> +	struct nfs4_state_owner *sp;
>> +	struct nfs_server *server;
>> 	struct rb_node *pos;
>> 	int status = 0;
>> 
>> restart:
>> 	spin_lock(&clp->cl_lock);
>> -	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
>> -		struct nfs4_state_owner *sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
>> -		if (!test_and_clear_bit(ops->owner_flag_bit, &sp->so_flags))
>> -			continue;
>> -		atomic_inc(&sp->so_count);
>> -		spin_unlock(&clp->cl_lock);
>> -		status = nfs4_reclaim_open_state(sp, ops);
>> -		if (status < 0) {
>> -			set_bit(ops->owner_flag_bit, &sp->so_flags);
>> +	rcu_read_lock();
> 
> Ditto.
>> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>> +		for (pos = rb_first(&server->state_owners);
>> +		     pos != NULL;
>> +		     pos = rb_next(pos)) {
>> +			sp = rb_entry(pos,
>> +				struct nfs4_state_owner, so_server_node);
>> +			if (!test_and_clear_bit(ops->owner_flag_bit,
>> +							&sp->so_flags))
>> +				continue;
>> +			atomic_inc(&sp->so_count);
>> +			rcu_read_unlock();
>> +			spin_unlock(&clp->cl_lock);
>> +
>> +			status = nfs4_reclaim_open_state(sp, ops);
>> +			if (status < 0) {
>> +				set_bit(ops->owner_flag_bit, &sp->so_flags);
>> +				nfs4_put_state_owner(sp);
>> +				return nfs4_recovery_handle_error(clp, status);
>> +			}
>> +
>> 			nfs4_put_state_owner(sp);
>> -			return nfs4_recovery_handle_error(clp, status);
>> +			goto restart;
>> 		}
>> -		nfs4_put_state_owner(sp);
>> -		goto restart;
>> 	}
>> +	rcu_read_unlock();
>> 	spin_unlock(&clp->cl_lock);
>> 	return status;
>> }
>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>> index 452d964..e96ec55 100644
>> --- a/include/linux/nfs_fs_sb.h
>> +++ b/include/linux/nfs_fs_sb.h
>> @@ -47,11 +47,7 @@ struct nfs_client {
>> 	u64			cl_clientid;	/* constant */
>> 	unsigned long		cl_state;
>> 
>> -	struct rb_root		cl_openowner_id;
>> -	struct rb_root		cl_lockowner_id;
>> -
>> 	struct list_head	cl_delegations;
>> -	struct rb_root		cl_state_owners;
>> 	spinlock_t		cl_lock;
>> 
>> 	unsigned long		cl_lease_time;
>> @@ -148,6 +144,11 @@ struct nfs_server {
>> 						   that are supported on this
>> 						   filesystem */
>> 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
>> +
>> +	/* the following fields are protected by nfs_client->cl_lock */
>> +	struct rb_root		state_owners;
>> +	struct rb_root		openowner_id;
>> +	struct rb_root		lockowner_id;
>> #endif
>> 	void (*destroy)(struct nfs_server *);
>> 
>> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




