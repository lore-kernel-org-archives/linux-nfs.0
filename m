Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:43550 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441Ab1JKCcr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Oct 2011 22:32:47 -0400
Received: by ggnv2 with SMTP id v2so5174729ggn.19
        for <linux-nfs@vger.kernel.org>; Mon, 10 Oct 2011 19:32:47 -0700 (PDT)
Message-ID: <4E8F343D.8080408@tonian.com>
Date: Fri, 07 Oct 2011 13:17:49 -0400
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH 15/19] pnfs-obj: Get rid of objlayout_{alloc,free}_io_state
References: <4E8ADEDA.4050709@panasas.com> <1317724539-27764-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <1317724539-27764-1-git-send-email-bharrosh@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-10-04 06:35, Boaz Harrosh wrote:
> This is part of moving objio_osd to use the ORE.
> 
> objlayout_io_state had two functions:
> 1. It was used in the error reporting mechanism at layout_return.
>    This function is kept intact.
>    (Later patch will rename objlayout_io_state => objlayout_io_res)
> 2. Carrier of rw io members into the objio_read/write_paglist API.
>    This is removed in this patch.
> 
> The {r,w}data received from NFS are passed directly to the
> objio_{read,write}_paglist API. The io_engine is now allocating
> it's own IO state as part of the read/write. The minimal
> functionality that was part of the generic allocation is passed
> to the io_engine.
> 
> So part of this patch is rename of:
> 	ios->ol_state.foo => ios->foo
> 
> At objlayout_{read,write}_done an objlayout_io_state is passed that
> denotes the result of the IO. (Hence the later name change).
> If the IO is successful objlayout calls an objio_free_result() API
> immediately (Which for objio_osd causes the release of the io_state).
> If the IO ended in an error it is hanged onto until reported in
> layout_return and is released later through the objio_free_result()
> API. (All this is not new just renamed and cleaned)
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Reviewed-by: Benny Halevy <bhalevy@tonian.com>

Thanks!

