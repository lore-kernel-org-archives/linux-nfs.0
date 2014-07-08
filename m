Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:41258 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475AbaGHMkB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 08:40:01 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so4950750qge.39
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 05:40:00 -0700 (PDT)
Date: Tue, 8 Jul 2014 08:39:56 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 2/4] NFSD: Rervert "knfsd: locks: flag NFSv4-owned
 locks"
Message-ID: <20140708083956.0799b87c@tlielax.poochiereds.net>
In-Reply-To: <53BBE35B.6090003@gmail.com>
References: <53BAAAC5.9000106@gmail.com>
	<20140707132633.5eb59753@tlielax.poochiereds.net>
	<53BB6445.3060508@gmail.com>
	<20140708070320.1d5646f0@tlielax.poochiereds.net>
	<53BBE35B.6090003@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 08 Jul 2014 20:26:03 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> On 7/8/2014 19:03, Jeff Layton wrote:
> > On Tue, 08 Jul 2014 11:23:49 +0800
> > Kinglong Mee <kinglongmee@gmail.com> wrote:
> > 
> >> On 7/8/2014 01:26, Jeff Layton wrote:
> >>> On Mon, 07 Jul 2014 22:12:21 +0800
> >>> Kinglong Mee <kinglongmee@gmail.com> wrote:
> >>>
> > -------------------------[snip]------------------------------
> > 
> > [PATCH] NFSD: Rervert "knfsd: locks: flag NFSv4-owned locks"
> > 
> > Commit d5b9026a67 ([PATCH] knfsd: locks: flag NFSv4-owned locks) using
> > fl_lmops field in file_lock for checking nfsd4 lockowner.
> > 
> > But, commit 1a747ee0cc (locks: don't call ->copy_lock methods on return of conflicting locks) causes the fl_lmops of conflock for nfsd4_lock always be NULL.
> > 
> > Also, commit 0996905f93 (lockd: posix_test_lock() should not call locks_copy_lock()) caused the fl_lmops of conflock for nfsd4_lockt always be NULL too.
> > 
> > So that, using fl_lmops cannot checking nfsd4 lockowner for it always be NULL.
> > 
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfsd/nfs4state.c | 34 ++++++++++++++++++++++------------
> >  1 file changed, 22 insertions(+), 12 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index c400ec17915e..00cd7fd17b0f 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -4312,18 +4312,29 @@ nfs4_transform_lock_offset(struct file_lock *lock)
> >  		lock->fl_end = OFFSET_MAX;
> >  }
> >  
> > -/* Hack!: For now, we're defining this just so we can use a pointer to it
> > - * as a unique cookie to identify our (NFSv4's) posix locks. */
> > -static const struct lock_manager_operations nfsd_posix_mng_ops  = {
> > -};
> > +static bool
> > +nfs4_verify_lock_stateowner(struct nfs4_lockowner *lo, struct nfs4_client *clp)
> > +{
> > +	struct nfs4_stateowner *local = NULL;
> > +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> > +	unsigned int hashval = ownerstr_hashval(clp->cl_clientid.cl_id,
> > +						&lo->lo_owner.so_owner);
> 
> Needs the conflicting client which holds the lock,
> Not the new client which try to locking the file has be locked.
> 
> > +
> > +	list_for_each_entry(local, &nn->ownerstr_hashtbl[hashval], so_strhash) {
> > +		if (local == &lo->lo_owner)
> > +			return true;
> > +	}
> > +
> > +	return false;
> > +}
> >  
> >  static inline void
> > -nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
> > +nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny,
> > +			struct nfs4_client *clp)
> >  {
> > -	struct nfs4_lockowner *lo;
> > +	struct nfs4_lockowner *lo = (struct nfs4_lockowner *)fl->fl_owner;
> >  
> > -	if (fl->fl_lmops == &nfsd_posix_mng_ops) {
> > -		lo = (struct nfs4_lockowner *) fl->fl_owner;
> > +	if (nfs4_verify_lock_stateowner(lo, clp)) {
> >  		deny->ld_owner.data = kmemdup(lo->lo_owner.so_owner.data,
> >  					lo->lo_owner.so_owner.len, GFP_KERNEL);
> >  		if (!deny->ld_owner.data)
> > @@ -4594,7 +4605,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	file_lock->fl_pid = current->tgid;
> >  	file_lock->fl_file = filp;
> >  	file_lock->fl_flags = FL_POSIX;
> > -	file_lock->fl_lmops = &nfsd_posix_mng_ops;
> >  	file_lock->fl_start = lock->lk_offset;
> >  	file_lock->fl_end = last_byte_offset(lock->lk_offset, lock->lk_length);
> >  	nfs4_transform_lock_offset(file_lock);
> > @@ -4617,7 +4627,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	case (EAGAIN):		/* conflock holds conflicting lock */
> >  		status = nfserr_denied;
> >  		dprintk("NFSD: nfsd4_lock: conflicting lock found!\n");
> > -		nfs4_set_lock_denied(conflock, &lock->lk_denied);
> > +		nfs4_set_lock_denied(conflock, &lock->lk_denied,
> > +					cstate->clp);
> >  		break;
> >  	case (EDEADLK):
> >  		status = nfserr_deadlock;
> > @@ -4725,7 +4736,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  
> >  	if (file_lock->fl_type != F_UNLCK) {
> >  		status = nfserr_denied;
> > -		nfs4_set_lock_denied(file_lock, &lockt->lt_denied);
> > +		nfs4_set_lock_denied(file_lock, &lockt->lt_denied, cstate->clp);
> 
> The clp is the client which try to lock the file here,
> but the file have be locked by other client or server.
> 
> With this patch, the hashval is wrong.
>               *correct*                    *this patch*
> clid        conflicting client        new request lock client
> owner      from vfs_lock_file()        from vfs_lock_file()  
>             or vfs_test_lock()           or vfs_test_lock()
> hashval       right hashval           bad hashval (never exist)
> 
> With this patch, LOCK/LOCKT compound gets client with all zero, and owner with all zero.
> 
> thanks,
> Kinglong Mee
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

<facepalm>
Ahh ok, I see what you're saying now. I'll leave it to you to respin
once the rest of the client_mutex removal series is merged.
</facepalm>


-- 
Jeff Layton <jlayton@poochiereds.net>
