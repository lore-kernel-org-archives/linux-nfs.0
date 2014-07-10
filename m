Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f68.google.com ([209.85.216.68]:35477 "EHLO
	mail-qa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbaGJQQ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 12:16:27 -0400
Received: by mail-qa0-f68.google.com with SMTP id hw13so1073751qab.11
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 09:16:27 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 12:16:25 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 001/100] nfsd: close potential race between
 delegation break and laundromat
Message-ID: <20140710121625.69c8c08f@tlielax.poochiereds.net>
In-Reply-To: <20140710155905.GF26851@fieldses.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
	<1404842668-22521-2-git-send-email-jlayton@primarydata.com>
	<20140710155905.GF26851@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 11:59:05 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jul 08, 2014 at 02:02:49PM -0400, Jeff Layton wrote:
> > Bruce says:
> > 
> >     There's also a preexisting expire_client/laundromat vs break race:
> > 
> >     - expire_client/laundromat adds a delegation to its local
> >       reaplist using the same dl_recall_lru field that a delegation
> >       uses to track its position on the recall lru and drops the
> >       state lock.
> > 
> >     - a concurrent break_lease adds the delegation to the lru.
> > 
> >     - expire/client/laundromat then walks it reaplist and sees the
> >       lru head as just another delegation on the list....
> > 
> > Fix this race by checking the dl_time under the state_lock. If we find
> > that it's not 0, then we know that it has already been queued to the LRU
> > list and that we shouldn't queue it again.
> > 
> > In the case of destroy_client, we must also ensure that we don't hit
> > similar races by ensuring that we don't move any delegations to the
> > reaplist with a dl_time of 0. Just bump the dl_time by one before we
> > drop the state_lock. We're destroying the delegations anyway, so a 1s
> > difference there won't matter.
> > 
> > The fault injection code also requires a bit of surgery here:
> > 
> > First, in the case of nfsd_forget_client_delegations, we must prevent
> > the same sort of race vs. the delegation break callback. For that, we
> > just increment the dl_time to ensure that a delegation callback can't
> > race in while we're working on it.
> > 
> > We can't do that for nfsd_recall_client_delegations, as we need to have
> > it actually queue the delegation, and that won't happen if we increment
> > the dl_time. The state lock is held over that function, so we don't need
> > to worry about these sorts of races there.
> > 
> > There is one other potential bug nfsd_recall_client_delegations though.
> > Entries on the victims list are not dequeued before calling
> > nfsd_break_one_deleg. That's a potential list corruptor, so ensure that
> > we do that there.
> > 
> > Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfsd/nfs4state.c | 40 +++++++++++++++++++++++++++++++++-------
> >  1 file changed, 33 insertions(+), 7 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 763aeeb67ccf..633b34fd6c92 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -1287,6 +1287,8 @@ destroy_client(struct nfs4_client *clp)
> >  	while (!list_empty(&clp->cl_delegations)) {
> >  		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
> >  		list_del_init(&dp->dl_perclnt);
> > +		/* Ensure that deleg break won't try to requeue it */
> > +		++dp->dl_time;
> >  		list_move(&dp->dl_recall_lru, &reaplist);
> >  	}
> >  	spin_unlock(&state_lock);
> > @@ -2933,10 +2935,14 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
> >  	 * it's safe to take a reference: */
> >  	atomic_inc(&dp->dl_count);
> >  
> > -	list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
> > -
> > -	/* Only place dl_time is set; protected by i_lock: */
> > -	dp->dl_time = get_seconds();
> > +	/*
> > +	 * If the dl_time != 0, then we know that it has already been
> > +	 * queued for a lease break. Don't queue it again.
> > +	 */
> > +	if (dp->dl_time == 0) {
> 
> Any reason not to just make that
> 
> 	if (dp->dl_time)
> 		return;
> 
> ?
> 
> I don't know if it matters right now, but it might also be useful to
> know that no more work will get queued once dl_time is set.
> 
> --b.
> 

No, that makes a lot of sense. I'll respin and do that instead...


> > +		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
> > +		dp->dl_time = get_seconds();
> > +	}
> >  
> >  	block_delegations(&dp->dl_fh);
> >  
> > @@ -5081,8 +5087,23 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
> >  
> >  	lockdep_assert_held(&state_lock);
> >  	list_for_each_entry_safe(dp, next, &clp->cl_delegations, dl_perclnt) {
> > -		if (victims)
> > +		if (victims) {
> > +			/*
> > +			 * It's not safe to mess with delegations that have a
> > +			 * non-zero dl_time. They might have already been broken
> > +			 * and could be processed by the laundromat outside of
> > +			 * the state_lock. Just leave them be.
> > +			 */
> > +			if (dp->dl_time != 0)
> > +				continue;
> > +
> > +			/*
> > +			 * Increment dl_time to ensure that delegation breaks
> > +			 * don't monkey with it now that we are.
> > +			 */
> > +			++dp->dl_time;
> >  			list_move(&dp->dl_recall_lru, victims);
> > +		}
> >  		if (++count == max)
> >  			break;
> >  	}
> > @@ -5107,14 +5128,19 @@ u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
> >  
> >  u64 nfsd_recall_client_delegations(struct nfs4_client *clp, u64 max)
> >  {
> > -	struct nfs4_delegation *dp, *next;
> > +	struct nfs4_delegation *dp;
> >  	LIST_HEAD(victims);
> >  	u64 count;
> >  
> >  	spin_lock(&state_lock);
> >  	count = nfsd_find_all_delegations(clp, max, &victims);
> > -	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru)
> > +	while (!list_empty(&victims)) {
> > +		dp = list_first_entry(&victims, struct nfs4_delegation,
> > +					dl_recall_lru);
> > +		list_del_init(&dp->dl_recall_lru);
> > +		dp->dl_time = 0;
> >  		nfsd_break_one_deleg(dp);
> > +	}
> >  	spin_unlock(&state_lock);
> >  
> >  	return count;
> > -- 
> > 1.9.3
> > 


-- 
Jeff Layton <jlayton@primarydata.com>