> ---
>  fs/nfs/objlayout/objio_osd.c |   94 ++++++++++++++++++++++----------
>  fs/nfs/objlayout/objlayout.c |  124 +++++++++++-------------------------------
>  fs/nfs/objlayout/objlayout.h |   36 ++++++-------
>  3 files changed, 112 insertions(+), 142 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index 0c7c9ec..48eb91a 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -148,6 +148,13 @@ struct objio_state {
>  	/* Generic layer */
>  	struct objlayout_io_state ol_state;
>  
> +	struct page **pages;
> +	unsigned pgbase;
> +	unsigned nr_pages;
> +	unsigned long count;
> +	loff_t offset;
> +	bool sync;
> +
>  	struct objio_segment *layout;
>  
>  	struct kref kref;
> @@ -394,30 +401,43 @@ void objio_free_lseg(struct pnfs_layout_segment *lseg)
>  	kfree(objio_seg);
>  }
>  
> -int objio_alloc_io_state(struct pnfs_layout_segment *lseg,
> -			 struct objlayout_io_state **outp,
> -			 gfp_t gfp_flags)
> +static int
> +objio_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
> +	struct pnfs_layout_segment *lseg, struct page **pages, unsigned pgbase,
> +	loff_t offset, size_t count, void *rpcdata, gfp_t gfp_flags,
> +	struct objio_state **outp)
>  {
>  	struct objio_segment *objio_seg = OBJIO_LSEG(lseg);
>  	struct objio_state *ios;
> -	const unsigned first_size = sizeof(*ios) +
> -				objio_seg->num_comps * sizeof(ios->per_dev[0]);
> -	const unsigned sec_size = objio_seg->num_comps *
> -						sizeof(ios->ol_state.ioerrs[0]);
> -
> -	ios = kzalloc(first_size + sec_size, gfp_flags);
> -	if (unlikely(!ios))
> +	struct __alloc_objio_state {
> +		struct objio_state objios;
> +		struct _objio_per_comp per_dev[objio_seg->num_comps];
> +		struct pnfs_osd_ioerr ioerrs[objio_seg->num_comps];
> +	} *aos;
> +
> +	aos = kzalloc(sizeof(*aos), gfp_flags);
> +	if (unlikely(!aos))
>  		return -ENOMEM;
>  
> -	ios->layout = objio_seg;
> -	ios->ol_state.ioerrs = ((void *)ios) + first_size;
> -	ios->ol_state.num_comps = objio_seg->num_comps;
> +	ios = &aos->objios;
>  
> -	*outp = &ios->ol_state;
> +	ios->layout = objio_seg;
> +	objlayout_init_ioerrs(&aos->objios.ol_state, objio_seg->num_comps,
> +			aos->ioerrs, rpcdata, pnfs_layout_type);
> +
> +	ios->pages = pages;
> +	ios->pgbase = pgbase;
> +	ios->nr_pages = (pgbase + count + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	ios->offset = offset;
> +	ios->count = count;
> +	ios->sync = 0;
> +	BUG_ON(ios->nr_pages > (pgbase + count + PAGE_SIZE - 1) >> PAGE_SHIFT);
> +
> +	*outp = ios;
>  	return 0;
>  }
>  
> -void objio_free_io_state(struct objlayout_io_state *ol_state)
> +void objio_free_result(struct objlayout_io_state *ol_state)
>  {
>  	struct objio_state *ios = container_of(ol_state, struct objio_state,
>  					       ol_state);
> @@ -598,7 +618,7 @@ static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
>  	if (per_dev->bio == NULL) {
>  		unsigned pages_in_stripe = ios->layout->group_width *
>  				      (ios->layout->stripe_unit / PAGE_SIZE);
> -		unsigned bio_size = (ios->ol_state.nr_pages + pages_in_stripe) /
> +		unsigned bio_size = (ios->nr_pages + pages_in_stripe) /
>  				    ios->layout->group_width;
>  
>  		if (BIO_MAX_PAGES_KMALLOC < bio_size)
> @@ -615,11 +635,11 @@ static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
>  		unsigned pglen = min_t(unsigned, PAGE_SIZE - pgbase, cur_len);
>  		unsigned added_len;
>  
> -		BUG_ON(ios->ol_state.nr_pages <= pg);
> +		BUG_ON(ios->nr_pages <= pg);
>  		cur_len -= pglen;
>  
>  		added_len = bio_add_pc_page(q, per_dev->bio,
> -					ios->ol_state.pages[pg], pglen, pgbase);
> +					ios->pages[pg], pglen, pgbase);
>  		if (unlikely(pglen != added_len))
>  			return -ENOMEM;
>  		pgbase = 0;
> @@ -660,7 +680,7 @@ static int _prepare_one_group(struct objio_state *ios, u64 length,
>  				cur_len = stripe_unit - si->unit_off;
>  				page_off = si->unit_off & ~PAGE_MASK;
>  				BUG_ON(page_off &&
> -				      (page_off != ios->ol_state.pgbase));
> +				      (page_off != ios->pgbase));
>  			} else { /* dev > si->dev */
>  				per_dev->offset = si->obj_offset - si->unit_off;
>  				cur_len = stripe_unit;
> @@ -693,8 +713,8 @@ out:
>  
>  static int _io_rw_pagelist(struct objio_state *ios, gfp_t gfp_flags)
>  {
> -	u64 length = ios->ol_state.count;
> -	u64 offset = ios->ol_state.offset;
> +	u64 length = ios->count;
> +	u64 offset = ios->offset;
>  	struct _striping_info si;
>  	unsigned last_pg = 0;
>  	int ret = 0;
> @@ -748,7 +768,7 @@ static int _io_exec(struct objio_state *ios)
>  	int ret = 0;
>  	unsigned i;
>  	objio_done_fn saved_done_fn = ios->done;
> -	bool sync = ios->ol_state.sync;
> +	bool sync = ios->sync;
>  
>  	if (sync) {
>  		ios->done = _sync_done;
> @@ -792,7 +812,7 @@ static int _read_done(struct objio_state *ios)
>  	else
>  		status = ret;
>  
> -	objlayout_read_done(&ios->ol_state, status, ios->ol_state.sync);
> +	objlayout_read_done(&ios->ol_state, status, ios->sync);
>  	return ret;
>  }
>  
> @@ -854,12 +874,18 @@ err:
>  	return ret;
>  }
>  
> -int objio_read_pagelist(struct objlayout_io_state *ol_state)
> +int objio_read_pagelist(struct nfs_read_data *rdata)
>  {
> -	struct objio_state *ios = container_of(ol_state, struct objio_state,
> -					       ol_state);
> +	struct objio_state *ios;
>  	int ret;
>  
> +	ret = objio_alloc_io_state(NFS_I(rdata->inode)->layout,
> +			rdata->lseg, rdata->args.pages, rdata->args.pgbase,
> +			rdata->args.offset, rdata->args.count, rdata,
> +			GFP_KERNEL, &ios);
> +	if (unlikely(ret))
> +		return ret;
> +
>  	ret = _io_rw_pagelist(ios, GFP_KERNEL);
>  	if (unlikely(ret))
>  		return ret;
> @@ -886,7 +912,7 @@ static int _write_done(struct objio_state *ios)
>  		status = ret;
>  	}
>  
> -	objlayout_write_done(&ios->ol_state, status, ios->ol_state.sync);
> +	objlayout_write_done(&ios->ol_state, status, ios->sync);
>  	return ret;
>  }
>  
> @@ -976,12 +1002,20 @@ err:
>  	return ret;
>  }
>  
> -int objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
> +int objio_write_pagelist(struct nfs_write_data *wdata, int how)
>  {
> -	struct objio_state *ios = container_of(ol_state, struct objio_state,
> -					       ol_state);
> +	struct objio_state *ios;
>  	int ret;
>  
> +	ret = objio_alloc_io_state(NFS_I(wdata->inode)->layout,
> +			wdata->lseg, wdata->args.pages, wdata->args.pgbase,
> +			wdata->args.offset, wdata->args.count, wdata, GFP_NOFS,
> +			&ios);
> +	if (unlikely(ret))
> +		return ret;
> +
> +	ios->sync = 0 != (how & FLUSH_SYNC);
> +
>  	/* TODO: ios->stable = stable; */
>  	ret = _io_rw_pagelist(ios, GFP_NOFS);
>  	if (unlikely(ret))
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index 99c807d..a82053a 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> @@ -156,59 +156,23 @@ last_byte_offset(u64 start, u64 len)
>  	return end > start ? end - 1 : NFS4_MAX_UINT64;
>  }
>  
> -static struct objlayout_io_state *
> -objlayout_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
> -			struct page **pages,
> -			unsigned pgbase,
> -			loff_t offset,
> -			size_t count,
> -			struct pnfs_layout_segment *lseg,
> -			void *rpcdata,
> -			gfp_t gfp_flags)
> +void _fix_verify_io_params(struct pnfs_layout_segment *lseg,
> +			   struct page ***p_pages, unsigned *p_pgbase,
> +			   u64 offset, unsigned long count)
>  {
> -	struct objlayout_io_state *state;
>  	u64 lseg_end_offset;
>  
> -	dprintk("%s: allocating io_state\n", __func__);
> -	if (objio_alloc_io_state(lseg, &state, gfp_flags))
> -		return NULL;
> -
>  	BUG_ON(offset < lseg->pls_range.offset);
>  	lseg_end_offset = end_offset(lseg->pls_range.offset,
>  				     lseg->pls_range.length);
>  	BUG_ON(offset >= lseg_end_offset);
> -	if (offset + count > lseg_end_offset) {
> -		count = lseg->pls_range.length -
> -				(offset - lseg->pls_range.offset);
> -		dprintk("%s: truncated count %Zd\n", __func__, count);
> -	}
> +	WARN_ON(offset + count > lseg_end_offset);
>  
> -	if (pgbase > PAGE_SIZE) {
> -		pages += pgbase >> PAGE_SHIFT;
> -		pgbase &= ~PAGE_MASK;
> +	if (*p_pgbase > PAGE_SIZE) {
> +		dprintk("%s: pgbase(0x%x) > PAGE_SIZE\n", __func__, *p_pgbase);
> +		*p_pages += *p_pgbase >> PAGE_SHIFT;
> +		*p_pgbase &= ~PAGE_MASK;
>  	}
> -
> -	INIT_LIST_HEAD(&state->err_list);
> -	state->lseg = lseg;
> -	state->rpcdata = rpcdata;
> -	state->pages = pages;
> -	state->pgbase = pgbase;
> -	state->nr_pages = (pgbase + count + PAGE_SIZE - 1) >> PAGE_SHIFT;
> -	state->offset = offset;
> -	state->count = count;
> -	state->sync = 0;
> -
> -	return state;
> -}
> -
> -static void
> -objlayout_free_io_state(struct objlayout_io_state *state)
> -{
> -	dprintk("%s: freeing io_state\n", __func__);
> -	if (unlikely(!state))
> -		return;
> -
> -	objio_free_io_state(state);
>  }
>  
>  /*
> @@ -217,12 +181,10 @@ objlayout_free_io_state(struct objlayout_io_state *state)
>  static void
>  objlayout_iodone(struct objlayout_io_state *state)
>  {
> -	dprintk("%s: state %p status\n", __func__, state);
> -
>  	if (likely(state->status >= 0)) {
> -		objlayout_free_io_state(state);
> +		objio_free_result(state);
>  	} else {
> -		struct objlayout *objlay = OBJLAYOUT(state->lseg->pls_layout);
> +		struct objlayout *objlay = state->objlay;
>  
>  		spin_lock(&objlay->lock);
>  		objlay->delta_space_valid = OBJ_DSU_INVALID;
> @@ -289,15 +251,15 @@ objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
>  {
>  	struct nfs_read_data *rdata = state->rpcdata;
>  
> -	state->status = status;
> -	dprintk("%s: Begin status=%zd eof=%d\n", __func__,
> -		status, rdata->res.eof);
> -	rdata->task.tk_status = status;
> +	state->status = rdata->task.tk_status = status;
>  	if (status >= 0)
>  		rdata->res.count = status;
>  	objlayout_iodone(state);
>  	/* must not use state after this point */
>  
> +	dprintk("%s: Return status=%zd eof=%d sync=%d\n", __func__,
> +		status, rdata->res.eof, sync);
> +
>  	if (sync)
>  		pnfs_ld_read_done(rdata);
>  	else {
> @@ -314,7 +276,6 @@ objlayout_read_pagelist(struct nfs_read_data *rdata)
>  {
>  	loff_t offset = rdata->args.offset;
>  	size_t count = rdata->args.count;
> -	struct objlayout_io_state *state;
>  	int err;
>  	loff_t eof;
>  
> @@ -331,20 +292,14 @@ objlayout_read_pagelist(struct nfs_read_data *rdata)
>  	}
>  
>  	rdata->res.eof = (offset + count) >= eof;
> +	_fix_verify_io_params(rdata->lseg, &rdata->args.pages,
> +			      &rdata->args.pgbase,
> +			      rdata->args.offset, rdata->args.count);
>  
> -	state = objlayout_alloc_io_state(NFS_I(rdata->inode)->layout,
> -					 rdata->args.pages, rdata->args.pgbase,
> -					 offset, count,
> -					 rdata->lseg, rdata,
> -					 GFP_KERNEL);
> -	if (unlikely(!state)) {
> -		err = -ENOMEM;
> -		goto out;
> -	}
>  	dprintk("%s: inode(%lx) offset 0x%llx count 0x%Zx eof=%d\n",
>  		__func__, rdata->inode->i_ino, offset, count, rdata->res.eof);
>  
> -	err = objio_read_pagelist(state);
> +	err = objio_read_pagelist(rdata);
>   out:
>  	if (unlikely(err)) {
>  		rdata->pnfs_error = err;
> @@ -374,23 +329,18 @@ void
>  objlayout_write_done(struct objlayout_io_state *state, ssize_t status,
>  		     bool sync)
>  {
> -	struct nfs_write_data *wdata;
> +	struct nfs_write_data *wdata = state->rpcdata;
>  
> -	dprintk("%s: Begin\n", __func__);
> -	wdata = state->rpcdata;
> -	state->status = status;
> -	wdata->task.tk_status = status;
> +	state->status = wdata->task.tk_status = status;
>  	if (status >= 0) {
>  		wdata->res.count = status;
>  		wdata->verf.committed = state->committed;
> -		dprintk("%s: Return status %d committed %d\n",
> -			__func__, wdata->task.tk_status,
> -			wdata->verf.committed);
> -	} else
> -		dprintk("%s: Return status %d\n",
> -			__func__, wdata->task.tk_status);
> +	}
>  	objlayout_iodone(state);
> -	/* must not use state after this point */
> +	/* must not use oir after this point */
> +
> +	dprintk("%s: Return status %zd committed %d sync=%d\n", __func__,
> +		status, wdata->verf.committed, sync);
>  
>  	if (sync)
>  		pnfs_ld_write_done(wdata);
> @@ -407,25 +357,13 @@ enum pnfs_try_status
>  objlayout_write_pagelist(struct nfs_write_data *wdata,
>  			 int how)
>  {
> -	struct objlayout_io_state *state;
>  	int err;
>  
> -	state = objlayout_alloc_io_state(NFS_I(wdata->inode)->layout,
> -					 wdata->args.pages,
> -					 wdata->args.pgbase,
> -					 wdata->args.offset,
> -					 wdata->args.count,
> -					 wdata->lseg, wdata,
> -					 GFP_NOFS);
> -	if (unlikely(!state)) {
> -		err = -ENOMEM;
> -		goto out;
> -	}
> +	_fix_verify_io_params(wdata->lseg, &wdata->args.pages,
> +			      &wdata->args.pgbase,
> +			      wdata->args.offset, wdata->args.count);
>  
> -	state->sync = how & FLUSH_SYNC;
> -
> -	err = objio_write_pagelist(state, how & FLUSH_STABLE);
> - out:
> +	err = objio_write_pagelist(wdata, how);
>  	if (unlikely(err)) {
>  		wdata->pnfs_error = err;
>  		dprintk("%s: Returned Error %d\n", __func__, err);
> @@ -564,7 +502,7 @@ encode_accumulated_error(struct objlayout *objlay, __be32 *p)
>  			merge_ioerr(&accumulated_err, ioerr);
>  		}
>  		list_del(&state->err_list);
> -		objlayout_free_io_state(state);
> +		objio_free_result(state);
>  	}
>  
>  	pnfs_osd_xdr_encode_ioerr(p, &accumulated_err);
> @@ -632,7 +570,7 @@ objlayout_encode_layoutreturn(struct pnfs_layout_hdr *pnfslay,
>  			goto loop_done;
>  		}
>  		list_del(&state->err_list);
> -		objlayout_free_io_state(state);
> +		objio_free_result(state);
>  	}
>  loop_done:
>  	spin_unlock(&objlay->lock);
> diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
> index 4edac9b..d7b2ccfa 100644
> --- a/fs/nfs/objlayout/objlayout.h
> +++ b/fs/nfs/objlayout/objlayout.h
> @@ -75,14 +75,7 @@ OBJLAYOUT(struct pnfs_layout_hdr *lo)
>   * embedded in objects provider io_state data structure
>   */
>  struct objlayout_io_state {
> -	struct pnfs_layout_segment *lseg;
> -
> -	struct page **pages;
> -	unsigned pgbase;
> -	unsigned nr_pages;
> -	unsigned long count;
> -	loff_t offset;
> -	bool sync;
> +	struct objlayout *objlay;
>  
>  	void *rpcdata;
>  	int status;             /* res */
> @@ -99,6 +92,18 @@ struct objlayout_io_state {
>  	struct pnfs_osd_ioerr *ioerrs;
>  };
>  
> +static inline
> +void objlayout_init_ioerrs(struct objlayout_io_state *oir, unsigned num_comps,
> +			struct pnfs_osd_ioerr *ioerrs, void *rpcdata,
> +			struct pnfs_layout_hdr *pnfs_layout_type)
> +{
> +	oir->objlay = OBJLAYOUT(pnfs_layout_type);
> +	oir->rpcdata = rpcdata;
> +	INIT_LIST_HEAD(&oir->err_list);
> +	oir->num_comps = num_comps;
> +	oir->ioerrs = ioerrs;
> +}
> +
>  /*
>   * Raid engine I/O API
>   */
> @@ -109,15 +114,10 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
>  	gfp_t gfp_flags);
>  extern void objio_free_lseg(struct pnfs_layout_segment *lseg);
>  
> -extern int objio_alloc_io_state(
> -	struct pnfs_layout_segment *lseg,
> -	struct objlayout_io_state **outp,
> -	gfp_t gfp_flags);
> -extern void objio_free_io_state(struct objlayout_io_state *state);
> +extern void objio_free_result(struct objlayout_io_state *state);
>  
> -extern int objio_read_pagelist(struct objlayout_io_state *ol_state);
> -extern int objio_write_pagelist(struct objlayout_io_state *ol_state,
> -				    bool stable);
> +extern int objio_read_pagelist(struct nfs_read_data *rdata);
> +extern int objio_write_pagelist(struct nfs_write_data *wdata, int how);
>  
>  /*
>   * callback API
> @@ -127,10 +127,8 @@ extern void objlayout_io_set_result(struct objlayout_io_state *state,
>  			int osd_error, u64 offset, u64 length, bool is_write);
>  
>  static inline void
> -objlayout_add_delta_space_used(struct objlayout_io_state *state, s64 space_used)
> +objlayout_add_delta_space_used(struct objlayout *objlay, s64 space_used)
>  {
> -	struct objlayout *objlay = OBJLAYOUT(state->lseg->pls_layout);
> -
>  	/* If one of the I/Os errored out and the delta_space_used was
>  	 * invalid we render the complete report as invalid. Protocol mandate
>  	 * the DSU be accurate or not reported.
