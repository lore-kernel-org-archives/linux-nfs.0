From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 8/8] NFS: Fix a buffer overflow in the allocation of
	struct nfs_read/writedata
Date: Wed, 11 Apr 2007 22:37:50 -0400
Message-ID: <20070412023750.15270.92934.stgit@heimdal.trondhjem.org>
References: <20070412023714.15270.33322.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbpC6-0005mK-PI
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:54 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbpC8-0002gi-Cu
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:57 -0700
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

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c          |    5 +++--
 fs/nfs/internal.h        |   12 ++++++++++++
 fs/nfs/pagelist.c        |   10 ++++++++--
 fs/nfs/read.c            |   19 +++++++++----------
 fs/nfs/write.c           |   11 +++++------
 include/linux/nfs_fs.h   |    4 ++--
 include/linux/nfs_page.h |    4 ++--
 7 files changed, 41 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index b1c98ea..9ec2480 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -54,6 +54,7 @@
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
 
+#include "internal.h"
 #include "iostat.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
@@ -271,7 +272,7 @@ static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq, unsigned lo
 		bytes = min(rsize,count);
 
 		result = -ENOMEM;
-		data = nfs_readdata_alloc(pgbase + bytes);
+		data = nfs_readdata_alloc(nfs_page_array_len(pgbase, bytes));
 		if (unlikely(!data))
 			break;
 
@@ -599,7 +600,7 @@ static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq, unsigned l
 		bytes = min(wsize,count);
 
 		result = -ENOMEM;
-		data = nfs_writedata_alloc(pgbase + bytes);
+		data = nfs_writedata_alloc(nfs_page_array_len(pgbase, bytes));
 		if (unlikely(!data))
 			break;
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 6610f2b..ad2b40d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -231,3 +231,15 @@ unsigned int nfs_page_length(struct page *page)
 	}
 	return 0;
 }
+
+/*
+ * Determine the number of pages in an array of length 'len' and
+ * with a base offset of 'base'
+ */
+static inline
+unsigned int nfs_page_array_len(unsigned int base, size_t len)
+{
+	return ((unsigned long)len + (unsigned long)base +
+		PAGE_SIZE - 1) >> PAGE_SHIFT;
+}
+
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ce1d5a4..8418875 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -19,6 +19,8 @@
 #include <linux/nfs_mount.h>
 #include <linux/writeback.h>
 
+#include "internal.h"
+
 #define NFS_PARANOIA 1
 
 static struct kmem_cache *nfs_page_cachep;
@@ -232,7 +234,7 @@ out:
  */
 void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 		     struct inode *inode,
