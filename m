From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH v2] flow control for WRITE requests
Date: Tue, 24 Mar 2009 15:31:50 -0400
Message-ID: <49C93526.70303@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030107050107030709090803"
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39104 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756422AbZCXTb6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Mar 2009 15:31:58 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030107050107030709090803
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi.

Attached is a patch which implements some flow control for the
NFS client to control dirty pages.  The flow control is
implemented on a per-file basis and causes dirty pages to be
written out when the client can detect that the application is
writing in a serial fashion and has dirtied enough pages to
fill a complete over the wire transfer.

This work was precipitated by working on a situation where a
server at a customer site was not able to adequately handle
the behavior of the Linux NFS client.  This particular server
required that all data to the file written to the file be
written in a strictly serial fashion.  It also had problems
handling the Linux NFS client semantic of caching a large
amount of data and then sending out that data all at once.

The sequential ordering problem was resolved by a previous
patch which was submitted to the linux-nfs list.  This patch
addresses the capacity problem.

The problem is resolved by sending WRITE requests much
earlier in the process of the application writing to the file.
The client keeps track of the number of dirty pages associated
with the file and also the last offset of the data being
written.  When the client detects that a full over the wire
transfer could be constructed and that the application is
writing sequentially, then it generates an UNSTABLE write to
server for the currently dirty data.

The client also keeps track of the number of these WRITE
requests which have been generated.  It flow controls based
on a configurable maximum.  This keeps the client from
completely overwhelming the server.

A nice side effect of the framework is that the issue of
stat()'ing a file being written can be handled much more
quickly than before.  The amount of data that must be
transmitted to the server to satisfy the "latest mtime"
requirement is limited.  Also, the application writing to
the file is blocked until the over the wire GETATTR is
completed.  This allows the GETATTR to be send and the
response received without competing with the data being
written.

No performance regressions were seen during informal
performance testing.

As a side note -- the more natural model of flow control
would seem to be at the client/server level instead of
the per-file level.  However, that level was too coarse
with the particular server that was required to be used
because its requirements were at the per-file level.

The new functionality in this patch is controlled via the
use of the sysctl, nfs_max_outstanding_writes.  It defaults
to 0, meaning no flow control and the current behaviors.
Setting it to any non-zero value enables the functionality.
The value of 16 seems to be a good number and aligns with
other NFS and RPC tunables.

Lastly, the functionality of starting WRITE requests sooner
to smooth out the i/o pattern should probably be done by the
VM subsystem.  I am looking into this, but in the meantime
and to solve the immediate problem, this support is proposed.

    Thanx...

        ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--------------030107050107030709090803
Content-Type: text/plain;
 name="flow_control.devel.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="flow_control.devel.2"

