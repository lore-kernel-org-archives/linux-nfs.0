Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:33030 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbaHHPPB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2014 11:15:01 -0400
Received: by mail-ie0-f173.google.com with SMTP id tr6so6554560ieb.4
        for <linux-nfs@vger.kernel.org>; Fri, 08 Aug 2014 08:15:01 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 4/5] pnfs: add pnfs_put_lseg_async
Date: Fri,  8 Aug 2014 11:13:35 -0400
Message-Id: <1407510816-7002-5-git-send-email-dros@primarydata.com>
In-Reply-To: <1407510816-7002-1-git-send-email-dros@primarydata.com>
References: <1407510816-7002-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is useful when lsegs need to be released while holding locks.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 17 +++++++++++++++++
 fs/nfs/pnfs.h |  7 +++++++
 2 files changed, 24 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 83ff8a0..4e85315 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -361,6 +361,23 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 }
 EXPORT_SYMBOL_GPL(pnfs_put_lseg);
 
+static void pnfs_put_lseg_async_work(struct work_struct *work)
+{
+	struct pnfs_layout_segment *lseg;
+
+	lseg = container_of(work, struct pnfs_layout_segment, pls_work);
+
+	pnfs_put_lseg(lseg);
+}
+
+void
+pnfs_put_lseg_async(struct pnfs_layout_segment *lseg)
+{
+	INIT_WORK(&lseg->pls_work, pnfs_put_lseg_async_work);
+	schedule_work(&lseg->pls_work);
+}
+EXPORT_SYMBOL_GPL(pnfs_put_lseg_async);
+
 static u64
 end_offset(u64 start, u64 len)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 203b6c9..aca3dff 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -32,6 +32,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/workqueue.h>
 
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
@@ -46,6 +47,7 @@ struct pnfs_layout_segment {
 	atomic_t pls_refcount;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
+	struct work_struct pls_work;
 };
 
 enum pnfs_try_status {
@@ -181,6 +183,7 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 /* pnfs.c */
 void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
+void pnfs_put_lseg_async(struct pnfs_layout_segment *lseg);
 
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
 void unset_pnfs_layoutdriver(struct nfs_server *);
@@ -419,6 +422,10 @@ static inline void pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 {
 }
 
+static inline void pnfs_put_lseg_async(struct pnfs_layout_segment *lseg)
+{
+}
+
 static inline int pnfs_return_layout(struct inode *ino)
 {
 	return 0;
-- 
1.8.5.2 (Apple Git-48)