-		     int (*doio)(struct inode *, struct list_head *, size_t, int),
+		     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
 		     unsigned int bsize,
 		     int io_flags)
 {
@@ -299,8 +301,10 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 		 * since nfs_flush_multi and nfs_pagein_multi assume you
 		 * can have only one struct nfs_page.
 		 */
+		if (desc->pg_bsize < PAGE_SIZE)
+			return 0;
 		newlen += desc->pg_count;
-		if (desc->pg_base + newlen > desc->pg_bsize)
+		if (newlen > desc->pg_bsize)
 			return 0;
 		prev = nfs_list_entry(desc->pg_list.prev);
 		if (!nfs_can_coalesce_requests(prev, req))
@@ -321,6 +325,8 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 	if (!list_empty(&desc->pg_list)) {
 		int error = desc->pg_doio(desc->pg_inode,
 					  &desc->pg_list,
+					  nfs_page_array_len(desc->pg_base,
+							     desc->pg_count),
 					  desc->pg_count,
 					  desc->pg_ioflags);
 		if (error < 0)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index f001606..9a55807 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -27,8 +27,8 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-static int nfs_pagein_multi(struct inode *, struct list_head *, size_t, int);
-static int nfs_pagein_one(struct inode *, struct list_head *, size_t, int);
+static int nfs_pagein_multi(struct inode *, struct list_head *, unsigned int, size_t, int);
+static int nfs_pagein_one(struct inode *, struct list_head *, unsigned int, size_t, int);
 static const struct rpc_call_ops nfs_read_partial_ops;
 static const struct rpc_call_ops nfs_read_full_ops;
 
@@ -37,9 +37,8 @@ static mempool_t *nfs_rdata_mempool;
 
 #define MIN_POOL_READ	(32)
 
-struct nfs_read_data *nfs_readdata_alloc(size_t len)
+struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 {
-	unsigned int pagecount = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	struct nfs_read_data *p = mempool_alloc(nfs_rdata_mempool, GFP_NOFS);
 
 	if (p) {
@@ -135,9 +134,9 @@ static int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 
 	nfs_list_add_request(new, &one_request);
 	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
-		nfs_pagein_multi(inode, &one_request, len, 0);
+		nfs_pagein_multi(inode, &one_request, 1, len, 0);
 	else
-		nfs_pagein_one(inode, &one_request, len, 0);
+		nfs_pagein_one(inode, &one_request, 1, len, 0);
 	return 0;
 }
 
@@ -234,7 +233,7 @@ static void nfs_execute_read(struct nfs_read_data *data)
  * won't see the new data until our attribute cache is updated.  This is more
  * or less conventional NFS client behavior.
  */
-static int nfs_pagein_multi(struct inode *inode, struct list_head *head, size_t count, int flags)
+static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -250,7 +249,7 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, size_t
 	do {
 		size_t len = min(nbytes,rsize);
 
-		data = nfs_readdata_alloc(len);
+		data = nfs_readdata_alloc(1);
 		if (!data)
 			goto out_bad;
 		INIT_LIST_HEAD(&data->pages);
@@ -291,13 +290,13 @@ out_bad:
 	return -ENOMEM;
 }
 
-static int nfs_pagein_one(struct inode *inode, struct list_head *head, size_t count, int flags)
+static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
 	struct nfs_read_data	*data;
 
-	data = nfs_readdata_alloc(count);
+	data = nfs_readdata_alloc(npages);
 	if (!data)
 		goto out_bad;
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e600773..b1c071a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -72,9 +72,8 @@ void nfs_commit_free(struct nfs_write_data *wdata)
 	call_rcu_bh(&wdata->task.u.tk_rcu, nfs_commit_rcu_free);
 }
 
-struct nfs_write_data *nfs_writedata_alloc(size_t len)
+struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 {
-	unsigned int pagecount = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	struct nfs_write_data *p = mempool_alloc(nfs_wdata_mempool, GFP_NOFS);
 
 	if (p) {
@@ -797,7 +796,7 @@ static void nfs_execute_write(struct nfs_write_data *data)
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
  */
-static int nfs_flush_multi(struct inode *inode, struct list_head *head, size_t count, int how)
+static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -813,7 +812,7 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, size_t c
 	do {
 		size_t len = min(nbytes, wsize);
 
-		data = nfs_writedata_alloc(len);
+		data = nfs_writedata_alloc(1);
 		if (!data)
 			goto out_bad;
 		list_add(&data->pages, &list);
@@ -862,13 +861,13 @@ out_bad:
  * This is the case if nfs_updatepage detects a conflicting request
  * that has been written but not committed.
  */
-static int nfs_flush_one(struct inode *inode, struct list_head *head, size_t count, int how)
+static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
 	struct nfs_write_data	*data;
 
-	data = nfs_writedata_alloc(count);
+	data = nfs_writedata_alloc(npages);
 	if (!data)
 		goto out_bad;
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index e9ae0c6..0543439 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -455,7 +455,7 @@ nfs_have_writebacks(struct inode *inode)
 /*
  * Allocate nfs_write_data structures
  */
-extern struct nfs_write_data *nfs_writedata_alloc(size_t len);
+extern struct nfs_write_data *nfs_writedata_alloc(unsigned int npages);
 
 /*
  * linux/fs/nfs/read.c
@@ -469,7 +469,7 @@ extern void nfs_readdata_release(void *data);
 /*
  * Allocate nfs_read_data structures
  */
-extern struct nfs_read_data *nfs_readdata_alloc(size_t len);
+extern struct nfs_read_data *nfs_readdata_alloc(unsigned int npages);
 
 /*
  * linux/fs/nfs3proc.c
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index e49f356..1caeede 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -55,7 +55,7 @@ struct nfs_pageio_descriptor {
 	unsigned int		pg_base;
 
 	struct inode		*pg_inode;
-	int			(*pg_doio)(struct inode *, struct list_head *, size_t, int);
+	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int);
 	int 			pg_ioflags;
 	int			pg_error;
 };
@@ -77,7 +77,7 @@ extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *head, struct
 			  unsigned long idx_start, unsigned int npages);
 extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     struct inode *inode,
-			     int (*doio)(struct inode *, struct list_head *, size_t, int),
+			     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
 			     size_t bsize,
 			     int how);
 extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
