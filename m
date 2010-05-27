From: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
Subject: RE: [PATCH 7/8] pnfs-submit: forgetful client model
Date: Thu, 27 May 2010 11:38:19 -0700
Message-ID: <B9364369CA66BF45806C2CD86EAB8BA60631FAAB@SACMVEXC3-PRD.hq.netapp.com>
References: <1274119004-30213-1-git-send-email-batsakis@netapp.com> <1274119004-30213-2-git-send-email-batsakis@netapp.com> <1274119004-30213-3-git-send-email-batsakis@netapp.com> <1274119004-30213-4-git-send-email-batsakis@netapp.com> <1274119004-30213-5-git-send-email-batsakis@netapp.com> <1274119004-30213-6-git-send-email-batsakis@netapp.com> <1274119004-30213-7-git-send-email-batsakis@netapp.com> <1274119004-30213-8-git-send-email-batsakis@netapp.com> <4BFCE7F6.8050209@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37840 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755166Ab0E0Sih convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 May 2010 14:38:37 -0400
In-Reply-To: <4BFCE7F6.8050209@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Benny,

Thanks for the review. I ll resend a new version shortly.

-alexandros

> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@panasas.com]
> Sent: Wednesday, May 26, 2010 2:21 AM
> To: Batsakis, Alexandros
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: [PATCH 7/8] pnfs-submit: forgetful client model
> 
> On 2010-05-17 20:56, Alexandros Batsakis wrote:
> > Forgetful client model:
> >
> > If we receive a CB_LAYOUTRECALL
> > 	- we spawn a thread to handle the recall
> > 	(xxx: now only one recall can be active at a time, else
> NFS4ERR_DELAY)
> > 	- we check the stateid seqid
> > 	if it does not match we return NFS4ERR_DELAY
> > 	- we check for pending I/O
> > 	if there is we return NFS4ERR_DELAY
> > 	Else we return NO_MATCHING_LAYOUT.
> > 	Note that for whole file layouts there is no need to serialize
> LAYOUTGETs/LAYOUTRETURNs
> > For bulk layouts, if there is a layout active, we return NFS4_OK and
> we start
> > cleaning the layouts asynchronously. At the end we send a bulk
> LAYOUTRETURN.
> > Note that there is no need to prevent any new LAYOUTGETs explicitly
> as the server should
> > reject them.
> >
> > Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> > ---
> >  fs/nfs/callback_proc.c |  131
++++++++++++++++++++++++++++++++++----
> ----------
> >  fs/nfs/inode.c         |    2 +-
> >  fs/nfs/nfs4_fs.h       |    1 +
> >  fs/nfs/nfs4proc.c      |    4 +-
> >  fs/nfs/nfs4state.c     |    2 +-
> >  fs/nfs/pnfs.c          |   78 +++++++++++++---------------
> >  fs/nfs/pnfs.h          |    8 ++-
> >  7 files changed, 139 insertions(+), 87 deletions(-)
> >
> > diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> > index 24e2571..419fee7 100644
> > --- a/fs/nfs/callback_proc.c
> > +++ b/fs/nfs/callback_proc.c
> > @@ -129,6 +129,38 @@ int nfs4_validate_delegation_stateid(struct
> nfs_delegation *delegation, const nf
> >
> >  #if defined(CONFIG_NFS_V4_1)
> >
> > +static int
> 
> can return bool
> 
> > +pnfs_is_next_layout_stateid(const struct pnfs_layout_type *lo,
> > +			    const nfs4_stateid stateid)
> > +{
> > +	int seq;
> 
> how about calling it seqlock so it will be less confusing
> with regards to seqid.
> 
> > +	int res;
> 
> and res is "bool" too.
> 
> > +	u32 oldseqid, newseqid;
> > +
> > +	do {
> > +		seq = read_seqbegin(&lo->seqlock);
> > +		oldseqid = ntohl(lo->stateid.u.stateid.seqid);
> > +		newseqid = ntohl(stateid.u.stateid.seqid);
> 
> let's use the more modern be32_to_cpu form...
> 
> > +		res = !memcmp(lo->stateid.u.stateid.other,
> > +			      stateid.u.stateid.other,
> > +			      NFS4_STATEID_OTHER_SIZE);
> > +		if (res) { /* comparing layout stateids */
> > +			if (oldseqid == ~0)
> > +				res = (newseqid == 1);
> > +			else
> > +				res = (newseqid == oldseqid + 1);
> > +		} else { /* open stateid */
> > +			res = !memcmp(lo->stateid.u.data,
> > +				      &zero_stateid,
> > +				      NFS4_STATEID_SIZE);
> > +			if (res)
> > +				res = (newseqid == 1);
> > +		}
> > +	} while (read_seqretry(&lo->seqlock, seq));
> > +
> > +	return res;
> > +}
> > +
> >  /*
> >   * Retrieve an inode based on layout recall parameters
> >   *
> > @@ -190,10 +222,11 @@ static int pnfs_recall_layout(void *data)
> >  {
> >  	struct inode *inode, *ino;
> >  	struct nfs_client *clp;
> > +	struct nfs4_pnfs_layoutreturn *lrp;
> >  	struct cb_pnfs_layoutrecallargs rl;
> >  	struct recall_layout_threadargs *args =
> >  		(struct recall_layout_threadargs *)data;
> > -	int status;
> > +	int status = 0;
> >
> >  	daemonize("nfsv4-layoutreturn");
> >
> > @@ -204,46 +237,57 @@ static int pnfs_recall_layout(void *data)
> >  	clp = args->clp;
> >  	inode = args->inode;
> >  	rl = *args->rl;
> > -	args->result = 0;
> > -	complete(&args->started);
> > -	args = NULL;
> > -	/* Note: args must not be used after this point!!! */
> > -
> > -/* FIXME: need barrier here:
> > -   pause I/O to data servers
> > -   pause layoutgets
> > -   drain all outstanding writes to storage devices
> > -   wait for any outstanding layoutreturns and layoutgets mentioned
> in
> > -   cb_sequence.
> > -   then return layouts, resume after layoutreturns complete
> > - */
> >
> >  	/* support whole file layouts only */
> >  	rl.cbl_seg.offset = 0;
> >  	rl.cbl_seg.length = NFS4_MAX_UINT64;
> >
> >  	if (rl.cbl_recall_type == RETURN_FILE) {
> > -		status = pnfs_return_layout(inode, &rl.cbl_seg,
> &rl.cbl_stateid,
> > -					    RETURN_FILE);
> > +		if (pnfs_is_next_layout_stateid(&NFS_I(inode)->layout,
> rl.cbl_stateid))
> > +			status = pnfs_return_layout(inode, &rl.cbl_seg,
> &rl.cbl_stateid,
> > +						    RETURN_FILE, 0);
> > +		else
> > +			status = htonl(NFS4ERR_DELAY);
> 
> cpu_to_be32?
> 
> > +		/* forgetful client */
> >  		if (status)
> > -			dprintk("%s RETURN_FILE error: %d\n", __func__,
> status);
> > +			dprintk("%s RETURN_FILE : %d\n", __func__,
status);
> > +		else
> > +			status =  htonl(NFS4ERR_NOMATCHING_LAYOUT);
> 
> ditto
> 
> > +		args->result = status;
> > +		complete(&args->started);
> >  		goto out;
> >  	}
> >
> > -	/* FIXME: This loop is inefficient, running in O(|s_inodes|^2)
*/
> 
> Hmm, I would like this to be fixed, eventually.
> Maybe FIXME is too harsh and IMPROVEME would be better :)
> 
> > +	status = htonl(NFS4_OK);
> 
> ditto
> 
> > +	args->result = status;
> > +	complete(&args->started);
> > +	args = NULL;
> > +
> >  	while ((ino = nfs_layoutrecall_find_inode(clp, &rl)) != NULL) {
> >  		/* XXX need to check status on pnfs_return_layout */
> 
> s/XXX/FIXME/
> 
> > -		pnfs_return_layout(ino, &rl.cbl_seg, NULL, RETURN_FILE);
> > +		pnfs_return_layout(ino, &rl.cbl_seg, NULL, RETURN_FILE,
0);
> >  		iput(ino);
> >  	}
> >
> > -	/* send final layoutreturn */
> > -	status = pnfs_return_layout(inode, &rl.cbl_seg, NULL,
> rl.cbl_recall_type);
> > -	if (status)
> > -		printk(KERN_INFO "%s: ignoring pnfs_return_layout
> status=%d\n",
> > -				__func__, status);
> > +	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
> > +	if (!lrp) {
> > +		dprintk("%s: allocation failed. Cannot send last
> LAYOUTRETURN\n",
> > +			__func__);
> > +		goto out;
> > +	}
> > +
> > +	/* send final layoutreturn (bulk) */
> > +	lrp->args.reclaim = 0;
> > +	lrp->args.layout_type = rl.cbl_layout_type;
> > +	lrp->args.return_type = rl.cbl_recall_type;
> > +	lrp->args.lseg = rl.cbl_seg;
> > +	lrp->args.inode = inode;
> > +	lrp->lo = NULL;
> > +
> > +	pnfs4_proc_layoutreturn(lrp);
> >  out:
> > -	iput(inode);
> > +	clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
> > +	nfs_put_client(clp);
> >  	module_put_and_exit(0);
> >  	dprintk("%s: exit status %d\n", __func__, 0);
> >  	return 0;
> > @@ -261,15 +305,18 @@ static int pnfs_async_return_layout(struct
> nfs_client *clp, struct inode *inode,
> >  		.rl = rl,
> >  	};
> >  	struct task_struct *t;
> > -	int status;
> > -
> > -	/* should have returned NFS4ERR_NOMATCHING_LAYOUT... */
> > -	BUG_ON(inode == NULL);
> > +	int status = htonl(NFS4ERR_DELAY);
> >
> >  	dprintk("%s: -->\n", __func__);
> >
> > +	/* XXX: do not allow two concurrent layout recalls */
> > +	if (test_and_set_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state))
> > +		return status;
> > +
> >  	init_completion(&data.started);
> >  	__module_get(THIS_MODULE);
> > +	if (!atomic_inc_not_zero(&clp->cl_count))
> > +		goto out_put_no_client;
> >
> >  	t = kthread_run(pnfs_recall_layout, &data, "%s",
> "pnfs_recall_layout");
> >  	if (IS_ERR(t)) {
> > @@ -283,6 +330,9 @@ static int pnfs_async_return_layout(struct
> nfs_client *clp, struct inode *inode,
> >  	wait_for_completion(&data.started);
> >  	return data.result;
> >  out_module_put:
> > +	nfs_put_client(clp);
> > +out_put_no_client:
> > +	clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
> >  	module_put(THIS_MODULE);
> >  	return status;
> >  }
> > @@ -309,19 +359,24 @@ __be32 pnfs_cb_layoutrecall(struct
> cb_pnfs_layoutrecallargs *args,
> >  	do {
> >  		struct nfs_client *prev = clp;
> >  		num_client++;
> > -		inode = nfs_layoutrecall_find_inode(clp, args);
> > -		if (inode != NULL) {
> > -			if (PNFS_LD(&NFS_I(inode)->layout)->id ==
> > -			    args->cbl_layout_type) {
> > -				/* Set up a helper thread to actually
> > -				 * return the delegation */
> > +		/* the callback must come from the MDS personality */
> > +		if (!(clp->cl_exchange_flags &
EXCHGID4_FLAG_USE_PNFS_MDS))
> > +			goto loop;
> > +		if (args->cbl_recall_type == RETURN_FILE) {
> > +			inode = nfs_layoutrecall_find_inode(clp, args);
> > +			if (inode != NULL) {
> >  				res = pnfs_async_return_layout(clp,
inode,
> args);
> > -				if (res != 0)
> > -					res = htonl(NFS4ERR_RESOURCE);
> > -				break;
> > +				iput(inode);
> >  			}
> > +		} else {
> > +			/* we need the inode to get the nfs_server
struct */
> > +			inode = nfs_layoutrecall_find_inode(clp, args);
> > +			if (!inode)
> > +				goto loop;
> > +			res = pnfs_async_return_layout(clp, inode,
args);
> >  			iput(inode);
> >  		}
> > +loop:
> >  		clp = nfs_find_client_next(prev);
> >  		nfs_put_client(prev);
> >  	} while (clp != NULL);
> > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > index adf3280..584c9b8 100644
> > --- a/fs/nfs/inode.c
> > +++ b/fs/nfs/inode.c
> > @@ -1321,7 +1321,7 @@ void nfs4_clear_inode(struct inode *inode)
> >  	/* First call standard NFS clear_inode() code */
> >  	nfs_clear_inode(inode);
> >  #ifdef CONFIG_NFS_V4_1
> > -	pnfs_return_layout(inode, NULL, NULL, RETURN_FILE);
> > +	pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, 1);
> >  #endif /* CONFIG_NFS_V4_1 */
> >  }
> >  #endif
> > diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> > index 40ebe1d..90c57b3 100644
> > --- a/fs/nfs/nfs4_fs.h
> > +++ b/fs/nfs/nfs4_fs.h
> > @@ -47,6 +47,7 @@ enum nfs4_client_state {
> >  	NFS4CLNT_SESSION_RESET,
> >  	NFS4CLNT_SESSION_DRAINING,
> >  	NFS4CLNT_RECALL_SLOT,
> > +	NFS4CLNT_LAYOUT_RECALL,
> >  };
> >
> >  /*
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 6739d15..14e90e1 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -1085,7 +1085,7 @@ static void pnfs4_layout_reclaim(struct
> nfs4_state *state)
> >  	/* FIXME: send gratuitous layout commits and return with the
> reclaim
> >  	 * flag during grace period
> >  	 */
> > -	pnfs_return_layout(state->inode, NULL, &state->open_stateid,
> RETURN_FILE);
> > +	pnfs_return_layout(state->inode, NULL, NULL, RETURN_FILE, 1);
> >  	pnfs_set_layout_stateid(&NFS_I(state->inode)->layout,
> &zero_stateid);
> >  #endif /* CONFIG_NFS_V4_1 */
> >  }
> > @@ -2382,7 +2382,7 @@ pnfs4_proc_setattr(struct dentry *dentry,
> struct nfs_fattr *fattr,
> >
> >  	if (pnfs_enabled_sb(server) && has_layout(nfsi) &&
> >  	    pnfs_ld_layoutret_on_setattr(server->pnfs_curr_ld))
> > -		pnfs_return_layout(inode, NULL, NULL, RETURN_FILE);
> > +		pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, 1);
> >  	return nfs4_proc_setattr(dentry, fattr, sattr);
> >  }
> >  #endif /* CONFIG_NFS_V4_1 */
> > diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> > index 2d52300..cd2ae83 100644
> > --- a/fs/nfs/nfs4state.c
> > +++ b/fs/nfs/nfs4state.c
> > @@ -598,7 +598,7 @@ static void __nfs4_close(struct path *path,
> struct nfs4_state *state, fmode_t fm
> >  			range.offset = 0;
> >  			range.length = NFS4_MAX_UINT64;
> >  			pnfs_return_layout(state->inode, &range, NULL,
> > -					   RETURN_FILE);
> > +					   RETURN_FILE, 1);
> >  		}
> >  #endif /* CONFIG_NFS_V4_1 */
> >  		nfs4_do_close(path, state, wait);
> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > index 3b4dea0..2c96723 100644
> > --- a/fs/nfs/pnfs.c
> > +++ b/fs/nfs/pnfs.c
> > @@ -610,7 +610,7 @@ get_layout(struct inode *ino,
> >   */
> >  static inline int
> >  should_free_lseg(struct pnfs_layout_segment *lseg,
> > -		   struct nfs4_pnfs_layout_segment *range)
> > +		 struct nfs4_pnfs_layout_segment *range)
> >  {
> >  	return (range->iomode == IOMODE_ANY ||
> >  		lseg->range.iomode == range->iomode) &&
> > @@ -703,6 +703,8 @@ return_layout(struct inode *ino, struct
> nfs4_pnfs_layout_segment *range,
> >
> >  	dprintk("--> %s\n", __func__);
> >
> > +	BUG_ON(type != RETURN_FILE);
> > +
> >  	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
> >  	if (lrp == NULL) {
> >  		if (lo && (type == RETURN_FILE))
> > @@ -729,7 +731,8 @@ out:
> >  int
> >  _pnfs_return_layout(struct inode *ino, struct
> nfs4_pnfs_layout_segment *range,
> >  		    const nfs4_stateid *stateid, /* optional */
> > -		    enum pnfs_layoutreturn_type type)
> > +		    enum pnfs_layoutreturn_type type,
> > +		    int sendreturn)
> 
> s/int/bool/
> and we should use true/false rather than 1/0 in call sites.
> 
> >  {
> >  	struct pnfs_layout_type *lo = NULL;
> >  	struct nfs_inode *nfsi = NFS_I(ino);
> > @@ -739,14 +742,19 @@ _pnfs_return_layout(struct inode *ino, struct
> nfs4_pnfs_layout_segment *range,
> >  	dprintk("--> %s type %d\n", __func__, type);
> >
> >  	if (range)
> > -		arg = *range;
> > -	else {
> > +		arg.iomode = range->iomode;
> > +	else
> >  		arg.iomode = IOMODE_ANY;
> 
> how about
> 	arg.iomode = range ? range->iomode : IOMODE_ANY;
> 
> > -		arg.offset = 0;
> > -		arg.length = ~0;
> > -	}
> > +	arg.offset = 0;
> > +	arg.length = ~0;
> 
> NFS4_MAX_UINT64
> 
> > +
> >  	if (type == RETURN_FILE) {
> >  		if (nfsi->layout.layoutcommit_ctx) {
> > +			if (stateid && !sendreturn) { /* callback */
> > +				dprintk("%s: layoutcommit pending\n",
> __func__);
> > +				status = htonl(NFS4ERR_DELAY);
> 
> this function currently returns system errors, not nfs'p.
> 
> > +				goto out;
> > +			}
> >  			status = pnfs_layoutcommit_inode(ino, 1);
> >  			if (status) {
> >  				dprintk("%s: layoutcommit failed,
status=%d. "
> > @@ -763,11 +771,7 @@ _pnfs_return_layout(struct inode *ino, struct
> nfs4_pnfs_layout_segment *range,
> >  		}
> >  		if (!lo) {
> >  			dprintk("%s: no layout segments to return\n",
> __func__);
> > -			/* must send the LAYOUTRETURN in response to
recall
> */
> > -			if (stateid)
> > -				goto send_return;
> > -			else
> > -				goto out;
> > +			goto out;
> 
> what about the sendreturn case?
> 
> >  		}
> >
> >  		/* unlock w/o put rebalanced by eventual call to
> > @@ -776,13 +780,22 @@ _pnfs_return_layout(struct inode *ino, struct
> nfs4_pnfs_layout_segment *range,
> >  		unlock_current_layout(nfsi);
> >
> >  		if (pnfs_return_layout_barrier(nfsi, &arg)) {
> > +			if (stateid) { /* callback */
> > +				status = htonl(NFS4ERR_DELAY);
> 
> ditto
> 
> > +				lock_current_layout(nfsi);
> > +				put_unlock_current_layout(lo);
> > +				goto out;
> > +			}
> >  			dprintk("%s: waiting\n", __func__);
> >  			wait_event(nfsi->lo_waitq,
> > -				!pnfs_return_layout_barrier(nfsi,
&arg));
> > +				   !pnfs_return_layout_barrier(nfsi,
&arg));
> >  		}
> > +
> > +		if (sendreturn)
> > +			status = return_layout(ino, &arg, stateid, type,
lo);
> > +		else
> > +			pnfs_layout_release(lo, &arg);
> >  	}
> > -send_return:
> > -	status = return_layout(ino, &arg, stateid, type, lo);
> >  out:
> >  	dprintk("<-- %s status: %d\n", __func__, status);
> >  	return status;
> > @@ -1080,31 +1093,12 @@ pnfs_update_layout(struct inode *ino,
> >  	/* Check to see if the layout for the given range already exists
> */
> >  	lseg = pnfs_has_layout(lo, &arg, take_ref, !take_ref);
> >  	if (lseg && !lseg->valid) {
> > -		unlock_current_layout(nfsi);
> >  		if (take_ref)
> >  			put_lseg(lseg);
> > -		for (;;) {
> > -			prepare_to_wait(&nfsi->lo_waitq, &__wait,
> > -					TASK_KILLABLE);
> > -			lock_current_layout(nfsi);
> > -			lseg = pnfs_has_layout(lo, &arg, take_ref,
> !take_ref);
> > -			if (!lseg || lseg->valid)
> > -				break;
> > -			dprintk("%s: invalid lseg %p ref %d\n",
__func__,
> > -				lseg,
atomic_read(&lseg->kref.refcount)-1);
> > -			if (take_ref)
> > -				put_lseg(lseg);
> > -			if (signal_pending(current)) {
> > -				lseg = NULL;
> > -				result = -ERESTARTSYS;
> > -				break;
> > -			}
> > -			unlock_current_layout(nfsi);
> > -			schedule();
> > -		}
> > -		finish_wait(&nfsi->lo_waitq, &__wait);
> > -		if (result)
> > -			goto out_put;
> > +
> > +		/* someone is cleaning the layout */
> > +		result = -EAGAIN;
> 
> Ah well, I'm not sure if this works, did you test that?
> Anyhow, will work properly with the long awaited state machine.
> 
> > +		goto out_put;
> >  	}
> >
> >  	if (lseg) {
> > @@ -1434,7 +1428,7 @@ pnfs_pageio_init_read(struct
> nfs_pageio_descriptor *pgio,
> >
> >  	if (count > 0 && !below_threshold(inode, count, 0)) {
> >  		status = pnfs_update_layout(inode, ctx, count,
> > -						loff, IOMODE_READ,
NULL);
> > +					    loff, IOMODE_READ, NULL);
> >  		dprintk("%s *rsize %Zd virt update returned %d\n",
> >  			__func__, *rsize, status);
> >  		if (status != 0)
> > @@ -1673,7 +1667,7 @@ pnfs_writeback_done(struct nfs_write_data
> *data)
> >  			.length = data->args.count,
> >  		};
> >  		dprintk("%s: retrying\n", __func__);
> > -		_pnfs_return_layout(data->inode, &range, NULL,
> RETURN_FILE);
> > +		_pnfs_return_layout(data->inode, &range, NULL,
RETURN_FILE,
> 1);
> 
> s/1/true/
> 
> >  		pnfs_initiate_write(data, NFS_CLIENT(data->inode),
> >  				    pdata->call_ops, pdata->how);
> >  	}
> > @@ -1804,7 +1798,7 @@ pnfs_read_done(struct nfs_read_data *data)
> >  			.length = data->args.count,
> >  		};
> >  		dprintk("%s: retrying\n", __func__);
> > -		_pnfs_return_layout(data->inode, &range, NULL,
> RETURN_FILE);
> > +		_pnfs_return_layout(data->inode, &range, NULL,
RETURN_FILE,
> 1);
> 
> ditto
> 
> >  		pnfs_initiate_read(data, NFS_CLIENT(data->inode),
> >  				   pdata->call_ops);
> >  	}
> > @@ -2030,7 +2024,7 @@ pnfs_commit_done(struct nfs_write_data *data)
> >  			.length = data->args.count,
> >  		};
> >  		dprintk("%s: retrying\n", __func__);
> > -		_pnfs_return_layout(data->inode, &range, NULL,
> RETURN_FILE);
> > +		_pnfs_return_layout(data->inode, &range, NULL,
RETURN_FILE,
> 1);
> 
> ditto
> 
> >  		pnfs_initiate_commit(data, NFS_CLIENT(data->inode),
> >  				     pdata->call_ops, pdata->how);
> >  	}
> > diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> > index 9e43973..794a2d3 100644
> > --- a/fs/nfs/pnfs.h
> > +++ b/fs/nfs/pnfs.h
> > @@ -40,7 +40,8 @@ int pnfs_update_layout(struct inode *ino, struct
> nfs_open_context *ctx,
> >
> >  int _pnfs_return_layout(struct inode *, struct
> nfs4_pnfs_layout_segment *,
> >  			const nfs4_stateid *stateid, /* optional */
> > -			enum pnfs_layoutreturn_type);
> > +			enum pnfs_layoutreturn_type,
> > +			int sendreturn);
> 
> bool
> 
> >  void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh
> *mntfh, u32 id);
> >  void unmount_pnfs_layoutdriver(struct nfs_server *);
> >  int pnfs_use_read(struct inode *inode, ssize_t count);
> > @@ -236,14 +237,15 @@ static inline void
> pnfs_modify_new_request(struct nfs_page *req,
> >  static inline int pnfs_return_layout(struct inode *ino,
> >  				     struct nfs4_pnfs_layout_segment
*lseg,
> >  				     const nfs4_stateid *stateid, /*
optional
> */
> > -				     enum pnfs_layoutreturn_type type)
> > +				     enum pnfs_layoutreturn_type type,
> > +				     int sendreturn)
> 
> bool
> 
> Thanks!
> 
> Benny
> 
> >  {
> >  	struct nfs_inode *nfsi = NFS_I(ino);
> >  	struct nfs_server *nfss = NFS_SERVER(ino);
> >
> >  	if (pnfs_enabled_sb(nfss) &&
> >  	    (type != RETURN_FILE || has_layout(nfsi)))
> > -		return _pnfs_return_layout(ino, lseg, stateid, type);
> > +		return _pnfs_return_layout(ino, lseg, stateid, type,
> sendreturn);
> >
> >  	return 0;
> >  }

