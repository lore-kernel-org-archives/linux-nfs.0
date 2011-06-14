Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38165 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab1FNPk0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 11:40:26 -0400
Received: by iwn34 with SMTP id 34so4747790iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 08:40:26 -0700 (PDT)
Message-ID: <4DF780E8.8060300@gmail.com>
Date: Tue, 14 Jun 2011 11:40:24 -0400
From: Benny Halevy <bhalevy.lists@gmail.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 21/34] pnfsblock: SPLITME: add extent manipulation functions
References: <cover.1307921137.git.rees@umich.edu> <7075734d5615269fb396abdbf8d2b30cf602acc1.1307921138.git.rees@umich.edu>
In-Reply-To: <7075734d5615269fb396abdbf8d2b30cf602acc1.1307921138.git.rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Regarding the "SPLITME", please either fix the commit message
or split the patch :)
(I'm in favour of keeping this patch as it is)

Benny

On 2011-06-12 19:44, Jim Rees wrote:
> From: Fred Isaman <iisaman@citi.umich.edu>
>  as it i
> Adds working implementations of various support functions
> to handle INVAL extents, needed by writes, such as
> mark_initialized_sectors and is_sector_initialized.
> 
> SPLIT: this needs to be split into the exported functions, and the
> range support functions (which will be replaced eventually.)
> 
> [pnfsblock: fix 64-bit compiler warnings for extent manipulation]
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/blocklayout/blocklayout.h |   30 ++++-
>  fs/nfs/blocklayout/extents.c     |  253 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 281 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
> index 06aa36a..a231d49 100644
> --- a/fs/nfs/blocklayout/blocklayout.h
> +++ b/fs/nfs/blocklayout/blocklayout.h
> @@ -35,6 +35,8 @@
>  #include <linux/nfs_fs.h>
>  #include "../pnfs.h"
>  
> +#define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> 9)
> +
>  #define PG_pnfserr PG_owner_priv_1
>  #define PagePnfsErr(page)	test_bit(PG_pnfserr, &(page)->flags)
>  #define SetPagePnfsErr(page)	set_bit(PG_pnfserr, &(page)->flags)
> @@ -101,8 +103,23 @@ enum exstate4 {
>  	PNFS_BLOCK_NONE_DATA		= 3  /* unmapped, it's a hole */
>  };
>  
> +#define MY_MAX_TAGS (15) /* tag bitnums used must be less than this */
> +
> +struct my_tree_t {
> +	sector_t		mtt_step_size;	/* Internal sector alignment */
> +	struct list_head	mtt_stub; /* Should be a radix tree */
> +};
> +
>  struct pnfs_inval_markings {
> -	/* STUB */
> +	spinlock_t	im_lock;
> +	struct my_tree_t im_tree;	/* Sectors that need LAYOUTCOMMIT */
> +	sector_t	im_block_size;	/* Server blocksize in sectors */
> +};
> +
> +struct pnfs_inval_tracking {
> +	struct list_head it_link;
> +	int		 it_sector;
> +	int		 it_tags;
>  };
>  
>  /* sector_t fields are all in 512-byte sectors */
> @@ -121,7 +138,11 @@ struct pnfs_block_extent {
>  static inline void
>  INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
>  {
> -	/* STUB */
> +	spin_lock_init(&marks->im_lock);
> +	INIT_LIST_HEAD(&marks->im_tree.mtt_stub);
> +	marks->im_block_size = blocksize;
> +	marks->im_tree.mtt_step_size = min((sector_t)PAGE_CACHE_SECTORS,
> +					   blocksize);
>  }
>  
>  enum extentclass4 {
> @@ -222,8 +243,13 @@ void free_block_dev(struct pnfs_block_dev *bdev);
>  struct pnfs_block_extent *
>  find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
>  		struct pnfs_block_extent **cow_read);
> +int mark_initialized_sectors(struct pnfs_inval_markings *marks,
> +			     sector_t offset, sector_t length,
> +			     sector_t **pages);
>  void put_extent(struct pnfs_block_extent *be);
>  struct pnfs_block_extent *alloc_extent(void);
> +struct pnfs_block_extent *get_extent(struct pnfs_block_extent *be);
> +int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
>  int add_and_merge_extent(struct pnfs_block_layout *bl,
>  			 struct pnfs_block_extent *new);
>  
> diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
> index f0b3f13..3d36f66 100644
> --- a/fs/nfs/blocklayout/extents.c
> +++ b/fs/nfs/blocklayout/extents.c
> @@ -33,6 +33,259 @@
>  #include "blocklayout.h"
>  #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
>  
> +/* Bit numbers */
> +#define EXTENT_INITIALIZED 0
> +#define EXTENT_WRITTEN     1
> +#define EXTENT_IN_COMMIT   2
> +#define INTERNAL_EXISTS    MY_MAX_TAGS
> +#define INTERNAL_MASK      ((1 << INTERNAL_EXISTS) - 1)
> +
> +/* Returns largest t<=s s.t. t%base==0 */
> +static inline sector_t normalize(sector_t s, int base)
> +{
> +	sector_t tmp = s; /* Since do_div modifies its argument */
> +	return s - do_div(tmp, base);
> +}
> +
> +static inline sector_t normalize_up(sector_t s, int base)
> +{
> +	return normalize(s + base - 1, base);
> +}
> +
> +/* Complete stub using list while determine API wanted */
> +
> +/* Returns tags, or negative */
> +static int32_t _find_entry(struct my_tree_t *tree, u64 s)
> +{
> +	struct pnfs_inval_tracking *pos;
> +
> +	dprintk("%s(%llu) enter\n", __func__, s);
> +	list_for_each_entry_reverse(pos, &tree->mtt_stub, it_link) {
> +		if (pos->it_sector > s)
> +			continue;
> +		else if (pos->it_sector == s)
> +			return pos->it_tags & INTERNAL_MASK;
> +		else
> +			break;
> +	}
> +	return -ENOENT;
> +}
> +
> +static inline
> +int _has_tag(struct my_tree_t *tree, u64 s, int32_t tag)
> +{
> +	int32_t tags;
> +
> +	dprintk("%s(%llu, %i) enter\n", __func__, s, tag);
> +	s = normalize(s, tree->mtt_step_size);
> +	tags = _find_entry(tree, s);
> +	if ((tags < 0) || !(tags & (1 << tag)))
> +		return 0;
> +	else
> +		return 1;
> +}
> +
> +/* Creates entry with tag, or if entry already exists, unions tag to it.
> + * If storage is not NULL, newly created entry will use it.
> + * Returns number of entries added, or negative on error.
> + */
> +static int _add_entry(struct my_tree_t *tree, u64 s, int32_t tag,
> +		      struct pnfs_inval_tracking *storage)
> +{
> +	int found = 0;
> +	struct pnfs_inval_tracking *pos;
> +
> +	dprintk("%s(%llu, %i, %p) enter\n", __func__, s, tag, storage);
> +	list_for_each_entry_reverse(pos, &tree->mtt_stub, it_link) {
> +		if (pos->it_sector > s)
> +			continue;
> +		else if (pos->it_sector == s) {
> +			found = 1;
> +			break;
> +		} else
> +			break;
> +	}
> +	if (found) {
> +		pos->it_tags |= (1 << tag);
> +		return 0;
> +	} else {
> +		struct pnfs_inval_tracking *new;
> +		if (storage)
> +			new = storage;
> +		else {
> +			new = kmalloc(sizeof(*new), GFP_KERNEL);
> +			if (!new)
> +				return -ENOMEM;
> +		}
> +		new->it_sector = s;
> +		new->it_tags = (1 << tag);
> +		list_add(&new->it_link, &pos->it_link);
> +		return 1;
> +	}
> +}
> +
> +/* XXXX Really want option to not create */
> +/* Over range, unions tag with existing entries, else creates entry with tag */
> +static int _set_range(struct my_tree_t *tree, int32_t tag, u64 s, u64 length)
> +{
> +	u64 i;
> +
> +	dprintk("%s(%i, %llu, %llu) enter\n", __func__, tag, s, length);
> +	for (i = normalize(s, tree->mtt_step_size); i < s + length;
> +	     i += tree->mtt_step_size)
> +		if (_add_entry(tree, i, tag, NULL))
> +			return -ENOMEM;
> +	return 0;
> +}
> +
> +/* Ensure that future operations on given range of tree will not malloc */
> +static int _preload_range(struct my_tree_t *tree, u64 offset, u64 length)
> +{
> +	u64 start, end, s;
> +	int count, i, used = 0, status = -ENOMEM;
> +	struct pnfs_inval_tracking **storage;
> +
> +	dprintk("%s(%llu, %llu) enter\n", __func__, offset, length);
> +	start = normalize(offset, tree->mtt_step_size);
> +	end = normalize_up(offset + length, tree->mtt_step_size);
> +	count = (int)(end - start) / (int)tree->mtt_step_size;
> +
> +	/* Pre-malloc what memory we might need */
> +	storage = kmalloc(sizeof(*storage) * count, GFP_KERNEL);
> +	if (!storage)
> +		return -ENOMEM;
> +	for (i = 0; i < count; i++) {
> +		storage[i] = kmalloc(sizeof(struct pnfs_inval_tracking),
> +				     GFP_KERNEL);
> +		if (!storage[i])
> +			goto out_cleanup;
> +	}
> +
> +	/* Now need lock - HOW??? */
> +
> +	for (s = start; s < end; s += tree->mtt_step_size)
> +		used += _add_entry(tree, s, INTERNAL_EXISTS, storage[used]);
> +
> +	/* Unlock - HOW??? */
> +	status = 0;
> +
> + out_cleanup:
> +	for (i = used; i < count; i++) {
> +		if (!storage[i])
> +			break;
> +		kfree(storage[i]);
> +	}
> +	kfree(storage);
> +	return status;
> +}
> +
> +static void set_needs_init(sector_t *array, sector_t offset)
> +{
> +	sector_t *p = array;
> +
> +	dprintk("%s enter\n", __func__);
> +	if (!p)
> +		return;
> +	while (*p < offset)
> +		p++;
> +	if (*p == offset)
> +		return;
> +	else if (*p == ~0) {
> +		*p++ = offset;
> +		*p = ~0;
> +		return;
> +	} else {
> +		sector_t *save = p;
> +		dprintk("%s Adding %llu\n", __func__, (u64)offset);
> +		while (*p != ~0)
> +			p++;
> +		p++;
> +		memmove(save + 1, save, (char *)p - (char *)save);
> +		*save = offset;
> +		return;
> +	}
> +}
> +
> +/* We are relying on page lock to serialize this */
> +int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect)
> +{
> +	int rv;
> +
> +	spin_lock(&marks->im_lock);
> +	rv = _has_tag(&marks->im_tree, isect, EXTENT_INITIALIZED);
> +	spin_unlock(&marks->im_lock);
> +	return rv;
> +}
> +
> +/* Marks sectors in [offest, offset_length) as having been initialized.
> + * All lengths are step-aligned, where step is min(pagesize, blocksize).
> + * Notes where partial block is initialized, and helps prepare it for
> + * complete initialization later.
> + */
> +/* Currently assumes offset is page-aligned */
> +int mark_initialized_sectors(struct pnfs_inval_markings *marks,
> +			     sector_t offset, sector_t length,
> +			     sector_t **pages)
> +{
> +	sector_t s, start, end;
> +	sector_t *array = NULL; /* Pages to mark */
> +
> +	dprintk("%s(offset=%llu,len=%llu) enter\n",
> +		__func__, (u64)offset, (u64)length);
> +	s = max((sector_t) 3,
> +		2 * (marks->im_block_size / (PAGE_CACHE_SECTORS)));
> +	dprintk("%s set max=%llu\n", __func__, (u64)s);
> +	if (pages) {
> +		array = kmalloc(s * sizeof(sector_t), GFP_KERNEL);
> +		if (!array)
> +			goto outerr;
> +		array[0] = ~0;
> +	}
> +
> +	start = normalize(offset, marks->im_block_size);
> +	end = normalize_up(offset + length, marks->im_block_size);
> +	if (_preload_range(&marks->im_tree, start, end - start))
> +		goto outerr;
> +
> +	spin_lock(&marks->im_lock);
> +
> +	for (s = normalize_up(start, PAGE_CACHE_SECTORS);
> +	     s < offset; s += PAGE_CACHE_SECTORS) {
> +		dprintk("%s pre-area pages\n", __func__);
> +		/* Portion of used block is not initialized */
> +		if (!_has_tag(&marks->im_tree, s, EXTENT_INITIALIZED))
> +			set_needs_init(array, s);
> +	}
> +	if (_set_range(&marks->im_tree, EXTENT_INITIALIZED, offset, length))
> +		goto out_unlock;
> +	for (s = normalize_up(offset + length, PAGE_CACHE_SECTORS);
> +	     s < end; s += PAGE_CACHE_SECTORS) {
> +		dprintk("%s post-area pages\n", __func__);
> +		if (!_has_tag(&marks->im_tree, s, EXTENT_INITIALIZED))
> +			set_needs_init(array, s);
> +	}
> +
> +	spin_unlock(&marks->im_lock);
> +
> +	if (pages) {
> +		if (array[0] == ~0) {
> +			kfree(array);
> +			*pages = NULL;
> +		} else
> +			*pages = array;
> +	}
> +	return 0;
> +
> + out_unlock:
> +	spin_unlock(&marks->im_lock);
> + outerr:
> +	if (pages) {
> +		kfree(array);
> +		*pages = NULL;
> +	}
> +	return -ENOMEM;
> +}
> +
>  static void print_bl_extent(struct pnfs_block_extent *be)
>  {
>  	dprintk("PRINT EXTENT extent %p\n", be);