--- linux-2.6.28.i586/fs/nfs/inode.c.org
+++ linux-2.6.28.i586/fs/nfs/inode.c
@@ -486,8 +486,10 @@ void nfs_setattr_update_inode(struct ino
 int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
 	struct inode *inode = dentry->d_inode;
-	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	int need_atime = nfsi->cache_validity & NFS_INO_INVALID_ATIME;
 	int err;
+	int inc_outstanding_writes = nfs_max_outstanding_writes;
 
 	/*
 	 * Flush out writes to the server in order to update c/mtime.
@@ -497,9 +499,14 @@ int nfs_getattr(struct vfsmount *mnt, st
 	 * nfs_wb_nocommit.
 	 */
 	if (S_ISREG(inode->i_mode)) {
-		mutex_lock(&inode->i_mutex);
-		nfs_wb_nocommit(inode);
-		mutex_unlock(&inode->i_mutex);
+		if (inc_outstanding_writes) {
+			atomic_add(inc_outstanding_writes, &nfsi->writes);
+			nfs_wb_nocommit(inode);
+		} else {
+			mutex_lock(&inode->i_mutex);
+			nfs_wb_nocommit(inode);
+			mutex_unlock(&inode->i_mutex);
+		}
 	}
 
 	/*
@@ -523,6 +530,10 @@ int nfs_getattr(struct vfsmount *mnt, st
 		generic_fillattr(inode, stat);
 		stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
 	}
+	if (S_ISREG(inode->i_mode) && inc_outstanding_writes) {
+		atomic_sub(inc_outstanding_writes, &nfsi->writes);
+		wake_up(&nfsi->writes_wq);
+	}
 	return err;
 }
 
@@ -1288,9 +1299,13 @@ static void init_once(void *foo)
 	INIT_RADIX_TREE(&nfsi->nfs_page_tree, GFP_ATOMIC);
 	nfsi->ncommit = 0;
 	nfsi->npages = 0;
+	atomic_set(&nfsi->ndirty, 0);
 	atomic_set(&nfsi->silly_count, 1);
 	INIT_HLIST_HEAD(&nfsi->silly_list);
 	init_waitqueue_head(&nfsi->waitqueue);
+	atomic_set(&nfsi->writes, 0);
+	init_waitqueue_head(&nfsi->writes_wq);
+	nfsi->wrpos = 0;
 	nfs4_init_once(nfsi);
 }
 
--- linux-2.6.28.i586/fs/nfs/write.c.org
+++ linux-2.6.28.i586/fs/nfs/write.c
@@ -197,7 +197,9 @@ static int nfs_set_page_writeback(struct
 	if (!ret) {
 		struct inode *inode = page->mapping->host;
 		struct nfs_server *nfss = NFS_SERVER(inode);
+		struct nfs_inode *nfsi = NFS_I(inode);
 
+		atomic_dec(&nfsi->ndirty);
 		if (atomic_long_inc_return(&nfss->writeback) >
 				NFS_CONGESTION_ON_THRESH)
 			set_bdi_congested(&nfss->backing_dev_info, WRITE);
@@ -310,6 +312,33 @@ static int nfs_writepages_callback(struc
 	return ret;
 }
 
+int nfs_max_outstanding_writes = 0;
+
+static void nfs_inc_outstanding_writes(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	atomic_inc(&nfsi->writes);
+}
+
+static void nfs_dec_outstanding_writes(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	if (atomic_dec_return(&nfsi->writes) < nfs_max_outstanding_writes)
+		wake_up(&nfsi->writes_wq);
+}
+
+void nfs_wait_for_outstanding_writes(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	if (nfs_max_outstanding_writes) {
+		wait_event(nfsi->writes_wq,
+		    atomic_read(&nfsi->writes) < nfs_max_outstanding_writes);
+	}
+}
+
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
@@ -369,6 +398,7 @@ static int nfs_inode_add_request(struct 
 	SetPagePrivate(req->wb_page);
 	set_page_private(req->wb_page, (unsigned long)req);
 	nfsi->npages++;
+	atomic_inc(&nfsi->ndirty);
 	kref_get(&req->wb_kref);
 	radix_tree_tag_set(&nfsi->nfs_page_tree, req->wb_index,
 				NFS_PAGE_TAG_LOCKED);
@@ -405,6 +435,10 @@ static void nfs_inode_remove_request(str
 static void
 nfs_mark_request_dirty(struct nfs_page *req)
 {
+	struct inode *inode = req->wb_context->path.dentry->d_inode;
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	atomic_inc(&nfsi->ndirty);
 	__set_page_dirty_nobuffers(req->wb_page);
 }
 
@@ -633,6 +667,7 @@ static struct nfs_page *nfs_try_to_updat
 		req->wb_bytes = end - req->wb_offset;
 	else
 		req->wb_bytes = rqend - req->wb_offset;
+	atomic_inc(&NFS_I(inode)->ndirty);
 out_unlock:
 	spin_unlock(&inode->i_lock);
 	return req;
@@ -855,6 +890,8 @@ static int nfs_write_rpcsetup(struct nfs
 		count,
 		(unsigned long long)data->args.offset);
 
+	nfs_inc_outstanding_writes(inode);
+
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -1130,7 +1167,7 @@ int nfs_writeback_done(struct rpc_task *
 	 */
 	status = NFS_PROTO(data->inode)->write_done(task, data);
 	if (status != 0)
-		return status;
+		goto out;
 	nfs_add_stats(data->inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
@@ -1186,7 +1223,9 @@ int nfs_writeback_done(struct rpc_task *
 		/* Can't do anything about it except throw an error. */
 		task->tk_status = -EIO;
 	}
-	return 0;
+out:
+	nfs_dec_outstanding_writes(data->inode);
+	return status;
 }
 
 
@@ -1546,6 +1585,29 @@ int nfs_wb_page(struct inode *inode, str
 	return nfs_wb_page_priority(inode, page, FLUSH_STABLE);
 }
 
+/*
+ * Start the WRITE requests for dirty pages on their way.
+ * This is used when a sufficient number of dirty pages
+ * have accumulated.
+ */
+int nfs_wb_interim(struct inode *inode)
+{
+	struct address_space *mapping = inode->i_mapping;
+	struct writeback_control wbc = {
+		.bdi = mapping->backing_dev_info,
+		.sync_mode = WB_SYNC_NONE,
+		.nr_to_write = LONG_MAX,
+		.range_start = 0,
+		.range_end = LLONG_MAX,
+	};
+	int ret;
+
+	ret = nfs_writepages(mapping, &wbc);
+	if (ret < 0)
+		__mark_inode_dirty(inode, I_DIRTY_PAGES);
+	return ret;
+}
+
 int __init nfs_init_writepagecache(void)
 {
 	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
--- linux-2.6.28.i586/fs/nfs/sysctl.c.org
+++ linux-2.6.28.i586/fs/nfs/sysctl.c
@@ -58,6 +58,14 @@ static ctl_table nfs_cb_sysctls[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name = CTL_UNNUMBERED,
+		.procname = "nfs_max_outstanding_writes",
+		.data = &nfs_max_outstanding_writes,
+		.maxlen = sizeof(int),
+		.mode = 0644,
+		.proc_handler = &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
--- linux-2.6.28.i586/fs/nfs/file.c.org
+++ linux-2.6.28.i586/fs/nfs/file.c
@@ -512,11 +512,17 @@ static int nfs_need_sync_write(struct fi
 	return 0;
 }
 
+static int nfs_is_serial(struct inode *inode, loff_t pos)
+{
+	return NFS_I(inode)->wrpos == pos;
+}
+
 static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos)
 {
-	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
-	struct inode * inode = dentry->d_inode;
+	struct dentry *dentry = iocb->ki_filp->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	struct nfs_inode *nfsi = NFS_I(inode);
 	ssize_t result;
 	size_t count = iov_length(iov, nr_segs);
 
@@ -530,6 +536,13 @@ static ssize_t nfs_file_write(struct kio
 	result = -EBUSY;
 	if (IS_SWAPFILE(inode))
 		goto out_swapfile;
+
+	result = count;
+	if (!count)
+		goto out;
+
+	nfs_wait_for_outstanding_writes(inode);
+
 	/*
 	 * O_APPEND implies that we must revalidate the file length.
 	 */
@@ -539,17 +552,22 @@ static ssize_t nfs_file_write(struct kio
 			goto out;
 	}
 
-	result = count;
-	if (!count)
-		goto out;
-
 	nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, count);
 	result = generic_file_aio_write(iocb, iov, nr_segs, pos);
 	/* Return error values for O_SYNC and IS_SYNC() */
-	if (result >= 0 && nfs_need_sync_write(iocb->ki_filp, inode)) {
-		int err = nfs_do_fsync(nfs_file_open_context(iocb->ki_filp), inode);
-		if (err < 0)
-			result = err;
+	if (result >= 0) {
+		if (nfs_need_sync_write(iocb->ki_filp, inode)) {
+			int err;
+			err = nfs_do_fsync(nfs_file_open_context(iocb->ki_filp),
+					inode);
+			if (err < 0)
+				result = err;
+		} else if (nfs_max_outstanding_writes &&
+		    nfs_is_serial(inode, pos) &&
+		    atomic_read(&nfsi->ndirty) >= NFS_SERVER(inode)->wpages)
+			nfs_wb_interim(inode);
+		if (result > 0)
+			nfsi->wrpos = pos + result;
 	}
 out:
 	return result;
--- linux-2.6.28.i586/include/linux/nfs_fs.h.org
+++ linux-2.6.28.i586/include/linux/nfs_fs.h
@@ -168,6 +168,7 @@ struct nfs_inode {
 
 	unsigned long		ncommit,
 				npages;
+	atomic_t		ndirty;
 
 	/* Open contexts for shared mmap writes */
 	struct list_head	open_files;
@@ -186,6 +187,9 @@ struct nfs_inode {
 	fmode_t			 delegation_state;
 	struct rw_semaphore	rwsem;
 #endif /* CONFIG_NFS_V4*/
+	atomic_t		writes;	/* number of outstanding WRITEs */
+	wait_queue_head_t	writes_wq;
+	loff_t			wrpos;	/* position after last WRITE */
 	struct inode		vfs_inode;
 };
 
@@ -459,12 +463,14 @@ extern void nfs_unblock_sillyrename(stru
  * linux/fs/nfs/write.c
  */
 extern int  nfs_congestion_kb;
+extern int  nfs_max_outstanding_writes;
 extern int  nfs_writepage(struct page *page, struct writeback_control *wbc);
 extern int  nfs_writepages(struct address_space *, struct writeback_control *);
 extern int  nfs_flush_incompatible(struct file *file, struct page *page);
 extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
-extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
+extern int  nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 extern void nfs_writedata_release(void *);
+extern void nfs_wait_for_outstanding_writes(struct inode *);
 
 /*
  * Try to write back everything synchronously (but check the
@@ -475,6 +481,7 @@ extern int nfs_wb_all(struct inode *inod
 extern int nfs_wb_nocommit(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
+extern int nfs_wb_interim(struct inode *);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commitdata_alloc(void);

--------------030107050107030709090803--
