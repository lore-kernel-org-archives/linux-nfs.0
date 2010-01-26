From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 09/12] NFS: Replace __nfs_write_mapping with
 sync_inode()
Date: Tue, 26 Jan 2010 18:17:39 -0500
Message-ID: <1264547859.3788.37.camel@localhost>
References: <20100125221544.16750.70574.stgit@localhost.localdomain>
	 <20100125221545.16750.63968.stgit@localhost.localdomain>
	 <20100126112148.GA25170@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58831 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153Ab0AZXSB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2010 18:18:01 -0500
In-Reply-To: <20100126112148.GA25170@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-01-26 at 06:21 -0500, Christoph Hellwig wrote: 
> On Mon, Jan 25, 2010 at 05:15:45PM -0500, Trond Myklebust wrote:
> >  int nfs_wb_nocommit(struct inode *inode)
> >  {
> > -	return nfs_write_mapping(inode->i_mapping, FLUSH_NOCOMMIT);
> > +	return filemap_write_and_wait(inode->i_mapping);
> 
> Any point in keeping this as a wrapper for a single well-documented
> caller?  Also taking i_mutex around it seems a bit questionable these
> days given that filemap_write_and_wait avoids lifelocks with writing
> applications okay and we use it without i_mutex all over the place.
> 

I'm replacing the former patch with the following updated version.

Cheers
  Trond

--------------------------------------------------------------------------------------------- 
NFS: Replace __nfs_write_mapping with sync_inode()

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Now that we have correct COMMIT semantics in writeback_single_inode, we can
reduce and simplify nfs_wb_all(). Also replace nfs_wb_nocommit() with a
call to filemap_write_and_wait(), which doesn't need to hold the
inode->i_mutex.

With that done, we can eliminate nfs_write_mapping() altogether.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c         |   15 +++++----------
 fs/nfs/write.c         |   42 +++++-------------------------------------
 include/linux/nfs_fs.h |    2 --
 3 files changed, 10 insertions(+), 49 deletions(-)


diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 8341709..733cb27 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -495,17 +495,11 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
 	int err;
 
-	/*
-	 * Flush out writes to the server in order to update c/mtime.
-	 *
-	 * Hold the i_mutex to suspend application writes temporarily;
-	 * this prevents long-running writing applications from blocking
-	 * nfs_wb_nocommit.
-	 */
+	/* Flush out writes to the server in order to update c/mtime.  */
 	if (S_ISREG(inode->i_mode)) {
-		mutex_lock(&inode->i_mutex);
-		nfs_wb_nocommit(inode);
-		mutex_unlock(&inode->i_mutex);
+		err = filemap_write_and_wait(inode->i_mapping);
+		if (err)
+			goto out;
 	}
 
 	/*
@@ -529,6 +523,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 		generic_fillattr(inode, stat);
 		stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
 	}
+out:
 	return err;
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 53df027..c28cf57 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1443,7 +1443,6 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 	pgoff_t idx_start, idx_end;
 	unsigned int npages = 0;
 	LIST_HEAD(head);
-	int nocommit = how & FLUSH_NOCOMMIT;
 	long pages, ret;
 
 	/* FIXME */
@@ -1460,14 +1459,11 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 				npages = 0;
 		}
 	}
-	how &= ~FLUSH_NOCOMMIT;
 	spin_lock(&inode->i_lock);
 	do {
 		ret = nfs_wait_on_requests_locked(inode, idx_start, npages);
 		if (ret != 0)
 			continue;
-		if (nocommit)
-			break;
 		pages = nfs_scan_commit(inode, &head, idx_start, npages);
 		if (pages == 0)
 			break;
@@ -1481,47 +1477,19 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 	return ret;
 }
 
-static int __nfs_write_mapping(struct address_space *mapping, struct writeback_control *wbc, int how)
-{
-	int ret;
-
-	ret = nfs_writepages(mapping, wbc);
-	if (ret < 0)
-		goto out;
-	ret = nfs_sync_mapping_wait(mapping, wbc, how);
-	if (ret < 0)
-		goto out;
-	return 0;
-out:
-	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
-	return ret;
-}
-
-/* Two pass sync: first using WB_SYNC_NONE, then WB_SYNC_ALL */
-static int nfs_write_mapping(struct address_space *mapping, int how)
+/*
+ * flush the inode to disk.
+ */
+int nfs_wb_all(struct inode *inode)
 {
 	struct writeback_control wbc = {
-		.bdi = mapping->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
 		.range_start = 0,
 		.range_end = LLONG_MAX,
 	};
 
-	return __nfs_write_mapping(mapping, &wbc, how);
-}
-
-/*
- * flush the inode to disk.
- */
-int nfs_wb_all(struct inode *inode)
-{
-	return nfs_write_mapping(inode->i_mapping, 0);
-}
-
-int nfs_wb_nocommit(struct inode *inode)
-{
-	return nfs_write_mapping(inode->i_mapping, FLUSH_NOCOMMIT);
+	return sync_inode(inode, &wbc);
 }
 
 int nfs_wb_page_cancel(struct inode *inode, struct page *page)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1eec414..3383622 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -33,7 +33,6 @@
 #define FLUSH_STABLE		4	/* commit to stable storage */
 #define FLUSH_LOWPRI		8	/* low priority background flush */
 #define FLUSH_HIGHPRI		16	/* high priority memory reclaim flush */
-#define FLUSH_NOCOMMIT		32	/* Don't send the NFSv3/v4 COMMIT */
 
 #ifdef __KERNEL__
 
@@ -477,7 +476,6 @@ extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
  */
 extern long nfs_sync_mapping_wait(struct address_space *, struct writeback_control *, int);
 extern int nfs_wb_all(struct inode *inode);
-extern int nfs_wb_nocommit(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)

