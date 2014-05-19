Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:39588 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441AbaESPP0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 11:15:26 -0400
Received: by mail-ig0-f171.google.com with SMTP id c1so3602589igq.10
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 08:15:26 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 7/8] nfs: clean up function decls in nfs_page.h
Date: Mon, 19 May 2014 11:15:07 -0400
Message-Id: <1400512508-7530-8-git-send-email-dros@primarydata.com>
In-Reply-To: <1400512508-7530-1-git-send-email-dros@primarydata.com>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For consistency, remove argument names in function declarations

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 include/linux/nfs_page.h | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 4b48548..09ffb6a 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -95,32 +95,32 @@ struct nfs_pageio_descriptor {
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
 
-extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
-					    struct page *page,
-					    struct nfs_page *last,
-					    unsigned int offset,
-					    unsigned int count);
+extern	struct nfs_page *nfs_create_request(struct nfs_open_context *,
+					    struct page *,
+					    struct nfs_page *,
+					    unsigned int,
+					    unsigned int);
 extern	void nfs_release_request(struct nfs_page *);
 
 
-extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
-			     struct inode *inode,
-			     const struct nfs_pageio_ops *pg_ops,
-			     const struct nfs_pgio_completion_ops *compl_ops,
-			     const struct nfs_rw_ops *rw_ops,
-			     size_t bsize,
-			     int how);
+extern	void nfs_pageio_init(struct nfs_pageio_descriptor *,
+			     struct inode *,
+			     const struct nfs_pageio_ops *,
+			     const struct nfs_pgio_completion_ops *,
+			     const struct nfs_rw_ops *,
+			     size_t,
+			     int);
 extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
 				   struct nfs_page *);
 extern  int nfs_pageio_resend(struct nfs_pageio_descriptor *,
 			      struct nfs_pgio_header *);
-extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);
+extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *);
 extern	void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *, pgoff_t);
-extern size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
-				struct nfs_page *prev,
-				struct nfs_page *req);
+extern size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *,
+				struct nfs_page *,
+				struct nfs_page *);
 extern  int nfs_wait_on_request(struct nfs_page *);
-extern	void nfs_unlock_request(struct nfs_page *req);
+extern	void nfs_unlock_request(struct nfs_page *);
 extern	void nfs_unlock_and_release_request(struct nfs_page *);
 extern void nfs_page_group_lock(struct nfs_page *);
 extern void nfs_page_group_unlock(struct nfs_page *);
-- 
1.8.5.2 (Apple Git-48)

