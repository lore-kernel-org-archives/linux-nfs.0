Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:55486 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab1JKCfy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Oct 2011 22:35:54 -0400
Received: by ywb5 with SMTP id 5so6040188ywb.19
        for <linux-nfs@vger.kernel.org>; Mon, 10 Oct 2011 19:35:53 -0700 (PDT)
Message-ID: <4E8F3672.6030009@tonian.com>
Date: Fri, 07 Oct 2011 13:27:14 -0400
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH 19/19] pnfs-obj: move to ore 03: Remove old raid engine
References: <4E8ADEDA.4050709@panasas.com> <1317724632-27887-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <1317724632-27887-1-git-send-email-bharrosh@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-10-04 06:37, Boaz Harrosh wrote:
> Finally remove all the old raid engine, which is by now
> dead code.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Acked-by: Benny Halevy <bhalevy@tonian.com>

Thanks!

> ---
>  fs/nfs/objlayout/objio_osd.c |  504 ------------------------------------------
>  1 files changed, 0 insertions(+), 504 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index 00b3849..3161da6 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -188,48 +188,6 @@ out:
>  	return err;
>  }
>  
> -#if 0
> -static int _verify_data_map(struct pnfs_osd_layout *layout)
> -{
> -	struct pnfs_osd_data_map *data_map = &layout->olo_map;
> -	u64 stripe_length;
> -	u32 group_width;
> -
> -/* FIXME: Only raid0 for now. if not go through MDS */
> -	if (data_map->odm_raid_algorithm != PNFS_OSD_RAID_0) {
> -		printk(KERN_ERR "Only RAID_0 for now\n");
> -		return -ENOTSUPP;
> -	}
> -	if (0 != (data_map->odm_num_comps % (data_map->odm_mirror_cnt + 1))) {
> -		printk(KERN_ERR "Data Map wrong, num_comps=%u mirrors=%u\n",
> -			  data_map->odm_num_comps, data_map->odm_mirror_cnt);
> -		return -EINVAL;
> -	}
> -
> -	if (data_map->odm_group_width)
> -		group_width = data_map->odm_group_width;
> -	else
> -		group_width = data_map->odm_num_comps /
> -						(data_map->odm_mirror_cnt + 1);
> -
> -	stripe_length = (u64)data_map->odm_stripe_unit * group_width;
> -	if (stripe_length >= (1ULL << 32)) {
> -		printk(KERN_ERR "Total Stripe length(0x%llx)"
> -			  " >= 32bit is not supported\n", _LLU(stripe_length));
> -		return -ENOTSUPP;
> -	}
> -
> -	if (0 != (data_map->odm_stripe_unit & ~PAGE_MASK)) {
> -		printk(KERN_ERR "Stripe Unit(0x%llx)"
> -			  " must be Multples of PAGE_SIZE(0x%lx)\n",
> -			  _LLU(data_map->odm_stripe_unit), PAGE_SIZE);
> -		return -ENOTSUPP;
> -	}
> -
> -	return 0;
> -}
> -#endif
> -
>  static void copy_single_comp(struct ore_components *oc, unsigned c,
>  			     struct pnfs_osd_object_cred *src_comp)
>  {
> @@ -441,327 +399,6 @@ static void __on_dev_error(struct ore_io_state *ios,
>  				dev_offset, dev_len, !ios->reading);
>  }
>  
> -#if 0
> -static void _clear_bio(struct bio *bio)
> -{
> -	struct bio_vec *bv;
> -	unsigned i;
> -
> -	__bio_for_each_segment(bv, bio, i, 0) {
> -		unsigned this_count = bv->bv_len;
> -
> -		if (likely(PAGE_SIZE == this_count))
> -			clear_highpage(bv->bv_page);
> -		else
> -			zero_user(bv->bv_page, bv->bv_offset, this_count);
> -	}
> -}
> -
> -static int _io_check(struct objio_state *ios, bool is_write)
> -{
> -	enum osd_err_priority oep = OSD_ERR_PRI_NO_ERROR;
> -	int lin_ret = 0;
> -	int i;
> -
> -	for (i = 0; i <  ios->numdevs; i++) {
> -		struct osd_sense_info osi;
> -		struct osd_request *or = ios->per_dev[i].or;
> -		int ret;
> -
> -		if (!or)
> -			continue;
> -
> -		ret = osd_req_decode_sense(or, &osi);
> -		if (likely(!ret))
> -			continue;
> -
> -		if (OSD_ERR_PRI_CLEAR_PAGES == osi.osd_err_pri) {
> -			/* start read offset passed endof file */
> -			BUG_ON(is_write);
> -			_clear_bio(ios->per_dev[i].bio);
> -			dprintk("%s: start read offset passed end of file "
> -				"offset=0x%llx, length=0x%lx\n", __func__,
> -				_LLU(ios->per_dev[i].offset),
> -				ios->per_dev[i].length);
> -
> -			continue; /* we recovered */
> -		}
> -		__on_dev_error(ios, is_write, ios->oc->ods[i],
> -				ios->per_dev[i].dev, osi.osd_err_pri,
> -				ios->per_dev[i].offset, ios->per_dev[i].length);
> -
> -		if (osi.osd_err_pri >= oep) {
> -			oep = osi.osd_err_pri;
> -			lin_ret = ret;
> -		}
> -	}
> -
> -	return lin_ret;
> -}
> -
> -/*
> - * Common IO state helpers.
> - */
> -static void _io_free(struct objio_state *ios)
> -{
> -	unsigned i;
> -
> -	for (i = 0; i < ios->numdevs; i++) {
> -		struct _objio_per_comp *per_dev = &ios->per_dev[i];
> -
> -		if (per_dev->or) {
> -			osd_end_request(per_dev->or);
> -			per_dev->or = NULL;
> -		}
> -
> -		if (per_dev->bio) {
> -			bio_put(per_dev->bio);
> -			per_dev->bio = NULL;
> -		}
> -	}
> -}
> -
> -struct osd_dev *_io_od(struct objio_state *ios, unsigned dev)
> -{
> -	unsigned min_dev = ios->oc->first_dev;
> -	unsigned max_dev = min_dev + ios->oc->numdevs;
> -
> -	BUG_ON(dev < min_dev || max_dev <= dev);
> -	return ios->oc->ods[dev - min_dev]->od;
> -}
> -
> -struct _striping_info {
> -	u64 obj_offset;
> -	u64 group_length;
> -	unsigned dev;
> -	unsigned unit_off;
> -};
> -
> -static void _calc_stripe_info(struct objio_state *ios, u64 file_offset,
> -			      struct _striping_info *si)
> -{
> -	u32	stripe_unit = ios->layout->stripe_unit;
> -	u32	group_width = ios->layout->group_width;
> -	u64	group_depth = ios->layout->group_depth;
> -	u32	U = stripe_unit * group_width;
> -
> -	u64	T = U * group_depth;
> -	u64	S = T * ios->layout->group_count;
> -	u64	M = div64_u64(file_offset, S);
> -
> -	/*
> -	G = (L - (M * S)) / T
> -	H = (L - (M * S)) % T
> -	*/
> -	u64	LmodU = file_offset - M * S;
> -	u32	G = div64_u64(LmodU, T);
> -	u64	H = LmodU - G * T;
> -
> -	u32	N = div_u64(H, U);
> -
> -	div_u64_rem(file_offset, stripe_unit, &si->unit_off);
> -	si->obj_offset = si->unit_off + (N * stripe_unit) +
> -				  (M * group_depth * stripe_unit);
> -
> -	/* "H - (N * U)" is just "H % U" so it's bound to u32 */
> -	si->dev = (u32)(H - (N * U)) / stripe_unit + G * group_width;
> -	si->dev *= ios->layout->mirrors_p1;
> -
> -	si->group_length = T - H;
> -}
> -
> -static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
> -		unsigned pgbase, struct _objio_per_comp *per_dev, int len,
> -		gfp_t gfp_flags)
> -{
> -	unsigned pg = *cur_pg;
> -	int cur_len = len;
> -	struct request_queue *q =
> -			osd_request_queue(_io_od(ios, per_dev->dev));
> -
> -	if (per_dev->bio == NULL) {
> -		unsigned pages_in_stripe = ios->layout->group_width *
> -				      (ios->layout->stripe_unit / PAGE_SIZE);
> -		unsigned bio_size = (ios->nr_pages + pages_in_stripe) /
> -				    ios->layout->group_width;
> -
> -		if (BIO_MAX_PAGES_KMALLOC < bio_size)
> -			bio_size = BIO_MAX_PAGES_KMALLOC;
> -
> -		per_dev->bio = bio_kmalloc(gfp_flags, bio_size);
> -		if (unlikely(!per_dev->bio)) {
> -			dprintk("Faild to allocate BIO size=%u\n", bio_size);
> -			return -ENOMEM;
> -		}
> -	}
> -
> -	while (cur_len > 0) {
> -		unsigned pglen = min_t(unsigned, PAGE_SIZE - pgbase, cur_len);
> -		unsigned added_len;
> -
> -		BUG_ON(ios->nr_pages <= pg);
> -		cur_len -= pglen;
> -
> -		added_len = bio_add_pc_page(q, per_dev->bio,
> -					ios->pages[pg], pglen, pgbase);
> -		if (unlikely(pglen != added_len))
> -			return -ENOMEM;
> -		pgbase = 0;
> -		++pg;
> -	}
> -	BUG_ON(cur_len);
> -
> -	per_dev->length += len;
> -	*cur_pg = pg;
> -	return 0;
> -}
> -
> -static int _prepare_one_group(struct objio_state *ios, u64 length,
> -			      struct _striping_info *si, unsigned *last_pg,
> -			      gfp_t gfp_flags)
> -{
> -	unsigned stripe_unit = ios->layout->stripe_unit;
> -	unsigned mirrors_p1 = ios->layout->mirrors_p1;
> -	unsigned devs_in_group = ios->layout->group_width * mirrors_p1;
> -	unsigned dev = si->dev;
> -	unsigned first_dev = dev - (dev % devs_in_group);
> -	unsigned max_comp = ios->numdevs ? ios->numdevs - mirrors_p1 : 0;
> -	unsigned cur_pg = *last_pg;
> -	int ret = 0;
> -
> -	while (length) {
> -		struct _objio_per_comp *per_dev = &ios->per_dev[dev - first_dev];
> -		unsigned cur_len, page_off = 0;
> -
> -		if (!per_dev->length) {
> -			per_dev->dev = dev;
> -			if (dev < si->dev) {
> -				per_dev->offset = si->obj_offset + stripe_unit -
> -								   si->unit_off;
> -				cur_len = stripe_unit;
> -			} else if (dev == si->dev) {
> -				per_dev->offset = si->obj_offset;
> -				cur_len = stripe_unit - si->unit_off;
> -				page_off = si->unit_off & ~PAGE_MASK;
> -				BUG_ON(page_off &&
> -				      (page_off != ios->pgbase));
> -			} else { /* dev > si->dev */
> -				per_dev->offset = si->obj_offset - si->unit_off;
> -				cur_len = stripe_unit;
> -			}
> -
> -			if (max_comp < dev - first_dev)
> -				max_comp = dev - first_dev;
> -		} else {
> -			cur_len = stripe_unit;
> -		}
> -		if (cur_len >= length)
> -			cur_len = length;
> -
> -		ret = _add_stripe_unit(ios, &cur_pg, page_off , per_dev,
> -				       cur_len, gfp_flags);
> -		if (unlikely(ret))
> -			goto out;
> -
> -		dev += mirrors_p1;
> -		dev = (dev % devs_in_group) + first_dev;
> -
> -		length -= cur_len;
> -		ios->length += cur_len;
> -	}
> -out:
> -	ios->numdevs = max_comp + mirrors_p1;
> -	*last_pg = cur_pg;
> -	return ret;
> -}
> -
> -static int _io_rw_pagelist(struct objio_state *ios, gfp_t gfp_flags)
> -{
> -	u64 length = ios->count;
> -	u64 offset = ios->offset;
> -	struct _striping_info si;
> -	unsigned last_pg = 0;
> -	int ret = 0;
> -
> -	while (length) {
> -		_calc_stripe_info(ios, offset, &si);
> -
> -		if (length < si.group_length)
> -			si.group_length = length;
> -
> -		ret = _prepare_one_group(ios, si.group_length, &si, &last_pg, gfp_flags);
> -		if (unlikely(ret))
> -			goto out;
> -
> -		offset += si.group_length;
> -		length -= si.group_length;
> -	}
> -
> -out:
> -	if (!ios->length)
> -		return ret;
> -
> -	return 0;
> -}
> -
> -static int _sync_done(struct objio_state *ios)
> -{
> -	struct completion *waiting = ios->private;
> -
> -	complete(waiting);
> -	return 0;
> -}
> -
> -static void _last_io(struct kref *kref)
> -{
> -	struct objio_state *ios = container_of(kref, struct objio_state, kref);
> -
> -	ios->done(ios);
> -}
> -
> -static void _done_io(struct osd_request *or, void *p)
> -{
> -	struct objio_state *ios = p;
> -
> -	kref_put(&ios->kref, _last_io);
> -}
> -
> -static int _io_exec(struct objio_state *ios)
> -{
> -	DECLARE_COMPLETION_ONSTACK(wait);
> -	int ret = 0;
> -	unsigned i;
> -	objio_done_fn saved_done_fn = ios->done;
> -	bool sync = ios->sync;
> -
> -	if (sync) {
> -		ios->done = _sync_done;
> -		ios->private = &wait;
> -	}
> -
> -	kref_init(&ios->kref);
> -
> -	for (i = 0; i < ios->numdevs; i++) {
> -		struct osd_request *or = ios->per_dev[i].or;
> -
> -		if (!or)
> -			continue;
> -
> -		kref_get(&ios->kref);
> -		osd_execute_request_async(or, _done_io, ios);
> -	}
> -
> -	kref_put(&ios->kref, _last_io);
> -
> -	if (sync) {
> -		wait_for_completion(&wait);
> -		ret = saved_done_fn(ios);
> -	}
> -
> -	return ret;
> -}
> -#endif
> -
>  /*
>   * read
>   */
> @@ -781,63 +418,6 @@ static void _read_done(struct ore_io_state *ios, void *private)
>  	objlayout_read_done(&objios->oir, status, objios->sync);
>  }
>  
> -#if 0
> -static int _read_mirrors(struct objio_state *ios, unsigned cur_comp)
> -{
> -	struct osd_request *or = NULL;
> -	struct _objio_per_comp *per_dev = &ios->per_dev[cur_comp];
> -	unsigned dev = per_dev->dev;
> -	struct ore_comp *cred =
> -			&ios->oc->comps[cur_comp];
> -	struct osd_obj_id obj = cred->obj;
> -	int ret;
> -
> -	or = osd_start_request(_io_od(ios, dev), GFP_KERNEL);
> -	if (unlikely(!or)) {
> -		ret = -ENOMEM;
> -		goto err;
> -	}
> -	per_dev->or = or;
> -
> -	osd_req_read(or, &obj, per_dev->offset, per_dev->bio, per_dev->length);
> -
> -	ret = osd_finalize_request(or, 0, cred->cred, NULL);
> -	if (ret) {
> -		dprintk("%s: Faild to osd_finalize_request() => %d\n",
> -			__func__, ret);
> -		goto err;
> -	}
> -
> -	dprintk("%s:[%d] dev=%d obj=0x%llx start=0x%llx length=0x%lx\n",
> -		__func__, cur_comp, dev, obj.id, _LLU(per_dev->offset),
> -		per_dev->length);
> -
> -err:
> -	return ret;
> -}
> -
> -static int _read_exec(struct objio_state *ios)
> -{
> -	unsigned i;
> -	int ret;
> -
> -	for (i = 0; i < ios->numdevs; i += ios->layout->mirrors_p1) {
> -		if (!ios->per_dev[i].length)
> -			continue;
> -		ret = _read_mirrors(ios, i);
> -		if (unlikely(ret))
> -			goto err;
> -	}
> -
> -	ios->done = _read_done;
> -	return _io_exec(ios);
> -
> -err:
> -	_io_free(ios);
> -	return ret;
> -}
> -#endif
> -
>  int objio_read_pagelist(struct nfs_read_data *rdata)
>  {
>  	struct objio_state *objios;
> @@ -879,90 +459,6 @@ static void _write_done(struct ore_io_state *ios, void *private)
>  	objlayout_write_done(&objios->oir, status, objios->sync);
>  }
>  
> -#if 0
> -static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
> -{
> -	struct _objio_per_comp *master_dev = &ios->per_dev[cur_comp];
> -	unsigned dev = ios->per_dev[cur_comp].dev;
> -	unsigned last_comp = cur_comp + ios->layout->mirrors_p1;
> -	int ret;
> -
> -	for (; cur_comp < last_comp; ++cur_comp, ++dev) {
> -		struct osd_request *or = NULL;
> -		struct ore_comp *cred = &ios->oc->comps[cur_comp];
> -		struct osd_obj_id obj = cred->obj;
> -		struct _objio_per_comp *per_dev = &ios->per_dev[cur_comp];
> -		struct bio *bio;
> -
> -		or = osd_start_request(_io_od(ios, dev), GFP_NOFS);
> -		if (unlikely(!or)) {
> -			ret = -ENOMEM;
> -			goto err;
> -		}
> -		per_dev->or = or;
> -
> -		if (per_dev != master_dev) {
> -			bio = bio_kmalloc(GFP_NOFS,
> -					  master_dev->bio->bi_max_vecs);
> -			if (unlikely(!bio)) {
> -				dprintk("Faild to allocate BIO size=%u\n",
> -					master_dev->bio->bi_max_vecs);
> -				ret = -ENOMEM;
> -				goto err;
> -			}
> -
> -			__bio_clone(bio, master_dev->bio);
> -			bio->bi_bdev = NULL;
> -			bio->bi_next = NULL;
> -			per_dev->bio = bio;
> -			per_dev->dev = dev;
> -			per_dev->length = master_dev->length;
> -			per_dev->offset =  master_dev->offset;
> -		} else {
> -			bio = master_dev->bio;
> -			bio->bi_rw |= REQ_WRITE;
> -		}
> -
> -		osd_req_write(or, &obj, per_dev->offset, bio, per_dev->length);
> -
> -		ret = osd_finalize_request(or, 0, cred->cred, NULL);
> -		if (ret) {
> -			dprintk("%s: Faild to osd_finalize_request() => %d\n",
> -				__func__, ret);
> -			goto err;
> -		}
> -
> -		dprintk("%s:[%d] dev=%d obj=0x%llx start=0x%llx length=0x%lx\n",
> -			__func__, cur_comp, dev, obj.id, _LLU(per_dev->offset),
> -			per_dev->length);
> -	}
> -
> -err:
> -	return ret;
> -}
> -
> -static int _write_exec(struct objio_state *ios)
> -{
> -	unsigned i;
> -	int ret;
> -
> -	for (i = 0; i < ios->numdevs; i += ios->layout->mirrors_p1) {
> -		if (!ios->per_dev[i].length)
> -			continue;
> -		ret = _write_mirrors(ios, i);
> -		if (unlikely(ret))
> -			goto err;
> -	}
> -
> -	ios->done = _write_done;
> -	return _io_exec(ios);
> -
> -err:
> -	_io_free(ios);
> -	return ret;
> -}
> -#endif
> -
>  int objio_write_pagelist(struct nfs_write_data *wdata, int how)
>  {
>  	struct objio_state *objios;
