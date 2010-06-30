From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH 4/5] SQUASHME pnfs-submit embed pnfs_layout_type
Date: Wed, 30 Jun 2010 15:43:39 -0400
Message-ID: <50FF7D0F-429C-4369-946B-3BE8C15834C2@netapp.com>
References: <1277829737-5465-1-git-send-email-andros@netapp.com> <1277829737-5465-2-git-send-email-andros@netapp.com> <1277829737-5465-3-git-send-email-andros@netapp.com> <1277829737-5465-4-git-send-email-andros@netapp.com> <1277829737-5465-5-git-send-email-andros@netapp.com> <4C2B1633.4090909@panasas.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: benny@panasas.com, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5442 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752401Ab0F3Tn6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jun 2010 15:43:58 -0400
In-Reply-To: <4C2B1633.4090909@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 30, 2010, at 6:02 AM, Boaz Harrosh wrote:

> On 06/29/2010 07:42 PM, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Each layoutdriver embeds the pnfs_layout_type in it's private  
>> layout cache
>> head structure, and allocates them both with the alloc_layout
>> layoutdriver_io_operation.
>>
>> Move all nfs inode pnfs field initialization into nfs4_init_once.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/callback_proc.c    |    2 +-
>> fs/nfs/inode.c            |   43 ++++---------------------
>> fs/nfs/nfs4proc.c         |    2 +-
>> fs/nfs/nfs4state.c        |    4 +-
>> fs/nfs/nfs4xdr.c          |    2 +-
>> fs/nfs/pnfs.c             |   78 ++++++++++++++++++++++++ 
>> +--------------------
>> include/linux/nfs4_pnfs.h |   14 ++------
>> include/linux/nfs_fs.h    |    4 +-
>> 8 files changed, 61 insertions(+), 88 deletions(-)
>>
>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>> index 4766695..d999ea8 100644
>> --- a/fs/nfs/callback_proc.c
>> +++ b/fs/nfs/callback_proc.c
>> @@ -233,7 +233,7 @@ static int pnfs_recall_layout(void *data)
>> 	rl.cbl_seg.length = NFS4_MAX_UINT64;
>>
>> 	if (rl.cbl_recall_type == RETURN_FILE) {
>> -		if (pnfs_is_next_layout_stateid(&NFS_I(inode)->layout,
>> +		if (pnfs_is_next_layout_stateid(NFS_I(inode)->layout,
>> 						rl.cbl_stateid))
>> 			status = pnfs_return_layout(inode, &rl.cbl_seg,
>> 						    &rl.cbl_stateid, RETURN_FILE,
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index cb12d33..c290806 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -1361,17 +1361,6 @@ void nfs4_clear_inode(struct inode *inode)
>> }
>> #endif
>>
>> -static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
>> -{
>> -#ifdef CONFIG_NFS_V4_1
>> -	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
>> -	nfsi->layout.roc_iomode = 0;
>> -	nfsi->layout.lo_cred = NULL;
>> -	nfsi->layout.pnfs_write_begin_pos = 0;
>> -	nfsi->layout.pnfs_write_end_pos = 0;
>> -#endif /* CONFIG_NFS_V4_1 */
>> -}
>> -
>> struct inode *nfs_alloc_inode(struct super_block *sb)
>> {
>> 	struct nfs_inode *nfsi;
>> @@ -1387,23 +1376,14 @@ struct inode *nfs_alloc_inode(struct  
>> super_block *sb)
>> #ifdef CONFIG_NFS_V4
>> 	nfsi->nfs4_acl = NULL;
>> #endif /* CONFIG_NFS_V4 */
>> -	pnfs_alloc_init_inode(nfsi);
>> 	return &nfsi->vfs_inode;
>> }
>>
>> static void pnfs_destroy_inode(struct nfs_inode *nfsi)
>> {
>> #ifdef CONFIG_NFS_V4_1
>> -	if (!list_empty(&nfsi->layout.segs))
>> +	if (has_layout(nfsi))
>> 		pnfs_destroy_layout(nfsi);
>> -
>> -	WARN_ON(!list_empty(&nfsi->layout.segs));
>> -	if (nfsi->layout.refcount)
>> -		printk("%s: WARNING: layout.refcount %d\n", __func__,
>> -			nfsi->layout.refcount);
>> -	WARN_ON(nfsi->layout.refcount);
>> -	WARN_ON(!list_empty(&nfsi->layout.lo_layouts));
>
> Andy, these problems did not go away with this patch. Please re- 
> instate
> them for the new code. All 3 WARN_ONs still apply. Perhaps in  
> pnfs_destroy_layout()

OK - good idea.
>
>> -	WARN_ON(nfsi->layout.ld_data);
>> #endif /* CONFIG_NFS_V4_1 */
>> }
>>
>> @@ -1415,20 +1395,6 @@ void nfs_destroy_inode(struct inode *inode)
>> 	kmem_cache_free(nfs_inode_cachep, nfsi);
>> }
>>
>> -static void pnfs_init_once(struct nfs_inode *nfsi)
>> -{
>> -#ifdef CONFIG_NFS_V4_1
>> -	init_waitqueue_head(&nfsi->lo_waitq);
>> -	nfsi->pnfs_layout_state = 0;
>> -	nfsi->pnfs_layout_suspend = 0;
>> -	seqlock_init(&nfsi->layout.seqlock);
>> -	INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
>> -	INIT_LIST_HEAD(&nfsi->layout.segs);
>> -	nfsi->layout.refcount = 0;
>> -	nfsi->layout.ld_data = NULL;
>> -#endif /* CONFIG_NFS_V4_1 */
>> -}
>> -
>> static inline void nfs4_init_once(struct nfs_inode *nfsi)
>> {
>> #ifdef CONFIG_NFS_V4
>> @@ -1436,6 +1402,12 @@ static inline void nfs4_init_once(struct  
>> nfs_inode *nfsi)
>> 	nfsi->delegation = NULL;
>> 	nfsi->delegation_state = 0;
>> 	init_rwsem(&nfsi->rwsem);
>> +#ifdef CONFIG_NFS_V4_1
>> +	init_waitqueue_head(&nfsi->lo_waitq);
>> +	nfsi->layout = NULL;
>> +	nfsi->pnfs_layout_state = 0;
>> +	nfsi->pnfs_layout_suspend = 0;
>> +#endif /* CONFIG_NFS_V4_1 */
>> #endif
>> }
>>
>> @@ -1454,7 +1426,6 @@ static void init_once(void *foo)
>> 	INIT_HLIST_HEAD(&nfsi->silly_list);
>> 	init_waitqueue_head(&nfsi->waitqueue);
>> 	nfs4_init_once(nfsi);
>> -	pnfs_init_once(nfsi);
>> }
>>
>> static int __init nfs_init_inodecache(void)
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 6283996..61f4aa9 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1086,7 +1086,7 @@ static void pnfs4_layout_reclaim(struct  
>> nfs4_state *state)
>> 	 * flag during grace period
>> 	 */
>> 	pnfs_destroy_layout(NFS_I(state->inode));
>> -	pnfs_set_layout_stateid(&NFS_I(state->inode)->layout,  
>> &zero_stateid);
>> +	pnfs_set_layout_stateid(NFS_I(state->inode)->layout,  
>> &zero_stateid);
>> #endif /* CONFIG_NFS_V4_1 */
>> }
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index bfe679b..6f44cb0 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -597,10 +597,10 @@ static void __nfs4_close(struct path *path,  
>> struct nfs4_state *state,
>> #ifdef CONFIG_NFS_V4_1
>> 		struct nfs_inode *nfsi = NFS_I(state->inode);
>>
>> -		if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
>> +		if (has_layout(nfsi) && nfsi->layout->roc_iomode) {
>> 			struct nfs4_pnfs_layout_segment range;
>>
>> -			range.iomode = nfsi->layout.roc_iomode;
>> +			range.iomode = nfsi->layout->roc_iomode;
>> 			range.offset = 0;
>> 			range.length = NFS4_MAX_UINT64;
>> 			pnfs_return_layout(state->inode, &range, NULL,
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index eeee855..0fd02b1 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -1886,7 +1886,7 @@ encode_layoutreturn(struct xdr_stream *xdr,
>> 		ld_io_ops->encode_layoutreturn);
>> 		if (ld_io_ops->encode_layoutreturn) {
>> 			ld_io_ops->encode_layoutreturn(
>> -				&NFS_I(args->inode)->layout, xdr, args);
>> +				NFS_I(args->inode)->layout, xdr, args);
>> 		} else {
>> 			p = reserve_space(xdr, 4);
>> 			*p = cpu_to_be32(0);
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 7f6ace2..9275140 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -153,7 +153,7 @@ pnfs_need_layoutcommit(struct nfs_inode *nfsi,  
>> struct nfs_open_context *ctx)
>> 	dprintk("%s: has_layout=%d ctx=%p\n", __func__, has_layout(nfsi),  
>> ctx);
>> 	spin_lock(&nfsi->vfs_inode.i_lock);
>> 	if (has_layout(nfsi) && !layoutcommit_needed(nfsi)) {
>> -		nfsi->layout.lo_cred = get_rpccred(ctx->state->owner->so_cred);
>> +		nfsi->layout->lo_cred = get_rpccred(ctx->state->owner->so_cred);
>> 		__set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->pnfs_layout_state);
>> 		nfsi->change_attr++;
>> 		spin_unlock(&nfsi->vfs_inode.i_lock);
>> @@ -174,17 +174,17 @@ pnfs_update_last_write(struct nfs_inode  
>> *nfsi, loff_t offset, size_t extent)
>> 	loff_t end_pos;
>>
>> 	spin_lock(&nfsi->vfs_inode.i_lock);
>> -	if (offset < nfsi->layout.pnfs_write_begin_pos)
>> -		nfsi->layout.pnfs_write_begin_pos = offset;
>> +	if (offset < nfsi->layout->pnfs_write_begin_pos)
>> +		nfsi->layout->pnfs_write_begin_pos = offset;
>> 	end_pos = offset + extent - 1; /* I'm being inclusive */
>> -	if (end_pos > nfsi->layout.pnfs_write_end_pos)
>> -		nfsi->layout.pnfs_write_end_pos = end_pos;
>> +	if (end_pos > nfsi->layout->pnfs_write_end_pos)
>> +		nfsi->layout->pnfs_write_end_pos = end_pos;
>> 	dprintk("%s: Wrote %lu@%lu bpos %lu, epos: %lu\n",
>> 		__func__,
>> 		(unsigned long) extent,
>> 		(unsigned long) offset ,
>> -		(unsigned long) nfsi->layout.pnfs_write_begin_pos,
>> -		(unsigned long) nfsi->layout.pnfs_write_end_pos);
>> +		(unsigned long) nfsi->layout->pnfs_write_begin_pos,
>> +		(unsigned long) nfsi->layout->pnfs_write_end_pos);
>> 	spin_unlock(&nfsi->vfs_inode.i_lock);
>> }
>>
>> @@ -325,10 +325,9 @@ get_layout(struct pnfs_layout_type *lo)
>> static inline struct pnfs_layout_type *
>> grab_current_layout(struct nfs_inode *nfsi)
>> {
>> -	struct pnfs_layout_type *lo = &nfsi->layout;
>> +	struct pnfs_layout_type *lo = nfsi->layout;
>>
>> -	BUG_ON_UNLOCKED_LO(lo);
>
> Why did you drop this one?

It is called in get_layout.

>
>> -	if (!lo->ld_data)
>> +	if (!lo)
>> 		return NULL;
>> 	get_layout(lo);
>> 	return lo;
>> @@ -342,13 +341,13 @@ put_layout(struct pnfs_layout_type *lo)
>>
>> 	lo->refcount--;
>> 	if (!lo->refcount) {
>> -		struct layoutdriver_io_operations *io_ops =
>> -			PNFS_LD_IO_OPS(lo);
>> +		struct layoutdriver_io_operations *io_ops = PNFS_LD_IO_OPS(lo);
>> +		struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
>>
>> -		dprintk("%s: freeing layout %p\n", __func__, lo->ld_data);
>> +		dprintk("%s: freeing layout cache %p\n", __func__, lo);
>> 		WARN_ON(!list_empty(&lo->lo_layouts));
>> -		io_ops->free_layout(lo->ld_data);
>> -		lo->ld_data = NULL;
>> +		io_ops->free_layout(lo);
>> +		nfsi->layout = NULL;
>> 	}
>> }
>>
>> @@ -688,7 +687,7 @@ pnfs_return_layout_barrier(struct nfs_inode  
>> *nfsi,
>> 	bool ret = false;
>>
>> 	spin_lock(&nfsi->vfs_inode.i_lock);
>> -	list_for_each_entry (lseg, &nfsi->layout.segs, fi_list) {
>> +	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list) {
>
> White space cleanup. actually I like the space. I thought checkpatch
> was fixed to accept these spaces?

Nope - still there in Fedora 12.
>
>> 		if (!should_free_lseg(lseg, range))
>> 			continue;
>> 		lseg->valid = false;
>> @@ -894,17 +893,20 @@ pnfs_insert_layout(struct pnfs_layout_type *lo,
>> 	dprintk("%s:Return\n", __func__);
>> }
>>
>> +/*
>> + * Each layoutdriver embeds pnfs_layout_type in it's per-layout  
>> type layout
>> + * cache structure. Initialize the common pnfs_layout_type fields.
>> + */
>> static struct pnfs_layout_type *
>> alloc_init_layout(struct inode *ino)
>> {
>> -	void *ld_data;
>> 	struct pnfs_layout_type *lo;
>> 	struct layoutdriver_io_operations *io_ops;
>>
>> 	io_ops = NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops;
>> -	lo = &NFS_I(ino)->layout;
>> -	ld_data = io_ops->alloc_layout(ino);
>> -	if (!ld_data) {
>> +	lo = NFS_I(ino)->layout;
>> +	lo = io_ops->alloc_layout(ino);
>
> Oops, ;-)

Yeah... :)
>
>> +	if (!lo) {
>> 		printk(KERN_ERR
>> 			"%s: out of memory: io_ops->alloc_layout failed\n",
>> 			__func__);
>> @@ -912,11 +914,17 @@ alloc_init_layout(struct inode *ino)
>> 	}
>>
>> 	spin_lock(&ino->i_lock);
>> -	BUG_ON(lo->ld_data != NULL);
>
> You could still do a BUG_ON(nfsi->layout) above before the io_ops- 
> >alloc_layout(ino)
> call.

OK.

>
>> -	lo->ld_data = ld_data;
>> -	memset(&lo->stateid, 0, NFS4_STATEID_SIZE);
>> 	lo->refcount = 1;
>> +	INIT_LIST_HEAD(&lo->lo_layouts);
>> +	INIT_LIST_HEAD(&lo->segs);
>> 	lo->roc_iomode = 0;
>> +	seqlock_init(&lo->seqlock);
>
> All these below, I'd drop. The comment above io_ops->alloc_layout  
> should
> say that it must return a ZEROed out structure, which it is in your
> files-layout patch.

Alright.

-->Andy

>
>> +	memset(&lo->stateid, 0, NFS4_STATEID_SIZE);
>> +	lo->lo_cred = NULL;
>> +	lo->pnfs_write_begin_pos = 0;
>> +	lo->pnfs_write_end_pos = 0;
>
>> +	lo->lo_inode = ino;
>> +	NFS_I(ino)->layout = lo;
>> 	spin_unlock(&ino->i_lock);
>
> Just as a note:
>  A pointer/word atomic inspection theory is based on the fact that  
> the set is
>  done with a memory barrier. Same as the test/set_bit operations. So  
> here
>  the spin_unlock provides that for us, naturally. (*Not* that the  
> inode state will
>  really need it, because no one will actually care before the  
> allocation is done)
>
>> 	return lo;
>> }
>> @@ -962,7 +970,7 @@ get_lock_alloc_layout(struct inode *ino)
>> 		/* Was current_layout already allocated while we slept?
>> 		 * If so, retry get_lock'ing it. Otherwise, allocate it.
>> 		 */
>> -		if (nfsi->layout.ld_data) {
>> +		if (nfsi->layout) {
>> 			spin_lock(&ino->i_lock);
>> 			continue;
>> 		}
>> @@ -1312,7 +1320,7 @@ pnfs_set_pg_test(struct inode *inode, struct  
>> nfs_pageio_descriptor *pgio)
>>
>> 	pgio->pg_test = NULL;
>>
>> -	laytype = &NFS_I(inode)->layout;
>> +	laytype = NFS_I(inode)->layout;
>> 	ld = NFS_SERVER(inode)->pnfs_curr_ld;
>> 	if (!pnfs_enabled_sb(NFS_SERVER(inode)) || !laytype)
>> 		return;
>> @@ -1445,7 +1453,7 @@ pnfs_writepages(struct nfs_write_data *wdata,  
>> int how)
>> 		numpages);
>> 	wdata->pdata.lseg = lseg;
>> 	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->write_pagelist(
>> -							&nfsi->layout,
>> +							nfsi->layout,
>> 							args->pages,
>> 							args->pgbase,
>> 							numpages,
>> @@ -1498,7 +1506,7 @@ pnfs_readpages(struct nfs_read_data *rdata)
>> 		__func__, numpages);
>> 	rdata->pdata.lseg = lseg;
>> 	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->read_pagelist(
>> -							&nfsi->layout,
>> +							nfsi->layout,
>> 							args->pages,
>> 							args->pgbase,
>> 							numpages,
>> @@ -1559,7 +1567,7 @@ pnfs_commit(struct nfs_write_data *data, int  
>> sync)
>> 	 * This will be done by passing the buck to the layout driver.
>> 	 */
>> 	data->pdata.lseg = NULL;
>> -	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(&nfsi->layout,
>> +	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(nfsi->layout,
>> 							sync, data);
>> 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
>> 	return trypnfs;
>> @@ -1630,14 +1638,14 @@ pnfs_layoutcommit_inode(struct inode  
>> *inode, int sync)
>> 	/* Clear layoutcommit properties in the inode so
>> 	 * new lc info can be generated
>> 	 */
>> -	write_begin_pos = nfsi->layout.pnfs_write_begin_pos;
>> -	write_end_pos = nfsi->layout.pnfs_write_end_pos;
>> -	data->cred = nfsi->layout.lo_cred;
>> -	nfsi->layout.pnfs_write_begin_pos = 0;
>> -	nfsi->layout.pnfs_write_end_pos = 0;
>> -	nfsi->layout.lo_cred = NULL;
>> +	write_begin_pos = nfsi->layout->pnfs_write_begin_pos;
>> +	write_end_pos = nfsi->layout->pnfs_write_end_pos;
>> +	data->cred = nfsi->layout->lo_cred;
>> +	nfsi->layout->pnfs_write_begin_pos = 0;
>> +	nfsi->layout->pnfs_write_end_pos = 0;
>> +	nfsi->layout->lo_cred = NULL;
>> 	__clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->pnfs_layout_state);
>> -	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
>> +	pnfs_get_layout_stateid(&data->args.stateid, nfsi->layout);
>>
>> 	spin_unlock(&inode->i_lock);
>>
>> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
>> index 4d9b15c..6e46589 100644
>> --- a/include/linux/nfs4_pnfs.h
>> +++ b/include/linux/nfs4_pnfs.h
>> @@ -35,13 +35,13 @@ struct pnfs_layoutdriver_type {
>> static inline struct nfs_inode *
>> PNFS_NFS_INODE(struct pnfs_layout_type *lo)
>> {
>> -	return container_of(lo, struct nfs_inode, layout);
>> +	return NFS_I(lo->lo_inode);
>> }
>>
>> static inline struct inode *
>> PNFS_INODE(struct pnfs_layout_type *lo)
>> {
>> -	return &PNFS_NFS_INODE(lo)->vfs_inode;
>> +	return lo->lo_inode;
>> }
>>
>> static inline struct nfs_server *
>> @@ -50,12 +50,6 @@ PNFS_NFS_SERVER(struct pnfs_layout_type *lo)
>> 	return NFS_SERVER(PNFS_INODE(lo));
>> }
>>
>> -static inline void *
>> -PNFS_LD_DATA(struct pnfs_layout_type *lo)
>> -{
>> -	return lo->ld_data;
>> -}
>> -
>> static inline struct pnfs_layoutdriver_type *
>> PNFS_LD(struct pnfs_layout_type *lo)
>> {
>> @@ -77,7 +71,7 @@ PNFS_LD_POLICY_OPS(struct pnfs_layout_type *lo)
>> static inline bool
>> has_layout(struct nfs_inode *nfsi)
>> {
>> -	return nfsi->layout.ld_data != NULL;
>> +	return nfsi->layout != NULL;
>> }
>>
>> static inline bool
>> @@ -149,7 +143,7 @@ struct layoutdriver_io_operations {
>> 	/* Layout information. For each inode, alloc_layout is executed  
>> once to retrieve an
>> 	 * inode specific layout structure.  Each subsequent layoutget  
>> operation results in
>> 	 * a set_layout call to set the opaque layout in the layout  
>> driver.*/
>> -	void * (*alloc_layout) (struct inode *inode);
>> +	struct pnfs_layout_type * (*alloc_layout) (struct inode *inode);
>> 	void (*free_layout) (void *layoutid);
>> 	struct pnfs_layout_segment * (*alloc_lseg) (struct  
>> pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
>> 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>> index cebc958..43d516e 100644
>> --- a/include/linux/nfs_fs.h
>> +++ b/include/linux/nfs_fs.h
>> @@ -104,13 +104,13 @@ struct pnfs_layout_type {
>> 	int roc_iomode;			/* iomode to return on close, 0=none */
>> 	seqlock_t seqlock;		/* Protects the stateid */
>> 	nfs4_stateid stateid;
>> -	void *ld_data;			/* layout driver private data */
>> 	struct rpc_cred         *lo_cred; /* layoutcommit credential */
>> 	/* DH: These vars keep track of the maximum write range
>> 	 * so the values can be used for layoutcommit.
>> 	 */
>> 	loff_t                  pnfs_write_begin_pos;
>> 	loff_t                  pnfs_write_end_pos;
>> +	struct inode		*lo_inode;
>> };
>>
>> /*
>> @@ -201,7 +201,7 @@ struct nfs_inode {
>> 	/* pNFS layout information */
>> #if defined(CONFIG_NFS_V4_1)
>> 	wait_queue_head_t lo_waitq;
>> -	struct pnfs_layout_type layout;
>> +	struct pnfs_layout_type *layout;
>> 	unsigned long pnfs_layout_state;
>> 	#define NFS_INO_RO_LAYOUT_FAILED 0 /* ro LAYOUTGET failed stop  
>> trying */
>> 	#define NFS_INO_RW_LAYOUT_FAILED 1 /* rw LAYOUTGET failed stop  
>> trying */
>
> Boaz

