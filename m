From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 6/8] NFS: Cleanup for nfs_readpages()
Date: Wed, 11 Apr 2007 22:37:40 -0400
Message-ID: <20070412023740.15270.87250.stgit@heimdal.trondhjem.org>
References: <20070412023714.15270.33322.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbpBv-0005lg-VX
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:44 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbpBy-0002Vs-3b
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:46 -0700
In-Reply-To: <20070412023714.15270.33322.stgit@heimdal.trondhjem.org>
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

Do the coalescing of read requests into block sized requests and start of
I/O as we scan through the pages instead of in a second pass.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/pagelist.c        |    4 ++--
 fs/nfs/read.c            |   47 +++++++++++++++-------------------------------
 include/linux/nfs_page.h |    2 ++
 3 files changed, 19 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 5281285..094537d 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -342,8 +342,8 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
  * Returns true if the request 'req' was successfully coalesced into the
  * existing list of pages 'desc'.
  */
-static int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
-				  struct nfs_page *req)
+int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
+			   struct nfs_page *req)
 {
 	while (!nfs_pageio_do_add_request(desc, req)) {
 		nfs_pageio_doio(desc);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 0effa74..f001606 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -321,28 +321,6 @@ out_bad:
 	return -ENOMEM;
 }
 
-static int
-nfs_pagein_list(struct inode *inode, struct list_head *head, unsigned int rsize)
-{
-	struct nfs_pageio_descriptor desc;
-	unsigned int pages = 0;
-	int error = 0;
-
-	if (rsize < PAGE_CACHE_SIZE)
-		nfs_pageio_init(&desc, inode, nfs_pagein_multi, rsize, 0);
-	else
-		nfs_pageio_init(&desc, inode, nfs_pagein_one, rsize, 0);
-
-	nfs_pageio_add_list(&desc, head);
-	nfs_pageio_complete(&desc);
-	pages += (desc.pg_bytes_written + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-
-	nfs_async_read_error(head);
-	if (error >= 0)
-		return pages;
-	return error;
-}
-
 /*
  * This is the callback from RPC telling us whether a reply was
  * received or some error occurred (timeout or socket shutdown).
@@ -532,7 +510,7 @@ out_error:
 }
 
 struct nfs_readdesc {
-	struct list_head *head;
+	struct nfs_pageio_descriptor *pgio;
 	struct nfs_open_context *ctx;
 };
 
@@ -556,19 +534,21 @@ readpage_async_filler(void *data, struct page *page)
 	}
 	if (len < PAGE_CACHE_SIZE)
 		memclear_highpage_flush(page, len, PAGE_CACHE_SIZE - len);
-	nfs_list_add_request(new, desc->head);
+	nfs_pageio_add_request(desc->pgio, new);
 	return 0;
 }
 
 int nfs_readpages(struct file *filp, struct address_space *mapping,
 		struct list_head *pages, unsigned nr_pages)
 {
-	LIST_HEAD(head);
+	struct nfs_pageio_descriptor pgio;
 	struct nfs_readdesc desc = {
-		.head		= &head,
+		.pgio = &pgio,
 	};
 	struct inode *inode = mapping->host;
 	struct nfs_server *server = NFS_SERVER(inode);
+	size_t rsize = server->rsize;
+	unsigned long npages;
 	int ret = -ESTALE;
 
 	dprintk("NFS: nfs_readpages (%s/%Ld %d)\n",
@@ -587,13 +567,16 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	} else
 		desc.ctx = get_nfs_open_context((struct nfs_open_context *)
 				filp->private_data);
+	if (rsize < PAGE_CACHE_SIZE)
+		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
+	else
+		nfs_pageio_init(&pgio, inode, nfs_pagein_one, rsize, 0);
+
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
-	if (!list_empty(&head)) {
-		int err = nfs_pagein_list(inode, &head, server->rsize);
-		if (!ret)
-			nfs_add_stats(inode, NFSIOS_READPAGES, err);
-			ret = err;
-	}
+
+	nfs_pageio_complete(&pgio);
+	npages = (pgio.pg_bytes_written + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	nfs_add_stats(inode, NFSIOS_READPAGES, npages);
 	put_nfs_open_context(desc.ctx);
 out:
 	return ret;
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 13f5ee2..ee5b09c 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -84,6 +84,8 @@ extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     int (*doio)(struct inode *, struct list_head *, size_t, int),
 			     size_t bsize,
 			     int how);
+extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
+				   struct nfs_page *);
 extern	void nfs_pageio_add_list(struct nfs_pageio_descriptor *,
 				 struct list_head *);
 extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
