From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/4] NFS: Fix nfs_direct_dirty_pages()
Date: Tue, 22 May 2007 10:29:23 -0400
Message-ID: <20070522142923.22559.49677.stgit@heimdal.trondhjem.org>
References: <20070522142908.22559.91696.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqVMd-00049r-QZ
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 07:29:28 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqVMf-0006Gc-He
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 07:29:30 -0700
In-Reply-To: <20070522142908.22559.91696.stgit@heimdal.trondhjem.org>
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

We only need to dirty the pages that were actually read in.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index ef0ce2c..4060e6f 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -122,9 +122,15 @@ ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov, loff_
 	return -EINVAL;
 }
 
-static void nfs_direct_dirty_pages(struct page **pages, unsigned int npages)
+static void nfs_direct_dirty_pages(struct page **pages, unsigned int pgbase, size_t count)
 {
+	unsigned int npages;
 	unsigned int i;
+
+	if (count == 0)
+		return;
+	pages += (pgbase >> PAGE_SHIFT);
+	npages = (count + (pgbase & ~PAGE_MASK) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	for (i = 0; i < npages; i++) {
 		struct page *page = pages[i];
 		if (!PageCompound(page))
@@ -224,18 +230,20 @@ static void nfs_direct_read_result(struct rpc_task *task, void *calldata)
 	if (nfs_readpage_result(task, data) != 0)
 		return;
 
-	nfs_direct_dirty_pages(data->pagevec, data->npages);
-	nfs_direct_release_pages(data->pagevec, data->npages);
-
 	spin_lock(&dreq->lock);
 
-	if (likely(task->tk_status >= 0))
+	if (likely(task->tk_status >= 0)) {
 		dreq->count += data->res.count;
-	else
+		nfs_direct_dirty_pages(data->pagevec,
+				data->args.pgbase,
+				data->res.count);
+	} else
 		dreq->error = task->tk_status;
 
 	spin_unlock(&dreq->lock);
 
+	nfs_direct_release_pages(data->pagevec, data->npages);
+
 	if (put_dreq(dreq))
 		nfs_direct_complete(dreq);
 }

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
