Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:65095 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409AbaIOSOz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 14:14:55 -0400
Received: by mail-ig0-f175.google.com with SMTP id h15so4410462igd.8
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 11:14:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 06/14] pnfs: add pnfs_put_lseg_async
Date: Mon, 15 Sep 2014 14:14:37 -0400
Message-Id: <1410804885-17228-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1410804885-17228-6-git-send-email-trond.myklebust@primarydata.com>
References: <1410804885-17228-1-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-2-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-3-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-4-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-5-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

commit e6cf82d1830f5e16a10d566f58db70f297ba5da8 upstream.

This is useful when lsegs need to be released while holding locks.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 17 +++++++++++++++++
 fs/nfs/pnfs.h |  7 +++++++
 2 files changed, 24 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ecbed4632d11..5f3eb3df7c59 100644
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
index a4a58be94064..ae22a9ccc1b9 100644
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
@@ -179,6 +181,7 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 /* pnfs.c */
 void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
+void pnfs_put_lseg_async(struct pnfs_layout_segment *lseg);
 
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
 void unset_pnfs_layoutdriver(struct nfs_server *);
@@ -410,6 +413,10 @@ static inline void pnfs_put_lseg(struct pnfs_layout_segment *lseg)
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
1.9.3

