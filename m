From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/5] NFS: Fix the 'desynchronized value of
	nfs_i.ncommit' error
Date: Fri, 20 Apr 2007 16:12:45 -0400
Message-ID: <20070420201245.7897.64946.stgit@heimdal.trondhjem.org>
References: <20070420200358.7897.75870.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, Florin Iucha <florin@iucha.net>,
	Adrian Bunk <bunk@stusta.de>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HezTH-0002oD-AZ
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:43 -0700
Received: from dh166.citi.umich.edu ([141.211.133.166]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HezTJ-0006n2-I4
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:45 -0700
In-Reply-To: <20070420200358.7897.75870.stgit@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Redirtying a request that is already marked for commit will screw up the
accounting for NR_UNSTABLE_NFS as well as nfs_i.ncommit.
Ensure that all requests on the commit queue are labelled with the
PG_NEED_COMMIT flag, and avoid moving them onto the dirty list inside
nfs_page_mark_flush().

Also inline nfs_mark_request_dirty() into nfs_page_mark_flush() for
atomicity reasons. Avoid dropping the spinlock until we're done marking the
request in the radix tree and have added it to the ->dirty list.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |   47 ++++++++++++++++++++++-------------------------
 1 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 8e94246..ce5b4a9 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -38,7 +38,6 @@
 static struct nfs_page * nfs_update_request(struct nfs_open_context*,
 					    struct page *,
 					    unsigned int, unsigned int);
-static void nfs_mark_request_dirty(struct nfs_page *req);
 static long nfs_flush_mapping(struct address_space *mapping, struct writeback_control *wbc, int how);
 static const struct rpc_call_ops nfs_write_partial_ops;
 static const struct rpc_call_ops nfs_write_full_ops;
@@ -255,7 +254,8 @@ static void nfs_end_page_writeback(struct page *page)
 static int nfs_page_mark_flush(struct page *page)
 {
 	struct nfs_page *req;
-	spinlock_t *req_lock = &NFS_I(page->mapping->host)->req_lock;
+	struct nfs_inode *nfsi = NFS_I(page->mapping->host);
+	spinlock_t *req_lock = &nfsi->req_lock;
 	int ret;
 
 	spin_lock(req_lock);
@@ -279,11 +279,23 @@ static int nfs_page_mark_flush(struct page *page)
 			return ret;
 		spin_lock(req_lock);
 	}
-	spin_unlock(req_lock);
+	if (test_bit(PG_NEED_COMMIT, &req->wb_flags)) {
+		/* This request is marked for commit */
+		spin_unlock(req_lock);
+		nfs_unlock_request(req);
+		return 1;
+	}
 	if (nfs_set_page_writeback(page) == 0) {
 		nfs_list_remove_request(req);
-		nfs_mark_request_dirty(req);
-	}
+		/* add the request to the inode's dirty list. */
+		radix_tree_tag_set(&nfsi->nfs_page_tree,
+				req->wb_index, NFS_PAGE_TAG_DIRTY);
+		nfs_list_add_request(req, &nfsi->dirty);
+		nfsi->ndirty++;
+		spin_unlock(req_lock);
+		__mark_inode_dirty(page->mapping->host, I_DIRTY_PAGES);
+	} else
+		spin_unlock(req_lock);
 	ret = test_bit(PG_NEED_FLUSH, &req->wb_flags);
 	nfs_unlock_request(req);
 	return ret;
@@ -406,24 +418,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
-/*
- * Add a request to the inode's dirty list.
- */
-static void
-nfs_mark_request_dirty(struct nfs_page *req)
-{
-	struct inode *inode = req->wb_context->dentry->d_inode;
-	struct nfs_inode *nfsi = NFS_I(inode);
-
-	spin_lock(&nfsi->req_lock);
-	radix_tree_tag_set(&nfsi->nfs_page_tree,
-			req->wb_index, NFS_PAGE_TAG_DIRTY);
-	nfs_list_add_request(req, &nfsi->dirty);
-	nfsi->ndirty++;
-	spin_unlock(&nfsi->req_lock);
-	__mark_inode_dirty(inode, I_DIRTY_PAGES);
-}
-
 static void
 nfs_redirty_request(struct nfs_page *req)
 {
@@ -438,7 +432,7 @@ nfs_dirty_request(struct nfs_page *req)
 {
 	struct page *page = req->wb_page;
 
-	if (page == NULL)
+	if (page == NULL || test_bit(PG_NEED_COMMIT, &req->wb_flags))
 		return 0;
 	return !PageWriteback(req->wb_page);
 }
@@ -456,6 +450,7 @@ nfs_mark_request_commit(struct nfs_page *req)
 	spin_lock(&nfsi->req_lock);
 	nfs_list_add_request(req, &nfsi->commit);
 	nfsi->ncommit++;
+	set_bit(PG_NEED_COMMIT, &(req)->wb_flags);
 	spin_unlock(&nfsi->req_lock);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
@@ -470,7 +465,7 @@ int nfs_write_need_commit(struct nfs_write_data *data)
 static inline
 int nfs_reschedule_unstable_write(struct nfs_page *req)
 {
-	if (test_and_clear_bit(PG_NEED_COMMIT, &req->wb_flags)) {
+	if (test_bit(PG_NEED_COMMIT, &req->wb_flags)) {
 		nfs_mark_request_commit(req);
 		return 1;
 	}
@@ -557,6 +552,7 @@ static void nfs_cancel_commit_list(struct list_head *head)
 		req = nfs_list_entry(head->next);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		nfs_list_remove_request(req);
+		clear_bit(PG_NEED_COMMIT, &(req)->wb_flags);
 		nfs_inode_remove_request(req);
 		nfs_unlock_request(req);
 	}
@@ -1295,6 +1291,7 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
+		clear_bit(PG_NEED_COMMIT, &(req)->wb_flags);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 
 		dprintk("NFS: commit (%s/%Ld %d@%Ld)",

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
