Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37639 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279AbbI3Oaw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Sep 2015 10:30:52 -0400
Date: Wed, 30 Sep 2015 10:30:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, Andrew W Elble <aweits@rit.edu>
Subject: Re: [PATCH] nfsd: serialize state seqid morphing operations
Message-ID: <20150930143049.GA15798@fieldses.org>
References: <1442490428-29487-1-git-send-email-jeff.layton@primarydata.com>
 <20150929211155.GI3190@fieldses.org>
 <20150929172638.6cc775ff@tlielax.poochiereds.net>
 <20150929231427.GA12002@fieldses.org>
 <20150930065338.44ba7315@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150930065338.44ba7315@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 30, 2015 at 06:53:38AM -0400, Jeff Layton wrote:
> On Tue, 29 Sep 2015 19:14:27 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Tue, Sep 29, 2015 at 05:26:38PM -0400, Jeff Layton wrote:
> > > On Tue, 29 Sep 2015 17:11:55 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > > > On Thu, Sep 17, 2015 at 07:47:08AM -0400, Jeff Layton wrote:
> > > > > Andrew was seeing a race occur when an OPEN and OPEN_DOWNGRADE were
> > > > > running in parallel. The server would receive the OPEN_DOWNGRADE first
> > > > > and check its seqid, but then an OPEN would race in and bump it. The
> > > > > OPEN_DOWNGRADE would then complete and bump the seqid again.  The result
> > > > > was that the OPEN_DOWNGRADE would be applied after the OPEN, even though
> > > > > it should have been rejected since the seqid changed.
> > > > > 
> > > > > The only recourse we have here I think is to serialize operations that
> > > > > bump the seqid in a stateid, particularly when we're given a seqid in
> > > > > the call. To address this, we add a new rw_semaphore to the
> > > > > nfs4_ol_stateid struct. We do a down_write prior to checking the seqid
> > > > > after looking up the stateid to ensure that nothing else is going to
> > > > > bump it while we're operating on it.
> > > > > 
> > > > > In the case of OPEN, we do a down_read, as the call doesn't contain a
> > > > > seqid. Those can run in parallel -- we just need to serialize them when
> > > > > there is a concurrent OPEN_DOWNGRADE or CLOSE.
> > > > > 
> > > > > LOCK and LOCKU however always take the write lock as there is no
> > > > > opportunity for parallelizing those.
> > > > > 
> > > > > Reported-and-Tested-by: Andrew W Elble <aweits@rit.edu>
> > > > > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > > > > ---
> > > > >  fs/nfsd/nfs4state.c | 33 ++++++++++++++++++++++++++++-----
> > > > >  fs/nfsd/state.h     | 19 ++++++++++---------
> > > > >  2 files changed, 38 insertions(+), 14 deletions(-)
> > > > > 
> > > > > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > > > > index 0f1d5691b795..1b39edf10b67 100644
> > > > > --- a/fs/nfsd/nfs4state.c
> > > > > +++ b/fs/nfsd/nfs4state.c
> > > > > @@ -3360,6 +3360,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
> > > > >  	stp->st_access_bmap = 0;
> > > > >  	stp->st_deny_bmap = 0;
> > > > >  	stp->st_openstp = NULL;
> > > > > +	init_rwsem(&stp->st_rwsem);
> > > > >  	spin_lock(&oo->oo_owner.so_client->cl_lock);
> > > > >  	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
> > > > >  	spin_lock(&fp->fi_lock);
> > > > > @@ -4187,15 +4188,20 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
> > > > >  	 */
> > > > >  	if (stp) {
> > > > >  		/* Stateid was found, this is an OPEN upgrade */
> > > > > +		down_read(&stp->st_rwsem);
> > > > >  		status = nfs4_upgrade_open(rqstp, fp, current_fh, stp, open);
> > > > > -		if (status)
> > > > > +		if (status) {
> > > > > +			up_read(&stp->st_rwsem);
> > > > >  			goto out;
> > > > > +		}
> > > > >  	} else {
> > > > >  		stp = open->op_stp;
> > > > >  		open->op_stp = NULL;
> > > > >  		init_open_stateid(stp, fp, open);
> > > > > +		down_read(&stp->st_rwsem);
> > > > >  		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
> > > > >  		if (status) {
> > > > > +			up_read(&stp->st_rwsem);
> > > > >  			release_open_stateid(stp);
> > > > >  			goto out;
> > > > >  		}
> > > > > @@ -4207,6 +4213,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
> > > > >  	}
> > > > >  	update_stateid(&stp->st_stid.sc_stateid);
> > > > >  	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
> > > > > +	up_read(&stp->st_rwsem);
> > > > >  
> > > > >  	if (nfsd4_has_session(&resp->cstate)) {
> > > > >  		if (open->op_deleg_want & NFS4_SHARE_WANT_NO_DELEG) {
> > > > 
> > > > The patch looks good, but:
> > > > 
> > > > Does it matter that we don't have an exclusive lock over that
> > > > update_stateid?
> > > > 
> > > > I think there's at least one small bug there:
> > > > 
> > > > 	static inline void update_stateid(stateid_t *stateid)
> > > > 	{       
> > > > 	        stateid->si_generation++;
> > > > 	        /* Wraparound recommendation from 3530bis-13 9.1.3.2: */
> > > > 	        if (stateid->si_generation == 0)
> > > > 	                stateid->si_generation = 1;
> > > > 	}
> > > > 
> > > > The si_generation increment isn't atomic, and even if it were the wraparound
> > > > handling definitely wouldn't.  That's a pretty small race.
> > > > 
> > > 
> > > Yeah, I eyeballed that some time ago and convinced myself it was ok,
> > > but I think you're right that there is a potential race there. That
> > > counter sort of seems like something that ought to use atomics in some
> > > fashion. The wraparound is tricky, but could be done locklessly with
> > > cmpxchg, I think...
> > > > Does it also matter that this si_generation update isn't atomic with respect
> > > > to the actual open and upgrade of the share bits?
> > > > 
> > > 
> > > I don't think so. If you race with a concurrent OPEN upgrade, the
> > > server will either have what you requested or a superset of that. It's
> > > only OPEN_DOWNGRADE and CLOSE that need full serialization.
> > 
> > IO also takes stateids, and I think it'd be interesting to think about
> > scenarios that involve concurrent opens and reads or writes.  For
> > example:
> > 
> > 	- process_open2 upgrades R to RW
> > 
> > 				- Write processed with si_generation=1
> > 
> > 	- process_open2 bumps si_generation
> > 
> > The write succeeds, but it was performed with a stateid that represented
> > a read-only open.  I believe that write should have gotten either
> > OPENMODE (if it happened before the open) or OLD_STATEID (if it happened
> > after).
> > 
> > I don't know if that's actually a problem in practice.
> > 
> 
> That's a different issue altogether. We're not serializing anything but
> operations that morph the seqid in this patch, and WRITE doesn't do
> that.

Sure.  And this patch is an improvement on its own and should probably
be applied as is.  I just couldn't help wondering about this other stuff
while I was looking at this part of the code.

> If we need to hold the seqid static over the life of operations that
> happened to provide that seqid then that's a much larger effort, and
> probably not suitable for a rw semaphore. You'd need to allow for a 3rd
> class of "locker" that is able to operate in parallel with one another
> but that prevents any changes to the seqid.
> 
> > Hm, I also wonder about the window between the si_generation bump and
> > memcpy.  Multiple concurrent opens could end up returning the same
> > stateid:
> > 
> > 	- si_generation++
> > 				- si_generation++
> > 
> > 	- memcpy new stateid
> > 				- memcpy new stateid
> > 
> > Again, I'm not sure if that will actually cause application-visible
> > problems.
> > 
> 
> That, could be a problem.
> 
> One thing to notice is that update_stateid is always followed by the
> memcpy of that stateid. Perhaps we should roll the two together --
> update the stateid and do the memcpy under a spinlock or something.
> That also would also make it trivial to fix the wraparound problem too.

Sounds reasonable.

> Do you think we could get away with a global spinlock for that, or do
> we need to consider adding one to the nfs4_stid?

It'd be easy enough to do, wouldn't it?

I mean, really making open code scale sounds like a project for another
day, but glomming locks together also seems easier than splitting them
apart, so I'd rather start with the finer locking and then fix it later
if somebody decides it's not optimal.

--b.
