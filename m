Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50132 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763362AbZLQIS1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Dec 2009 03:18:27 -0500
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
From: Peter Zijlstra <peterz@infradead.org>
To: Steve Rago <sar@nec-labs.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond.Myklebust@netapp.com, Wu Fengguang <fengguang.wu@intel.com>,
        "jens.axboe" <jens.axboe@oracle.com>
In-Reply-To: <1261015420.1947.54.camel@serenity>
References: <1261015420.1947.54.camel@serenity>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Dec 2009 09:17:57 +0100
Message-ID: <1261037877.27920.36.camel@laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2009-12-16 at 21:03 -0500, Steve Rago wrote:
> Eager Writeback for NFS Clients
> -------------------------------
> Prevent applications that write large sequential streams of data (like backup, for example)
> from entering into a memory pressure state, which degrades performance by falling back to
> synchronous operations (both synchronous writes and additional commits).  This is accomplished
> by preventing the client application from dirtying pages faster than they can be written to
> the server: clients write pages eagerly instead of lazily.
> 
> The eager writeback is controlled by a sysctl: fs.nfs.nfs_max_woutstanding set to 0 disables
> the feature.  Otherwise it contains the maximum number of outstanding NFS writes that can be
> in flight for a given file.  This is used to block the application from dirtying more pages
> until the writes are complete.
> 
> This patch is based heavily (okay, almost entirely) on a prior patch by Peter Staubach.  For
> the original patch, see http://article.gmane.org/gmane.linux.nfs/24323.
> 
> The patch below applies to linux-2.6.32-rc7, but it should apply cleanly to vanilla linux-2.6.32.
> 
> Performance data and tuning notes can be found on my web site (http://www.nec-labs.com/~sar).
> With iozone, I see about 50% improvement for large sequential write workloads over a 1Gb Ethernet.
> With an in-house micro-benchmark, I see 80% improvement for large, single-stream, sequential
> workloads (where "large" is defined to be greater than the memory size on the client).
> 
> Signed-off-by: Steve Rago <sar@nec-labs.com>
> ---
> 
> diff -rupN -X linux-2.6.32-rc7/Documentation/dontdiff linux-2.6.32-rc7-orig/fs/fs-writeback.c linux-2.6.32-rc7/fs/fs-writeback.c
> --- linux-2.6.32-rc7-orig/fs/fs-writeback.c	2009-11-12 19:46:07.000000000 -0500
> +++ linux-2.6.32-rc7/fs/fs-writeback.c	2009-11-30 15:36:30.735453450 -0500
> @@ -771,6 +771,8 @@ static long wb_writeback(struct bdi_writ
>  		wbc.range_start = 0;
>  		wbc.range_end = LLONG_MAX;
>  	}
> +	if (args->for_background || wbc.for_kupdate)
> +		wbc.nonblocking = 1;
>  
>  	for (;;) {
>  		/*
> @@ -859,6 +861,8 @@ static long wb_check_old_data_flush(stru
>  	unsigned long expired;
>  	long nr_pages;
>  
> +	if (dirty_writeback_interval == 0)
> +		return 0;
>  	expired = wb->last_old_flush +
>  			msecs_to_jiffies(dirty_writeback_interval * 10);
>  	if (time_before(jiffies, expired))
> @@ -954,7 +958,11 @@ int bdi_writeback_task(struct bdi_writeb
>  				break;
>  		}
>  
> -		wait_jiffies = msecs_to_jiffies(dirty_writeback_interval * 10);
> +		if (dirty_writeback_interval == 0)
> +			wait_jiffies = msecs_to_jiffies(5000);	/* default */
> +		else
> +			wait_jiffies =
> +				msecs_to_jiffies(dirty_writeback_interval * 10);

I'm not up-to-date on the bdi-writeout stuff, but this just looks wrong.

>  		schedule_timeout_interruptible(wait_jiffies);
>  		try_to_freeze();
>  	}
> diff -rupN -X linux-2.6.32-rc7/Documentation/dontdiff linux-2.6.32-rc7-orig/fs/nfs/file.c linux-2.6.32-rc7/fs/nfs/file.c
> --- linux-2.6.32-rc7-orig/fs/nfs/file.c	2009-11-12 19:46:07.000000000 -0500
> +++ linux-2.6.32-rc7/fs/nfs/file.c	2009-11-30 15:21:22.635101295 -0500
> @@ -589,11 +589,17 @@ static int nfs_need_sync_write(struct fi
>  	return 0;
>  }
>  
> +static int nfs_is_seqwrite(struct inode *inode, loff_t pos)
> +{
> +	return NFS_I(inode)->wrpos == pos;
> +}
> +
>  static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
>  				unsigned long nr_segs, loff_t pos)
>  {
>  	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
>  	struct inode * inode = dentry->d_inode;
> +	struct nfs_inode *nfsi = NFS_I(inode);
>  	ssize_t result;
>  	size_t count = iov_length(iov, nr_segs);
>  
> @@ -607,6 +613,12 @@ static ssize_t nfs_file_write(struct kio
>  	result = -EBUSY;
>  	if (IS_SWAPFILE(inode))
>  		goto out_swapfile;
> +
> +	result = count;
> +	if (!count)
> +		goto out;
> +	nfs_wait_woutstanding(inode);
> +
>  	/*
>  	 * O_APPEND implies that we must revalidate the file length.
>  	 */
> @@ -623,10 +635,21 @@ static ssize_t nfs_file_write(struct kio
>  	nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, count);
>  	result = generic_file_aio_write(iocb, iov, nr_segs, pos);
>  	/* Return error values for O_SYNC and IS_SYNC() */
> -	if (result >= 0 && nfs_need_sync_write(iocb->ki_filp, inode)) {
> -		int err = nfs_do_fsync(nfs_file_open_context(iocb->ki_filp), inode);
> -		if (err < 0)
> -			result = err;
> +	if (result >= 0) {
> +		if (nfs_need_sync_write(iocb->ki_filp, inode)) {
> +			int err;
> +
> +			err = nfs_do_fsync(nfs_file_open_context(iocb->ki_filp),
> +					   inode);
> +			if (err < 0)
> +				result = err;
> +		} else if (nfs_max_woutstanding != 0 &&
> +		     nfs_is_seqwrite(inode, pos) &&
> +		     atomic_read(&nfsi->ndirty) >= NFS_SERVER(inode)->wpages) {
> +			nfs_wb_eager(inode);
> +		}
> +		if (result > 0)
> +			nfsi->wrpos = pos + result;
>  	}
>  out:
>  	return result;
> diff -rupN -X linux-2.6.32-rc7/Documentation/dontdiff linux-2.6.32-rc7-orig/fs/nfs/inode.c linux-2.6.32-rc7/fs/nfs/inode.c
> --- linux-2.6.32-rc7-orig/fs/nfs/inode.c	2009-11-12 19:46:07.000000000 -0500
> +++ linux-2.6.32-rc7/fs/nfs/inode.c	2009-11-13 11:36:43.888410914 -0500
> @@ -508,7 +508,9 @@ void nfs_setattr_update_inode(struct ino
>  int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
>  {
>  	struct inode *inode = dentry->d_inode;
> -	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
> +	struct nfs_inode *nfsi = NFS_I(inode);
> +	int need_atime = nfsi->cache_validity & NFS_INO_INVALID_ATIME;
> +	int woutstanding = nfs_max_woutstanding;
>  	int err;
>  
>  	/*
> @@ -519,9 +521,8 @@ int nfs_getattr(struct vfsmount *mnt, st
>  	 * nfs_wb_nocommit.
>  	 */
>  	if (S_ISREG(inode->i_mode)) {
> -		mutex_lock(&inode->i_mutex);
> +		atomic_add(woutstanding, &nfsi->writes);
>  		nfs_wb_nocommit(inode);
> -		mutex_unlock(&inode->i_mutex);
>  	}
>  
>  	/*
> @@ -545,6 +546,11 @@ int nfs_getattr(struct vfsmount *mnt, st
>  		generic_fillattr(inode, stat);
>  		stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
>  	}
> +
> +	if (S_ISREG(inode->i_mode)) {
> +		atomic_sub(woutstanding, &nfsi->writes);
> +		wake_up(&nfsi->writes_wq);
> +	}
>  	return err;
>  }
>  
> @@ -1418,9 +1424,13 @@ static void init_once(void *foo)
>  	INIT_LIST_HEAD(&nfsi->access_cache_inode_lru);
>  	INIT_RADIX_TREE(&nfsi->nfs_page_tree, GFP_ATOMIC);
>  	nfsi->npages = 0;
> +	atomic_set(&nfsi->ndirty, 0);
>  	atomic_set(&nfsi->silly_count, 1);
>  	INIT_HLIST_HEAD(&nfsi->silly_list);
>  	init_waitqueue_head(&nfsi->waitqueue);
> +	atomic_set(&nfsi->writes, 0);
> +	init_waitqueue_head(&nfsi->writes_wq);
> +	nfsi->wrpos = 0;
>  	nfs4_init_once(nfsi);
>  }
>  
> diff -rupN -X linux-2.6.32-rc7/Documentation/dontdiff linux-2.6.32-rc7-orig/fs/nfs/sysctl.c linux-2.6.32-rc7/fs/nfs/sysctl.c
> --- linux-2.6.32-rc7-orig/fs/nfs/sysctl.c	2009-11-12 19:46:07.000000000 -0500
> +++ linux-2.6.32-rc7/fs/nfs/sysctl.c	2009-11-13 11:36:43.895459044 -0500
> @@ -58,6 +58,14 @@ static ctl_table nfs_cb_sysctls[] = {
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec,
>  	},
> +	{
> +		.ctl_name       = CTL_UNNUMBERED,
> +		.procname       = "nfs_max_woutstanding",
> +		.data           = &nfs_max_woutstanding,
> +		.maxlen         = sizeof(int),
> +		.mode           = 0644,
> +		.proc_handler   = &proc_dointvec,
> +	},
>  	{ .ctl_name = 0 }
>  };
>  
> diff -rupN -X linux-2.6.32-rc7/Documentation/dontdiff linux-2.6.32-rc7-orig/fs/nfs/write.c linux-2.6.32-rc7/fs/nfs/write.c
> --- linux-2.6.32-rc7-orig/fs/nfs/write.c	2009-11-12 19:46:07.000000000 -0500
> +++ linux-2.6.32-rc7/fs/nfs/write.c	2009-12-08 13:26:35.416629518 -0500
> @@ -176,6 +176,8 @@ static void nfs_mark_uptodate(struct pag
>  
>  static int wb_priority(struct writeback_control *wbc)
>  {
> +	if (nfs_max_woutstanding != 0)
> +		return 0;
>  	if (wbc->for_reclaim)
>  		return FLUSH_HIGHPRI | FLUSH_STABLE;
>  	if (wbc->for_kupdate)
> @@ -200,7 +202,9 @@ static int nfs_set_page_writeback(struct
>  	if (!ret) {
>  		struct inode *inode = page->mapping->host;
>  		struct nfs_server *nfss = NFS_SERVER(inode);
> +		struct nfs_inode *nfsi = NFS_I(inode);
>  
> +		atomic_dec(&nfsi->ndirty);
>  		if (atomic_long_inc_return(&nfss->writeback) >
>  				NFS_CONGESTION_ON_THRESH) {
>  			set_bdi_congested(&nfss->backing_dev_info,
> @@ -325,6 +329,39 @@ static int nfs_writepages_callback(struc
>  	return ret;
>  }
>  
> +int nfs_max_woutstanding = 16;
> +
> +static void nfs_inc_woutstanding(struct inode *inode)
> +{
> +	struct nfs_inode *nfsi = NFS_I(inode);
> +	atomic_inc(&nfsi->writes);
> +}
> +
> +static void nfs_dec_woutstanding(struct inode *inode)
> +{
> +	struct nfs_inode *nfsi = NFS_I(inode);
> +	if (atomic_dec_return(&nfsi->writes) < nfs_max_woutstanding)
> +		wake_up(&nfsi->writes_wq);
> +}
> +
> +void nfs_wait_woutstanding(struct inode *inode)
> +{
> +	if (nfs_max_woutstanding != 0) {
> +		unsigned long background_thresh;
> +		unsigned long dirty_thresh;
> +		long npages;
> +		struct nfs_inode *nfsi = NFS_I(inode);
> +
> +		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
> +		npages = global_page_state(NR_FILE_DIRTY) +
> +			 global_page_state(NR_UNSTABLE_NFS) +
> +			 global_page_state(NR_WRITEBACK);
> +		if (npages >= background_thresh)
> +			wait_event(nfsi->writes_wq,
> +			   atomic_read(&nfsi->writes) < nfs_max_woutstanding);
> +	}
> +}

This looks utterly busted too, why the global state and not the nfs
client's bdi state?

Also, why create this extra workqueue and not simply use the congestion
interface that is present? If the congestion stuff doesn't work for you,
fix that, don't add extra muck like this.

> +
>  int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
>  {
>  	struct inode *inode = mapping->host;
> @@ -420,6 +457,9 @@ static void nfs_inode_remove_request(str
>  static void
>  nfs_mark_request_dirty(struct nfs_page *req)
>  {
> +	struct inode *inode = req->wb_context->path.dentry->d_inode;
> +	struct nfs_inode *nfsi = NFS_I(inode);
> +	atomic_inc(&nfsi->ndirty);
>  	__set_page_dirty_nobuffers(req->wb_page);
>  }
>  
> @@ -682,16 +722,18 @@ static struct nfs_page * nfs_setup_write
>  
>  	req = nfs_try_to_update_request(inode, page, offset, bytes);
>  	if (req != NULL)
> -		goto out;
> +		return req;
>  	req = nfs_create_request(ctx, inode, page, offset, bytes);
>  	if (IS_ERR(req))
> -		goto out;
> +		return req;
>  	error = nfs_inode_add_request(inode, req);
>  	if (error != 0) {
>  		nfs_release_request(req);
>  		req = ERR_PTR(error);
> +	} else {
> +		struct nfs_inode *nfsi = NFS_I(inode);
> +		atomic_inc(&nfsi->ndirty);
>  	}
> -out:
>  	return req;
>  }
>  
> @@ -877,6 +919,7 @@ static int nfs_write_rpcsetup(struct nfs
>  		count,
>  		(unsigned long long)data->args.offset);
>  
> +	nfs_inc_woutstanding(inode);
>  	task = rpc_run_task(&task_setup_data);
>  	if (IS_ERR(task))
>  		return PTR_ERR(task);
> @@ -1172,7 +1215,7 @@ int nfs_writeback_done(struct rpc_task *
>  	 */
>  	status = NFS_PROTO(data->inode)->write_done(task, data);
>  	if (status != 0)
> -		return status;
> +		goto out;
>  	nfs_add_stats(data->inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
>  
>  #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
> @@ -1229,6 +1272,8 @@ int nfs_writeback_done(struct rpc_task *
>  		task->tk_status = -EIO;
>  	}
>  	nfs4_sequence_free_slot(server->nfs_client, &data->res.seq_res);
> +out:
> +	nfs_dec_woutstanding(data->inode);
>  	return 0;
>  }
>  
> @@ -1591,6 +1636,24 @@ int nfs_wb_page(struct inode *inode, str
>  	return nfs_wb_page_priority(inode, page, FLUSH_STABLE);
>  }
>  
> +int nfs_wb_eager(struct inode *inode)
> +{
> +	struct address_space *mapping = inode->i_mapping;
> +	struct writeback_control wbc = {
> +		.bdi            = mapping->backing_dev_info,
> +		.sync_mode      = WB_SYNC_NONE,
> +		.nr_to_write    = LONG_MAX,
> +		.range_start    = 0,
> +		.range_end      = LLONG_MAX,
> +	};
> +	int ret;
> +
> +	ret = nfs_writepages(mapping, &wbc);
> +	if (ret < 0)
> +		__mark_inode_dirty(inode, I_DIRTY_PAGES);
> +	return ret;
> +}
> +
>  #ifdef CONFIG_MIGRATION
>  int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
>  		struct page *page)
> @@ -1674,4 +1737,3 @@ void nfs_destroy_writepagecache(void)
>  	mempool_destroy(nfs_wdata_mempool);
>  	kmem_cache_destroy(nfs_wdata_cachep);
>  }
> -
> diff -rupN -X linux-2.6.32-rc7/Documentation/dontdiff linux-2.6.32-rc7-orig/include/linux/nfs_fs.h linux-2.6.32-rc7/include/linux/nfs_fs.h
> --- linux-2.6.32-rc7-orig/include/linux/nfs_fs.h	2009-11-12 19:46:07.000000000 -0500
> +++ linux-2.6.32-rc7/include/linux/nfs_fs.h	2009-11-13 11:36:43.982136105 -0500
> @@ -166,6 +166,7 @@ struct nfs_inode {
>  	struct radix_tree_root	nfs_page_tree;
>  
>  	unsigned long		npages;
> +	atomic_t		ndirty;
>  
>  	/* Open contexts for shared mmap writes */
>  	struct list_head	open_files;
> @@ -187,6 +188,11 @@ struct nfs_inode {
>  #ifdef CONFIG_NFS_FSCACHE
>  	struct fscache_cookie	*fscache;
>  #endif
> +
> +	loff_t			wrpos;
> +	atomic_t		writes;
> +	wait_queue_head_t	writes_wq;
> +
>  	struct inode		vfs_inode;
>  };
>  
> @@ -467,11 +473,13 @@ extern void nfs_unblock_sillyrename(stru
>   * linux/fs/nfs/write.c
>   */
>  extern int  nfs_congestion_kb;
> +extern int  nfs_max_woutstanding;
>  extern int  nfs_writepage(struct page *page, struct writeback_control *wbc);
>  extern int  nfs_writepages(struct address_space *, struct writeback_control *);
>  extern int  nfs_flush_incompatible(struct file *file, struct page *page);
>  extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
>  extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
> +extern void nfs_wait_woutstanding(struct inode *);
>  
>  /*
>   * Try to write back everything synchronously (but check the
> @@ -482,6 +490,7 @@ extern int nfs_wb_all(struct inode *inod
>  extern int nfs_wb_nocommit(struct inode *inode);
>  extern int nfs_wb_page(struct inode *inode, struct page* page);
>  extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
> +extern int nfs_wb_eager(struct inode *inode);
>  #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
>  extern int  nfs_commit_inode(struct inode *, int);
>  extern struct nfs_write_data *nfs_commitdata_alloc(void);
> diff -rupN -X linux-2.6.32-rc7/Documentation/dontdiff linux-2.6.32-rc7-orig/mm/page-writeback.c linux-2.6.32-rc7/mm/page-writeback.c
> --- linux-2.6.32-rc7-orig/mm/page-writeback.c	2009-11-12 19:46:07.000000000 -0500
> +++ linux-2.6.32-rc7/mm/page-writeback.c	2009-11-18 10:05:22.314373138 -0500
> @@ -536,7 +536,7 @@ static void balance_dirty_pages(struct a
>  		 * threshold otherwise wait until the disk writes catch
>  		 * up.
>  		 */
> -		if (bdi_nr_reclaimable > bdi_thresh) {
> +		if (bdi_nr_reclaimable != 0) {
>  			writeback_inodes_wbc(&wbc);
>  			pages_written += write_chunk - wbc.nr_to_write;
>  			get_dirty_limits(&background_thresh, &dirty_thresh,

And I think you just broke regular writeback here, allowing for tons of
unneeded writeout of very small chunks.

This really needs to be multiple patches, and a proper changelog
describing why you do things. The above, because my benchmark goes
faster, just isn't sufficient.

Also, I don't think this needs to have a sysctl, it should just work.

