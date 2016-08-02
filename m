Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:35513 "EHLO
	mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537AbcHBVa3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Aug 2016 17:30:29 -0400
Received: by mail-qt0-f176.google.com with SMTP id x25so131796903qtx.2
        for <linux-nfs@vger.kernel.org>; Tue, 02 Aug 2016 14:28:39 -0700 (PDT)
Message-ID: <1470173317.15226.19.camel@redhat.com>
Subject: Re: [RFC PATCH 2/4] nfsd: have nfsd4_lock use blocking locks for
 v4.1+ locks
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 02 Aug 2016 17:28:37 -0400
In-Reply-To: <20160802204314.GG15324@fieldses.org>
References: <1470161731-11301-1-git-send-email-jlayton@redhat.com>
	 <1470161731-11301-3-git-send-email-jlayton@redhat.com>
	 <20160802204314.GG15324@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-08-02 at 16:43 -0400, J. Bruce Fields wrote:
> On Tue, Aug 02, 2016 at 02:15:29PM -0400, Jeff Layton wrote:
> > 
> > Create a new per-lockowner+per-inode structure that contains a
> > file_lock. Have nfsd4_lock add this structure to the lockowner's list
> > prior to setting the lock. Then call the vfs and request a blocking lock
> > (by setting FL_SLEEP). If we get anything besides FILE_LOCK_DEFERRED
> > back, then we dequeue the block structure and free it. When the next
> > lock request comes in, we'll look for an existing block for the same
> > filehandle and dequeue and reuse it if there is one.
> 
> I'm probably just missing it because I only skimmed the patch quickly,
> but I don't see you distinguishing the blocking and non-blocking case.
> I think we only want to do this in the {READ,WRITE}W_LT case, as
> {READ,WRITE}_LT is a hint from the client that it's not going to wait
> for the lock.  Sending a notify without a preceding blocking request is
> probably a (relatively harmless) protocol bug.
> 
> --b.
> 

Ahh good point, I'm not distinguishing those cases currently. I'll fix
that up in the next iteration. And yeah, in the event that the client
isn't actually waiting on the lock, it should just ignore the
notification. Still, best not to notify unless something is waiting for
it.

I've not yet coded up the client-side part of this yet either, so for
now the client just replies with NFS4ERR_NOTSUPP anyway. Adding that is
next...

Thanks for having a look!

