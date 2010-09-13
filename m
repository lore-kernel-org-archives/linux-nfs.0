Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38222 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754669Ab0IMLcM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 07:32:12 -0400
Message-ID: <4C8E0BBA.9070109@panasas.com>
Date: Mon, 13 Sep 2010 13:32:10 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 09/13] RFC: nfs: create and destroy inode's layout cache
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>	 <1283450419-5648-10-git-send-email-iisaman@netapp.com> <1284147785.10062.80.camel@heimdal.trondhjem.org>
In-Reply-To: <1284147785.10062.80.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-10 22:43, Trond Myklebust wrote:
> On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
>> From: The pNFS Team <linux-nfs@vger.kernel.org>
>>
>> At the start of the io paths, try to grab the relevant layout
>> information.  This will initiate the inode's layout cache, but
>> stubs ensure the cache stays empty.
>>
>> Signed-off-by: TBD - melding/reorganization of several patches
>> ---
>>  fs/nfs/file.c          |    5 ++
>>  fs/nfs/inode.c         |    3 +
>>  fs/nfs/pnfs.c          |  140 ++++++++++++++++++++++++++++++++++++++++++++++++
>>  fs/nfs/pnfs.h          |   39 +++++++++++++
>>  fs/nfs/read.c          |    3 +
>>  include/linux/nfs_fs.h |    3 +
>>  6 files changed, 193 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index eb51bd6..10ebdfb 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -36,6 +36,7 @@
>>  #include "internal.h"
>>  #include "iostat.h"
>>  #include "fscache.h"
>> +#include "pnfs.h"
>>  
>>  #define NFSDBG_FACILITY		NFSDBG_FILE
>>  
>> @@ -386,6 +387,10 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
>>  		file->f_path.dentry->d_name.name,
>>  		mapping->host->i_ino, len, (long long) pos);
>>  
>> +	pnfs_update_layout(mapping->host,
>> +			   nfs_file_open_context(file),
>> +			   IOMODE_RW);
>> +
>>  start:
>>  	/*
>>  	 * Prevent starvation issues if someone is doing a consistency
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 7d2d6c7..0dc6dad 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -48,6 +48,7 @@
>>  #include "internal.h"
>>  #include "fscache.h"
>>  #include "dns_resolve.h"
>> +#include "pnfs.h"
>>  
>>  #define NFSDBG_FACILITY		NFSDBG_VFS
>>  
>> @@ -1409,6 +1410,7 @@ void nfs4_evict_inode(struct inode *inode)
>>  {
>>  	truncate_inode_pages(&inode->i_data, 0);
>>  	end_writeback(inode);
>> +	pnfs_destroy_layout(NFS_I(inode));
>>  	/* If we are holding a delegation, return it! */
>>  	nfs_inode_return_delegation_noreclaim(inode);
>>  	/* First call standard NFS clear_inode() code */
>> @@ -1446,6 +1448,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
>>  	nfsi->delegation = NULL;
>>  	nfsi->delegation_state = 0;
>>  	init_rwsem(&nfsi->rwsem);
>> +	nfsi->layout = NULL;
>>  #endif
>>  }
>>  
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 8d503fc..65f923b 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -151,3 +151,143 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
>>  	spin_unlock(&pnfs_spinlock);
>>  }
>>  EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
>> +
>> +static void
>> +get_layout_hdr_locked(struct pnfs_layout_hdr *lo)
>> +{
>> +	assert_spin_locked(&lo->inode->i_lock);
>> +	lo->refcount++;
>> +}
>> +
>> +static void
>> +put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
>> +{
>> +	assert_spin_locked(&lo->inode->i_lock);
>> +	BUG_ON(lo->refcount <= 0);
>> +
>> +	lo->refcount--;
>> +	if (!lo->refcount) {
>> +		dprintk("%s: freeing layout cache %p\n", __func__, lo);
>> +		NFS_I(lo->inode)->layout = NULL;
>> +		kfree(lo);
>> +	}
>> +}
>> +
>> +void
>> +pnfs_destroy_layout(struct nfs_inode *nfsi)
>> +{
>> +	struct pnfs_layout_hdr *lo;
>> +
>> +	spin_lock(&nfsi->vfs_inode.i_lock);
>> +	lo = nfsi->layout;
>> +	if (lo) {
>> +		/* Matched by refcount set to 1 in alloc_init_layout_hdr */
>> +		put_layout_hdr_locked(lo);
>> +	}
>> +	spin_unlock(&nfsi->vfs_inode.i_lock);
>> +}
>> +
>> +/* STUB - pretend LAYOUTGET to server failed */
>> +static struct pnfs_layout_segment *
>> +send_layoutget(struct pnfs_layout_hdr *lo,
>> +	   struct nfs_open_context *ctx,
>> +	   u32 iomode)
>> +{
>> +	struct inode *ino = lo->inode;
>> +
>> +	set_bit(lo_fail_bit(iomode), &lo->state);
>> +	spin_lock(&ino->i_lock);
>> +	put_layout_hdr_locked(lo);
>> +	spin_unlock(&ino->i_lock);
>> +	return NULL;
>> +}
>> +
>> +static struct pnfs_layout_hdr *
>> +alloc_init_layout_hdr(struct inode *ino)
>> +{
>> +	struct pnfs_layout_hdr *lo;
>> +
>> +	lo = kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
>> +	if (!lo)
>> +		return NULL;
>> +	lo->refcount = 1;
>> +	lo->inode = ino;
>> +	return lo;
>> +}
>> +
>> +static struct pnfs_layout_hdr *
>> +pnfs_find_alloc_layout(struct inode *ino)
>> +{
>> +	struct nfs_inode *nfsi = NFS_I(ino);
>> +	struct pnfs_layout_hdr *new = NULL;
>> +
>> +	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
>> +
>> +	assert_spin_locked(&ino->i_lock);
>> +	if (nfsi->layout)
>> +		return nfsi->layout;
>> +
>> +	spin_unlock(&ino->i_lock);
>> +	new = alloc_init_layout_hdr(ino);
>> +	spin_lock(&ino->i_lock);
>> +
>> +	if (likely(nfsi->layout == NULL))	/* Won the race? */
>> +		nfsi->layout = new;
>> +	else
>> +		kfree(new);
>> +	return nfsi->layout;
>> +}
>> +
>> +/* STUB - LAYOUTGET never succeeds, so cache is empty */
>> +static struct pnfs_layout_segment *
>> +pnfs_has_layout(struct pnfs_layout_hdr *lo, u32 iomode)
>> +{
>> +	return NULL;
>> +}
>> +
>> +/*
>> + * Layout segment is retreived from the server if not cached.
>> + * The appropriate layout segment is referenced and returned to the caller.
>> + */
>> +struct pnfs_layout_segment *
>> +pnfs_update_layout(struct inode *ino,
>> +		   struct nfs_open_context *ctx,
>> +		   enum pnfs_iomode iomode)
>> +{
>> +	struct nfs_inode *nfsi = NFS_I(ino);
>> +	struct pnfs_layout_hdr *lo;
>> +	struct pnfs_layout_segment *lseg = NULL;
>> +
>> +	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
>> +		return NULL;
>> +	spin_lock(&ino->i_lock);
>> +	lo = pnfs_find_alloc_layout(ino);
>> +	if (lo == NULL) {
>> +		dprintk("%s ERROR: can't get pnfs_layout_hdr\n", __func__);
>> +		goto out_unlock;
>> +	}
>> +
>> +	/* Check to see if the layout for the given range already exists */
>> +	lseg = pnfs_has_layout(lo, iomode);
>> +	if (lseg) {
>> +		dprintk("%s: Using cached lseg %p for iomode %d)\n",
>> +			__func__, lseg, iomode);
>> +		goto out_unlock;
>> +	}
>> +
>> +	/* if LAYOUTGET already failed once we don't try again */
>> +	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->state))
>> +		goto out_unlock;
>> +
>> +	get_layout_hdr_locked(lo);
>> +	spin_unlock(&ino->i_lock);
>> +
>> +	lseg = send_layoutget(lo, ctx, iomode);
>> +out:
>> +	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
>> +		nfsi->layout->state, lseg);
>> +	return lseg;
>> +out_unlock:
>> +	spin_unlock(&ino->i_lock);
>> +	goto out;
>> +}
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 9049b9a..b63b445 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -14,6 +14,11 @@
>>  
>>  #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
>>  
>> +enum {
>> +	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
>> +	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
>> +};
>> +
>>  /* Per-layout driver specific registration structure */
>>  struct pnfs_layoutdriver_type {
>>  	struct list_head pnfs_tblid;
>> @@ -22,6 +27,12 @@ struct pnfs_layoutdriver_type {
>>  	struct layoutdriver_io_operations *ld_io_ops;
>>  };
>>  
>> +struct pnfs_layout_hdr {
>> +	int			refcount;
>         ^^^^^ Why not make this 'unsigned int', and/or 'unsigned long'?

Should be fine, we just need to be careful about underflow/overflow
before changing its value.

Benny
