From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 09/13] RFC: nfs: create and destroy inode's layout cache
Date: Fri, 10 Sep 2010 15:43:05 -0400
Message-ID: <1284147785.10062.80.camel@heimdal.trondhjem.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	 <1283450419-5648-10-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29267 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752938Ab0IJTnz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 15:43:55 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o8AJhrqL000739
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 12:43:54 -0700 (PDT)
In-Reply-To: <1283450419-5648-10-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
> From: The pNFS Team <linux-nfs@vger.kernel.org>
> 
> At the start of the io paths, try to grab the relevant layout
> information.  This will initiate the inode's layout cache, but
> stubs ensure the cache stays empty.
> 
> Signed-off-by: TBD - melding/reorganization of several patches
> ---
>  fs/nfs/file.c          |    5 ++
>  fs/nfs/inode.c         |    3 +
>  fs/nfs/pnfs.c          |  140 ++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/pnfs.h          |   39 +++++++++++++
>  fs/nfs/read.c          |    3 +
>  include/linux/nfs_fs.h |    3 +
>  6 files changed, 193 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index eb51bd6..10ebdfb 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -36,6 +36,7 @@
>  #include "internal.h"
>  #include "iostat.h"
>  #include "fscache.h"
> +#include "pnfs.h"
>  
>  #define NFSDBG_FACILITY		NFSDBG_FILE
>  
> @@ -386,6 +387,10 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
>  		file->f_path.dentry->d_name.name,
>  		mapping->host->i_ino, len, (long long) pos);
>  
> +	pnfs_update_layout(mapping->host,
> +			   nfs_file_open_context(file),
> +			   IOMODE_RW);
> +
>  start:
>  	/*
>  	 * Prevent starvation issues if someone is doing a consistency
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 7d2d6c7..0dc6dad 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -48,6 +48,7 @@
>  #include "internal.h"
>  #include "fscache.h"
>  #include "dns_resolve.h"
> +#include "pnfs.h"
>  
>  #define NFSDBG_FACILITY		NFSDBG_VFS
>  
> @@ -1409,6 +1410,7 @@ void nfs4_evict_inode(struct inode *inode)
>  {
>  	truncate_inode_pages(&inode->i_data, 0);
>  	end_writeback(inode);
> +	pnfs_destroy_layout(NFS_I(inode));
>  	/* If we are holding a delegation, return it! */
>  	nfs_inode_return_delegation_noreclaim(inode);
>  	/* First call standard NFS clear_inode() code */
> @@ -1446,6 +1448,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
>  	nfsi->delegation = NULL;
>  	nfsi->delegation_state = 0;
>  	init_rwsem(&nfsi->rwsem);
> +	nfsi->layout = NULL;
>  #endif
>  }
>  
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 8d503fc..65f923b 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -151,3 +151,143 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
>  	spin_unlock(&pnfs_spinlock);
>  }
>  EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
> +
> +static void
> +get_layout_hdr_locked(struct pnfs_layout_hdr *lo)
> +{
> +	assert_spin_locked(&lo->inode->i_lock);
> +	lo->refcount++;
> +}
> +
> +static void
> +put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
> +{
> +	assert_spin_locked(&lo->inode->i_lock);
> +	BUG_ON(lo->refcount <= 0);
> +
> +	lo->refcount--;
> +	if (!lo->refcount) {
> +		dprintk("%s: freeing layout cache %p\n", __func__, lo);
> +		NFS_I(lo->inode)->layout = NULL;
> +		kfree(lo);
> +	}
> +}
> +
> +void
> +pnfs_destroy_layout(struct nfs_inode *nfsi)
> +{
> +	struct pnfs_layout_hdr *lo;
> +
> +	spin_lock(&nfsi->vfs_inode.i_lock);
> +	lo = nfsi->layout;
> +	if (lo) {
> +		/* Matched by refcount set to 1 in alloc_init_layout_hdr */
> +		put_layout_hdr_locked(lo);
> +	}
> +	spin_unlock(&nfsi->vfs_inode.i_lock);
> +}
> +
> +/* STUB - pretend LAYOUTGET to server failed */
> +static struct pnfs_layout_segment *
> +send_layoutget(struct pnfs_layout_hdr *lo,
> +	   struct nfs_open_context *ctx,
> +	   u32 iomode)
> +{
> +	struct inode *ino = lo->inode;
> +
> +	set_bit(lo_fail_bit(iomode), &lo->state);
> +	spin_lock(&ino->i_lock);
> +	put_layout_hdr_locked(lo);
> +	spin_unlock(&ino->i_lock);
> +	return NULL;
> +}
> +
> +static struct pnfs_layout_hdr *
> +alloc_init_layout_hdr(struct inode *ino)
> +{
> +	struct pnfs_layout_hdr *lo;
> +
> +	lo = kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
> +	if (!lo)
> +		return NULL;
> +	lo->refcount = 1;
> +	lo->inode = ino;
> +	return lo;
> +}
> +
> +static struct pnfs_layout_hdr *
> +pnfs_find_alloc_layout(struct inode *ino)
> +{
> +	struct nfs_inode *nfsi = NFS_I(ino);
> +	struct pnfs_layout_hdr *new = NULL;
> +
> +	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
> +
> +	assert_spin_locked(&ino->i_lock);
> +	if (nfsi->layout)
> +		return nfsi->layout;
> +
> +	spin_unlock(&ino->i_lock);
> +	new = alloc_init_layout_hdr(ino);
> +	spin_lock(&ino->i_lock);
> +
> +	if (likely(nfsi->layout == NULL))	/* Won the race? */
> +		nfsi->layout = new;
> +	else
> +		kfree(new);
> +	return nfsi->layout;
> +}
> +
> +/* STUB - LAYOUTGET never succeeds, so cache is empty */
> +static struct pnfs_layout_segment *
> +pnfs_has_layout(struct pnfs_layout_hdr *lo, u32 iomode)
> +{
> +	return NULL;
> +}
> +
> +/*
> + * Layout segment is retreived from the server if not cached.
> + * The appropriate layout segment is referenced and returned to the caller.
> + */
> +struct pnfs_layout_segment *
> +pnfs_update_layout(struct inode *ino,
> +		   struct nfs_open_context *ctx,
> +		   enum pnfs_iomode iomode)
> +{
> +	struct nfs_inode *nfsi = NFS_I(ino);
> +	struct pnfs_layout_hdr *lo;
> +	struct pnfs_layout_segment *lseg = NULL;
> +
> +	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
> +		return NULL;
> +	spin_lock(&ino->i_lock);
> +	lo = pnfs_find_alloc_layout(ino);
> +	if (lo == NULL) {
> +		dprintk("%s ERROR: can't get pnfs_layout_hdr\n", __func__);
> +		goto out_unlock;
> +	}
> +
> +	/* Check to see if the layout for the given range already exists */
> +	lseg = pnfs_has_layout(lo, iomode);
> +	if (lseg) {
> +		dprintk("%s: Using cached lseg %p for iomode %d)\n",
> +			__func__, lseg, iomode);
> +		goto out_unlock;
> +	}
> +
> +	/* if LAYOUTGET already failed once we don't try again */
> +	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->state))
> +		goto out_unlock;
> +
> +	get_layout_hdr_locked(lo);
> +	spin_unlock(&ino->i_lock);
> +
> +	lseg = send_layoutget(lo, ctx, iomode);
> +out:
> +	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
> +		nfsi->layout->state, lseg);
> +	return lseg;
> +out_unlock:
> +	spin_unlock(&ino->i_lock);
> +	goto out;
> +}
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 9049b9a..b63b445 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -14,6 +14,11 @@
>  
>  #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
>  
> +enum {
> +	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
> +	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
> +};
> +
>  /* Per-layout driver specific registration structure */
>  struct pnfs_layoutdriver_type {
>  	struct list_head pnfs_tblid;
> @@ -22,6 +27,12 @@ struct pnfs_layoutdriver_type {
>  	struct layoutdriver_io_operations *ld_io_ops;
>  };
>  
> +struct pnfs_layout_hdr {
> +	int			refcount;
        ^^^^^ Why not make this 'unsigned int', and/or 'unsigned long'?
> +	unsigned long		state;
> +	struct inode		*inode;
> +};
> +
>  /* Layout driver I/O operations. */
>  struct layoutdriver_io_operations {
>  	/* Registration information for a new mounted file system */
> @@ -32,11 +43,39 @@ struct layoutdriver_io_operations {
>  extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
>  extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
>  
> +struct pnfs_layout_segment *
> +pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
> +		   enum pnfs_iomode access_type);
>  void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
>  void unset_pnfs_layoutdriver(struct nfs_server *);
> +void pnfs_destroy_layout(struct nfs_inode *);
> +
> +
> +static inline int lo_fail_bit(u32 iomode)
> +{
> +	return iomode == IOMODE_RW ?
> +			 NFS_LAYOUT_RW_FAILED : NFS_LAYOUT_RO_FAILED;
> +}
> +
> +/* Return true if a layout driver is being used for this mountpoint */
> +static inline int pnfs_enabled_sb(struct nfs_server *nfss)
> +{
> +	return nfss->pnfs_curr_ld != NULL;
> +}
>  
>  #else  /* CONFIG_NFS_V4_1 */
>  
> +static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
> +{
> +}
> +
> +static inline struct pnfs_layout_segment *
> +pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
> +		   enum pnfs_iomode access_type)
> +{
> +	return NULL;
> +}
> +
>  static inline void set_pnfs_layoutdriver(struct nfs_server *s, u32 id)
>  {
>  }
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index 87adc27..f7eb66f 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -25,6 +25,7 @@
>  #include "internal.h"
>  #include "iostat.h"
>  #include "fscache.h"
> +#include "pnfs.h"
>  
>  #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
>  
> @@ -121,6 +122,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
>  	len = nfs_page_length(page);
>  	if (len == 0)
>  		return nfs_return_empty_page(page);
> +	pnfs_update_layout(inode, ctx, IOMODE_READ);
>  	new = nfs_create_request(ctx, inode, page, 0, len);
>  	if (IS_ERR(new)) {
>  		unlock_page(page);
> @@ -625,6 +627,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
>  	if (ret == 0)
>  		goto read_complete; /* all pages were read */
>  
> +	pnfs_update_layout(inode, desc.ctx, IOMODE_READ);
>  	if (rsize < PAGE_CACHE_SIZE)
>  		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
>  	else
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index a0f49a3..ebd87a9 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -188,6 +188,9 @@ struct nfs_inode {
>  	struct nfs_delegation	*delegation;
>  	fmode_t			 delegation_state;
>  	struct rw_semaphore	rwsem;
> +
> +	/* pNFS layout information */
> +	struct pnfs_layout_hdr *layout;
>  #endif /* CONFIG_NFS_V4*/
>  #ifdef CONFIG_NFS_FSCACHE
>  	struct fscache_cookie	*fscache;


