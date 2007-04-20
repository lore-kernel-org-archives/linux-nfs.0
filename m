From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/5] NFS: Fix race in nfs_set_page_dirty
Date: Fri, 20 Apr 2007 16:12:50 -0400
Message-ID: <20070420201250.7897.77055.stgit@heimdal.trondhjem.org>
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
	id 1HezTN-0002oT-9C
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:49 -0700
Received: from dh166.citi.umich.edu ([141.211.133.166]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HezTO-0006oP-LH
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:51 -0700
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

Protect nfs_set_page_dirty() against races with nfs_inode_add_request.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ce5b4a9..7975589 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -388,6 +388,8 @@ static int nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	}
 	SetPagePrivate(req->wb_page);
 	set_page_private(req->wb_page, (unsigned long)req);
+	if (PageDirty(req->wb_page))
+		set_bit(PG_NEED_FLUSH, &req->wb_flags);
 	nfsi->npages++;
 	atomic_inc(&req->wb_count);
 	return 0;
@@ -407,6 +409,8 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 	set_page_private(req->wb_page, 0);
 	ClearPagePrivate(req->wb_page);
 	radix_tree_delete(&nfsi->nfs_page_tree, req->wb_index);
+	if (test_and_clear_bit(PG_NEED_FLUSH, &req->wb_flags))
+		__set_page_dirty_nobuffers(req->wb_page);
 	nfsi->npages--;
 	if (!nfsi->npages) {
 		spin_unlock(&nfsi->req_lock);
@@ -1527,15 +1531,22 @@ int nfs_wb_page(struct inode *inode, struct page* page)
 
 int nfs_set_page_dirty(struct page *page)
 {
+	spinlock_t *req_lock = &NFS_I(page->mapping->host)->req_lock;
 	struct nfs_page *req;
+	int ret;
 
-	req = nfs_page_find_request(page);
+	spin_lock(req_lock);
+	req = nfs_page_find_request_locked(page);
 	if (req != NULL) {
 		/* Mark any existing write requests for flushing */
-		set_bit(PG_NEED_FLUSH, &req->wb_flags);
+		ret = !test_and_set_bit(PG_NEED_FLUSH, &req->wb_flags);
+		spin_unlock(req_lock);
 		nfs_release_request(req);
+		return ret;
 	}
-	return __set_page_dirty_nobuffers(page);
+	ret = __set_page_dirty_nobuffers(page);
+	spin_unlock(req_lock);
+	return ret;
 }
 
 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
