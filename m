Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50252 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757416AbaIRGEX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Sep 2014 02:04:23 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 18 Sep 2014 16:03:17 +1000
Subject: [PATCH 3/4] NFS: avoid deadlocks with loop-back mounted NFS
 filesystems.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140918060317.23854.40603.stgit@notabene.brown>
In-Reply-To: <20140918055907.23854.32118.stgit@notabene.brown>
References: <20140918055907.23854.32118.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support for loop-back mounted NFS filesystems is useful when NFS is
used to access shared storage in a high-availability cluster.

If the node running the NFS server fails, some other node can mount the
filesystem and start providing NFS service.  If that node already had
the filesystem NFS mounted, it will now have it loop-back mounted.

nfsd can suffer a deadlock when allocating memory and entering direct
reclaim.
While direct reclaim does not write to the NFS filesystem it can send
and wait for a COMMIT through nfs_release_page().

This patch modifies nfs_release_page() to wait a limited time for the
commit to complete - one second.  If the commit doesn't complete
in this time, nfs_release_page() will fail.  This means it might now
fail in some cases where it wouldn't before.  These cases are only
when 'gfp' includes '__GFP_WAIT'.

nfs_release_page() is only called by try_to_release_page(), and that
can only be called on an NFS page with required 'gfp' flags from
 - page_cache_pipe_buf_steal() in splice.c
 - shrink_page_list() in vmscan.c
 - invalidate_inode_pages2_range() in truncate.c

The first two handle failure quite safely.  The last is only called
after ->launder_page() has been called, and that will have waited
for the commit to finish already.

So aborting if the commit takes longer than 1 second is perfectly safe.

If nfs_release_page() is called on a sequence of pages which are all
in the same file which is blocked on COMMIT, each page could
contribute a 1 second delay which could be come excessive.  I have
seen delays of as much as 208 seconds.

To keep the delay to one second, the bdi is marked as write-congested
if the commit didn't finished.  Once it does finish, the
write-congested flag will be cleared.

With this, the longest total delay in try_to_free_pages that I have
seen in under 3 seconds.  With no waiting in nfs_release_page at all
I have seen delays of nearly 1.5 seconds.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/file.c  |   30 ++++++++++++++++++++----------
 fs/nfs/write.c |    7 +++++++
 2 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 524dd80d1898..febba950d8a6 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -468,17 +468,27 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 
 	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
 
-	/* Only do I/O if gfp is a superset of GFP_KERNEL, and we're not
-	 * doing this memory reclaim for a fs-related allocation.
+	/* Always try to initiate a 'commit' if relevant, but only
+	 * wait for it if __GFP_WAIT is set and the calling process is
+	 * allowed to block.  Even then, only wait 1 second and only
+	 * if the 'bdi' is not congested.
+	 * Waiting indefinitely can cause deadlocks when the NFS
+	 * server is on this machine, and there is no particular need
+	 * to wait extensively here.  A short wait has the benefit
+	 * that someone else can worry about the freezer.
 	 */
-	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL &&
-	    !(current->flags & PF_FSTRANS)) {
-		int how = FLUSH_SYNC;
-
-		/* Don't let kswapd deadlock waiting for OOM RPC calls */
-		if (current_is_kswapd())
-			how = 0;
-		nfs_commit_inode(mapping->host, how);
+	if (mapping) {
+		struct nfs_server *nfss = NFS_SERVER(mapping->host);
+		nfs_commit_inode(mapping->host, 0);
+		if ((gfp & __GFP_WAIT) &&
+		    !current_is_kswapd() &&
+		    !(current->flags & PF_FSTRANS) &&
+		    !bdi_write_congested(&nfss->backing_dev_info))
+			wait_on_page_bit_killable_timeout(page, PG_private,
+							  HZ);
+		if (PagePrivate(page))
+			set_bdi_congested(&nfss->backing_dev_info,
+					  BLK_RW_ASYNC);
 	}
 	/* If PagePrivate() is set, then the page is not freeable */
 	if (PagePrivate(page))
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 175d5d073ccf..3066c7fcb565 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -731,6 +731,8 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 		if (likely(!PageSwapCache(head->wb_page))) {
 			set_page_private(head->wb_page, 0);
 			ClearPagePrivate(head->wb_page);
+			smp_mb__after_atomic();
+			wake_up_page(head->wb_page, PG_private);
 			clear_bit(PG_MAPPED, &head->wb_flags);
 		}
 		nfsi->npages--;
@@ -1636,6 +1638,7 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 	struct nfs_page	*req;
 	int status = data->task.tk_status;
 	struct nfs_commit_info cinfo;
+	struct nfs_server *nfss;
 
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
@@ -1669,6 +1672,10 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 	next:
 		nfs_unlock_and_release_request(req);
 	}
+	nfss = NFS_SERVER(data->inode);
+	if (atomic_long_read(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
+		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
 	nfs_init_cinfo(&cinfo, data->inode, data->dreq);
 	if (atomic_dec_and_test(&cinfo.mds->rpcs_out))
 		nfs_commit_clear_lock(NFS_I(data->inode));


