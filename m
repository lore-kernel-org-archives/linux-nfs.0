Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:15432 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758227Ab1FJXAh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 19:00:37 -0400
Message-ID: <4DF2A20B.2030901@panasas.com>
Date: Fri, 10 Jun 2011 16:00:27 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <benny@tonian.com>
CC: "J. Bruce Fields" <bfields@citi.umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [RFC] pnfsd: Return all ROC layouts On Close
References: <4DE3B812.8020804@panasas.com> <4DE3D392.3020902@panasas.com> <4DF27702.4060900@tonian.com>
In-Reply-To: <4DF27702.4060900@tonian.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/10/2011 12:56 PM, Benny Halevy wrote:
> On 2011-05-30 13:27, Benny Halevy wrote:
>> On 2011-05-30 18:30, Boaz Harrosh wrote:
>>>
>>> As talk to with Trond, when a client has sent an nfs4_close, the
>>> server can surly assume that the given client has already forgotten
>>> all it's ROC given layouts. And in fact the current Linux-client goes
>>> to grate length to make sure all ROC layouts are invalidated, before
>>> sending the close. If a new open+IO comes in and tries to get a new layout,
>>> it will wait for the nfs4_close to return before sending the new layout_get.
>>>
>>> So in light of above the server should simulate layout_return and remove
>>> any layouts marked ROC on nfs4_close.
>>>
>>> Current code is protocol correct, but a more fine-grained approach can be
>>> devised to also release layouts in open_downgrade, of all unused iomodes.
>>> But to do this I'll need the help of an expert.
>>>
>>> With this patch in, I'm finally able to run with the new Linux-Client together
>>> with a Linux-Server. Before, the layouts where only released and freed on umount
>>> and in a modest machine like the UML I use, few 10s of "git checkout linux" the
>>> server would oom.
>>>
>>> Benny please submit it to the pnfs tree, so we can run with this in Bakeathone.
>>>
>>> So please all help me to verify and refine this code.
>>>
>>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>>> ---
>>>  fs/nfsd/nfs4pnfsd.c |   44 ++++++++++++++++++++++++++++++++++++++++++--
>>>  fs/nfsd/nfs4state.c |    3 +++
>>>  fs/nfsd/pnfsd.h     |    3 +++
>>>  3 files changed, 48 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
>>> index 9089e6b9..d8f744e 100644
>>> --- a/fs/nfsd/nfs4pnfsd.c
>>> +++ b/fs/nfsd/nfs4pnfsd.c
>>> @@ -402,7 +402,8 @@ init_layout(struct nfs4_layout_state *ls,
>>>  	    struct nfs4_client *clp,
>>>  	    struct svc_fh *current_fh,
>>>  	    struct nfsd4_layout_seg *seg,
>>> -	    stateid_t *stateid)
>>> +	    stateid_t *stateid,
>>> +	    bool roc)
>>>  {
>>>  	dprintk("pNFS %s: ls %p lp %p clp %p fp %p ino %p\n", __func__,
>>>  		ls, lp, clp, fp, fp->fi_inode);
>>> @@ -412,6 +413,7 @@ init_layout(struct nfs4_layout_state *ls,
>>>  	lp->lo_file = fp;
>>>  	get_layout_state(ls);
>>>  	lp->lo_state = ls;
>>> +	lp->lo_roc = roc;
>>>  	memcpy(&lp->lo_seg, seg, sizeof(lp->lo_seg));
>>>  	spin_lock(&layout_lock);
>>>  	update_layout_stateid(ls, stateid);
>>> @@ -914,7 +916,8 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
>>>  		goto out_freelayout;
>>>  
>>>  	/* Can't merge, so let's initialize this new layout */
>>> -	init_layout(ls, lp, fp, clp, lgp->lg_fhp, &res.lg_seg, &lgp->lg_sid);
>>> +	init_layout(ls, lp, fp, clp, lgp->lg_fhp, &res.lg_seg, &lgp->lg_sid,
>>> +		    res.lg_return_on_close);
>>>  out_unlock:
>>>  	if (ls)
>>>  		put_layout_state(ls);
>>> @@ -1328,6 +1331,43 @@ nomatching_layout(struct nfs4_layoutrecall *clr)
>>>  	iput(inode);
>>>  }
>>>  
>>> +/* Return On Close:
>>> + *   Look for all layouts of @fp that belong to @clp, if ROC is set, remove
>>> + *   the layout and simulate a layout_return. Surly the client has forgotten
>>> + *   these layouts or it would return them before the close.
>>> + */
>>> +void pnfs_roc(struct nfs4_client *clp, struct nfs4_file *fp,
>>> +	      enum pnfs_iomode iomode)
>>
>> what's the iomode for?
>>
>> The nfs CLOSE operation is sent on the final close on the client side.
>> otherwise you'd get an OPEN_DOWNGRADE for which return on close is not
>> really defined.
> 
> Ping... :)
> 
> Benny
> 

