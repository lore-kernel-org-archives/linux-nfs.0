Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:64437 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936AbaGCLUP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 07:20:15 -0400
Received: by mail-qg0-f46.google.com with SMTP id q107so45901qgd.5
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jul 2014 04:20:14 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 3 Jul 2014 07:20:12 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 004/114] nfsd: Avoid taking state_lock while holding
 inode lock in nfsd_break_one_deleg
Message-ID: <20140703072012.74b78c49@tlielax.poochiereds.net>
In-Reply-To: <20140702211424.GD11510@fieldses.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
	<1404143423-24381-5-git-send-email-jlayton@primarydata.com>
	<20140702211424.GD11510@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2 Jul 2014 17:14:24 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jun 30, 2014 at 11:48:33AM -0400, Jeff Layton wrote:
> > state_lock is a heavily contended global lock. We don't want to grab
> > that while simultaneously holding the inode->i_lock.
> > 
> > Add a new per-nfs4_file lock that we can use to protect the
> > per-nfs4_file delegation list. Hold that while walking the list in the
> > break_deleg callback and queue the workqueue job for each one.
> > 
> > The workqueue job can then take the state_lock and do the list
> > manipulations without the i_lock being held prior to starting the
> > rpc call.
> 
> The code tends to assume that the callback thread only works with the
> delegation struct itself and puts it when done but doesn't otherwise
> touch other state.
> 
> I wonder how this interacts with state shutdown.... 
> 
> E.g. in nfs4_state_shutdown_net() we walk the dl_recall_lru and destroy
> everything we find, but this callback workqueue is still running so I
> think another delegation could get added to that list after this?  Does
> that cause bugs?
> 

I don't see what would prevent those bugs today and I'm unclear on why
you think this patch will make things worse. All this patch really does
is protect the dl_perfile list manipulations with a new per-nfs4_file
lock, and have it lock that when walking the perfile list. Then it has
the workqueue callback do the work of adding it to the del_recall_lru
list.

Why wouldn't you have the same problem if you do the queueing to the
LRU list in break_deleg codepath with the code as it is today?

That said, the delegation code is horribly complex so it's possible
I've missed something here.

> And it'd also be worth checking delegreturn and destroy_client.
> 
> Maybe there's no bug, or they just need to flush the workqueue at the
> appropriate point.
> 
> There's also a preexisting expire_client/laundromat vs break race:
> 
> 	- expire_client/laundromat adds a delegation to its local
> 	  reaplist using the same dl_recall_lru field that a delegation
> 	  uses to track its position on the recall lru and drops the
> 	  state lock.
> 
> 	- a concurrent break_lease adds the delegation to the lru.
> 
> 	- expire/client/laundromat then walks it reaplist and sees the
> 	  lru head as just another delegation on the list....
> 
> Possibly unrelated, but it might be good to fix that first.
> 
> --b.
> 

I was thinking that that would be fixed up in a later patch:

    nfsd: Fix delegation revocation

...but now I'm not so sure. Once you drop the fi_lock, you could end up
with the race above.

Honestly, the locking around the delegation code is still a mess, even
with this series. I don't care much for the state_lock/recall_lock at
all. It seems like we ought to be able to do something more granular
there. Let me give it some thought -- maybe I can come up with a better
way to handle this.


> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  fs/nfsd/nfs4callback.c | 28 +++++++++++++++++++++-------
> >  fs/nfsd/nfs4state.c    | 43 ++++++++++++++++++++++++++++---------------
> >  fs/nfsd/state.h        |  2 ++
> >  3 files changed, 51 insertions(+), 22 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > index 00cb9b7a75f6..cba4ca375f5e 100644
> > --- a/fs/nfsd/nfs4callback.c
> > +++ b/fs/nfsd/nfs4callback.c
> > @@ -43,7 +43,7 @@
> >  #define NFSDDBG_FACILITY                NFSDDBG_PROC
> >  
> >  static void nfsd4_mark_cb_fault(struct nfs4_client *, int reason);
> > -static void nfsd4_do_callback_rpc(struct work_struct *w);
> > +static void nfsd4_run_cb_null(struct work_struct *w);
> >  
> >  #define NFSPROC4_CB_NULL 0
> >  #define NFSPROC4_CB_COMPOUND 1
> > @@ -764,7 +764,7 @@ static void do_probe_callback(struct nfs4_client *clp)
> >  
> >  	cb->cb_ops = &nfsd4_cb_probe_ops;
> >  
> > -	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
> > +	INIT_WORK(&cb->cb_work, nfsd4_run_cb_null);
> >  
> >  	run_nfsd4_cb(cb);
> >  }
> > @@ -936,7 +936,7 @@ void nfsd4_shutdown_callback(struct nfs4_client *clp)
> >  	set_bit(NFSD4_CLIENT_CB_KILL, &clp->cl_flags);
> >  	/*
> >  	 * Note this won't actually result in a null callback;
> > -	 * instead, nfsd4_do_callback_rpc() will detect the killed
> > +	 * instead, nfsd4_run_cb_null() will detect the killed
> >  	 * client, destroy the rpc client, and stop:
> >  	 */
> >  	do_probe_callback(clp);
> > @@ -1014,9 +1014,8 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
> >  		run_nfsd4_cb(cb);
> >  }
> >  
> > -static void nfsd4_do_callback_rpc(struct work_struct *w)
> > +static void nfsd4_run_callback_rpc(struct nfsd4_callback *cb)
> >  {
> > -	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
> >  	struct nfs4_client *clp = cb->cb_clp;
> >  	struct rpc_clnt *clnt;
> >  
> > @@ -1034,6 +1033,22 @@ static void nfsd4_do_callback_rpc(struct work_struct *w)
> >  			cb->cb_ops, cb);
> >  }
> >  
> > +static void nfsd4_run_cb_null(struct work_struct *w)
> > +{
> > +	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback,
> > +							cb_work);
> > +	nfsd4_run_callback_rpc(cb);
> > +}
> > +
> > +static void nfsd4_run_cb_recall(struct work_struct *w)
> > +{
> > +	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback,
> > +							cb_work);
> > +
> > +	nfsd4_prepare_cb_recall(cb->cb_op);
> > +	nfsd4_run_callback_rpc(cb);
> > +}
> > +
> >  void nfsd4_cb_recall(struct nfs4_delegation *dp)
> >  {
> >  	struct nfsd4_callback *cb = &dp->dl_recall;
> > @@ -1050,8 +1065,7 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
> >  
> >  	INIT_LIST_HEAD(&cb->cb_per_client);
> >  	cb->cb_done = true;
> > -
> > -	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
> > +	INIT_WORK(&cb->cb_work, nfsd4_run_cb_recall);
> >  
> >  	run_nfsd4_cb(&dp->dl_recall);
> >  }
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index b49b46b0ce23..461229a01963 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -513,7 +513,9 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
> >  	lockdep_assert_held(&state_lock);
> >  
> >  	dp->dl_stid.sc_type = NFS4_DELEG_STID;
> > +	spin_lock(&fp->fi_lock);
> >  	list_add(&dp->dl_perfile, &fp->fi_delegations);
> > +	spin_unlock(&fp->fi_lock);
> >  	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
> >  }
> >  
> > @@ -521,14 +523,18 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
> >  static void
> >  unhash_delegation(struct nfs4_delegation *dp)
> >  {
> > +	struct nfs4_file *fp = dp->dl_file;
> > +
> >  	spin_lock(&state_lock);
> >  	list_del_init(&dp->dl_perclnt);
> > -	list_del_init(&dp->dl_perfile);
> >  	list_del_init(&dp->dl_recall_lru);
> > +	spin_lock(&fp->fi_lock);
> > +	list_del_init(&dp->dl_perfile);
> > +	spin_unlock(&fp->fi_lock);
> >  	spin_unlock(&state_lock);
> > -	if (dp->dl_file) {
> > -		nfs4_put_deleg_lease(dp->dl_file);
> > -		put_nfs4_file(dp->dl_file);
> > +	if (fp) {
> > +		nfs4_put_deleg_lease(fp);
> > +		put_nfs4_file(fp);
> >  		dp->dl_file = NULL;
> >  	}
> >  }
> > @@ -2612,6 +2618,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
> >  	lockdep_assert_held(&state_lock);
> >  
> >  	atomic_set(&fp->fi_ref, 1);
> > +	spin_lock_init(&fp->fi_lock);
> >  	INIT_LIST_HEAD(&fp->fi_stateids);
> >  	INIT_LIST_HEAD(&fp->fi_delegations);
> >  	ihold(ino);
> > @@ -2857,26 +2864,32 @@ out:
> >  	return ret;
> >  }
> >  
> > -static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
> > +void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
> >  {
> >  	struct nfs4_client *clp = dp->dl_stid.sc_client;
> >  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> >  
> > -	lockdep_assert_held(&state_lock);
> > +	/*
> > +	 * We can't do this in nfsd_break_deleg_cb because it is
> > +	 * already holding inode->i_lock
> > +	 */
> > +	spin_lock(&state_lock);
> > +	if (list_empty(&dp->dl_recall_lru)) {
> > +		dp->dl_time = get_seconds();
> > +		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
> > +	}
> > +	spin_unlock(&state_lock);
> > +}
> > +
> > +static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
> > +{
> >  	/* We're assuming the state code never drops its reference
> >  	 * without first removing the lease.  Since we're in this lease
> >  	 * callback (and since the lease code is serialized by the kernel
> >  	 * lock) we know the server hasn't removed the lease yet, we know
> >  	 * it's safe to take a reference: */
> >  	atomic_inc(&dp->dl_count);
> > -
> > -	list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
> > -
> > -	/* Only place dl_time is set; protected by i_lock: */
> > -	dp->dl_time = get_seconds();
> > -
> >  	block_delegations(&dp->dl_fh);
> > -
> >  	nfsd4_cb_recall(dp);
> >  }
> >  
> > @@ -2901,11 +2914,11 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
> >  	 */
> >  	fl->fl_break_time = 0;
> >  
> > -	spin_lock(&state_lock);
> >  	fp->fi_had_conflict = true;
> > +	spin_lock(&fp->fi_lock);
> >  	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
> >  		nfsd_break_one_deleg(dp);
> > -	spin_unlock(&state_lock);
> > +	spin_unlock(&fp->fi_lock);
> >  }
> >  
> >  static
> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > index 9447f86f2778..7d6ba06c1abe 100644
> > --- a/fs/nfsd/state.h
> > +++ b/fs/nfsd/state.h
> > @@ -382,6 +382,7 @@ static inline struct nfs4_lockowner * lockowner(struct nfs4_stateowner *so)
> >  /* nfs4_file: a file opened by some number of (open) nfs4_stateowners. */
> >  struct nfs4_file {
> >  	atomic_t		fi_ref;
> > +	spinlock_t		fi_lock;
> >  	struct hlist_node       fi_hash;    /* hash by "struct inode *" */
> >  	struct list_head        fi_stateids;
> >  	struct list_head	fi_delegations;
> > @@ -471,6 +472,7 @@ extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
> >  extern int nfsd4_create_callback_queue(void);
> >  extern void nfsd4_destroy_callback_queue(void);
> >  extern void nfsd4_shutdown_callback(struct nfs4_client *);
> > +extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
> >  extern void nfs4_put_delegation(struct nfs4_delegation *dp);
> >  extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
> >  							struct nfsd_net *nn);
> > -- 
> > 1.9.3
> > 


-- 
Jeff Layton <jlayton@primarydata.com>
