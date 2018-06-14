Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55296 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755085AbeFNQc6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 12:32:58 -0400
Date: Thu, 14 Jun 2018 12:32:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: devel@lists.nfs-ganesha.org, sostapov@redhat.com,
        Supriti.Singh@suse.com,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH] rados_cluster: add a "design" manpage
Message-ID: <20180614163257.GD24594@fieldses.org>
References: <20180523122140.8373-1-jlayton@kernel.org>
 <20180531213733.GB4654@fieldses.org>
 <fbc5ad16342dc1b4d50041bfa1274fc0197486a9.camel@kernel.org>
 <20180601141725.GB10666@fieldses.org>
 <84dd9dbf7e11818cd4188b01e0834a1f04cd24ae.camel@kernel.org>
 <20180601144655.GD10666@fieldses.org>
 <20180608163307.GC12719@fieldses.org>
 <9783b24b59a30f700c307cdd2771ea72c67be097.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9783b24b59a30f700c307cdd2771ea72c67be097.camel@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 14, 2018 at 06:01:27AM -0400, Jeff Layton wrote:
> I know this is a "best effort" sort of thing, but should this be done
> with atomic loads and stores (READ_ONCE/WRITE_ONCE)?

We're just setting it to 1 when a reclaim comes in, and then once a
second checking the result and clearing it.  So yes that's a slightly
sloppy way of checking whether something happens once a second.

I *think* the worst that could happen is something like:

	read 0 from somebody_reclaimed
					reclaim writes 1 to somebody_reclaimed
	write 0 to somebody_reclaimed

and then a client that's reclaiming only very close to the 1-second mark
could get overlooked.

I'm assuming in any reasonable situation that a client can manage at
least 10-100 reclaims a second, and that the race window is probably
several orders of magnitude less than a second (even after taking into
account weird memory ordering).

Would READ/WRITE_ONCE do it right?  I'm not sure it's worth it.

--b.


> 
> >  
> >  	dprintk("NFSD: nfsd4_open filename %.*s op_openowner %p\n",
> >  		(int)open->op_fname.len, open->op_fname.data,
> > @@ -424,6 +425,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  			if (status)
> >  				goto out;
> >  			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
> > +			reclaim = true;
> >  		case NFS4_OPEN_CLAIM_FH:
> >  		case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
> >  			status = do_open_fhandle(rqstp, cstate, open);
> > @@ -452,6 +454,8 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	WARN(status && open->op_created,
> >  	     "nfsd4_process_open2 failed to open newly-created file! status=%u\n",
> >  	     be32_to_cpu(status));
> > +	if (reclaim && !status)
> > +		nn->somebody_reclaimed = true;
> >  out:
> >  	if (resfh && resfh != &cstate->current_fh) {
> >  		fh_dup2(&cstate->current_fh, resfh);
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 59ae65d3eec3..ffe816fe6e89 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -4689,6 +4689,28 @@ nfsd4_end_grace(struct nfsd_net *nn)
> >  	 */
> >  }
> >  
> > +/*
> > + * If we've waited a lease period but there are still clients trying to
> > + * reclaim, wait a little longer to give them a chance to finish.
> > + */
> > +static bool clients_still_reclaiming(struct nfsd_net *nn)
> > +{
> > +	unsigned long now = get_seconds();
> > +	unsigned long double_grace_period_end = nn->boot_time +
> > +						2 * nn->nfsd4_lease;
> > +
> > +	if (!nn->somebody_reclaimed)
> > +		return false;
> > +	nn->somebody_reclaimed = false;
> > +	/*
> > +	 * If we've given them *two* lease times to reclaim, and they're
> > +	 * still not done, give up:
> > +	 */
> > +	if (time_after(now, double_grace_period_end))
> > +		return false;
> > +	return true;
> > +}
> > +
> >  static time_t
> >  nfs4_laundromat(struct nfsd_net *nn)
> >  {
> > @@ -4702,6 +4724,11 @@ nfs4_laundromat(struct nfsd_net *nn)
> >  	time_t t, new_timeo = nn->nfsd4_lease;
> >  
> >  	dprintk("NFSD: laundromat service - starting\n");
> > +
> > +	if (clients_still_reclaiming(nn)) {
> > +		new_timeo = 0;
> > +		goto out;
> > +	}
> >  	nfsd4_end_grace(nn);
> >  	INIT_LIST_HEAD(&reaplist);
> >  	spin_lock(&nn->client_lock);
> > @@ -4799,7 +4826,7 @@ nfs4_laundromat(struct nfsd_net *nn)
> >  		posix_unblock_lock(&nbl->nbl_lock);
> >  		free_blocked_lock(nbl);
> >  	}
> > -
> > +out:
> >  	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
> >  	return new_timeo;
> >  }
> > @@ -6049,6 +6076,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	case 0: /* success! */
> >  		nfs4_inc_and_copy_stateid(&lock->lk_resp_stateid, &lock_stp->st_stid);
> >  		status = 0;
> > +		if (lock->lk_reclaim)
> > +			nn->somebody_reclaimed = true;
> >  		break;
> >  	case FILE_LOCK_DEFERRED:
> >  		nbl = NULL;
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index d107b4426f7e..5f22476cf371 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -1239,6 +1239,7 @@ static __net_init int nfsd_init_net(struct net *net)
> >  		goto out_idmap_error;
> >  	nn->nfsd4_lease = 90;	/* default lease time */
> >  	nn->nfsd4_grace = 90;
> > +	nn->somebody_reclaimed = false;
> >  	nn->clverifier_counter = prandom_u32();
> >  	nn->clientid_counter = prandom_u32();
> >  
> 
> -- 
> Jeff Layton <jlayton@kernel.org>