Fine just drop the iomode param for now. But with out this patch I cannot
run

Boaz

>>
>> Benny
>>
>>> +{
>>> +	struct nfs4_layout *lo, *nextlp;
>>> +
>>> +	spin_lock(&layout_lock);
>>> +	list_for_each_entry_safe (lo, nextlp, &fp->fi_layouts, lo_perfile) {
>>> +		struct nfsd4_pnfs_layoutreturn lr;
>>> +		bool empty;
>>> +
>>> +		/* Check for a match */
>>> +		if (!lo->lo_roc ||
>>> +		    (lo->lo_client != clp) ||
>>> +		    ((iomode != IOMODE_ANY) && (lo->lo_seg.iomode != iomode))
>>> +		)
>>> +			continue;
>>> +
>>> +		/* Return the layout */
>>> +		memset(&lr, 0, sizeof(lr));
>>> +		lr.args.lr_return_type = RETURN_FILE;
>>> +		lr.args.lr_seg = lo->lo_seg;
>>> +		dequeue_layout(lo);
>>> +		destroy_layout(lo); /* do not access lp after this */
>>> +
>>> +		empty = list_empty(&fp->fi_layouts);
>>> +		fs_layout_return(fp->fi_inode->i_sb, fp->fi_inode, &lr,
>>> +				 LR_FLAG_EXPIRE,
>>> +				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);
>>> +	}
>>> +	spin_unlock(&layout_lock);
>>> +}
>>> +
>>>  void pnfs_expire_client(struct nfs4_client *clp)
>>>  {
>>>  	for (;;) {
>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>> index 66f6f48..a116e41 100644
>>> --- a/fs/nfsd/nfs4state.c
>>> +++ b/fs/nfsd/nfs4state.c
>>> @@ -3592,6 +3592,9 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>>  	/* release_stateid() calls nfsd_close() if needed */
>>>  	release_open_stateid(stp);
>>>  
>>> +	/* RFC: what to do with IOMODE */
>>> +	pnfs_roc(stp->st_stateowner->so_client, stp->st_file, IOMODE_ANY);
>>> +
>>>  	/* place unused nfs4_stateowners on so_close_lru list to be
>>>  	 * released by the laundromat service after the lease period
>>>  	 * to enable us to handle CLOSE replay
>>> diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
>>> index c11d93d..fcb16d2 100644
>>> --- a/fs/nfsd/pnfsd.h
>>> +++ b/fs/nfsd/pnfsd.h
>>> @@ -59,6 +59,7 @@ struct nfs4_layout {
>>>  	struct nfs4_client		*lo_client;
>>>  	struct nfs4_layout_state	*lo_state;
>>>  	struct nfsd4_layout_seg 	lo_seg;
>>> +	bool				lo_roc;
>>>  };
>>>  
>>>  struct pnfs_inval_state {
>>> @@ -124,6 +125,8 @@ int nfs4_pnfs_cb_change_state(struct pnfs_get_state *);
>>>  void nfs4_ds_get_verifier(stateid_t *, struct super_block *, u32 *);
>>>  int put_layoutrecall(struct nfs4_layoutrecall *);
>>>  void nomatching_layout(struct nfs4_layoutrecall *);
>>> +void pnfs_roc(struct nfs4_client *clp, struct nfs4_file *fp,
>>> +	      enum pnfs_iomode iomode);
>>>  void *layoutrecall_done(struct nfs4_layoutrecall *);
>>>  void nfsd4_cb_layout(struct nfs4_layoutrecall *);
>>>  int nfsd_layout_recall_cb(struct super_block *, struct inode *,
>>

