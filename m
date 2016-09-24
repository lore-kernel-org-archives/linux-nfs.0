Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f181.google.com ([209.85.213.181]:35359 "EHLO
        mail-yb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760957AbcIXAnr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2016 20:43:47 -0400
Received: by mail-yb0-f181.google.com with SMTP id d69so73210584ybf.2
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2016 17:43:47 -0700 (PDT)
Message-ID: <1474677824.29585.11.camel@redhat.com>
Subject: Re: [PATCH v3 2/5] nfsd: have nfsd4_lock use blocking locks for
 v4.1+ locks
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Date: Fri, 23 Sep 2016 20:43:44 -0400
In-Reply-To: <20160923211901.GB9998@fieldses.org>
References: <1474057707-31286-1-git-send-email-jlayton@redhat.com>
         <1474057707-31286-3-git-send-email-jlayton@redhat.com>
         <20160923211901.GB9998@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-09-23 at 17:19 -0400, J. Bruce Fields wrote:
> On Fri, Sep 16, 2016 at 04:28:24PM -0400, Jeff Layton wrote:
> > 
> > Create a new per-lockowner+per-inode structure that contains a
> > file_lock. Have nfsd4_lock add this structure to the lockowner's list
> > prior to setting the lock. Then call the vfs and request a blocking lock
> > (by setting FL_SLEEP). If we get anything besides FILE_LOCK_DEFERRED
> 
> That doesn't sound right.  FILE_LOCK_DEFERRED is a special case for
> asynchronous locking--it means "I don't know whether there's a conflict
> or not, it may take a while to check", not "there's a conflict".
> 
> (Ugh.  I apologize for the asynchronous locking code.)
> 
> --b.
> 

The local file locking code definitely uses this return code to mean
"This lock is blocked, and I'll call your lm_notify when it's
unblocked", which is exactly what we rely on here.

There is a place that uses it in the way you mention though, and that is
when DLM and svc lockd are interacting via dlm_posix_lock(). lockd can't
be in play here since this is all NFSv4, so I think the code does handle
this correctly.

That said...maybe should probably think about some way to disambiguate
those two states in the return code. It is horribly confusing.
 
> > back, then we dequeue the block structure and free it. When the next
> > lock request comes in, we'll look for an existing block for the same
> > filehandle and dequeue and reuse it if there is one.
> > 
> > When the lock comes free (a'la an lm_notify call), we dequeue it
> > from the lockowner's list and kick off a CB_NOTIFY_LOCK callback to
> > inform the client that it should retry the lock request.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfsd/nfs4state.c | 164 ++++++++++++++++++++++++++++++++++++++++++++++------
> >  fs/nfsd/state.h     |  12 +++-
> >  2 files changed, 156 insertions(+), 20 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index a204d7e109d4..ca0db4974e5b 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -99,6 +99,7 @@ static struct kmem_cache *odstate_slab;
> >  static void free_session(struct nfsd4_session *);
> >  
> >  static const struct nfsd4_callback_ops nfsd4_cb_recall_ops;
> > +static const struct nfsd4_callback_ops nfsd4_cb_notify_lock_ops;
> >  
> >  static bool is_session_dead(struct nfsd4_session *ses)
> >  {
> > @@ -210,6 +211,84 @@ static void nfsd4_put_session(struct nfsd4_session *ses)
> >  	spin_unlock(&nn->client_lock);
> >  }
> >  
> > +static struct nfsd4_blocked_lock *
> > +find_blocked_lock(struct nfs4_lockowner *lo, struct knfsd_fh *fh,
> > +			struct nfsd_net *nn)
> > +{
> > +	struct nfsd4_blocked_lock *cur, *found = NULL;
> > +
> > +	spin_lock(&nn->client_lock);
> > +	list_for_each_entry(cur, &lo->lo_blocked, nbl_list) {
> > +		if (fh_match(fh, &cur->nbl_fh)) {
> > +			list_del_init(&cur->nbl_list);
> > +			found = cur;
> > +			break;
> > +		}
> > +	}
> > +	spin_unlock(&nn->client_lock);
> > +	if (found)
> > +		posix_unblock_lock(&found->nbl_lock);
> > +	return found;
> > +}
> > +
> > +static struct nfsd4_blocked_lock *
> > +find_or_allocate_block(struct nfs4_lockowner *lo, struct knfsd_fh *fh,
> > +			struct nfsd_net *nn)
> > +{
> > +	struct nfsd4_blocked_lock *nbl;
> > +
> > +	nbl = find_blocked_lock(lo, fh, nn);
> > +	if (!nbl) {
> > +		nbl= kmalloc(sizeof(*nbl), GFP_KERNEL);
> > +		if (nbl) {
> > +			fh_copy_shallow(&nbl->nbl_fh, fh);
> > +			locks_init_lock(&nbl->nbl_lock);
> > +			nfsd4_init_cb(&nbl->nbl_cb, lo->lo_owner.so_client,
> > +					&nfsd4_cb_notify_lock_ops,
> > +					NFSPROC4_CLNT_CB_NOTIFY_LOCK);
> > +		}
> > +	}
> > +	return nbl;
> > +}
> > +
> > +static void
> > +free_blocked_lock(struct nfsd4_blocked_lock *nbl)
> > +{
> > +	locks_release_private(&nbl->nbl_lock);
> > +	kfree(nbl);
> > +}
> > +
> > +static int
> > +nfsd4_cb_notify_lock_done(struct nfsd4_callback *cb, struct rpc_task *task)
> > +{
> > +	/*
> > +	 * Since this is just an optimization, we don't try very hard if it
> > +	 * turns out not to succeed. We'll requeue it on NFS4ERR_DELAY, and
> > +	 * just quit trying on anything else.
> > +	 */
> > +	switch (task->tk_status) {
> > +	case -NFS4ERR_DELAY:
> > +		rpc_delay(task, 1 * HZ);
> > +		return 0;
> > +	default:
> > +		return 1;
> > +	}
> > +}
> > +
> > +static void
> > +nfsd4_cb_notify_lock_release(struct nfsd4_callback *cb)
> > +{
> > +	struct nfsd4_blocked_lock	*nbl = container_of(cb,
> > +						struct nfsd4_blocked_lock, nbl_cb);
> > +
> > +	free_blocked_lock(nbl);
> > +}
> > +
> > +static const struct nfsd4_callback_ops nfsd4_cb_notify_lock_ops = {
> > +	.done		= nfsd4_cb_notify_lock_done,
> > +	.release	= nfsd4_cb_notify_lock_release,
> > +};
> > +
> >  static inline struct nfs4_stateowner *
> >  nfs4_get_stateowner(struct nfs4_stateowner *sop)
> >  {
> > @@ -5309,7 +5388,29 @@ nfsd4_fl_put_owner(fl_owner_t owner)
> >  		nfs4_put_stateowner(&lo->lo_owner);
> >  }
> >  
> > +static void
> > +nfsd4_lm_notify(struct file_lock *fl)
> > +{
> > +	struct nfs4_lockowner		*lo = (struct nfs4_lockowner *)fl->fl_owner;
> > +	struct net			*net = lo->lo_owner.so_client->net;
> > +	struct nfsd_net			*nn = net_generic(net, nfsd_net_id);
> > +	struct nfsd4_blocked_lock	*nbl = container_of(fl,
> > +						struct nfsd4_blocked_lock, nbl_lock);
> > +	bool queue = false;
> > +
> > +	spin_lock(&nn->client_lock);
> > +	if (!list_empty(&nbl->nbl_list)) {
> > +		list_del_init(&nbl->nbl_list);
> > +		queue = true;
> > +	}
> > +	spin_unlock(&nn->client_lock);
> > +
> > +	if (queue)
> > +		nfsd4_run_cb(&nbl->nbl_cb);
> > +}
> > +
> >  static const struct lock_manager_operations nfsd_posix_mng_ops  = {
> > +	.lm_notify = nfsd4_lm_notify,
> >  	.lm_get_owner = nfsd4_fl_get_owner,
> >  	.lm_put_owner = nfsd4_fl_put_owner,
> >  };
> > @@ -5407,6 +5508,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
> >  	lo = alloc_stateowner(lockowner_slab, &lock->lk_new_owner, clp);
> >  	if (!lo)
> >  		return NULL;
> > +	INIT_LIST_HEAD(&lo->lo_blocked);
> >  	INIT_LIST_HEAD(&lo->lo_owner.so_stateids);
> >  	lo->lo_owner.so_is_open_owner = 0;
> >  	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
> > @@ -5588,12 +5690,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	struct nfs4_ol_stateid *open_stp = NULL;
> >  	struct nfs4_file *fp;
> >  	struct file *filp = NULL;
> > +	struct nfsd4_blocked_lock *nbl = NULL;
> >  	struct file_lock *file_lock = NULL;
> >  	struct file_lock *conflock = NULL;
> >  	__be32 status = 0;
> >  	int lkflg;
> >  	int err;
> >  	bool new = false;
> > +	unsigned char fl_type;
> > +	unsigned int fl_flags = FL_POSIX;
> >  	struct net *net = SVC_NET(rqstp);
> >  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> >  
> > @@ -5658,46 +5763,55 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	if (!locks_in_grace(net) && lock->lk_reclaim)
> >  		goto out;
> >  
> > -	file_lock = locks_alloc_lock();
> > -	if (!file_lock) {
> > -		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
> > -		status = nfserr_jukebox;
> > -		goto out;
> > -	}
> > -
> >  	fp = lock_stp->st_stid.sc_file;
> >  	switch (lock->lk_type) {
> > -		case NFS4_READ_LT:
> >  		case NFS4_READW_LT:
> > +			if (nfsd4_has_session(cstate))
> > +				fl_flags |= FL_SLEEP;
> > +			/* Fallthrough */
> > +		case NFS4_READ_LT:
> >  			spin_lock(&fp->fi_lock);
> >  			filp = find_readable_file_locked(fp);
> >  			if (filp)
> >  				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_READ);
> >  			spin_unlock(&fp->fi_lock);
> > -			file_lock->fl_type = F_RDLCK;
> > +			fl_type = F_RDLCK;
> >  			break;
> > -		case NFS4_WRITE_LT:
> >  		case NFS4_WRITEW_LT:
> > +			if (nfsd4_has_session(cstate))
> > +				fl_flags |= FL_SLEEP;
> > +			/* Fallthrough */
> > +		case NFS4_WRITE_LT:
> >  			spin_lock(&fp->fi_lock);
> >  			filp = find_writeable_file_locked(fp);
> >  			if (filp)
> >  				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_WRITE);
> >  			spin_unlock(&fp->fi_lock);
> > -			file_lock->fl_type = F_WRLCK;
> > +			fl_type = F_WRLCK;
> >  			break;
> >  		default:
> >  			status = nfserr_inval;
> >  		goto out;
> >  	}
> > +
> >  	if (!filp) {
> >  		status = nfserr_openmode;
> >  		goto out;
> >  	}
> >  
> > +	nbl = find_or_allocate_block(lock_sop, &fp->fi_fhandle, nn);
> > +	if (!nbl) {
> > +		dprintk("NFSD: %s: unable to allocate block!\n", __func__);
> > +		status = nfserr_jukebox;
> > +		goto out;
> > +	}
> > +
> > +	file_lock = &nbl->nbl_lock;
> > +	file_lock->fl_type = fl_type;
> >  	file_lock->fl_owner = (fl_owner_t)lockowner(nfs4_get_stateowner(&lock_sop->lo_owner));
> >  	file_lock->fl_pid = current->tgid;
> >  	file_lock->fl_file = filp;
> > -	file_lock->fl_flags = FL_POSIX;
> > +	file_lock->fl_flags = fl_flags;
> >  	file_lock->fl_lmops = &nfsd_posix_mng_ops;
> >  	file_lock->fl_start = lock->lk_offset;
> >  	file_lock->fl_end = last_byte_offset(lock->lk_offset, lock->lk_length);
> > @@ -5710,18 +5824,27 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		goto out;
> >  	}
> >  
> > +	if (fl_flags & FL_SLEEP) {
> > +		spin_lock(&nn->client_lock);
> > +		list_add_tail(&nbl->nbl_list, &lock_sop->lo_blocked);
> > +		spin_unlock(&nn->client_lock);
> > +	}
> > +
> >  	err = vfs_lock_file(filp, F_SETLK, file_lock, conflock);
> > -	switch (-err) {
> > +	switch (err) {
> >  	case 0: /* success! */
> >  		nfs4_inc_and_copy_stateid(&lock->lk_resp_stateid, &lock_stp->st_stid);
> >  		status = 0;
> >  		break;
> > -	case (EAGAIN):		/* conflock holds conflicting lock */
> > +	case FILE_LOCK_DEFERRED:
> > +		nbl = NULL;
> > +		/* Fallthrough */
> > +	case -EAGAIN:		/* conflock holds conflicting lock */
> >  		status = nfserr_denied;
> >  		dprintk("NFSD: nfsd4_lock: conflicting lock found!\n");
> >  		nfs4_set_lock_denied(conflock, &lock->lk_denied);
> >  		break;
> > -	case (EDEADLK):
> > +	case -EDEADLK:
> >  		status = nfserr_deadlock;
> >  		break;
> >  	default:
> > @@ -5730,6 +5853,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		break;
> >  	}
> >  out:
> > +	if (nbl) {
> > +		/* dequeue it if we queued it before */
> > +		if (fl_flags & FL_SLEEP) {
> > +			spin_lock(&nn->client_lock);
> > +			list_del_init(&nbl->nbl_list);
> > +			spin_unlock(&nn->client_lock);
> > +		}
> > +		free_blocked_lock(nbl);
> > +	}
> >  	if (filp)
> >  		fput(filp);
> >  	if (lock_stp) {
> > @@ -5753,8 +5885,6 @@ out:
> >  	if (open_stp)
> >  		nfs4_put_stid(&open_stp->st_stid);
> >  	nfsd4_bump_seqid(cstate, status);
> > -	if (file_lock)
> > -		locks_free_lock(file_lock);
> >  	if (conflock)
> >  		locks_free_lock(conflock);
> >  	return status;
> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > index 88d029dd13aa..e45c183a8bf7 100644
> > --- a/fs/nfsd/state.h
> > +++ b/fs/nfsd/state.h
> > @@ -440,11 +440,11 @@ struct nfs4_openowner {
> >  /*
> >   * Represents a generic "lockowner". Similar to an openowner. References to it
> >   * are held by the lock stateids that are created on its behalf. This object is
> > - * a superset of the nfs4_stateowner struct (or would be if it needed any extra
> > - * fields).
> > + * a superset of the nfs4_stateowner struct.
> >   */
> >  struct nfs4_lockowner {
> > -	struct nfs4_stateowner	lo_owner; /* must be first element */
> > +	struct nfs4_stateowner	lo_owner;	/* must be first element */
> > +	struct list_head	lo_blocked;	/* blocked file_locks */
> >  };
> >  
> >  static inline struct nfs4_openowner * openowner(struct nfs4_stateowner *so)
> > @@ -580,7 +580,13 @@ static inline bool nfsd4_stateid_generation_after(stateid_t *a, stateid_t *b)
> >  	return (s32)(a->si_generation - b->si_generation) > 0;
> >  }
> >  
> > +/*
> > + * When a client tries to get a lock on a file, we set one of these objects
> > + * on the blocking lock. When the lock becomes free, we can then issue a
> > + * CB_NOTIFY_LOCK to the server.
> > + */
> >  struct nfsd4_blocked_lock {
> > +	struct list_head	nbl_list;
> >  	struct file_lock	nbl_lock;
> >  	struct knfsd_fh		nbl_fh;
> >  	struct nfsd4_callback	nbl_cb;
> > -- 
> > 2.7.4

-- 
Jeff Layton <jlayton@redhat.com>