> > 
> > 
> > When the lock comes free (a'la an lm_notify call), we dequeue it
> > from the lockowner's list and kick off a CB_NOTIFY_LOCK callback to
> > inform the client that it should retry the lock request.
> > 
> > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfsd/nfs4state.c | 152 +++++++++++++++++++++++++++++++++++++++++++++++-----
> >  fs/nfsd/state.h     |  12 +++--
> >  2 files changed, 147 insertions(+), 17 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 70d0b9b33031..38367201c14f 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -99,6 +99,7 @@ static struct kmem_cache *odstate_slab;
> >  static void free_session(struct nfsd4_session *);
> >  
> >  static const struct nfsd4_callback_ops nfsd4_cb_recall_ops;
> > +static const struct nfsd4_callback_ops nfsd4_cb_notify_lock_ops;
> >  
> >  static bool is_session_dead(struct nfsd4_session *ses)
> >  {
> > @@ -210,6 +211,84 @@ static void nfsd4_put_session(struct nfsd4_session *ses)
> > > >  	spin_unlock(&nn->client_lock);
> >  }
> >  
> > +static struct nfsd4_blocked_lock *
> > +find_blocked_lock(struct nfs4_lockowner *lo, struct knfsd_fh *fh,
> > > > +			struct nfsd_net *nn)
> > +{
> > > > +	struct nfsd4_blocked_lock *cur, *found = NULL;
> > +
> > > > +	spin_lock(&nn->client_lock);
> > > > +	list_for_each_entry(cur, &lo->lo_blocked, nbl_list) {
> > > > +		if (fh_match(fh, &cur->nbl_fh)) {
> > > > +			list_del_init(&cur->nbl_list);
> > > > +			found = cur;
> > > > +			break;
> > > > +		}
> > > > +	}
> > > > +	spin_unlock(&nn->client_lock);
> > > > +	if (found)
> > > > +		posix_unblock_lock(&found->nbl_lock);
> > > > +	return found;
> > +}
> > +
> > +static struct nfsd4_blocked_lock *
> > +find_or_allocate_block(struct nfs4_lockowner *lo, struct knfsd_fh *fh,
> > > > +			struct nfsd_net *nn)
> > +{
> > > > +	struct nfsd4_blocked_lock *nbl;
> > +
> > > > +	nbl = find_blocked_lock(lo, fh, nn);
> > > > +	if (!nbl) {
> > > > +		nbl= kmalloc(sizeof(*nbl), GFP_KERNEL);
> > > > +		if (nbl) {
> > > > +			fh_copy_shallow(&nbl->nbl_fh, fh);
> > > > +			locks_init_lock(&nbl->nbl_lock);
> > > > +			nfsd4_init_cb(&nbl->nbl_cb, lo->lo_owner.so_client,
> > > > +					&nfsd4_cb_notify_lock_ops,
> > > > +					NFSPROC4_CLNT_CB_NOTIFY_LOCK);
> > > > +		}
> > > > +	}
> > > > +	return nbl;
> > +}
> > +
> > +static void
> > +free_blocked_lock(struct nfsd4_blocked_lock *nbl)
> > +{
> > > > +	locks_release_private(&nbl->nbl_lock);
> > > > +	kfree(nbl);
> > +}
> > +
> > +static int
> > +nfsd4_cb_notify_lock_done(struct nfsd4_callback *cb, struct rpc_task *task)
> > +{
> > > > +	/*
> > > > +	 * Since this is just an optimization, we don't try very hard if it
> > > > +	 * turns out not to succeed. We'll requeue it on NFS4ERR_DELAY, and
> > > > +	 * just quit trying on anything else.
> > > > +	 */
> > > > +	switch (task->tk_status) {
> > > > +	case -NFS4ERR_DELAY:
> > > > +		rpc_delay(task, 1 * HZ);
> > > > +		return 0;
> > > > +	default:
> > > > +		return 1;
> > > > +	}
> > +}
> > +
> > +static void
> > +nfsd4_cb_notify_lock_release(struct nfsd4_callback *cb)
> > +{
> > > > > > +	struct nfsd4_blocked_lock	*nbl = container_of(cb,
> > > > +						struct nfsd4_blocked_lock, nbl_cb);
> > +
> > > > +	free_blocked_lock(nbl);
> > +}
> > +
> > +static const struct nfsd4_callback_ops nfsd4_cb_notify_lock_ops = {
> > > > > > +	.done		= nfsd4_cb_notify_lock_done,
> > > > > > +	.release	= nfsd4_cb_notify_lock_release,
> > +};
> > +
> >  static inline struct nfs4_stateowner *
> >  nfs4_get_stateowner(struct nfs4_stateowner *sop)
> >  {
> > @@ -5296,7 +5375,29 @@ nfsd4_fl_put_owner(fl_owner_t owner)
> > > >  		nfs4_put_stateowner(&lo->lo_owner);
> >  }
> >  
> > +static void
> > +nfsd4_lm_notify(struct file_lock *fl)
> > +{
> > > > > > +	struct nfs4_lockowner		*lo = (struct nfs4_lockowner *)fl->fl_owner;
> > > > > > +	struct net			*net = lo->lo_owner.so_client->net;
> > > > > > +	struct nfsd_net			*nn = net_generic(net, nfsd_net_id);
> > > > > > +	struct nfsd4_blocked_lock	*nbl = container_of(fl,
> > > > +						struct nfsd4_blocked_lock, nbl_lock);
> > > > +	bool queue = false;
> > +
> > > > +	spin_lock(&nn->client_lock);
> > > > +	if (!list_empty(&nbl->nbl_list)) {
> > > > +		list_del_init(&nbl->nbl_list);
> > > > +		queue = true;
> > > > +	}
> > > > +	spin_unlock(&nn->client_lock);
> > +
> > > > +	if (queue)
> > > > +		nfsd4_run_cb(&nbl->nbl_cb);
> > +}
> > +
> >  static const struct lock_manager_operations nfsd_posix_mng_ops  = {
> > > > +	.lm_notify = nfsd4_lm_notify,
> > > >  	.lm_get_owner = nfsd4_fl_get_owner,
> > > >  	.lm_put_owner = nfsd4_fl_put_owner,
> >  };
> > @@ -5394,6 +5495,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
> > > >  	lo = alloc_stateowner(lockowner_slab, &lock->lk_new_owner, clp);
> > > >  	if (!lo)
> > > >  		return NULL;
> > > > +	INIT_LIST_HEAD(&lo->lo_blocked);
> > > >  	INIT_LIST_HEAD(&lo->lo_owner.so_stateids);
> > > >  	lo->lo_owner.so_is_open_owner = 0;
> > > >  	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
> > @@ -5558,12 +5660,14 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > > >  	struct nfs4_ol_stateid *open_stp = NULL;
> > > >  	struct nfs4_file *fp;
> > > >  	struct file *filp = NULL;
> > > > +	struct nfsd4_blocked_lock *nbl = NULL;
> > > >  	struct file_lock *file_lock = NULL;
> > > >  	struct file_lock *conflock = NULL;
> > > >  	__be32 status = 0;
> > > >  	int lkflg;
> > > >  	int err;
> > > >  	bool new = false;
> > > > +	unsigned char fl_type;
> > > >  	struct net *net = SVC_NET(rqstp);
> > > >  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> >  
> > @@ -5630,13 +5734,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > > >  	if (!locks_in_grace(net) && lock->lk_reclaim)
> > > >  		goto out;
> >  
> > > > -	file_lock = locks_alloc_lock();
> > > > -	if (!file_lock) {
> > > > -		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
> > > > -		status = nfserr_jukebox;
> > > > -		goto out;
> > > > -	}
> > -
> > > >  	fp = lock_stp->st_stid.sc_file;
> > > >  	switch (lock->lk_type) {
> > > >  		case NFS4_READ_LT:
> > @@ -5646,7 +5743,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > > >  			if (filp)
> > > >  				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_READ);
> > > >  			spin_unlock(&fp->fi_lock);
> > > > -			file_lock->fl_type = F_RDLCK;
> > > > +			fl_type = F_RDLCK;
> > > >  			break;
> > > >  		case NFS4_WRITE_LT:
> > > >  		case NFS4_WRITEW_LT:
> > @@ -5655,17 +5752,27 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > > >  			if (filp)
> > > >  				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_WRITE);
> > > >  			spin_unlock(&fp->fi_lock);
> > > > -			file_lock->fl_type = F_WRLCK;
> > > > +			fl_type = F_WRLCK;
> > > >  			break;
> > > >  		default:
> > > >  			status = nfserr_inval;
> > > >  		goto out;
> > > >  	}
> > +
> > > >  	if (!filp) {
> > > >  		status = nfserr_openmode;
> > > >  		goto out;
> > > >  	}
> >  
> > > > +	nbl = find_or_allocate_block(lock_sop, &fp->fi_fhandle, nn);
> > > > +	if (!nbl) {
> > > > +		dprintk("NFSD: %s: unable to allocate block!\n", __func__);
> > > > +		status = nfserr_jukebox;
> > > > +		goto out;
> > > > +	}
> > +
> > > > +	file_lock = &nbl->nbl_lock;
> > > > +	file_lock->fl_type = fl_type;
> > > >  	file_lock->fl_owner = (fl_owner_t)lockowner(nfs4_get_stateowner(&lock_sop->lo_owner));
> > > >  	file_lock->fl_pid = current->tgid;
> > > >  	file_lock->fl_file = filp;
> > @@ -5682,18 +5789,28 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > > >  		goto out;
> > > >  	}
> >  
> > > > +	if (nfsd4_has_session(cstate)) {
> > > > +		file_lock->fl_flags |= FL_SLEEP;
> > > > +		spin_lock(&nn->client_lock);
> > > > +		list_add_tail(&nbl->nbl_list, &lock_sop->lo_blocked);
> > > > +		spin_unlock(&nn->client_lock);
> > > > +	}
> > +
> > > >  	err = vfs_lock_file(filp, F_SETLK, file_lock, conflock);
> > > > -	switch (-err) {
> > > > +	switch (err) {
> > > >  	case 0: /* success! */
> > > >  		nfs4_inc_and_copy_stateid(&lock->lk_resp_stateid, &lock_stp->st_stid);
> > > >  		status = 0;
> > > >  		break;
> > > > > > -	case (EAGAIN):		/* conflock holds conflicting lock */
> > > > +	case FILE_LOCK_DEFERRED:
> > > > +		nbl = NULL;
> > > > +		/* Fallthrough */
> > > > > > +	case EAGAIN:		/* conflock holds conflicting lock */
> > > >  		status = nfserr_denied;
> > > >  		dprintk("NFSD: nfsd4_lock: conflicting lock found!\n");
> > > >  		nfs4_set_lock_denied(conflock, &lock->lk_denied);
> > > >  		break;
> > > > -	case (EDEADLK):
> > > > +	case EDEADLK:
> > > >  		status = nfserr_deadlock;
> > > >  		break;
> > > >  	default:
> > @@ -5702,6 +5819,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > > >  		break;
> > > >  	}
> >  out:
> > > > +	if (nbl) {
> > > > +		/* dequeue it if we queued it before */
> > > > +		if (nfsd4_has_session(cstate)) {
> > > > +			spin_lock(&nn->client_lock);
> > > > +			list_del_init(&nbl->nbl_list);
> > > > +			spin_unlock(&nn->client_lock);
> > > > +		}
> > > > +		free_blocked_lock(nbl);
> > > > +	}
> > > >  	if (filp)
> > > >  		fput(filp);
> > > >  	if (lock_stp) {
> > @@ -5725,8 +5851,6 @@ out:
> > > >  	if (open_stp)
> > > >  		nfs4_put_stid(&open_stp->st_stid);
> > > >  	nfsd4_bump_seqid(cstate, status);
> > > > -	if (file_lock)
> > > > -		locks_free_lock(file_lock);
> > > >  	if (conflock)
> > > >  		locks_free_lock(conflock);
> > > >  	return status;
> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > index ecf3f4671654..056b0e4c485b 100644
> > --- a/fs/nfsd/state.h
> > +++ b/fs/nfsd/state.h
> > @@ -440,11 +440,11 @@ struct nfs4_openowner {
> >  /*
> >   * Represents a generic "lockowner". Similar to an openowner. References to it
> >   * are held by the lock stateids that are created on its behalf. This object is
> > - * a superset of the nfs4_stateowner struct (or would be if it needed any extra
> > - * fields).
> > + * a superset of the nfs4_stateowner struct.
> >   */
> >  struct nfs4_lockowner {
> > > > > > -	struct nfs4_stateowner	lo_owner; /* must be first element */
> > > > > > > > +	struct nfs4_stateowner	lo_owner;	/* must be first element */
> > > > > > > > +	struct list_head	lo_blocked;	/* blocked file_locks */
> >  };
> >  
> >  static inline struct nfs4_openowner * openowner(struct nfs4_stateowner *so)
> > @@ -580,7 +580,13 @@ static inline bool nfsd4_stateid_generation_after(stateid_t *a, stateid_t *b)
> > > >  	return (s32)(a->si_generation - b->si_generation) > 0;
> >  }
> >  
> > +/*
> > + * When a client tries to get a lock on a file, we set one of these objects
> > + * on the blocking lock. When the lock becomes free, we can then issue a
> > + * CB_NOTIFY_LOCK to the server.
> > + */
> >  struct nfsd4_blocked_lock {
> > > > > > +	struct list_head	nbl_list;
> > > > > >  	struct file_lock	nbl_lock;
> > > > > >  	struct knfsd_fh		nbl_fh;
> > > > > >  	struct nfsd4_callback	nbl_cb;
> > -- 
> > 2.7.4

-- 
Jeff Layton <jlayton@redhat.com>
