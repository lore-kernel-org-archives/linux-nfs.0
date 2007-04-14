From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFS: Ensure PG_writeback is cleared when writeback fails
Date: Sat, 14 Apr 2007 19:10:12 -0400
Message-ID: <1176592212.6089.26.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcrPa-0001zY-6P
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 16:12:06 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HcrPc-0001il-3k
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 16:12:08 -0700
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

If the writebacks are cancelled via nfs_cancel_dirty_list, or due to the
memory allocation failing in nfs_flush_one/nfs_flush_multi, then we must
ensure that the PG_writeback flag is cleared.

Also ensure that we actually own the PG_writeback flag whenever we
schedule a new writeback by making nfs_set_page_writeback() return the
value of test_set_page_writeback().
The PG_writeback page flag ends up replacing the functionality of the
PG_FLUSHING nfs_page flag, so we rip that out too.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
---

 fs/nfs/write.c           |   22 +++++++++++++++-------
 include/linux/nfs_page.h |    1 -
 2 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2867e6b..e5d7cac 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -218,9 +218,11 @@ int nfs_congestion_kb;
 #define NFS_CONGESTION_OFF_THRESH	\
 	(NFS_CONGESTION_ON_THRESH - (NFS_CONGESTION_ON_THRESH >> 2))
 
-static void nfs_set_page_writeback(struct page *page)
+static int nfs_set_page_writeback(struct page *page)
 {
-	if (!test_set_page_writeback(page)) {
+	int ret = test_set_page_writeback(page);
+
+	if (!ret) {
 		struct inode *inode = page->mapping->host;
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
@@ -228,6 +230,7 @@ static void nfs_set_page_writeback(struct page *page)
 				NFS_CONGESTION_ON_THRESH)
 			set_bdi_congested(&nfss->backing_dev_info, WRITE);
 	}
+	return ret;
 }
 
 static void nfs_end_page_writeback(struct page *page)
@@ -277,10 +280,8 @@ static int nfs_page_mark_flush(struct page *page)
 		spin_lock(req_lock);
 	}
 	spin_unlock(req_lock);
-	if (test_and_set_bit(PG_FLUSHING, &req->wb_flags) == 0) {
+	if (nfs_set_page_writeback(page) == 0)
 		nfs_mark_request_dirty(req);
-		nfs_set_page_writeback(page);
-	}
 	ret = test_bit(PG_NEED_FLUSH, &req->wb_flags);
 	nfs_unlock_request(req);
 	return ret;
@@ -424,7 +425,6 @@ nfs_mark_request_dirty(struct nfs_page *req)
 static void
 nfs_redirty_request(struct nfs_page *req)
 {
-	clear_bit(PG_FLUSHING, &req->wb_flags);
 	__set_page_dirty_nobuffers(req->wb_page);
 }
 
@@ -434,7 +434,11 @@ nfs_redirty_request(struct nfs_page *req)
 static inline int
 nfs_dirty_request(struct nfs_page *req)
 {
-	return test_bit(PG_FLUSHING, &req->wb_flags) == 0;
+	struct page *page = req->wb_page;
+
+	if (page == NULL)
+		return 0;
+	return !PageWriteback(req->wb_page);
 }
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
@@ -500,6 +504,7 @@ static void nfs_cancel_dirty_list(struct list_head *head)
 	while(!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
+		nfs_end_page_writeback(req->wb_page);
 		nfs_inode_remove_request(req);
 		nfs_clear_page_writeback(req);
 	}
@@ -890,6 +895,7 @@ out_bad:
 		list_del(&data->pages);
 		nfs_writedata_release(data);
 	}
+	nfs_end_page_writeback(req->wb_page);
 	nfs_redirty_request(req);
 	nfs_clear_page_writeback(req);
 	return -ENOMEM;
@@ -935,6 +941,7 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, int how)
 	while (!list_empty(head)) {
 		struct nfs_page *req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
+		nfs_end_page_writeback(req->wb_page);
 		nfs_redirty_request(req);
 		nfs_clear_page_writeback(req);
 	}
@@ -970,6 +977,7 @@ out_err:
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
+		nfs_end_page_writeback(req->wb_page);
 		nfs_redirty_request(req);
 		nfs_clear_page_writeback(req);
 	}
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 2e555d4..d111be6 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -31,7 +31,6 @@
 #define PG_NEED_COMMIT		1
 #define PG_NEED_RESCHED		2
 #define PG_NEED_FLUSH		3
-#define PG_FLUSHING		4
 
 struct nfs_inode;
 struct nfs_page {

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
