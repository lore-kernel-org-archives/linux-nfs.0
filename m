Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56513 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751468Ab0LWX2D convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Dec 2010 18:28:03 -0500
Subject: Re: [PATCH 2/4] NFS: Move cl_state_owners and related fields to
 the nfs_server struct
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <9834C79C-8BB1-4C77-90A1-89545CAA7D4A@oracle.com>
References: <20101223214503.2344.79300.stgit@matisse.1015granger.net>
	 <20101223215425.2344.36322.stgit@matisse.1015granger.net>
	 <1293141874.9718.1.camel@heimdal.trondhjem.org>
	 <9834C79C-8BB1-4C77-90A1-89545CAA7D4A@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 23 Dec 2010 18:27:45 -0500
Message-ID: <1293146865.11068.5.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-23 at 17:49 -0500, Chuck Lever wrote:
> On Dec 23, 2010, at 5:04 PM, Trond Myklebust wrote:
> 
> > On Thu, 2010-12-23 at 16:54 -0500, Chuck Lever wrote:
> >> NFSv4 migration needs to reassociate state owners from the source to
> >> the destination nfs_server data structures.  To make that easier, move
> >> the cl_state_owners field to the nfs_server struct.  cl_openowner_id
> >> and cl_lockowner_id accompany this move, as they are used in
> >> conjunction with cl_state_owners.
> >> 
> >> The cl_lock field in the parent nfs_client continues to protect all
> >> three of these fields.
> >> 
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> 
> >> fs/nfs/nfs4_fs.h          |    2 
> >> fs/nfs/nfs4state.c        |  239 ++++++++++++++++++++++++++++++++-------------
> >> include/linux/nfs_fs_sb.h |    9 +-
> >> 3 files changed, 177 insertions(+), 73 deletions(-)
> >> 
> >> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> >> index 7a6eecf..fa5c5d3 100644
> >> --- a/fs/nfs/nfs4_fs.h
> >> +++ b/fs/nfs/nfs4_fs.h
> >> @@ -109,7 +109,7 @@ struct nfs_unique_id {
> >> struct nfs4_state_owner {
> >> 	struct nfs_unique_id so_owner_id;
> >> 	struct nfs_server    *so_server;
> >> -	struct rb_node	     so_client_node;
> >> +	struct rb_node	     so_server_node;
> >> 
> >> 	struct rpc_cred	     *so_cred;	 /* Associated cred */
> >> 
> >> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> >> index f575a31..fbcfe72 100644
> >> --- a/fs/nfs/nfs4state.c
> >> +++ b/fs/nfs/nfs4state.c
> >> @@ -105,14 +105,17 @@ static void nfs4_clear_machine_cred(struct nfs_client *clp)
> >> 		put_rpccred(cred);
> >> }
> >> 
> >> -struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
> >> +static struct rpc_cred *
> >> +nfs4_get_renew_cred_server_locked(struct nfs_server *server)
> >> {
> >> +	struct rpc_cred *cred = NULL;
> >> 	struct nfs4_state_owner *sp;
> >> 	struct rb_node *pos;
> >> -	struct rpc_cred *cred = NULL;
> >> 
> >> -	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
> >> -		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
> >> +	for (pos = rb_first(&server->state_owners);
> >> +	     pos != NULL;
> >> +	     pos = rb_next(pos)) {
> >> +		sp = rb_entry(pos, struct nfs4_state_owner, so_server_node);
> >> 		if (list_empty(&sp->so_states))
> >> 			continue;
> >> 		cred = get_rpccred(sp->so_cred);
> >> @@ -121,6 +124,28 @@ struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
> >> 	return cred;
> >> }
> >> 
> >> +/**
> >> + * nfs4_get_renew_cred_locked - Acquire credential for a renew operation
> >> + * @clp: client state handle
> >> + *
> >> + * Returns an rpc_cred with reference count bumped, or NULL.
> >> + * Caller must hold clp->cl_lock.
> 
> Here's a case where clp->cl_lock will always be held before we invoke rcu_read_lock().  This is why I tried to take cl_lock first, then invoke rcu_read_lock().  I guess that's not a valid concern.
> 
> >> + */
> >> +struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
> >> +{
> >> +	struct rpc_cred *cred = NULL;
> >> +	struct nfs_server *server;
> >> +
> >> +	rcu_read_lock();
> >> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
> >> +		cred = nfs4_get_renew_cred_server_locked(server);
> >> +		if (cred != NULL)
> >> +			break;
> >> +	}
> >> +	rcu_read_unlock();
> >> +	return cred;
> >> +}
> >> +
> >> #if defined(CONFIG_NFS_V4_1)
> >> 
> >> static int nfs41_setup_state_renewal(struct nfs_client *clp)
> >> @@ -210,21 +235,45 @@ struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp)
> >> 
> >> #endif /* CONFIG_NFS_V4_1 */
> >> 
> >> -struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
> >> +static struct rpc_cred *
> >> +nfs4_get_setclientid_cred_server_locked(struct nfs_server *server)
> >> {
> >> +	struct rpc_cred *cred = NULL;
> >> 	struct nfs4_state_owner *sp;
> >> 	struct rb_node *pos;
> >> +
> >> +	pos = rb_first(&server->state_owners);
> >> +	if (pos != NULL) {
> >> +		sp = rb_entry(pos, struct nfs4_state_owner, so_server_node);
> >> +		cred = get_rpccred(sp->so_cred);
> >> +	}
> >> +	return cred;
> >> +}
> >> +
> >> +/**
> >> + * nfs4_get_setclientid_cred - Acquire credential for a setclientid operation
> >> + * @clp: client state handle
> >> + *
> >> + * Returns an rpc_cred with reference count bumped, or NULL.
> >> + */
> >> +struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
> >> +{
> >> +	struct nfs_server *server;
> >> 	struct rpc_cred *cred;
> >> 
> >> 	spin_lock(&clp->cl_lock);
> >> 	cred = nfs4_get_machine_cred_locked(clp);
> >> 	if (cred != NULL)
> >> 		goto out;
> >> -	pos = rb_first(&clp->cl_state_owners);
> >> -	if (pos != NULL) {
> >> -		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
> >> -		cred = get_rpccred(sp->so_cred);
> >> +
> >> +	rcu_read_lock();
> > 
> > Here's another rcu_read_lock() nested inside a spin locked section.
> 
> In this case, we're already holding cl_lock in order to call nfs4_get_machine_cred_locked().  Is it worth the extra logic to release the lock and then grab it repeatedly in the loop?

I'd prefer to just see the rcu_read_lock() moved outside the spin lock
in situations like this. Doing so shouldn't make a difference to the
performance, but it looks neater.

There are a couple of comments in code elsewhere that say that you
shouldn't rely on rcu_read_lock() being the same as preempt_disable(),
so I suppose we shouldn't get rid of it altogether.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

