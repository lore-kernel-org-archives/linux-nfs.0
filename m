Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31119 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755207Ab0KNLoR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Nov 2010 06:44:17 -0500
Message-ID: <4CDFCB8D.7040209@panasas.com>
Date: Sun, 14 Nov 2010 13:44:13 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 16/22] pnfs-submit: rewrite of layout state handling and
 cb_layoutrecall
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>	 <1289551724-18575-17-git-send-email-iisaman@netapp.com> <1289639517.3669.9.camel@heimdal.trondhjem.org>
In-Reply-To: <1289639517.3669.9.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-13 11:11, Trond Myklebust wrote:
> On Fri, 2010-11-12 at 03:48 -0500, Fred Isaman wrote:
>> Remove NFS_LAYOUT_STATEID_SET in favor of just checking list_empty(lo->segs).
>>
>> LAYOUTGETs with openstateid are serialized.  Waiting on the condition
>> (list_empty(lo->segs) && plh_outstanding>0) both drains outstanding RPCs once
>> the stateid is invalidated and allows only a single LAYOUTGET(openstateid)
>> through at a time.
>>
>> Before sending a LAYOUTRETURN, plh_block_lgets is incremented.  It is
>> decremented in the rpc_release function.  While set, LAYOUTGETs are
>> paused in their rpc_prepare function, and any responses are
>> forgotten.
>>
>> Callbacks are handled by blocking any matching LAYOUTGETS while processing and
>> initiating drain of IO.  A notification system is set up so that when
>> all relevant IO is finished, the state manger thread is invoked, which
>> synchronously sends the final matching LAYOUTRETURN before unblocking
>> LAYOUTGETS.
>>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>>  fs/nfs/callback.h         |    7 +
>>  fs/nfs/callback_proc.c    |  466 +++++++++++++++++++++++----------------------
>>  fs/nfs/client.c           |    3 +
>>  fs/nfs/nfs4proc.c         |   81 ++++++--
>>  fs/nfs/nfs4state.c        |    4 +
>>  fs/nfs/nfs4xdr.c          |   16 ++-
>>  fs/nfs/pnfs.c             |  177 +++++++++++++-----
>>  fs/nfs/pnfs.h             |   41 +++-
>>  include/linux/nfs_fs_sb.h |    4 +
>>  9 files changed, 497 insertions(+), 302 deletions(-)
>>
>> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
>> index cea58cc..4a9905b 100644
>> --- a/fs/nfs/callback.h
>> +++ b/fs/nfs/callback.h
>> @@ -163,6 +163,9 @@ struct cb_layoutrecallargs {
>>  extern unsigned nfs4_callback_layoutrecall(
>>  	struct cb_layoutrecallargs *args,
>>  	void *dummy, struct cb_process_state *cps);
>> +extern bool matches_outstanding_recall(struct inode *ino,
>> +				       struct pnfs_layout_range *range);
>> +extern void nfs_client_return_layouts(struct nfs_client *clp);
>>  
>>  static inline void put_session_client(struct nfs4_session *session)
>>  {
>> @@ -178,6 +181,10 @@ find_client_from_cps(struct cb_process_state *cps, struct sockaddr *addr)
>>  
>>  #else
>>  
>> +static inline void nfs_client_return_layouts(struct nfs_client *clp)
>> +{
>> +}
>> +
>>  static inline struct nfs_client *
>>  find_client_from_cps(struct cb_process_state *cps, struct sockaddr *addr)
>>  {
>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>> index 6e0fc40..af405cf 100644
>> --- a/fs/nfs/callback_proc.c
>> +++ b/fs/nfs/callback_proc.c
>> @@ -124,265 +124,283 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
>>  #if defined(CONFIG_NFS_V4_1)
>>  
>>  static bool
>> -pnfs_is_next_layout_stateid(const struct pnfs_layout_hdr *lo,
>> -			    const nfs4_stateid stateid)
>> +_recall_matches_lget(struct pnfs_cb_lrecall_info *cb_info,
>> +		     struct inode *ino, struct pnfs_layout_range *range)
>>  {
>> -	bool res;
>> -	u32 oldseqid, newseqid;
>> -
>> -	spin_lock(&lo->inode->i_lock);
>> -	{
>> -		oldseqid = be32_to_cpu(lo->stateid.stateid.seqid);
>> -		newseqid = be32_to_cpu(stateid.stateid.seqid);
>> -		res = !memcmp(lo->stateid.stateid.other,
>> -			      stateid.stateid.other,
>> -			      NFS4_STATEID_OTHER_SIZE);
>> -		if (res) { /* comparing layout stateids */
>> -			if (oldseqid == ~0)
>> -				res = (newseqid == 1);
>> -			else
>> -				res = (newseqid == oldseqid + 1);
>> -		} else { /* open stateid */
>> -			res = !memcmp(lo->stateid.data,
>> -				      &zero_stateid,
>> -				      NFS4_STATEID_SIZE);
>> -			if (res)
>> -				res = (newseqid == 1);
>> -		}
>> -	}
>> -	spin_unlock(&lo->inode->i_lock);
>> +	struct cb_layoutrecallargs *cb_args = &cb_info->pcl_args;
>>  
>> -	return res;
>> +	switch (cb_args->cbl_recall_type) {
>> +	case RETURN_ALL:
>> +		return true;
>> +	case RETURN_FSID:
>> +		return !memcmp(&NFS_SERVER(ino)->fsid, &cb_args->cbl_fsid,
>> +			       sizeof(struct nfs_fsid));
>> +	case RETURN_FILE:
>> +		return (ino == cb_info->pcl_ino) &&
>> +			should_free_lseg(range, &cb_args->cbl_range);
>> +	default:
>> +		BUG();
> 
> Why should we BUG() just because the server is screwed up? That's not a
> client bug.
> 

Agreed.  This should be handled earlier in nfs4_callback_layoutrecall
or do_callback_layoutrecall so that we can return NFS4ERR_INVALID.


>> +	}
>>  }
>>  
>> -/*
>> - * Retrieve an inode based on layout recall parameters
>> - *
>> - * Note: caller must iput(inode) to dereference the inode.
>> - */
>> -static struct inode *
>> -nfs_layoutrecall_find_inode(struct nfs_client *clp,
>> -			    const struct cb_layoutrecallargs *args)
>> +bool
>> +matches_outstanding_recall(struct inode *ino, struct pnfs_layout_range *range)
>>  {
>> -	struct nfs_inode *nfsi;
>> -	struct pnfs_layout_hdr *lo;
>> -	struct nfs_server *server;
>> -	struct inode *ino = NULL;
>> -
>> -	dprintk("%s: Begin recall_type=%d clp %p\n",
>> -		__func__, args->cbl_recall_type, clp);
>> -
>> -	spin_lock(&clp->cl_lock);
>> -	list_for_each_entry(lo, &clp->cl_layouts, layouts) {
>> -		nfsi = NFS_I(lo->inode);
>> -		if (!nfsi)
>> -			continue;
>> -
>> -		dprintk("%s: Searching inode=%lu\n",
>> -			__func__, nfsi->vfs_inode.i_ino);
>> -
>> -		if (args->cbl_recall_type == RETURN_FILE) {
>> -		    if (nfs_compare_fh(&args->cbl_fh, &nfsi->fh))
>> -			continue;
>> -		} else if (args->cbl_recall_type == RETURN_FSID) {
>> -			server = NFS_SERVER(&nfsi->vfs_inode);
>> -			if (server->fsid.major != args->cbl_fsid.major ||
>> -			    server->fsid.minor != args->cbl_fsid.minor)
>> -				continue;
>> +	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
>> +	struct pnfs_cb_lrecall_info *cb_info;
>> +	bool rv = false;
>> +
>> +	assert_spin_locked(&clp->cl_lock);
> 
> Can we please go easy on the asserts? There is way too much asserting
> going on in the NFSv4.1 code. This isn't a publicly visible interface,
> so just get it right in the debugging process before the merge, and then
> kill these asserts...
> 

OK. We can keep them in a DEVONLY patch only in the development tree
(it becomes handy when any changes are made on these code paths)

>> +	list_for_each_entry(cb_info, &clp->cl_layoutrecalls, pcl_list) {
>> +		if (_recall_matches_lget(cb_info, ino, range)) {
>> +			rv = true;
>> +			break;
>>  		}
>> -
>> -		/* Make sure client didn't clean up layout without
>> -		 * telling the server */
>> -		if (!has_layout(nfsi))
>> -			continue;
>> -
>> -		ino = igrab(&nfsi->vfs_inode);
>> -		dprintk("%s: Found inode=%p\n", __func__, ino);
>> -		break;
>>  	}
>> -	spin_unlock(&clp->cl_lock);
>> -	return ino;
>> +	return rv;
>>  }
>>  
>> -struct recall_layout_threadargs {
>> -	struct inode *inode;
>> -	struct nfs_client *clp;
>> -	struct completion started;
>> -	struct cb_layoutrecallargs *rl;
>> -	int result;
>> -};
>> -
>> -static int pnfs_recall_layout(void *data)
>> +/* Send a synchronous LAYOUTRETURN.  By the time this is called, we know
>> + * all IO has been drained, any matching lsegs deleted, and that no
>> + * overlapping LAYOUTGETs will be sent or processed for the duration
>> + * of this call.
>> + * Note that it is possible that when this is called, the stateid has
>> + * been invalidated.  But will not be cleared, so can still use.
>> + */
>> +static int
>> +pnfs_send_layoutreturn(struct nfs_client *clp,
>> +		       struct pnfs_cb_lrecall_info *cb_info)
>>  {
>> -	struct inode *inode, *ino;
>> -	struct nfs_client *clp;
>> -	struct cb_layoutrecallargs rl;
>> +	struct cb_layoutrecallargs *args = &cb_info->pcl_args;
>>  	struct nfs4_layoutreturn *lrp;
>> -	struct recall_layout_threadargs *args =
>> -		(struct recall_layout_threadargs *)data;
>> -	int status = 0;
>> -
>> -	daemonize("nfsv4-layoutreturn");
>> -
>> -	dprintk("%s: recall_type=%d fsid 0x%llx-0x%llx start\n",
>> -		__func__, args->rl->cbl_recall_type,
>> -		args->rl->cbl_fsid.major, args->rl->cbl_fsid.minor);
>> -
>> -	clp = args->clp;
>> -	inode = args->inode;
>> -	rl = *args->rl;
>> -
>> -	/* support whole file layouts only */
>> -	rl.cbl_range.offset = 0;
>> -	rl.cbl_range.length = NFS4_MAX_UINT64;
>> -
>> -	if (rl.cbl_recall_type == RETURN_FILE) {
>> -		if (pnfs_is_next_layout_stateid(NFS_I(inode)->layout,
>> -						rl.cbl_stateid))
>> -			status = pnfs_return_layout(inode, &rl.cbl_range,
>> -						    &rl.cbl_stateid, RETURN_FILE,
>> -						    false);
>> -		else
>> -			status = cpu_to_be32(NFS4ERR_DELAY);
>> -		if (status)
>> -			dprintk("%s RETURN_FILE error: %d\n", __func__, status);
>> -		else
>> -			status =  cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT);
>> -		args->result = status;
>> -		complete(&args->started);
>> -		goto out;
>> -	}
>> -
>> -	status = cpu_to_be32(NFS4_OK);
>> -	args->result = status;
>> -	complete(&args->started);
>> -	args = NULL;
>> -
>> -	/* IMPROVEME: This loop is inefficient, running in O(|s_inodes|^2) */
>> -	while ((ino = nfs_layoutrecall_find_inode(clp, &rl)) != NULL) {
>> -		/* FIXME: need to check status on pnfs_return_layout */
>> -		pnfs_return_layout(ino, &rl.cbl_range, NULL, RETURN_FILE, false);
>> -		iput(ino);
>> -	}
>>  
>>  	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
>> -	if (!lrp) {
>> -		dprintk("%s: allocation failed. Cannot send last LAYOUTRETURN\n",
>> -			__func__);
>> -		goto out;
>> -	}
>> -
>> -	/* send final layoutreturn */
>> +	if (!lrp)
>> +		return -ENOMEM;
>>  	lrp->args.reclaim = 0;
>> -	lrp->args.layout_type = rl.cbl_layout_type;
>> -	lrp->args.return_type = rl.cbl_recall_type;
>> +	lrp->args.layout_type = args->cbl_layout_type;
>> +	lrp->args.return_type = args->cbl_recall_type;
>>  	lrp->clp = clp;
>> -	lrp->args.range = rl.cbl_range;
>> -	lrp->args.inode = inode;
>> -	nfs4_proc_layoutreturn(lrp, true);
>> -
>> -out:
>> -	clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
>> -	nfs_put_client(clp);
>> -	module_put_and_exit(0);
>> -	dprintk("%s: exit status %d\n", __func__, 0);
>> -	return 0;
>> +	if (args->cbl_recall_type == RETURN_FILE) {
>> +		lrp->args.range = args->cbl_range;
>> +		lrp->args.inode = cb_info->pcl_ino;
>> +	} else {
>> +		lrp->args.range.iomode = IOMODE_ANY;
>> +		lrp->args.inode = NULL;
>> +	}
>> +	return nfs4_proc_layoutreturn(lrp, true);
>>  }
>>  
>> -/*
>> - * Asynchronous layout recall!
>> +/* Called by state manager to finish CB_LAYOUTRECALLS initiated by
>> + * nfs4_callback_layoutrecall().
>>   */
>> -static int pnfs_async_return_layout(struct nfs_client *clp, struct inode *inode,
>> -				    struct cb_layoutrecallargs *rl)
>> +void nfs_client_return_layouts(struct nfs_client *clp)
>>  {
>> -	struct recall_layout_threadargs data = {
>> -		.clp = clp,
>> -		.inode = inode,
>> -		.rl = rl,
>> -	};
>> -	struct task_struct *t;
>> -	int status = -EAGAIN;
>> +	struct pnfs_cb_lrecall_info *cb_info;
>>  
>> -	dprintk("%s: -->\n", __func__);
>> +	spin_lock(&clp->cl_lock);
>> +	while (true) {
>> +		if (list_empty(&clp->cl_layoutrecalls)) {
>> +			spin_unlock(&clp->cl_lock);
>> +			break;
>> +		}
>> +		cb_info = list_first_entry(&clp->cl_layoutrecalls,
>> +					   struct pnfs_cb_lrecall_info,
>> +					   pcl_list);
>> +		spin_unlock(&clp->cl_lock);
>> +		if (atomic_read(&cb_info->pcl_count) != 0)
>> +			break;
>> +		/* What do on error return?  These layoutreturns are
>> +		 * required by the protocol.  So if do not get
>> +		 * successful reply, probably have to do something
>> +		 * more drastic.
>> +		 */
>> +		pnfs_send_layoutreturn(clp, cb_info);
>> +		spin_lock(&clp->cl_lock);
>> +		/* Removing from the list unblocks LAYOUTGETs */
>> +		list_del(&cb_info->pcl_list);
>> +		clp->cl_cb_lrecall_count--;
>> +		rpc_wake_up(&clp->cl_rpcwaitq_recall);
>> +		kfree(cb_info);
>> +	}
>> +}
>>  
>> -	/* FIXME: do not allow two concurrent layout recalls */
>> -	if (test_and_set_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state))
>> -		return status;
>> -
>> -	init_completion(&data.started);
>> -	__module_get(THIS_MODULE);
>> -	atomic_inc(&clp->cl_count);
>> -
>> -	t = kthread_run(pnfs_recall_layout, &data, "%s", "pnfs_recall_layout");
>> -	if (IS_ERR(t)) {
>> -		printk(KERN_INFO "NFS: Layout recall callback thread failed "
>> -			"for client (clientid %08x/%08x)\n",
>> -			(unsigned)(clp->cl_clientid >> 32),
>> -			(unsigned)(clp->cl_clientid));
>> -		status = PTR_ERR(t);
>> -		goto out_module_put;
>> +void notify_drained(struct pnfs_cb_lrecall_info *d)
>> +{
>> +	if (d && atomic_dec_and_test(&d->pcl_count)) {
>> +		set_bit(NFS4CLNT_LAYOUT_RECALL, &d->pcl_clp->cl_state);
>> +		nfs4_schedule_state_manager(d->pcl_clp);
>>  	}
>> -	wait_for_completion(&data.started);
>> -	return data.result;
>> -out_module_put:
>> -	nfs_put_client(clp);
>> -	clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
>> -	module_put(THIS_MODULE);
>> -	return status;
>>  }
>>  
>> -static int pnfs_recall_all_layouts(struct nfs_client *clp)
>> +static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
>>  {
>> -	struct cb_layoutrecallargs rl;
>> -	struct inode *inode;
>> -	int status = 0;
>> -
>> -	rl.cbl_recall_type = RETURN_ALL;
>> -	rl.cbl_range.iomode = IOMODE_ANY;
>> -	rl.cbl_range.offset = 0;
>> -	rl.cbl_range.length = NFS4_MAX_UINT64;
>> -
>> -	/* we need the inode to get the nfs_server struct */
>> -	inode = nfs_layoutrecall_find_inode(clp, &rl);
>> -	if (!inode)
>> -		return status;
>> -	status = pnfs_async_return_layout(clp, inode, &rl);
>> -	iput(inode);
>> +	struct nfs_client *clp = cb_info->pcl_clp;
>> +	struct pnfs_layout_hdr *lo;
>> +	int rv = NFS4ERR_NOMATCHING_LAYOUT;
>> +	struct cb_layoutrecallargs *args = &cb_info->pcl_args;
>> +
>> +	if (args->cbl_recall_type == RETURN_FILE) {
>> +		LIST_HEAD(free_me_list);
>> +
>> +		spin_lock(&clp->cl_lock);
>> +		list_for_each_entry(lo, &clp->cl_layouts, layouts) {
>> +			if (nfs_compare_fh(&args->cbl_fh,
>> +					   &NFS_I(lo->inode)->fh))
>> +				continue;
>> +			if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
>> +				rv = NFS4ERR_DELAY;
>> +			else {
>> +				/* FIXME I need to better understand igrab and
>> +				 * does having a layout ref keep ino around?
>> +				 *  It should.
>> +				 */
>> +				/* We need to hold the reference until any
>> +				 * potential LAYOUTRETURN is finished.
>> +				 */
>> +				get_layout_hdr(lo);
>> +				cb_info->pcl_ino = lo->inode;
>> +				rv = NFS4_OK;
>> +			}
>> +			break;
>> +		}
>> +		spin_unlock(&clp->cl_lock);
>> +
>> +		spin_lock(&lo->inode->i_lock);
>> +		if (rv == NFS4_OK) {
>> +			lo->plh_block_lgets++;
>> +			nfs4_asynch_forget_layouts(lo, &args->cbl_range,
>> +						   cb_info, &free_me_list);
>> +		}
>> +		pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
>> +		spin_unlock(&lo->inode->i_lock);
>> +		pnfs_free_lseg_list(&free_me_list);
>> +	} else {
>> +		struct pnfs_layout_hdr *tmp;
>> +		LIST_HEAD(recall_list);
>> +		LIST_HEAD(free_me_list);
>> +		struct pnfs_layout_range range = {
>> +			.iomode = IOMODE_ANY,
>> +			.offset = 0,
>> +			.length = NFS4_MAX_UINT64,
>> +		};
>> +
>> +		spin_lock(&clp->cl_lock);
>> +		/* Per RFC 5661, 12.5.5.2.1.5, bulk recall must be serialized */
>> +		if (!list_is_singular(&clp->cl_layoutrecalls)) {
>> +			spin_unlock(&clp->cl_lock);
>> +			return NFS4ERR_DELAY;
>> +		}
>> +		list_for_each_entry(lo, &clp->cl_layouts, layouts) {
>> +			if ((args->cbl_recall_type == RETURN_FSID) &&
>> +			    memcmp(&NFS_SERVER(lo->inode)->fsid,
>> +				   &args->cbl_fsid, sizeof(struct nfs_fsid)))
>> +				continue;
>> +			get_layout_hdr(lo);
>> +			/* We could list_del(&lo->layouts) here */
>> +			BUG_ON(!list_empty(&lo->plh_bulk_recall));
>> +			list_add(&lo->plh_bulk_recall, &recall_list);
>> +		}
>> +		spin_unlock(&clp->cl_lock);
>> +		list_for_each_entry_safe(lo, tmp,
>> +					 &recall_list, plh_bulk_recall) {
>> +			spin_lock(&lo->inode->i_lock);
>> +			set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
>> +			nfs4_asynch_forget_layouts(lo, &range, cb_info,
>> +						   &free_me_list);
>> +			list_del_init(&lo->plh_bulk_recall);
>> +			spin_unlock(&lo->inode->i_lock);
>> +			put_layout_hdr(lo->inode);
>> +			rv = NFS4_OK;
>> +		}
>> +		pnfs_free_lseg_list(&free_me_list);
>> +	}
>> +	return rv;
>> +}
>> +
>> +static u32 do_callback_layoutrecall(struct nfs_client *clp,
>> +				    struct cb_layoutrecallargs *args)
>> +{
>> +	struct pnfs_cb_lrecall_info *new;
>> +	u32 res;
>> +
>> +	dprintk("%s enter, type=%i\n", __func__, args->cbl_recall_type);
>> +	new = kmalloc(sizeof(*new), GFP_KERNEL);
>> +	if (!new) {
>> +		res = NFS4ERR_RESOURCE;
>> +		goto out;
>> +	}
>> +	memcpy(&new->pcl_args, args, sizeof(*args));
>> +	atomic_set(&new->pcl_count, 1);
>> +	new->pcl_clp = clp;
>> +	new->pcl_ino = NULL;
>> +	spin_lock(&clp->cl_lock);
>> +	if (clp->cl_cb_lrecall_count >= PNFS_MAX_CB_LRECALLS) {
>> +		kfree(new);
>> +		res = NFS4ERR_DELAY;
>> +		spin_unlock(&clp->cl_lock);
>> +		goto out;
>> +	}
>> +	clp->cl_cb_lrecall_count++;
>> +	/* Adding to the list will block conflicting LGET activity */
>> +	list_add_tail(&new->pcl_list, &clp->cl_layoutrecalls);
>> +	spin_unlock(&clp->cl_lock);
>> +	res = initiate_layout_draining(new);
>> +	if (res || atomic_dec_and_test(&new->pcl_count)) {
>> +		spin_lock(&clp->cl_lock);
>> +		list_del(&new->pcl_list);
>> +		clp->cl_cb_lrecall_count--;
>> +		rpc_wake_up(&clp->cl_rpcwaitq_recall);
>> +		spin_unlock(&clp->cl_lock);
>> +		if (res == NFS4_OK) {
>> +			if (args->cbl_recall_type == RETURN_FILE) {
>> +				struct pnfs_layout_hdr *lo;
>> +
>> +				lo = NFS_I(new->pcl_ino)->layout;
>> +				spin_lock(&lo->inode->i_lock);
>> +				lo->plh_block_lgets--;
>> +				if (!pnfs_layoutgets_blocked(lo, NULL))
>> +					rpc_wake_up(&NFS_I(lo->inode)->lo_rpcwaitq_stateid);
>> +				spin_unlock(&lo->inode->i_lock);
>> +				put_layout_hdr(new->pcl_ino);
>> +			}
>> +			res = NFS4ERR_NOMATCHING_LAYOUT;
>> +		}
>> +		kfree(new);
>> +	}
>> +out:
>> +	dprintk("%s returning %i\n", __func__, res);
>> +	return res;
>>  
>> -	return status;
>>  }
>>  
>>  __be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
>>  				  void *dummy, struct cb_process_state *cps)
>>  {
>>  	struct nfs_client *clp;
>> -	struct inode *inode = NULL;
>> -	__be32 res;
>> -	int status;
>> +	u32 res;
>>  
>>  	dprintk("%s: -->\n", __func__);
>>  
>> -	res = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
>> -	if (cps->session) /* set in cb_sequence */
>> +	if (cps->session) { /* set in cb_sequence */
>>  		clp = cps->session->clp;
>> -	else
>> -		goto out;
>> +		res = do_callback_layoutrecall(clp, args);
>> +	} else
>> +		res = NFS4ERR_OP_NOT_IN_SESSION;
>>  
>> -	res = cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT);
>> -	/*
>> -	 * In the _ALL or _FSID case, we need the inode to get
>> -	 * the nfs_server struct.
>> -	 */
>> -	inode = nfs_layoutrecall_find_inode(clp, args);
>> -	if (!inode)
>> -		goto out;
>> -	status = pnfs_async_return_layout(clp, inode, args);
>> -	if (status)
>> -		res = cpu_to_be32(NFS4ERR_DELAY);
>> -	iput(inode);
>> -out:
>> -	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
>> -	return res;
>> +	dprintk("%s: exit with status = %d\n", __func__, res);
>> +	return cpu_to_be32(res);
>> +}
>> +
>> +static void pnfs_recall_all_layouts(struct nfs_client *clp)
>> +{
>> +	struct cb_layoutrecallargs args;
>> +
>> +	/* Pretend we got a CB_LAYOUTRECALL(ALL) */
>> +	memset(&args, 0, sizeof(args));
>> +	args.cbl_recall_type = RETURN_ALL;
>> +	/* FIXME we ignore errors, what should we do? */
> 
> We're a forgetful client: we don't care...
> 

Well, CB_RECALL_ANY is generated in order to trim the server's state down
by allowing the client to *return* state it needs less or no longer needs.
Just forgetting this state doesn't help the server at all with this job!
There's no equivalent error to NFS4ERR_NOMATCHING_LAYOUT for CB_RECALL_ANY.

>> +	do_callback_layoutrecall(clp, &args);
>>  }
> 
> 
> 
>>  
>>  int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
>> @@ -665,9 +683,7 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
>>  		flags |= FMODE_WRITE;
>>  	if (test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, (const unsigned long *)
>>  		     &args->craa_type_mask))
>> -		if (pnfs_recall_all_layouts(clp) == -EAGAIN)
>> -			status = cpu_to_be32(NFS4ERR_DELAY);
>> -
>> +		pnfs_recall_all_layouts(clp);
>>  	if (flags)
>>  		nfs_expire_all_delegation_types(clp, flags);
>>  out:
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index 3c8c841..dbf43e7 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -158,6 +158,9 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>>  		clp->cl_machine_cred = cred;
>>  #if defined(CONFIG_NFS_V4_1)
>>  	INIT_LIST_HEAD(&clp->cl_layouts);
>> +	INIT_LIST_HEAD(&clp->cl_layoutrecalls);
>> +	rpc_init_wait_queue(&clp->cl_rpcwaitq_recall,
>> +			    "NFS client CB_LAYOUTRECALLS");
>>  #endif
>>  	nfs_fscache_get_client_cookie(clp);
>>  
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index fe79872..6223c6a 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -5346,31 +5346,58 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
>>  	struct inode *ino = lgp->args.inode;
>>  	struct nfs_inode *nfsi = NFS_I(ino);
>>  	struct nfs_server *server = NFS_SERVER(ino);
>> +	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
>>  
>>  	dprintk("--> %s\n", __func__);
>> +	spin_lock(&clp->cl_lock);
>> +	if (matches_outstanding_recall(ino, &lgp->args.range)) {
>> +		rpc_sleep_on(&clp->cl_rpcwaitq_recall, task, NULL);
>> +		spin_unlock(&clp->cl_lock);
>> +		return;
>> +	}
>> +	spin_unlock(&clp->cl_lock);
>> +	/* Note the is a race here, where a CB_LAYOUTRECALL can come in
>> +	 * right now covering the LAYOUTGET we are about to send.
>> +	 * However, that is not so catastrophic, and there seems
>> +	 * to be no way to prevent it completely.
>> +	 */
>>  	spin_lock(&ino->i_lock);
>> -	if (pnfs_layoutgets_blocked(nfsi->layout)) {
>> +	if (pnfs_layoutgets_blocked(nfsi->layout, NULL)) {
>>  		rpc_sleep_on(&nfsi->lo_rpcwaitq_stateid, task, NULL);
>>  		spin_unlock(&ino->i_lock);
>>  		return;
>>  	}
>> +	/* This needs after above check but atomic with it in order to properly
>> +	 * serialize openstateid LAYOUTGETs.
>> +	 */
>> +	nfsi->layout->plh_outstanding++;
>>  	spin_unlock(&ino->i_lock);
>> +
>>  	if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
>> -				&lgp->res.seq_res, 0, task))
>> +				&lgp->res.seq_res, 0, task)) {
>> +		spin_lock(&ino->i_lock);
>> +		nfsi->layout->plh_outstanding--;
>> +		spin_unlock(&ino->i_lock);
>>  		return;
>> +	}
>>  	rpc_call_start(task);
>>  }
>>  
>>  static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
>>  {
>>  	struct nfs4_layoutget *lgp = calldata;
>> -	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
>> +	struct inode *ino = lgp->args.inode;
>>  
>>  	dprintk("--> %s\n", __func__);
>>  
>> -	if (!nfs4_sequence_done(task, &lgp->res.seq_res))
>> +	if (!nfs4_sequence_done(task, &lgp->res.seq_res)) {
>> +		/* layout code relies on fact that in this case
>> +		 * code falls back to tk_action=call_start, but not
>> +		 * back to rpc_prepare_task, to keep plh_outstanding
>> +		 * correct.
>> +		 */
>>  		return;
>> -
>> +	}
>>  	switch (task->tk_status) {
>>  	case 0:
>>  		break;
>> @@ -5379,7 +5406,11 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
>>  		task->tk_status = -NFS4ERR_DELAY;
>>  		/* Fall through */
>>  	default:
>> -		if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN) {
>> +		if (nfs4_async_handle_error(task, NFS_SERVER(ino),
>> +					    NULL, NULL) == -EAGAIN) {
>> +			spin_lock(&ino->i_lock);
>> +			NFS_I(ino)->layout->plh_outstanding--;
>> +			spin_unlock(&ino->i_lock);
>>  			rpc_restart_call_prepare(task);
>>  			return;
>>  		}
>> @@ -5437,13 +5468,20 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
>>  	if (IS_ERR(task))
>>  		return PTR_ERR(task);
>>  	status = nfs4_wait_for_completion_rpc_task(task);
>> -	if (status != 0)
>> -		goto out;
>> -	status = task->tk_status;
>> -	if (status != 0)
>> -		goto out;
>> -	status = pnfs_layout_process(lgp);
>> -out:
>> +	if (status == 0)
>> +		status = task->tk_status;
>> +	if (status == 0)
>> +		status = pnfs_layout_process(lgp);
>> +	else {
>> +		struct inode *ino = lgp->args.inode;
>> +		struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
>> +
>> +		spin_lock(&ino->i_lock);
>> +		lo->plh_outstanding--;
>> +		if (!pnfs_layoutgets_blocked(lo, NULL))
>> +			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
>> +		spin_unlock(&ino->i_lock);
>> +	}
>>  	rpc_put_task(task);
>>  	dprintk("<-- %s status=%d\n", __func__, status);
>>  	return status;
>> @@ -5587,9 +5625,9 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
>>  
>>  		spin_lock(&lo->inode->i_lock);
>>  		if (lrp->res.lrs_present)
>> -			pnfs_set_layout_stateid(lo, &lrp->res.stateid);
>> +			pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
>>  		else
>> -			pnfs_invalidate_layout_stateid(lo);
>> +			BUG_ON(!list_empty(&lo->segs));
>>  		spin_unlock(&lo->inode->i_lock);
>>  	}
>>  	dprintk("<-- %s\n", __func__);
>> @@ -5606,10 +5644,11 @@ static void nfs4_layoutreturn_release(void *calldata)
>>  
>>  		spin_lock(&ino->i_lock);
>>  		lo->plh_block_lgets--;
>> -		if (!pnfs_layoutgets_blocked(lo))
>> +		lo->plh_outstanding--;
>> +		if (!pnfs_layoutgets_blocked(lo, NULL))
>>  			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
>>  		spin_unlock(&ino->i_lock);
>> -		put_layout_hdr(lrp->args.inode);
>> +		put_layout_hdr(ino);
>>  	}
>>  	kfree(calldata);
>>  	dprintk("<-- %s\n", __func__);
>> @@ -5639,6 +5678,14 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
>>  	int status = 0;
>>  
>>  	dprintk("--> %s\n", __func__);
>> +	if (lrp->args.return_type == RETURN_FILE) {
>> +		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
>> +		/* FIXME we should test for BULK here */
>> +		spin_lock(&lo->inode->i_lock);
>> +		BUG_ON(lo->plh_block_lgets == 0);
>> +		lo->plh_outstanding++;
>> +		spin_unlock(&lo->inode->i_lock);
>> +	}
>>  	task = rpc_run_task(&task_setup_data);
>>  	if (IS_ERR(task))
>>  		return PTR_ERR(task);
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 00632f6..ceb0d66 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1560,6 +1560,10 @@ static void nfs4_state_manager(struct nfs_client *clp)
>>  			nfs_client_return_marked_delegations(clp);
>>  			continue;
>>  		}
>> +		if (test_and_clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state)) {
>> +			nfs_client_return_layouts(clp);
>> +			continue;
>> +		}
>>  		/* Recall session slots */
>>  		if (test_and_clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state)
>>  		   && nfs4_has_session(clp)) {
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 328cca5..f530c7e 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -1827,13 +1827,14 @@ encode_getdeviceinfo(struct xdr_stream *xdr,
>>  	hdr->replen += decode_getdeviceinfo_maxsz;
>>  }
>>  
>> -static void
>> +static int
>>  encode_layoutget(struct xdr_stream *xdr,
>>  		      const struct nfs4_layoutget_args *args,
>>  		      struct compound_hdr *hdr)
>>  {
>>  	nfs4_stateid stateid;
>>  	__be32 *p;
>> +	int status;
>>  
>>  	p = reserve_space(xdr, 44 + NFS4_STATEID_SIZE);
>>  	*p++ = cpu_to_be32(OP_LAYOUTGET);
>> @@ -1843,8 +1844,11 @@ encode_layoutget(struct xdr_stream *xdr,
>>  	p = xdr_encode_hyper(p, args->range.offset);
>>  	p = xdr_encode_hyper(p, args->range.length);
>>  	p = xdr_encode_hyper(p, args->minlength);
>> -	pnfs_get_layout_stateid(&stateid, NFS_I(args->inode)->layout,
>> -				args->ctx->state);
>> +	status = pnfs_choose_layoutget_stateid(&stateid,
>> +					       NFS_I(args->inode)->layout,
>> +					       args->ctx->state);
>> +	if (status)
>> +		return status;
>>  	p = xdr_encode_opaque_fixed(p, &stateid.data, NFS4_STATEID_SIZE);
>>  	*p = cpu_to_be32(args->maxcount);
>>  
>> @@ -1857,6 +1861,7 @@ encode_layoutget(struct xdr_stream *xdr,
>>  		args->maxcount);
>>  	hdr->nops++;
>>  	hdr->replen += decode_layoutget_maxsz;
>> +	return 0;
>>  }
>>  
>>  static int
>> @@ -2782,12 +2787,15 @@ static int nfs4_xdr_enc_layoutget(struct rpc_rqst *req, uint32_t *p,
>>  	struct compound_hdr hdr = {
>>  		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
>>  	};
>> +	int status;
>>  
>>  	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
>>  	encode_compound_hdr(&xdr, req, &hdr);
>>  	encode_sequence(&xdr, &args->seq_args, &hdr);
>>  	encode_putfh(&xdr, NFS_FH(args->inode), &hdr);
>> -	encode_layoutget(&xdr, args, &hdr);
>> +	status = encode_layoutget(&xdr, args, &hdr);
>> +	if (status)
>> +		return status;
>>  	encode_nops(&hdr);
>>  	return 0;
>>  }
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 07b04e8..2d817be 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -233,7 +233,7 @@ EXPORT_SYMBOL_GPL(pnfs_unregister_layoutdriver);
>>   */
>>  
>>  /* Need to hold i_lock if caller does not already hold reference */
>> -static void
>> +void
>>  get_layout_hdr(struct pnfs_layout_hdr *lo)
>>  {
>>  	atomic_inc(&lo->plh_refcount);
>> @@ -278,24 +278,29 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
>>  	smp_mb();
>>  	lseg->valid = true;
>>  	lseg->layout = lo;
>> +	lseg->drain_notification = NULL;
>>  }
>>  
>>  static void
>>  _put_lseg_common(struct pnfs_layout_segment *lseg)
>>  {
>> +	struct inode *ino = lseg->layout->inode;
>> +
>>  	BUG_ON(lseg->valid == true);
>>  	list_del(&lseg->fi_list);
>>  	if (list_empty(&lseg->layout->segs)) {
>>  		struct nfs_client *clp;
>>  
>> -		clp = NFS_SERVER(lseg->layout->inode)->nfs_client;
>> +		clp = NFS_SERVER(ino)->nfs_client;
>>  		spin_lock(&clp->cl_lock);
>>  		/* List does not take a reference, so no need for put here */
>>  		list_del_init(&lseg->layout->layouts);
>>  		spin_unlock(&clp->cl_lock);
>> -		pnfs_invalidate_layout_stateid(lseg->layout);
>> +		clear_bit(NFS_LAYOUT_BULK_RECALL, &lseg->layout->plh_flags);
>> +		if (!pnfs_layoutgets_blocked(lseg->layout, NULL))
>> +			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
>>  	}
>> -	rpc_wake_up(&NFS_I(lseg->layout->inode)->lo_rpcwaitq);
>> +	rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq);
>>  }
>>  
>>  /* The use of tmp_list is necessary because pnfs_curr_ld->free_lseg
>> @@ -325,9 +330,12 @@ put_lseg(struct pnfs_layout_segment *lseg)
>>  		atomic_read(&lseg->pls_refcount), lseg->valid);
>>  	ino = lseg->layout->inode;
>>  	if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
>> +		struct pnfs_cb_lrecall_info *drain_info = lseg->drain_notification;
>> +
>>  		_put_lseg_common(lseg);
>>  		spin_unlock(&ino->i_lock);
>>  		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
>> +		notify_drained(drain_info);
>>  		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
>>  		put_layout_hdr(ino);
>>  	}
>> @@ -345,7 +353,7 @@ EXPORT_SYMBOL_GPL(put_lseg);
>>   * READ		READ	true
>>   * READ		RW	false
>>   */
>> -static int
>> +bool
>>  should_free_lseg(struct pnfs_layout_range *lseg_range,
>>  		 struct pnfs_layout_range *recall_range)
>>  {
>> @@ -388,16 +396,19 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
>>  	dprintk("%s:Return\n", __func__);
>>  }
>>  
>> -static void
>> +void
>>  pnfs_free_lseg_list(struct list_head *free_me)
>>  {
>>  	struct pnfs_layout_segment *lseg, *tmp;
>>  	struct inode *ino;
>> +	struct pnfs_cb_lrecall_info *drain_info;
>>  
>>  	list_for_each_entry_safe(lseg, tmp, free_me, fi_list) {
>>  		BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
>>  		ino = lseg->layout->inode;
>> +		drain_info = lseg->drain_notification;
>>  		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
>> +		notify_drained(drain_info);
>>  		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
>>  		put_layout_hdr(ino);
>>  	}
>> @@ -453,40 +464,49 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
>>  	}
>>  }
>>  
>> -/* update lo->stateid with new if is more recent
>> - *
>> - * lo->stateid could be the open stateid, in which case we just use what given.
>> - */
>> +/* update lo->stateid with new if is more recent */
>>  void
>> -pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
>> -			const nfs4_stateid *new)
>> +pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
>> +			bool update_barrier)
>>  {
>> -	nfs4_stateid *old = &lo->stateid;
>> -	bool overwrite = false;
>> +	u32 oldseq, newseq;
>>  
>>  	assert_spin_locked(&lo->inode->i_lock);
>> -	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags) ||
>> -	    memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
>> -		overwrite = true;
>> -	else {
>> -		u32 oldseq, newseq;
>> -
>> -		oldseq = be32_to_cpu(old->stateid.seqid);
>> -		newseq = be32_to_cpu(new->stateid.seqid);
>> -		if ((int)(newseq - oldseq) > 0)
>> -			overwrite = true;
>> +	oldseq = be32_to_cpu(lo->stateid.stateid.seqid);
>> +	newseq = be32_to_cpu(new->stateid.seqid);
>> +	if ((int)(newseq - oldseq) > 0) {
>> +		memcpy(&lo->stateid, &new->stateid, sizeof(new->stateid));
>> +		if (update_barrier)
>> +			lo->plh_barrier = be32_to_cpu(new->stateid.seqid);
>> +		else {
>> +			/* Because of wraparound, we want to keep the barrier
>> +			 * "close" to the current seqids.  It needs to be
>> +			 * within 2**31 to count as "behind", so if it
>> +			 * gets too near that limit, give us a litle leeway
>> +			 * and bring it to within 2**30.
>> +			 * NOTE - and yes, this is all unsigned arithmetic.
>> +			 */
>> +			if (unlikely((newseq - lo->plh_barrier) > (3 << 29)))
>> +				lo->plh_barrier = newseq - (1 << 30);
>> +		}
>>  	}
>> -	if (overwrite)
>> -		memcpy(&old->stateid, &new->stateid, sizeof(new->stateid));
>>  }
>>  
>> -void
>> -pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
>> -			struct nfs4_state *open_state)
>> +int
>> +pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
>> +			      struct nfs4_state *open_state)
>>  {
>> +	int status = 0;
>> +
>>  	dprintk("--> %s\n", __func__);
>>  	spin_lock(&lo->inode->i_lock);
>> -	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags)) {
>> +	if (lo->plh_block_lgets ||
>> +	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
>> +		/* We avoid -EAGAIN, as that has special meaning to
>> +		 * some callers.
>> +		 */
>> +		status = -NFS4ERR_LAYOUTTRYLATER;
>> +	} else if (list_empty(&lo->segs)) {
>>  		int seq;
>>  
>>  		do {
>> @@ -494,12 +514,11 @@ pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
>>  			memcpy(dst->data, open_state->stateid.data,
>>  			       sizeof(open_state->stateid.data));
>>  		} while (read_seqretry(&open_state->seqlock, seq));
>> -		set_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
>>  	} else
>> -		memcpy(dst->data, lo->stateid.data,
>> -		       sizeof(lo->stateid.data));
>> +		memcpy(dst->data, lo->stateid.data, sizeof(lo->stateid.data));
>>  	spin_unlock(&lo->inode->i_lock);
>>  	dprintk("<-- %s\n", __func__);
>> +	return status;
>>  }
>>  
>>  /*
>> @@ -566,6 +585,28 @@ has_layout_to_return(struct pnfs_layout_hdr *lo,
>>  	return out;
>>  }
>>  
>> +void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
>> +				struct pnfs_layout_range *range,
>> +				struct pnfs_cb_lrecall_info *drain_info,
>> +				struct list_head *tmp_list)
>> +{
>> +	struct pnfs_layout_segment *lseg, *tmp;
>> +
>> +	assert_spin_locked(&lo->inode->i_lock);
> 
> Poor practice. If you want to ensure the caller holds the inode->i_lock,
> then just call the function '*_locked'. That is a lot more helpful than
> these damned asserts.
> 

That makes sense.

Benny

>> +	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
>> +		if (should_free_lseg(&lseg->range, range)) {
>> +			/* FIXME - need to change to something like a
>> +			 * notification bitmap to remove the restriction
>> +			 * of only being able to process a single
>> +			 * CB_LAYOUTRECALL at a time.
>> +			 */
>> +			BUG_ON(lseg->drain_notification);
>> +			lseg->drain_notification = drain_info;
>> +			atomic_inc(&drain_info->pcl_count);
>> +			mark_lseg_invalid(lseg, tmp_list);
>> +		}
>> +}
>> +
>>  /* Return true if there is layout based io in progress in the given range.
>>   * Assumes range has already been marked invalid, and layout marked to
>>   * prevent any new lseg from being inserted.
>> @@ -711,14 +752,6 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
>>  	dprintk("%s:Begin\n", __func__);
>>  
>>  	assert_spin_locked(&lo->inode->i_lock);
>> -	if (list_empty(&lo->segs)) {
>> -		struct nfs_client *clp = NFS_SERVER(lo->inode)->nfs_client;
>> -
>> -		spin_lock(&clp->cl_lock);
>> -		BUG_ON(!list_empty(&lo->layouts));
>> -		list_add_tail(&lo->layouts, &clp->cl_layouts);
>> -		spin_unlock(&clp->cl_lock);
>> -	}
>>  	list_for_each_entry(lp, &lo->segs, fi_list) {
>>  		if (cmp_layout(&lp->range, &lseg->range) > 0)
>>  			continue;
>> @@ -735,6 +768,9 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
>>  	}
>>  	if (!found) {
>>  		list_add_tail(&lseg->fi_list, &lo->segs);
>> +		if (list_is_singular(&lo->segs) &&
>> +		    !pnfs_layoutgets_blocked(lo, NULL))
>> +			rpc_wake_up(&NFS_I(lo->inode)->lo_rpcwaitq_stateid);
>>  		dprintk("%s: inserted lseg %p "
>>  			"iomode %d offset %llu length %llu at tail\n",
>>  			__func__, lseg, lseg->range.iomode,
>> @@ -756,6 +792,7 @@ alloc_init_layout_hdr(struct inode *ino)
>>  	atomic_set(&lo->plh_refcount, 1);
>>  	INIT_LIST_HEAD(&lo->layouts);
>>  	INIT_LIST_HEAD(&lo->segs);
>> +	INIT_LIST_HEAD(&lo->plh_bulk_recall);
>>  	lo->inode = ino;
>>  	return lo;
>>  }
>> @@ -843,6 +880,7 @@ pnfs_update_layout(struct inode *ino,
>>  		.length = NFS4_MAX_UINT64,
>>  	};
>>  	struct nfs_inode *nfsi = NFS_I(ino);
>> +	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
>>  	struct pnfs_layout_hdr *lo;
>>  	struct pnfs_layout_segment *lseg = NULL;
>>  
>> @@ -878,9 +916,28 @@ pnfs_update_layout(struct inode *ino,
>>  		goto out_unlock;
>>  
>>  	get_layout_hdr(lo); /* Matched in pnfs_layoutget_release */
>> +	if (list_empty(&lo->segs)) {
>> +		/* The lo must be on the clp list if there is any
>> +		 * chance of a CB_LAYOUTRECALL(FILE) coming in.
>> +		 */
>> +		spin_lock(&clp->cl_lock);
>> +		BUG_ON(!list_empty(&lo->layouts));
>> +		list_add_tail(&lo->layouts, &clp->cl_layouts);
>> +		spin_unlock(&clp->cl_lock);
>> +	}
>>  	spin_unlock(&ino->i_lock);
>>  
>>  	lseg = send_layoutget(lo, ctx, &arg);
>> +	if (!lseg) {
>> +		spin_lock(&ino->i_lock);
>> +		if (list_empty(&lo->segs)) {
>> +			spin_lock(&clp->cl_lock);
>> +			list_del_init(&lo->layouts);
>> +			spin_unlock(&clp->cl_lock);
>> +			clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
>> +		}
>> +		spin_unlock(&ino->i_lock);
>> +	}
>>  out:
>>  	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
>>  		nfsi->layout->plh_flags, lseg);
>> @@ -891,10 +948,15 @@ out_unlock:
>>  }
>>  
>>  bool
>> -pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo)
>> +pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid)
>>  {
>>  	assert_spin_locked(&lo->inode->i_lock);
>> -	return lo->plh_block_lgets;
>> +	if ((stateid) &&
>> +	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
>> +		return true;
>> +	return lo->plh_block_lgets ||
>> +		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
>> +		(list_empty(&lo->segs) && lo->plh_outstanding);
>>  }
>>  
>>  int
>> @@ -904,6 +966,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
>>  	struct nfs4_layoutget_res *res = &lgp->res;
>>  	struct pnfs_layout_segment *lseg;
>>  	struct inode *ino = lo->inode;
>> +	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
>>  	int status = 0;
>>  
>>  	/* Inject layout blob into I/O device driver */
>> @@ -915,10 +978,25 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
>>  			status = PTR_ERR(lseg);
>>  		dprintk("%s: Could not allocate layout: error %d\n",
>>  		       __func__, status);
>> +		spin_lock(&ino->i_lock);
>>  		goto out;
>>  	}
>>  
>>  	spin_lock(&ino->i_lock);
>> +	/* decrement needs to be done before call to pnfs_layoutget_blocked */
>> +	lo->plh_outstanding--;
>> +	spin_lock(&clp->cl_lock);
>> +	if (matches_outstanding_recall(ino, &res->range)) {
>> +		spin_unlock(&clp->cl_lock);
>> +		dprintk("%s forget reply due to recall\n", __func__);
>> +		goto out_forget_reply;
>> +	}
>> +	spin_unlock(&clp->cl_lock);
>> +
>> +	if (pnfs_layoutgets_blocked(lo, &res->stateid)) {
>> +		dprintk("%s forget reply due to state\n", __func__);
>> +		goto out_forget_reply;
>> +	}
>>  	init_lseg(lo, lseg);
>>  	lseg->range = res->range;
>>  	get_lseg(lseg);
>> @@ -934,10 +1012,19 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
>>  	}
>>  
>>  	/* Done processing layoutget. Set the layout stateid */
>> -	pnfs_set_layout_stateid(lo, &res->stateid);
>> -	spin_unlock(&ino->i_lock);
>> +	pnfs_set_layout_stateid(lo, &res->stateid, false);
>>  out:
>> +	if (!pnfs_layoutgets_blocked(lo, NULL))
>> +		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
>> +	spin_unlock(&ino->i_lock);
>>  	return status;
>> +
>> +out_forget_reply:
>> +	spin_unlock(&ino->i_lock);
>> +	lseg->layout = lo;
>> +	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
>> +	spin_lock(&ino->i_lock);
>> +	goto out;
>>  }
>>  
>>  void
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 891aeab..7ea121f 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -31,6 +31,7 @@
>>  #define FS_NFS_PNFS_H
>>  
>>  #include <linux/nfs_page.h>
>> +#include "callback.h" /* for cb_layoutrecallargs */
>>  
>>  struct pnfs_layout_segment {
>>  	struct list_head fi_list;
>> @@ -38,6 +39,7 @@ struct pnfs_layout_segment {
>>  	atomic_t pls_refcount;
>>  	bool valid;
>>  	struct pnfs_layout_hdr *layout;
>> +	struct pnfs_cb_lrecall_info *drain_notification;
>>  };
>>  
>>  enum pnfs_try_status {
>> @@ -52,7 +54,7 @@ enum pnfs_try_status {
>>  enum {
>>  	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
>>  	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
>> -	NFS_LAYOUT_STATEID_SET,		/* have a valid layout stateid */
>> +	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
>>  	NFS_LAYOUT_NEED_LCOMMIT,	/* LAYOUTCOMMIT needed */
>>  };
>>  
>> @@ -94,10 +96,13 @@ struct pnfs_layoutdriver_type {
>>  struct pnfs_layout_hdr {
>>  	atomic_t		plh_refcount;
>>  	struct list_head	layouts;   /* other client layouts */
>> +	struct list_head	plh_bulk_recall; /* clnt list of bulk recalls */
>>  	struct list_head	segs;      /* layout segments list */
>>  	int			roc_iomode;/* return on close iomode, 0=none */
>>  	nfs4_stateid		stateid;
>> +	unsigned long		plh_outstanding; /* number of RPCs out */
>>  	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
>> +	u32			plh_barrier; /* ignore lower seqids */
>>  	unsigned long		plh_flags;
>>  	struct rpc_cred		*cred;     /* layoutcommit credential */
>>  	/* DH: These vars keep track of the maximum write range
>> @@ -118,6 +123,14 @@ struct pnfs_device {
>>  	unsigned int  pglen;
>>  };
>>  
>> +struct pnfs_cb_lrecall_info {
>> +	struct list_head	pcl_list; /* hook into cl_layoutrecalls list */
>> +	atomic_t		pcl_count;
>> +	struct nfs_client	*pcl_clp;
>> +	struct inode		*pcl_ino;
>> +	struct cb_layoutrecallargs pcl_args;
>> +};
>> +
>>  /*
>>   * Device ID RCU cache. A device ID is unique per client ID and layout type.
>>   */
>> @@ -176,7 +189,10 @@ extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
>>  extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool wait);
>>  
>>  /* pnfs.c */
>> +void get_layout_hdr(struct pnfs_layout_hdr *lo);
>>  void put_lseg(struct pnfs_layout_segment *lseg);
>> +bool should_free_lseg(struct pnfs_layout_range *lseg_range,
>> +		      struct pnfs_layout_range *recall_range);
>>  struct pnfs_layout_segment *
>>  pnfs_has_layout(struct pnfs_layout_hdr *lo, struct pnfs_layout_range *range);
>>  struct pnfs_layout_segment *
>> @@ -201,15 +217,24 @@ enum pnfs_try_status pnfs_try_to_commit(struct nfs_write_data *,
>>  void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
>>  			   struct nfs_open_context *, struct list_head *);
>>  void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
>> -bool pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo);
>> +bool pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid);
>>  int pnfs_layout_process(struct nfs4_layoutget *lgp);
>> +void pnfs_free_lseg_list(struct list_head *tmp_list);
>>  void pnfs_destroy_layout(struct nfs_inode *);
>>  void pnfs_destroy_all_layouts(struct nfs_client *);
>>  void put_layout_hdr(struct inode *inode);
>>  void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
>> -			     const nfs4_stateid *new);
>> -void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
>> -			     struct nfs4_state *open_state);
>> +			     const nfs4_stateid *new,
>> +			     bool update_barrier);
>> +int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
>> +				  struct pnfs_layout_hdr *lo,
>> +				  struct nfs4_state *open_state);
>> +void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
>> +				struct pnfs_layout_range *range,
>> +				struct pnfs_cb_lrecall_info *drain_info,
>> +				struct list_head *tmp_list);
>> +/* FIXME - this should be in callback.h, but pnfs_cb_lrecall_info needs to be there too */
>> +extern void notify_drained(struct pnfs_cb_lrecall_info *d);
>>  
>>  static inline bool
>>  has_layout(struct nfs_inode *nfsi)
>> @@ -223,12 +248,6 @@ static inline int lo_fail_bit(u32 iomode)
>>  			 NFS_LAYOUT_RW_FAILED : NFS_LAYOUT_RO_FAILED;
>>  }
>>  
>> -static inline void pnfs_invalidate_layout_stateid(struct pnfs_layout_hdr *lo)
>> -{
>> -	assert_spin_locked(&lo->inode->i_lock);
>> -	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
>> -}
>> -
>>  static inline void get_lseg(struct pnfs_layout_segment *lseg)
>>  {
>>  	atomic_inc(&lseg->pls_refcount);
>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>> index 3cae408..80dcc00 100644
>> --- a/include/linux/nfs_fs_sb.h
>> +++ b/include/linux/nfs_fs_sb.h
>> @@ -83,6 +83,10 @@ struct nfs_client {
>>  	u32			cl_exchange_flags;
>>  	struct nfs4_session	*cl_session; 	/* sharred session */
>>  	struct list_head	cl_layouts;
>> +	struct list_head	cl_layoutrecalls;
>> +	unsigned long		cl_cb_lrecall_count;
>> +#define PNFS_MAX_CB_LRECALLS (1)
>> +	struct rpc_wait_queue	cl_rpcwaitq_recall;
>>  	struct pnfs_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
>>  #endif /* CONFIG_NFS_V4_1 */
>>  
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
