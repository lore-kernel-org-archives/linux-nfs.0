From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull NFS client bugfixes for 2.6.35-rc6
Date: Fri, 30 Jul 2010 15:43:55 -0400
Message-ID: <1280519035.12852.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41815 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754990Ab0G3Tn5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jul 2010 15:43:57 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/file.c          |   13 +++++++++++--
 fs/nfs/nfsroot.c       |    2 +-
 fs/nfs/write.c         |   27 +++++++++++++++++++--------
 include/linux/nfs_fs.h |    1 +
 4 files changed, 32 insertions(+), 11 deletions(-)

commit cfb506e1d330387dfaf334dd493b3773d388863d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jul 30 15:31:57 2010 -0400

    NFS: Ensure that writepage respects the nonblock flag
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b608b283a962caaa280756bc8563016a71712acf
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jul 30 15:31:54 2010 -0400

    NFS: kswapd must not block in nfs_release_page
    
    See https://bugzilla.kernel.org/show_bug.cgi?id=16056
    
    If other processes are blocked waiting for kswapd to free up some memory so
    that they can make progress, then we cannot allow kswapd to block on those
    processes.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 674b2222920012244ca59978b356b25412a8dcc7
Author: Dan Carpenter <error27@gmail.com>
Date:   Tue Jul 13 13:34:59 2010 +0200

    nfs: include space for the NUL in root path
    
    In root_nfs_name() it does the following:
    
            if (strlen(buf) + strlen(cp) > NFS_MAXPATHLEN) {
                    printk(KERN_ERR "Root-NFS: Pathname for remote directory too long.\n");
                    return -1;
            }
            sprintf(nfs_export_path, buf, cp);
    
    In the original code if (strlen(buf) + strlen(cp) == NFS_MAXPATHLEN)
    then the sprintf() would lead to an overflow.  Generally the rest of the
    code assumes that the path can have NFS_MAXPATHLEN (1024) characters and
    a NUL terminator so the fix is to add space to the nfs_export_path[]
    buffer.
    
    Signed-off-by: Dan Carpenter <error27@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 36a5e74..f036153 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -27,6 +27,7 @@
 #include <linux/pagemap.h>
 #include <linux/aio.h>
 #include <linux/gfp.h>
+#include <linux/swap.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -493,11 +494,19 @@ static void nfs_invalidate_page(struct page *page, unsigned long offset)
  */
 static int nfs_release_page(struct page *page, gfp_t gfp)
 {
+	struct address_space *mapping = page->mapping;
+
 	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
 
 	/* Only do I/O if gfp is a superset of GFP_KERNEL */
-	if ((gfp & GFP_KERNEL) == GFP_KERNEL)
-		nfs_wb_page(page->mapping->host, page);
+	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL) {
+		int how = FLUSH_SYNC;
+
+		/* Don't let kswapd deadlock waiting for OOM RPC calls */
+		if (current_is_kswapd())
+			how = 0;
+		nfs_commit_inode(mapping->host, how);
+	}
 	/* If PagePrivate() is set, then the page is not freeable */
 	if (PagePrivate(page))
 		return 0;
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 6bd19d8..df101d9 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -105,7 +105,7 @@ static char nfs_root_name[256] __initdata = "";
 static __be32 servaddr __initdata = 0;
 
 /* Name of directory to mount */
-static char nfs_export_path[NFS_MAXPATHLEN] __initdata = { 0, };
+static char nfs_export_path[NFS_MAXPATHLEN + 1] __initdata = { 0, };
 
 /* NFS-related data */
 static struct nfs_mount_data nfs_data __initdata = { 0, };/* NFS mount info */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 91679e2..bb72ad3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -222,7 +222,7 @@ static void nfs_end_page_writeback(struct page *page)
 		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
 }
 
-static struct nfs_page *nfs_find_and_lock_request(struct page *page)
+static struct nfs_page *nfs_find_and_lock_request(struct page *page, bool nonblock)
 {
 	struct inode *inode = page->mapping->host;
 	struct nfs_page *req;
@@ -241,7 +241,10 @@ static struct nfs_page *nfs_find_and_lock_request(struct page *page)
 		 *	 request as dirty (in which case we don't care).
 		 */
 		spin_unlock(&inode->i_lock);
-		ret = nfs_wait_on_request(req);
+		if (!nonblock)
+			ret = nfs_wait_on_request(req);
+		else
+			ret = -EAGAIN;
 		nfs_release_request(req);
 		if (ret != 0)
 			return ERR_PTR(ret);
@@ -256,12 +259,12 @@ static struct nfs_page *nfs_find_and_lock_request(struct page *page)
  * May return an error if the user signalled nfs_wait_on_request().
  */
 static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
-				struct page *page)
+				struct page *page, bool nonblock)
 {
 	struct nfs_page *req;
 	int ret = 0;
 
-	req = nfs_find_and_lock_request(page);
+	req = nfs_find_and_lock_request(page, nonblock);
 	if (!req)
 		goto out;
 	ret = PTR_ERR(req);
@@ -283,12 +286,20 @@ out:
 static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
 {
 	struct inode *inode = page->mapping->host;
+	int ret;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
 	nfs_pageio_cond_complete(pgio, page->index);
-	return nfs_page_async_flush(pgio, page);
+	ret = nfs_page_async_flush(pgio, page,
+			wbc->sync_mode == WB_SYNC_NONE ||
+			wbc->nonblocking != 0);
+	if (ret == -EAGAIN) {
+		redirty_page_for_writepage(wbc, page);
+		ret = 0;
+	}
+	return ret;
 }
 
 /*
@@ -1379,7 +1390,7 @@ static const struct rpc_call_ops nfs_commit_ops = {
 	.rpc_release = nfs_commit_release,
 };
 
-static int nfs_commit_inode(struct inode *inode, int how)
+int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
 	int may_wait = how & FLUSH_SYNC;
@@ -1443,7 +1454,7 @@ out_mark_dirty:
 	return ret;
 }
 #else
-static int nfs_commit_inode(struct inode *inode, int how)
+int nfs_commit_inode(struct inode *inode, int how)
 {
 	return 0;
 }
@@ -1546,7 +1557,7 @@ int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 
 	nfs_fscache_release_page(page, GFP_KERNEL);
 
-	req = nfs_find_and_lock_request(page);
+	req = nfs_find_and_lock_request(page, false);
 	ret = PTR_ERR(req);
 	if (IS_ERR(req))
 		goto out;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 77c2ae5..f6e2455 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -493,6 +493,7 @@ extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
 #endif

