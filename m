Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753022Ab1BDVeU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:20 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
        Andy Adamson <andros@citi.umich.edu>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Dean Hildebrand <dhildeb@us.ibm.com>, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 06/40] pnfs_submit: wave3 associate layout segment with nfs_page
Date: Fri,  4 Feb 2011 16:33:28 -0500
Message-Id: <1296855242-2592-7-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-6-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/file.c            |    4 ----
 fs/nfs/pagelist.c        |   12 ++++++++++--
 fs/nfs/pnfs.c            |   14 ++++++++++++--
 fs/nfs/pnfs.h            |    5 +++++
 fs/nfs/read.c            |    9 ++++++---
 fs/nfs/write.c           |    2 +-
 include/linux/nfs_page.h |    3 ++-
 7 files changed, 36 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 7bf029e..d85a534 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -387,10 +387,6 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
 
-	pnfs_update_layout(mapping->host,
-			   nfs_file_open_context(file),
-			   IOMODE_RW);
-
 start:
 	/*
 	 * Prevent starvation issues if someone is doing a consistency
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 0e8dece..9a27592 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -20,6 +20,7 @@
 #include <linux/nfs_mount.h>
 
 #include "internal.h"
+#include "pnfs.h"
 
 static struct kmem_cache *nfs_page_cachep;
 
@@ -53,7 +54,8 @@ nfs_page_free(struct nfs_page *p)
 struct nfs_page *
 nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 		   struct page *page,
-		   unsigned int offset, unsigned int count)
+		   unsigned int offset, unsigned int count,
+		   struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page		*req;
 
@@ -84,6 +86,9 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	req->wb_bytes   = count;
 	req->wb_context = get_nfs_open_context(ctx);
 	kref_init(&req->wb_kref);
+	req->wb_lseg    = lseg;
+	if (lseg)
+		get_lseg(lseg);
 	return req;
 }
 
@@ -159,9 +164,12 @@ void nfs_clear_request(struct nfs_page *req)
 		put_nfs_open_context(ctx);
 		req->wb_context = NULL;
 	}
+	if (req->wb_lseg != NULL) {
+		put_lseg(req->wb_lseg);
+		req->wb_lseg = NULL;
+	}
 }
 
-
 /**
  * nfs_release_request - Release the count on an NFS read/write request
  * @req: request to release
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c7199db..1811204 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -264,7 +264,7 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
 	return 0;
 }
 
-static void
+void
 put_lseg(struct pnfs_layout_segment *lseg)
 {
 	struct inode *ino;
@@ -282,6 +282,7 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		free_lseg(lseg);
 	}
 }
+EXPORT_SYMBOL_GPL(put_lseg);
 
 static bool
 should_free_lseg(u32 lseg_iomode, u32 recall_iomode)
@@ -795,7 +796,6 @@ pnfs_update_layout(struct inode *ino,
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout->plh_flags, lseg);
-	put_lseg(lseg); /* STUB - callers currently ignore return value */
 	return lseg;
 out_unlock:
 	spin_unlock(&ino->i_lock);
@@ -910,6 +910,16 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	pnfs_set_pg_test(inode, pgio);
 }
 
+static void _pnfs_clear_lseg_from_pages(struct list_head *head)
+{
+	struct nfs_page *req;
+
+	list_for_each_entry(req, head, wb_list) {
+		put_lseg(req->wb_lseg);
+		req->wb_lseg = NULL;
+	}
+}
+
 /*
  * Device ID cache. Currently supports one layout type per struct nfs_client.
  * Add layout type to the lookup key to expand to support multiple types.
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7a75a0c..7614c3b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -151,6 +151,7 @@ extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
 
 /* pnfs.c */
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
+void put_lseg(struct pnfs_layout_segment *lseg);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
@@ -210,6 +211,10 @@ static inline void get_lseg(struct pnfs_layout_segment *lseg)
 {
 }
 
+static inline void put_lseg(struct pnfs_layout_segment *lseg)
+{
+}
+
 static inline struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 11e7d6e..2eac0f1 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -117,12 +117,14 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	LIST_HEAD(one_request);
 	struct nfs_page	*new;
 	unsigned int len;
+	struct pnfs_layout_segment *lseg;
 
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	pnfs_update_layout(inode, ctx, IOMODE_READ);
-	new = nfs_create_request(ctx, inode, page, 0, len);
+	lseg = pnfs_update_layout(inode, ctx, IOMODE_READ);
+	new = nfs_create_request(ctx, inode, page, 0, len, lseg);
+	put_lseg(lseg);
 	if (IS_ERR(new)) {
 		unlock_page(page);
 		return PTR_ERR(new);
@@ -569,7 +571,8 @@ readpage_async_filler(void *data, struct page *page)
 	if (len == 0)
 		return nfs_return_empty_page(page);
 
-	new = nfs_create_request(desc->ctx, inode, page, 0, len);
+	new = nfs_create_request(desc->ctx, inode, page, 0, len,
+				 desc->pgio->pg_lseg);
 	if (IS_ERR(new))
 		goto out_error;
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7a2905d..7f3c10a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -651,7 +651,7 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 	req = nfs_try_to_update_request(inode, page, offset, bytes);
 	if (req != NULL)
 		goto out;
-	req = nfs_create_request(ctx, inode, page, offset, bytes);
+	req = nfs_create_request(ctx, inode, page, offset, bytes, NULL);
 	if (IS_ERR(req))
 		goto out;
 	error = nfs_inode_add_request(inode, req);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index ec9fd30..484c5b9 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -75,7 +75,8 @@ extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
 					    struct inode *inode,
 					    struct page *page,
 					    unsigned int offset,
-					    unsigned int count);
+					    unsigned int count,
+					    struct pnfs_layout_segment *lseg);
 extern	void nfs_clear_request(struct nfs_page *req);
 extern	void nfs_release_request(struct nfs_page *req);
 
-- 
1.6.6

