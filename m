Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:59308 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab1FNPho (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 11:37:44 -0400
Received: by iwn34 with SMTP id 34so4745292iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 08:37:43 -0700 (PDT)
Message-ID: <4DF7800C.1010503@gmail.com>
Date: Tue, 14 Jun 2011 11:36:44 -0400
From: Benny Halevy <bhalevy.lists@gmail.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 17/34] pnfsblock: call and parse getdevicelist
References: <cover.1307921137.git.rees@umich.edu> <c42adbc8a8c7e03043bfbef1b9a2ceb72f1baf89.1307921138.git.rees@umich.edu>
In-Reply-To: <c42adbc8a8c7e03043bfbef1b9a2ceb72f1baf89.1307921138.git.rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-12 19:44, Jim Rees wrote:
> From: Fred Isaman <iisaman@citi.umich.edu>
> 
> Call GETDEVICELIST during mount, then call and parse GETDEVICEINFO
> for each device returned.
> 
> [pnfsblock: fix pnfs_deviceid references]
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> [pnfsblock: fix print format warnings for sector_t and size_t]
> [pnfs-block: #include <linux/vmalloc.h>]
> [pnfsblock: no PNFS_NFS_SERVER]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [pnfsblock: fix bug determining size of striped volume]
> [pnfsblock: fix oops when using multiple devices]
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/blocklayout/blocklayout.c |  155 +++++++++++++++++++++++++++++++++++++-
>  fs/nfs/blocklayout/blocklayout.h |   95 +++++++++++++++++++++++
>  2 files changed, 248 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 88b9d1a..36374f4 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -31,7 +31,7 @@
>   */
>  #include <linux/module.h>
>  #include <linux/init.h>
> -
> +#include <linux/vmalloc.h>
>  #include "blocklayout.h"
>  
>  #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
> @@ -164,17 +164,168 @@ bl_cleanup_layoutcommit(struct pnfs_layout_hdr *lo,
>  {
>  }
>  
> +static void free_blk_mountid(struct block_mount_id *mid)
> +{
> +	if (mid) {
> +		struct pnfs_block_dev *dev;
> +		spin_lock(&mid->bm_lock);
> +		while (!list_empty(&mid->bm_devlist)) {
> +			dev = list_first_entry(&mid->bm_devlist,
> +					       struct pnfs_block_dev,
> +					       bm_node);
> +			list_del(&dev->bm_node);
> +			free_block_dev(dev);
> +		}
> +		spin_unlock(&mid->bm_lock);
> +		kfree(mid);
> +	}
> +}
> +
> +/* This is mostly copied from the filelayout's get_device_info function.
> + * It seems much of this should be at the generic pnfs level.
> + */
> +static struct pnfs_block_dev *
> +nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
> +			struct nfs4_deviceid *d_id,
> +			struct list_head *sdlist)
> +{
> +	struct pnfs_device *dev;
> +	struct pnfs_block_dev *rv = NULL;
> +	u32 max_resp_sz;
> +	int max_pages;
> +	struct page **pages = NULL;
> +	int i, rc;
> +
> +	/*
> +	 * Use the session max response size as the basis for setting
> +	 * GETDEVICEINFO's maxcount
> +	 */
> +	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
> +	max_pages = max_resp_sz >> PAGE_SHIFT;
> +	dprintk("%s max_resp_sz %u max_pages %d\n",
> +		__func__, max_resp_sz, max_pages);
> +
> +	dev = kmalloc(sizeof(*dev), GFP_KERNEL);
> +	if (!dev) {
> +		dprintk("%s kmalloc failed\n", __func__);
> +		return NULL;
> +	}
> +
> +	pages = kzalloc(max_pages * sizeof(struct page *), GFP_KERNEL);
> +	if (pages == NULL) {
> +		kfree(dev);
> +		return NULL;
> +	}
> +	for (i = 0; i < max_pages; i++) {
> +		pages[i] = alloc_page(GFP_KERNEL);
> +		if (!pages[i])
> +			goto out_free;
> +	}
> +
> +	/* set dev->area */
> +	dev->area = vmap(pages, max_pages, VM_MAP, PAGE_KERNEL);
> +	if (!dev->area)
> +		goto out_free;
> +
> +	memcpy(&dev->dev_id, d_id, sizeof(*d_id));
> +	dev->layout_type = LAYOUT_BLOCK_VOLUME;
> +	dev->pages = pages;
> +	dev->pgbase = 0;
> +	dev->pglen = PAGE_SIZE * max_pages;
> +	dev->mincount = 0;
> +
> +	dprintk("%s: dev_id: %s\n", __func__, dev->dev_id.data);
> +	rc = nfs4_proc_getdeviceinfo(server, dev);
> +	dprintk("%s getdevice info returns %d\n", __func__, rc);
> +	if (rc)
> +		goto out_free;
> +
> +	rv = nfs4_blk_decode_device(server, dev, sdlist);
> + out_free:
> +	if (dev->area != NULL)
> +		vunmap(dev->area);
> +	for (i = 0; i < max_pages; i++)
> +		__free_page(pages[i]);
> +	kfree(pages);
> +	kfree(dev);
> +	return rv;
> +}
> +
>  static int
>  bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
>  {
> +	struct block_mount_id *b_mt_id = NULL;
> +	struct pnfs_mount_type *mtype = NULL;
> +	struct pnfs_devicelist *dlist = NULL;
> +	struct pnfs_block_dev *bdev;
> +	LIST_HEAD(block_disklist);
> +	int status = 0, i;
> +
>  	dprintk("%s enter\n", __func__);
> -	return 0;
> +
> +	if (server->pnfs_blksize == 0) {
> +		dprintk("%s Server did not return blksize\n", __func__);
> +		return -EINVAL;
> +	}
> +	b_mt_id = kzalloc(sizeof(struct block_mount_id), GFP_KERNEL);
> +	if (!b_mt_id) {
> +		status = -ENOMEM;
> +		goto out_error;
> +	}
> +	/* Initialize nfs4 block layout mount id */
> +	spin_lock_init(&b_mt_id->bm_lock);
> +	INIT_LIST_HEAD(&b_mt_id->bm_devlist);
> +
> +	dlist = kmalloc(sizeof(struct pnfs_devicelist), GFP_KERNEL);
> +	if (!dlist)
> +		goto out_error;
> +	dlist->eof = 0;
> +	while (!dlist->eof) {
> +		status = nfs4_proc_getdevicelist(server, fh, dlist);
> +		if (status)
> +			goto out_error;
> +		dprintk("%s GETDEVICELIST numdevs=%i, eof=%i\n",
> +			__func__, dlist->num_devs, dlist->eof);
> +		/* For each device returned in dlist, call GETDEVICEINFO, and
> +		 * decode the opaque topology encoding to create a flat
> +		 * volume topology, matching VOLUME_SIMPLE disk signatures
> +		 * to disks in the visible block disk list.
> +		 * Construct an LVM meta device from the flat volume topology.
> +		 */
> +		for (i = 0; i < dlist->num_devs; i++) {
> +			bdev = nfs4_blk_get_deviceinfo(server, fh,
> +						     &dlist->dev_id[i],
> +						     &block_disklist);
> +			if (!bdev) {
> +				status = -ENODEV;
> +				goto out_error;
> +			}
> +			spin_lock(&b_mt_id->bm_lock);
> +			list_add(&bdev->bm_node, &b_mt_id->bm_devlist);
> +			spin_unlock(&b_mt_id->bm_lock);
> +		}
> +	}
> +	dprintk("%s SUCCESS\n", __func__);
> +	server->pnfs_ld_data = b_mt_id;
> +
> + out_return:
> +	kfree(dlist);
> +	return status;
> +
> + out_error:
> +	free_blk_mountid(b_mt_id);
> +	kfree(mtype);
> +	goto out_return;
>  }
>  
>  static int
>  bl_clear_layoutdriver(struct nfs_server *server)
>  {
> +	struct block_mount_id *b_mt_id = server->pnfs_ld_data;
> +
>  	dprintk("%s enter\n", __func__);
> +	free_blk_mountid(b_mt_id);
> +	dprintk("%s RETURNS\n", __func__);
>  	return 0;
>  }
>  
> diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
> index 6bbfc3d..21fa21c 100644
> --- a/fs/nfs/blocklayout/blocklayout.h
> +++ b/fs/nfs/blocklayout/blocklayout.h
> @@ -35,12 +35,60 @@
>  #include <linux/nfs_fs.h>
>  #include "../pnfs.h"
>  
> +struct block_mount_id {
> +	spinlock_t			bm_lock;    /* protects list */
> +	struct list_head		bm_devlist; /* holds pnfs_block_dev */
> +};
> +
>  struct pnfs_block_dev {
>  	struct list_head		bm_node;
>  	struct nfs4_deviceid		bm_mdevid;    /* associated devid */
>  	struct block_device		*bm_mdev;     /* meta device itself */
>  };
>  
> +/* holds visible disks that can be matched against VOLUME_SIMPLE signatures */
> +struct visible_block_device {
> +	struct list_head	vi_node;
> +	struct block_device	*vi_bdev;
> +	int			vi_mapped;
> +	int			vi_put_done;
> +};
> +
> +enum blk_vol_type {
> +	PNFS_BLOCK_VOLUME_SIMPLE   = 0,	/* maps to a single LU */
> +	PNFS_BLOCK_VOLUME_SLICE    = 1,	/* slice of another volume */
> +	PNFS_BLOCK_VOLUME_CONCAT   = 2,	/* concatenation of multiple volumes */
> +	PNFS_BLOCK_VOLUME_STRIPE   = 3	/* striped across multiple volumes */
> +};
> +
> +/* All disk offset/lengths are stored in 512-byte sectors */
> +struct pnfs_blk_volume {
> +	uint32_t		bv_type;
> +	sector_t 		bv_size;
> +	struct pnfs_blk_volume 	**bv_vols;
> +	int 			bv_vol_n;
> +	union {
> +		dev_t			bv_dev;
> +		sector_t		bv_stripe_unit;
> +		sector_t 		bv_offset;
> +	};
> +};
> +
> +/* Since components need not be aligned, cannot use sector_t */
> +struct pnfs_blk_sig_comp {
> +	int64_t 	bs_offset;  /* In bytes */
> +	uint32_t   	bs_length;  /* In bytes */
> +	char 		*bs_string;
> +};
> +
> +/* Maximum number of signatures components in a simple volume */
> +# define PNFS_BLOCK_MAX_SIG_COMP 16
> +
> +struct pnfs_blk_sig {
> +	int 				si_num_comps;
> +	struct pnfs_blk_sig_comp	si_comps[PNFS_BLOCK_MAX_SIG_COMP];
> +};
> +
>  enum exstate4 {
>  	PNFS_BLOCK_READWRITE_DATA	= 0,
>  	PNFS_BLOCK_READ_DATA		= 1,
> @@ -96,6 +144,8 @@ struct pnfs_block_layout {
>  	sector_t		bl_blocksize;  /* Server blocksize in sectors */
>  };
>  
> +#define BLK_ID(lo) ((struct block_mount_id *)(NFS_SERVER(lo->plh_inode)->pnfs_ld_data))
> +
>  static inline struct pnfs_block_layout *
>  BLK_LO2EXT(struct pnfs_layout_hdr *lo)
>  {
> @@ -108,6 +158,51 @@ BLK_LSEG2EXT(struct pnfs_layout_segment *lseg)
>          return BLK_LO2EXT(lseg->pls_layout);
>  }
>  
> +uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
> +
> +#define BLK_READBUF(p, e, nbytes)  do { \
> +	p = blk_overflow(p, e, nbytes); \
> +	if (!p) { \
> +		printk(KERN_WARNING \
> +			"%s: reply buffer overflowed in line %d.\n", \
> +			__func__, __LINE__); \
> +		goto out_err; \
> +	} \
> +} while (0)
> +
> +#define READ32(x)         (x) = ntohl(*p++)
> +#define READ64(x)         do {                  \
> +	(x) = (uint64_t)ntohl(*p++) << 32;           \
> +	(x) |= ntohl(*p++);                     \
> +} while (0)
> +#define COPYMEM(x, nbytes) do {                 \
> +	memcpy((x), p, nbytes);                 \
> +	p += XDR_QUADLEN(nbytes);               \
> +} while (0)
> +#define READ_DEVID(x)	COPYMEM((x)->data, NFS4_DEVICEID4_SIZE)
> +#define READ_SECTOR(x)     do { \
> +	READ64(tmp); \
> +	if (tmp & 0x1ff) { \
> +		printk(KERN_WARNING \
> +		       "%s Value not 512-byte aligned at line %d\n", \
> +		       __func__, __LINE__);			     \
> +		goto out_err; \
> +	} \
> +	(x) = tmp >> 9; \
> +} while (0)
> +
> +#define WRITE32(n)               do { \
> +	*p++ = htonl(n); \
> +	} while (0)
> +#define WRITE64(n)               do {                           \
> +	*p++ = htonl((uint32_t)((n) >> 32));			\
> +	*p++ = htonl((uint32_t)(n));				\
> +} while (0)
> +#define WRITEMEM(ptr, nbytes)     do {                          \
> +	p = xdr_encode_opaque_fixed(p, ptr, nbytes);	\
> +} while (0)
> +#define WRITE_DEVID(x)  WRITEMEM((x)->data, NFS4_DEVICEID4_SIZE)
> +

please don't use these obsolete macros and rather directly use the
official xdr {en,de}coding helpers and be32_to_cpu.
we're trying to eradicate them from the nfs client

Benny

>  /* blocklayoutdev.c */
>  struct block_device *nfs4_blkdev_get(dev_t dev);
>  int nfs4_blkdev_put(struct block_device *bdev);
