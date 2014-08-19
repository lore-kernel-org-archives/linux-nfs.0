Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53564 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819AbaHSUYm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2014 16:24:42 -0400
Date: Tue, 19 Aug 2014 16:24:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 6/6 v4] NFSD: Increase the reference of lockowner when
 coping file_lock
Message-ID: <20140819202441.GB4125@fieldses.org>
References: <53BAAAC5.9000106@gmail.com>
 <53E22EA5.70708@gmail.com>
 <20140809065112.700e0ecc@tlielax.poochiereds.net>
 <53E791F1.40802@gmail.com>
 <53ED5093.6000308@gmail.com>
 <53F36CB5.2030707@gmail.com>
 <20140819162344.269953bd@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140819162344.269953bd@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 19, 2014 at 04:23:44PM -0400, Jeff Layton wrote:
> On Tue, 19 Aug 2014 23:26:45 +0800
> Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
> > v4: same as v3, no change
> > v3: Update based on Jeff's comments
> > v2: Fix bad using of struct file_lock_operations for handle the owner.
> > 
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> > ---
> >  fs/nfsd/nfs4state.c | 34 ++++++++++++++++++++++++++++++----
> >  1 file changed, 30 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index e087a71..7161111 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -4869,9 +4869,31 @@ nfs4_transform_lock_offset(struct file_lock *lock)
> >  		lock->fl_end = OFFSET_MAX;
> >  }
> >  
> > -/* Hack!: For now, we're defining this just so we can use a pointer to it
> > - * as a unique cookie to identify our (NFSv4's) posix locks. */
> > +static inline struct nfs4_lockowner *
> > +nfs4_get_lockowner(struct nfs4_lockowner *lo)
> > +{
> > +	return lockowner(nfs4_get_stateowner(&lo->lo_owner));
> > +}
> > +
> 
> I'd probably not bother with this inline function. Just open code that
> into the callers.
> 
> > +static void nfsd4_fl_get_owner(struct file_lock *dst, struct file_lock *src)
> > +{
> > +	struct nfs4_lockowner *lo = (struct nfs4_lockowner *) src->fl_owner;
> > +	dst->fl_owner = (fl_owner_t) nfs4_get_lockowner(lo);
> > +}
> > +
> > +static void nfsd4_fl_put_owner(struct file_lock *fl)
> > +{
> > +	struct nfs4_lockowner *lo = (struct nfs4_lockowner *) fl->fl_owner;
> > +
> > +	if (lo) {
> > +		nfs4_put_stateowner(&lo->lo_owner);
> > +		fl->fl_owner = NULL;
> > +	}
> > +}
> > +
> >  static const struct lock_manager_operations nfsd_posix_mng_ops  = {
> > +	.lm_get_owner = nfsd4_fl_get_owner,
> > +	.lm_put_owner = nfsd4_fl_put_owner,
> >  };
> >  
> >  static inline void
> > @@ -5236,7 +5258,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		status = nfserr_openmode;
> >  		goto out;
> >  	}
> > -	file_lock->fl_owner = (fl_owner_t)lock_sop;
> > +
> > +	file_lock->fl_owner = (fl_owner_t) nfs4_get_lockowner(lock_sop);
> >  	file_lock->fl_pid = current->tgid;
> >  	file_lock->fl_file = filp;
> >  	file_lock->fl_flags = FL_POSIX;
> > @@ -5403,6 +5426,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	struct nfs4_ol_stateid *stp;
> >  	struct file *filp = NULL;
> >  	struct file_lock *file_lock = NULL;
> > +	struct nfs4_lockowner *lock_sop = NULL;
> 
> nit: Probably no need to initialize lock_sop to NULL. Even better, I'd
> just drop that and change the fl_owner assignment below.
> 
> >  	__be32 status;
> >  	int err;
> >  	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
> > @@ -5424,6 +5448,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		status = nfserr_lock_range;
> >  		goto put_stateid;
> >  	}
> > +
> > +	lock_sop = lockowner(stp->st_stateowner);
> >  	file_lock = locks_alloc_lock();
> >  	if (!file_lock) {
> >  		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
> > @@ -5432,7 +5458,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	}
> >  
> >  	file_lock->fl_type = F_UNLCK;
> > -	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
> > +	file_lock->fl_owner = (fl_owner_t) nfs4_get_lockowner(lock_sop);
> 
> I'd do this instead and not bother with a nfs4_get_lockowner at all...
> 
> 	file_lock->fl_owner = (fl_owner_t)lockowner(nfs4_get_stateowner(stp->st_stateowner));
> 
> >  	file_lock->fl_pid = current->tgid;
> >  	file_lock->fl_file = filp;
> >  	file_lock->fl_flags = FL_POSIX;
> 
> But those are minor nits. This looks fine otherwise.
> 
> Bruce, if it's OK by you, I'll just take the whole series once Kinglong
> respins. It does touch some nfsd code, but it hopefully shouldn't cause
> much in the way of conflicts with anything you have queued for v3.18.

That's fine by me.

--b.
