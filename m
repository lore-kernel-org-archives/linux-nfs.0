Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:62420 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932099AbaGUNXm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 09:23:42 -0400
Received: by mail-qa0-f42.google.com with SMTP id j15so5195929qaq.29
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 06:23:41 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 21 Jul 2014 09:23:40 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, NeilBrown <neilb@suse.de>,
        hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 10/10] nfsd: give block_delegation and
 delegation_blocked its own spinlock
Message-ID: <20140721092340.1adac16b@tlielax.poochiereds.net>
In-Reply-To: <20140721131127.GA8438@fieldses.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
	<1405696416-32585-11-git-send-email-jlayton@primarydata.com>
	<20140721170254.0289ab9f@notabene.brown>
	<20140721074412.4d9be086@tlielax.poochiereds.net>
	<20140721131127.GA8438@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 21 Jul 2014 09:11:27 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jul 21, 2014 at 07:44:12AM -0400, Jeff Layton wrote:
> > On Mon, 21 Jul 2014 17:02:54 +1000
> > NeilBrown <neilb@suse.de> wrote:
> > 
> > > On Fri, 18 Jul 2014 11:13:36 -0400 Jeff Layton <jlayton@primarydata.com>
> > > wrote:
> > > 
> > > > The state lock can be fairly heavily contended, and there's no reason
> > > > that nfs4_file lookups and delegation_blocked should be mutually
> > > > exclusive.  Let's give the new block_delegation code its own spinlock.
> > > > It does mean that we'll need to take a different lock in the delegation
> > > > break code, but that's not generally as critical to performance.
> > > > 
> > > > Cc: Neil Brown <neilb@suse.de>
> > > > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > > 
> > > Makes sense, thanks.
> > > However.....
> > > 
> > > 
> > > > ---
> > > >  fs/nfsd/nfs4state.c | 25 +++++++++++++------------
> > > >  1 file changed, 13 insertions(+), 12 deletions(-)
> > > > 
> > > > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > > > index a2c6c85adfc7..952def00363b 100644
> > > > --- a/fs/nfsd/nfs4state.c
> > > > +++ b/fs/nfsd/nfs4state.c
> > > > @@ -506,10 +506,11 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
> > > >   * Each filter is 256 bits.  We hash the filehandle to 32bit and use the
> > > >   * low 3 bytes as hash-table indices.
> > > >   *
> > > > - * 'state_lock', which is always held when block_delegations() is called,
> > > > - * is used to manage concurrent access.  Testing does not need the lock
> > > > - * except when swapping the two filters.
> > > > + * 'blocked_delegations_lock', which is always held when block_delegations()
> > > > + * is called, is used to manage concurrent access.  Testing does not need the
> > > > + * lock except when swapping the two filters.
> > > 
> > > ...this comment is wrong.  blocked_delegations_lock is *not* held when
> > > block_delegations() is call, it is taken when needed (almost) by
> > > block_delegations.
> > > 
> > 
> > Thanks, fixed.
> > 
> > > >   */
> > > > +static DEFINE_SPINLOCK(blocked_delegations_lock);
> > > >  static struct bloom_pair {
> > > >  	int	entries, old_entries;
> > > >  	time_t	swap_time;
> > > > @@ -525,7 +526,7 @@ static int delegation_blocked(struct knfsd_fh *fh)
> > > >  	if (bd->entries == 0)
> > > >  		return 0;
> > > >  	if (seconds_since_boot() - bd->swap_time > 30) {
> > > > -		spin_lock(&state_lock);
> > > > +		spin_lock(&blocked_delegations_lock);
> > > >  		if (seconds_since_boot() - bd->swap_time > 30) {
> > > >  			bd->entries -= bd->old_entries;
> > > >  			bd->old_entries = bd->entries;
> > > > @@ -534,7 +535,7 @@ static int delegation_blocked(struct knfsd_fh *fh)
> > > >  			bd->new = 1-bd->new;
> > > >  			bd->swap_time = seconds_since_boot();
> > > >  		}
> > > > -		spin_unlock(&state_lock);
> > > > +		spin_unlock(&blocked_delegations_lock);
> > > >  	}
> > > >  	hash = arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
> > > >  	if (test_bit(hash&255, bd->set[0]) &&
> > > > @@ -555,16 +556,16 @@ static void block_delegations(struct knfsd_fh *fh)
> > > >  	u32 hash;
> > > >  	struct bloom_pair *bd = &blocked_delegations;
> > > >  
> > > > -	lockdep_assert_held(&state_lock);
> > > > -
> > > >  	hash = arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
> > > >  
> > > >  	__set_bit(hash&255, bd->set[bd->new]);
> > > >  	__set_bit((hash>>8)&255, bd->set[bd->new]);
> > > >  	__set_bit((hash>>16)&255, bd->set[bd->new]);
> > > > +	spin_lock(&blocked_delegations_lock);
> > > 
> > > __set_bit isn't atomic.  The spin_lock should be taken *before* these
> > > __set_bit() calls.
> > > 
> > > Otherwise, looks fine.
> > > 
> > > Thanks,
> > > NeilBrown
> > > 
> > > 
> > 
> > Ok. I guess the worry is that we could end up setting bits in the
> > middle of swapping the two fields? Makes sense -- fixed in my repo.
> > I'll send out the updated set later today (it also includes a few nits
> > that HCH pointed out last week).
> > 
> > As a side note...I wonder how much we'll get in the way of false
> > positives with this scheme?
> > 
> > Given that we'll always have (or will have had) a nfs4_file
> > corresponding to this inode, perhaps we'd be better off doing something
> > like storing (and maybe hashing on) the filehandle in the nfs4_file,
> > and just ensuring that we hold on to it for 30s or so after the last
> > put?
> 
> You don't want to hold a reference to the inode unnecessarily.
> (Consider for example the case of a deleted-but-still-opened file, in
> which case people can notice if a large file hangs around eating up
> space for an extra 30 seconds.)  So I suppose you'd put fi_inode on last
> close and just make sure the rest of the code is prepared to deal with
> nfs4_file's with struct inodes.  That might make sense to do.
> 

Yeah, that's what I was thinking. Change the code to hash the nfs4_file
based on filehandle instead of inode (which may make sense anyway), and
then just keep it around for a little while to handle delegation checks
without pinning down any vfs objects. We could institute some sort of
LRU collection of unused nfs4_files too to ensure the cache doesn't
grow too large.

> Occasional false positives aren't necessarily a big deal, so the current
> approach seems a reasonable compromise for now.
> 

Right, it may be no big deal at all, but the question is -- "how often
do we hit false positives here?" I imagine it depends on workload to
some degree.

Is there some way we could sanity check the hit/miss rate without
needing to do too much tracking?

Anyway...it's more food for thought for later work in this area...

> > 
> > Not something I'm looking at doing today, but it might be worth
> > considering for a later delegations rework.
> > 
> > > >  	if (bd->entries == 0)
> > > >  		bd->swap_time = seconds_since_boot();
> > > >  	bd->entries += 1;
> > > > +	spin_unlock(&blocked_delegations_lock);
> > > >  }
> > > >  
> > > >  static struct nfs4_delegation *
> > > > @@ -3097,16 +3098,16 @@ void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
> > > >  	struct nfs4_client *clp = dp->dl_stid.sc_client;
> > > >  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> > > >  
> > > > -	/*
> > > > -	 * We can't do this in nfsd_break_deleg_cb because it is
> > > > -	 * already holding inode->i_lock
> > > > -	 */
> > > > -	spin_lock(&state_lock);
> > > >  	block_delegations(&dp->dl_fh);
> > > > +
> > > >  	/*
> > > > +	 * We can't do this in nfsd_break_deleg_cb because it is
> > > > +	 * already holding inode->i_lock.
> > > > +	 *
> > > >  	 * If the dl_time != 0, then we know that it has already been
> > > >  	 * queued for a lease break. Don't queue it again.
> > > >  	 */
> > > > +	spin_lock(&state_lock);
> > > >  	if (dp->dl_time == 0) {
> > > >  		dp->dl_time = get_seconds();
> > > >  		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
> > > 
> > 
> > 
> > -- 
> > Jeff Layton <jlayton@primarydata.com>
> 
> 


-- 
Jeff Layton <jlayton@primarydata.com>
