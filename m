From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/4] NFS: Fix handful of compiler warnings in direct.c
Date: Tue, 22 May 2007 10:29:08 -0400
Message-ID: <20070522142908.22559.91696.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqVMO-00048h-Ef
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 07:29:13 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqVMR-0006dZ-3F
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 07:29:15 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Chuck Lever <chuck.lever@oracle.com>

This patch fixes a couple of signage issues that were causing an Oops
when running the LTP diotest4 test. get_user_pages() returns a signed
error, hence we need to be careful when comparing with the unsigned
number of pages from data->npages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 345aa5c..6c588ec 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -122,9 +122,9 @@ ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov, loff_
 	return -EINVAL;
 }
 
-static void nfs_direct_dirty_pages(struct page **pages, int npages)
+static void nfs_direct_dirty_pages(struct page **pages, unsigned int npages)
 {
-	int i;
+	unsigned int i;
 	for (i = 0; i < npages; i++) {
 		struct page *page = pages[i];
 		if (!PageCompound(page))
@@ -132,9 +132,9 @@ static void nfs_direct_dirty_pages(struct page **pages, int npages)
 	}
 }
 
-static void nfs_direct_release_pages(struct page **pages, int npages)
+static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
 {
-	int i;
+	unsigned int i;
 	for (i = 0; i < npages; i++)
 		page_cache_release(pages[i]);
 }
@@ -279,9 +279,12 @@ static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq, unsigned lo
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 1, 0, data->pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
-		if (unlikely(result < data->npages)) {
-			if (result > 0)
-				nfs_direct_release_pages(data->pagevec, result);
+		if (result < 0) {
+			nfs_readdata_release(data);
+			break;
+		}
+		if ((unsigned)result < data->npages) {
+			nfs_direct_release_pages(data->pagevec, result);
 			nfs_readdata_release(data);
 			break;
 		}
@@ -610,9 +613,12 @@ static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq, unsigned l
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 0, 0, data->pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
-		if (unlikely(result < data->npages)) {
-			if (result > 0)
-				nfs_direct_release_pages(data->pagevec, result);
+		if (result < 0) {
+			nfs_writedata_release(data);
+			break;
+		}
+		if ((unsigned)result < data->npages) {
+			nfs_direct_release_pages(data->pagevec, result);
 			nfs_writedata_release(data);
 			break;
 		}

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
