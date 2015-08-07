Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:33253 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbbHGLLC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2015 07:11:02 -0400
Received: by ykoo205 with SMTP id o205so85889640yko.0
        for <linux-nfs@vger.kernel.org>; Fri, 07 Aug 2015 04:11:01 -0700 (PDT)
Date: Fri, 7 Aug 2015 07:10:58 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: grace-period ending & NLM
Message-ID: <20150807071058.689d83e9@tlielax.poochiereds.net>
In-Reply-To: <20150807010234.GA8747@fieldses.org>
References: <20150806202336.GA7235@fieldses.org>
	<20150806182442.13f19d7e@tlielax.poochiereds.net>
	<20150807010234.GA8747@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 6 Aug 2015 21:02:34 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Aug 06, 2015 at 06:24:42PM -0400, Jeff Layton wrote:
> > On Thu, 6 Aug 2015 16:23:36 -0400
> > bfields@fieldses.org (J. Bruce Fields) wrote:
> > 
> > > We have two grace periods, one for NLM and one for NFSv4+, and don't
> > > permit normal locking until both are over.
> > > 
> > > As far as I can tell nfsdcltrack doesn't understand statd/NSM state; it
> > > only concerns itself with NFSv4+.  It can end the NFSv4 grace period
> > > early, but that still leaves the server returning GRACE errors until NSM
> > > exits its grace period.
> > > 
> > > The server has never had any smarts to end the NSM grace period early,
> > > even though there are common cases (e.g., no clients at all) where it
> > > easily could.  We could fix that.
> > > 
> > 
> > Erm...but it does have those smarts. statd should end the grace period
> > early if there were no clients to be notified when it starts. That's
> > done by writing to /proc/fs/lockd/nlm_end_grace. Those patches were
> > merged upstream in the kernel and nfs-utils around the same time as the
> > other early grace lifting patches.
> 
> Yeah, I don't know how I forgot that.  Thanks for the reminder.  That
> doesn't seem to be working for me on Fedora 21.  I'll take another look.
> 
> (I may still apply ths patch if you don't see a problem with it.)
> 
> --b.
> 

No objection. I think it looks reasonable.

I'd also be interested to know why the NLM grace period isn't being
lifted early for you. That did work when I tested it last.

Oh, and I misstated earlier...it's not statd that lifts the grace
period early, it's sm-notify. sm-notify is in charge of notifying hosts
after a reboot and if it has none to notify it'll write "Y" to that file
(if it exists).


> > 
> > > But one quick thing we can do to limit the impact of the NLM grace
> > > period is just to note that NLM locks have never conflicted with NFSv4
> > > opens, so NFSv4 opens don't really need to be waiting.
> > > 
> > > Am I missing anything?
> > > 
> > > --b.
> > > 
> > > commit d2ab7fe05cd0
> > > Author: J. Bruce Fields <bfields@redhat.com>
> > > Date:   Thu Aug 6 12:47:02 2015 -0400
> > > 
> > >     lockd: NLM grace period shouldn't block NFSv4 opens
> > >     
> > >     NLM locks don't conflict with NFSv4 share reservations, so we're not
> > >     going to learn anything new by watiting for them.
> > >     
> > >     They do conflict with NFSv4 locks and with delegations.
> > >     
> > >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > 
> > > diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> > > index 530914b5c455..d678bcc3cbcb 100644
> > > --- a/fs/lockd/svc.c
> > > +++ b/fs/lockd/svc.c
> > > @@ -591,6 +591,7 @@ static int lockd_init_net(struct net *net)
> > >  
> > >  	INIT_DELAYED_WORK(&ln->grace_period_end, grace_ender);
> > >  	INIT_LIST_HEAD(&ln->lockd_manager.list);
> > > +	ln->lockd_manager.block_opens = false;
> > >  	spin_lock_init(&ln->nsm_clnt_lock);
> > >  	return 0;
> > >  }
> > > diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
> > > index ae6e58ea4de5..fd8c9a5bcac4 100644
> > > --- a/fs/nfs_common/grace.c
> > > +++ b/fs/nfs_common/grace.c
> > > @@ -63,14 +63,33 @@ EXPORT_SYMBOL_GPL(locks_end_grace);
> > >   * lock reclaims.
> > >   */
> > >  int
> > > -locks_in_grace(struct net *net)
> > > +__state_in_grace(struct net *net, bool open)
> > >  {
> > >  	struct list_head *grace_list = net_generic(net, grace_net_id);
> > > +	struct lock_manager *lm;
> > >  
> > > -	return !list_empty(grace_list);
> > > +	if (!open)
> > > +		return !list_empty(grace_list);
> > > +
> > > +	list_for_each_entry(lm, grace_list, list) {
> > > +		if (lm->block_opens)
> > > +			return true;
> > > +	}
> > > +	return false;
> > > +}
> > > +
> > > +int locks_in_grace(struct net *net)
> > > +{
> > > +	return __state_in_grace(net, 0);
> > 
> > nit: 0 -> false (since the arg is a bool)
> > 
> > >  }
> > >  EXPORT_SYMBOL_GPL(locks_in_grace);
> > >  
> > > +int opens_in_grace(struct net *net)
> > > +{
> > > +	return __state_in_grace(net, 1);
> > > +}
> > > +EXPORT_SYMBOL_GPL(opens_in_grace);
> > > +
> > >  static int __net_init
> > >  grace_init_net(struct net *net)
> > >  {
> > > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > > index e779d7db24b0..b9681ee0ed19 100644
> > > --- a/fs/nfsd/nfs4proc.c
> > > +++ b/fs/nfsd/nfs4proc.c
> > > @@ -415,10 +415,10 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > >  	/* Openowner is now set, so sequence id will get bumped.  Now we need
> > >  	 * these checks before we do any creates: */
> > >  	status = nfserr_grace;
> > > -	if (locks_in_grace(net) && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
> > > +	if (opens_in_grace(net) && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
> > >  		goto out;
> > >  	status = nfserr_no_grace;
> > > -	if (!locks_in_grace(net) && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
> > > +	if (!opens_in_grace(net) && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
> > >  		goto out;
> > >  
> > >  	switch (open->op_claim_type) {
> > > @@ -827,7 +827,7 @@ nfsd4_remove(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > >  {
> > >  	__be32 status;
> > >  
> > > -	if (locks_in_grace(SVC_NET(rqstp)))
> > > +	if (opens_in_grace(SVC_NET(rqstp)))
> > >  		return nfserr_grace;
> > >  	status = nfsd_unlink(rqstp, &cstate->current_fh, 0,
> > >  			     remove->rm_name, remove->rm_namelen);
> > > @@ -846,7 +846,7 @@ nfsd4_rename(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > >  
> > >  	if (!cstate->save_fh.fh_dentry)
> > >  		return status;
> > > -	if (locks_in_grace(SVC_NET(rqstp)) &&
> > > +	if (opens_in_grace(SVC_NET(rqstp)) &&
> > >  		!(cstate->save_fh.fh_export->ex_flags & NFSEXP_NOSUBTREECHECK))
> > >  		return nfserr_grace;
> > >  	status = nfsd_rename(rqstp, &cstate->save_fh, rename->rn_sname,
> > > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > > index c94859122e6f..97fe7c8c6a8e 100644
> > > --- a/fs/nfsd/nfs4state.c
> > > +++ b/fs/nfsd/nfs4state.c
> > > @@ -4052,7 +4052,8 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
> > >  		case NFS4_OPEN_CLAIM_FH:
> > >  			/*
> > >  			 * Let's not give out any delegations till everyone's
> > > -			 * had the chance to reclaim theirs....
> > > +			 * had the chance to reclaim theirs, *and* until
> > > +			 * NLM locks have all been reclaimed:
> > >  			 */
> > >  			if (locks_in_grace(clp->net))
> > >  				goto out_no_deleg;
> > > @@ -4426,7 +4427,7 @@ check_special_stateids(struct net *net, svc_fh *current_fh, stateid_t *stateid,
> > >  {
> > >  	if (ONE_STATEID(stateid) && (flags & RD_STATE))
> > >  		return nfs_ok;
> > > -	else if (locks_in_grace(net)) {
> > > +	else if (opens_in_grace(net)) {
> > >  		/* Answer in remaining cases depends on existence of
> > >  		 * conflicting state; so we must wait out the grace period. */
> > >  		return nfserr_grace;
> > > @@ -4445,7 +4446,7 @@ check_special_stateids(struct net *net, svc_fh *current_fh, stateid_t *stateid,
> > >  static inline int
> > >  grace_disallows_io(struct net *net, struct inode *inode)
> > >  {
> > > -	return locks_in_grace(net) && mandatory_lock(inode);
> > > +	return opens_in_grace(net) && mandatory_lock(inode);
> > >  }
> > >  
> > >  /* Returns true iff a is later than b: */
> > > @@ -6564,6 +6565,7 @@ nfs4_state_start_net(struct net *net)
> > >  		return ret;
> > >  	nn->boot_time = get_seconds();
> > >  	nn->grace_ended = false;
> > > +	nn->nfsd4_manager.block_opens = true;
> > >  	locks_start_grace(net, &nn->nfsd4_manager);
> > >  	nfsd4_client_tracking_init(net);
> > >  	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %p)\n",
> > > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > > index cc008c338f5a..9a9d314f7b27 100644
> > > --- a/include/linux/fs.h
> > > +++ b/include/linux/fs.h
> > > @@ -942,12 +942,18 @@ struct lock_manager_operations {
> > >  
> > >  struct lock_manager {
> > >  	struct list_head list;
> > > +	/*
> > > +	 * NFSv4 and up also want opens blocked during the grace period;
> > > +	 * NLM doesn't care:
> > > +	 */
> > > +	bool block_opens;
> > >  };
> > >  
> > >  struct net;
> > >  void locks_start_grace(struct net *, struct lock_manager *);
> > >  void locks_end_grace(struct lock_manager *);
> > >  int locks_in_grace(struct net *);
> > > +int opens_in_grace(struct net *);
> > >  
> > >  /* that will die - we need it for nfs_lock_info */
> > >  #include <linux/nfs_fs_i.h>
> > 
> > 
> > Looks reasonable to me. I can't think of any reason for NLM to block v4
> > opens.
> > 
> > Acked-by: Jeff Layton <jeff.layton@primarydata.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jeff.layton@primarydata.com>
