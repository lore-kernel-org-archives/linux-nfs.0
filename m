Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38215 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253AbaG2Rxo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jul 2014 13:53:44 -0400
Date: Tue, 29 Jul 2014 13:53:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v6 2/9] nfsd: fully unhash delegations when revoking them
Message-ID: <20140729175341.GA21091@fieldses.org>
References: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
 <1406288067-20663-3-git-send-email-jlayton@primarydata.com>
 <20140729145331.GB19210@fieldses.org>
 <20140729124143.7e3bae67@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140729124143.7e3bae67@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2014 at 12:41:43PM -0400, Jeff Layton wrote:
> On Tue, 29 Jul 2014 10:53:31 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Fri, Jul 25, 2014 at 07:34:20AM -0400, Jeff Layton wrote:
> > > @@ -698,11 +699,10 @@ static void revoke_delegation(struct nfs4_delegation *dp)
> > >  	struct nfs4_client *clp = dp->dl_stid.sc_client;
> > >  
> > >  	if (clp->cl_minorversion == 0)
> > > -		destroy_delegation(dp);
> > > +		destroy_revoked_delegation(dp);
> > 
> > I don't understand this one--in the NFSv4.0 case, when is the delegation
> > unhashed?
> > 
> > (And, apologies if that's a repeat question.  I remember wondering about
> > this before but can't find mail in the archives....)
> > 
> > --b.
> > 
> 
> It's unhashed by the laundromat (or the fault injection code). The
> deltas that change that are later in this patch, but it doesn't have
> much context so it's a little tricky to spot. Here's the relevant code
> chunk from nfs4_laundromat:
> 
> ---------------[snip]-----------------
>         spin_lock(&state_lock);
>         list_for_each_safe(pos, next, &nn->del_recall_lru) {
>                 dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
>                 if (net_generic(dp->dl_stid.sc_client->net, nfsd_net_id) != nn)
>                         continue;
>                 if (time_after((unsigned long)dp->dl_time, (unsigned long)cutoff)) {
>                         t = dp->dl_time - cutoff;
>                         new_timeo = min(new_timeo, t);
>                         break;
>                 }
>                 unhash_delegation_locked(dp);
>                 list_add(&dp->dl_recall_lru, &reaplist);
>         }
>         spin_unlock(&state_lock);
>         list_for_each_safe(pos, next, &reaplist) {
>                 dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
>                 revoke_delegation(dp);
>         }
> ---------------[snip]-----------------
> 
> ...so the laundromat walks the nn->del_recall_lru list, unhashes any
> delegation that has expired and gathers them up onto the list. Then, it
> calls revoke_delegation on each outside of the lock.

Got it, thanks.

> As a side note, that net_generic comparison there looks bogus to me.
> How could you ever end up with an entry from a different namespace on
> this list? I left it in for now since it didn't seem relevant (or
> terribly expensive), but I suspect that it can be removed (or turned
> into a WARN or something).

Looks like this was an oversight from e8c69d17d1ef.  I'd be fine with
just removing it.

--b.

> 
> > >  	else {
> > > -		unhash_delegation(dp);
> > >  		dp->dl_stid.sc_type = NFS4_REVOKED_DELEG_STID;
> > > -		list_add(&dp->dl_recall_lru, &clp->cl_revoked);
> > > +		list_move(&dp->dl_recall_lru, &clp->cl_revoked);
> > >  	}
> > >  }
> > >  
> > > @@ -1458,15 +1458,14 @@ destroy_client(struct nfs4_client *clp)
> > >  	spin_lock(&state_lock);
> > >  	while (!list_empty(&clp->cl_delegations)) {
> > >  		dp = list_entry(clp->cl_delegations.next, struct
> > > nfs4_delegation, dl_perclnt);
> > > -		list_del_init(&dp->dl_perclnt);
> > > -		/* Ensure that deleg break won't try to requeue it
> > > */
> > > -		++dp->dl_time;
> > > -		list_move(&dp->dl_recall_lru, &reaplist);
> > > +		unhash_delegation_locked(dp);
> > > +		list_add(&dp->dl_recall_lru, &reaplist);
> > >  	}
> > >  	spin_unlock(&state_lock);
> > >  	while (!list_empty(&reaplist)) {
> > >  		dp = list_entry(reaplist.next, struct
> > > nfs4_delegation, dl_recall_lru);
> > > -		destroy_delegation(dp);
> > > +		list_del_init(&dp->dl_recall_lru);
> > > +		nfs4_put_delegation(dp);
> > >  	}
> > >  	list_splice_init(&clp->cl_revoked, &reaplist);
> > >  	while (!list_empty(&reaplist)) {
> > > @@ -3662,7 +3661,7 @@ nfs4_open_delegation(struct net *net, struct
> > > svc_fh *fh, open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
> > >  	return;
> > >  out_free:
> > > -	destroy_delegation(dp);
> > > +	nfs4_put_delegation(dp);
> > >  out_no_deleg:
> > >  	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
> > >  	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
> > > @@ -3900,7 +3899,8 @@ nfs4_laundromat(struct nfsd_net *nn)
> > >  			new_timeo = min(new_timeo, t);
> > >  			break;
> > >  		}
> > > -		list_move(&dp->dl_recall_lru, &reaplist);
> > > +		unhash_delegation_locked(dp);
> > > +		list_add(&dp->dl_recall_lru, &reaplist);
> > >  	}
> > >  	spin_unlock(&state_lock);
> > >  	list_for_each_safe(pos, next, &reaplist) {
> > > @@ -5382,12 +5382,8 @@ static u64 nfsd_find_all_delegations(struct
> > > nfs4_client *clp, u64 max, if (dp->dl_time != 0)
> > >  				continue;
> > >  
> > > -			/*
> > > -			 * Increment dl_time to ensure that
> > > delegation breaks
> > > -			 * don't monkey with it now that we are.
> > > -			 */
> > > -			++dp->dl_time;
> > > -			list_move(&dp->dl_recall_lru, victims);
> > > +			unhash_delegation_locked(dp);
> > > +			list_add(&dp->dl_recall_lru, victims);
> > >  		}
> > >  		if (++count == max)
> > >  			break;
> > > @@ -5642,12 +5638,14 @@ nfs4_state_shutdown_net(struct net *net)
> > >  	spin_lock(&state_lock);
> > >  	list_for_each_safe(pos, next, &nn->del_recall_lru) {
> > >  		dp = list_entry (pos, struct nfs4_delegation,
> > > dl_recall_lru);
> > > -		list_move(&dp->dl_recall_lru, &reaplist);
> > > +		unhash_delegation_locked(dp);
> > > +		list_add(&dp->dl_recall_lru, &reaplist);
> > >  	}
> > >  	spin_unlock(&state_lock);
> > >  	list_for_each_safe(pos, next, &reaplist) {
> > >  		dp = list_entry (pos, struct nfs4_delegation,
> > > dl_recall_lru);
> > > -		destroy_delegation(dp);
> > > +		list_del_init(&dp->dl_recall_lru);
> > > +		nfs4_put_delegation(dp);
> > >  	}
> > >  
> > >  	nfsd4_client_tracking_exit(net);
> > > -- 
> > > 1.9.3
> > > 
> 
> 
> -- 
> Jeff Layton <jlayton@primarydata.com>
