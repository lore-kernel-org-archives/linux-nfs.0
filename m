Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:30222 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752844Ab1BWAJq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 19:09:46 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfsd-lexp: recall layout on truncate
Date: Tue, 22 Feb 2011 16:09:43 -0800
Message-Id: <1298419783-27791-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/pnfsd.h      |    1 +
 fs/nfsd/pnfsd_lexp.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/vfs.c        |    4 ++
 3 files changed, 79 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 946f334..51dd982 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -139,6 +139,7 @@ extern struct sockaddr pnfsd_lexp_addr;
 extern size_t pnfs_lexp_addr_len;
 
 extern void pnfsd_lexp_init(struct inode *);
+extern int pnfsd_lexp_recall_layout(struct inode *);
 #endif /* CONFIG_PNFSD_LOCAL_EXPORT */
 
 #endif /* LINUX_NFSD_PNFSD_H */
diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index bf2f403..736cc3f 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -18,6 +18,8 @@
  * by David M. Richter <richterd@citi.umich.edu>
  */
 
+#include <linux/sched.h>
+#include <linux/wait.h>
 #include <linux/sunrpc/svc_xprt.h>
 #include <linux/nfsd/nfs4layoutxdr.h>
 
@@ -28,6 +30,8 @@
 struct sockaddr pnfsd_lexp_addr;
 size_t pnfs_lexp_addr_len;
 
+static wait_queue_head_t lo_recall_wq;
+
 static int
 pnfsd_lexp_layout_type(struct super_block *sb)
 {
@@ -196,8 +200,7 @@ static int
 pnfsd_lexp_layout_return(struct inode *inode,
 			 const struct nfsd4_pnfs_layoutreturn_arg *args)
 {
-	dprintk("%s: (unimplemented)\n", __func__);
-
+	wake_up_all(&lo_recall_wq);
 	return 0;
 }
 
@@ -220,6 +223,75 @@ static struct pnfs_export_operations pnfsd_lexp_ops = {
 void
 pnfsd_lexp_init(struct inode *inode)
 {
+	static bool init_once;
+
 	dprintk("%s: &pnfsd_lexp_ops=%p\n", __func__, &pnfsd_lexp_ops);
 	inode->i_sb->s_pnfs_op = &pnfsd_lexp_ops;
+
+	if (!init_once++)
+		init_waitqueue_head(&lo_recall_wq);
+}
+
+static bool
+has_no_layout(struct nfs4_file *fp)
+{
+	return list_empty(&fp->fi_layouts);
+}
+
+/*
+ * recalls the layout if needed and waits synchronously for its return
+ */
+int
+pnfsd_lexp_recall_layout(struct inode *inode)
+{
+	struct nfs4_file *fp;
+	struct nfsd4_pnfs_cb_layout cbl;
+	struct pnfsd_cb_ctl cb_ctl;
+	int status = 0;
+
+	dprintk("%s: begin\n", __func__);
+	fp = find_file(inode);
+	BUG_ON(!fp);
+
+	if (has_no_layout(fp))
+		goto out;
+
+	memset(&cb_ctl, 0, sizeof(cb_ctl));
+	status = pnfsd_get_cb_op(&cb_ctl);
+	BUG_ON(status);
+
+	memset(&cbl, 0, sizeof(cbl));
+	cbl.cbl_recall_type = RETURN_FILE;
+	cbl.cbl_seg.layout_type = LAYOUT_NFSV4_1_FILES;
+	/* for now, always recall the whole layout */
+	cbl.cbl_seg.iomode = IOMODE_ANY;
+	cbl.cbl_seg.offset = 0;
+	cbl.cbl_seg.length = NFS4_MAX_UINT64;
+
+	while (!has_no_layout(fp)) {
+		dprintk("%s: recalling layout\n", __func__);
+		status = cb_ctl.cb_op->cb_layout_recall(inode->i_sb, inode, &cbl);
+
+		switch (status) {
+		case 0:
+		case -EAGAIN:
+			break;
+		case -ENOENT:	/* no matching layout */
+			status = 0;
+			goto out_put_cb;
+		default:
+			goto out_put_cb;
+		}
+
+		dprintk("%s: waiting\n", __func__);
+		status = wait_event_interruptible(lo_recall_wq, has_no_layout(fp));
+		if (status)
+			break;
+	}
+out_put_cb:
+	pnfsd_put_cb_op(&cb_ctl);
+out:
+	put_nfs4_file(fp);
+	dprintk("%s: status=%d\n", __func__, status);
+	return status;
 }
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 79ba25f..021e89e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -36,6 +36,7 @@
 #ifdef CONFIG_NFSD_V4
 #include "acl.h"
 #include "idmap.h"
+#include "pnfsd.h"
 #include <linux/nfsd4_spnfs.h>
 #endif /* CONFIG_NFSD_V4 */
 #if defined(CONFIG_SPNFS_BLOCK)
@@ -384,6 +385,9 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 					NFSD_MAY_TRUNC|NFSD_MAY_OWNER_OVERRIDE);
 			if (err)
 				goto out;
+#if defined(CONFIG_PNFSD_LOCAL_EXPORT)
+			pnfsd_lexp_recall_layout(inode);
+#endif /* CONFIG_PNFSD_LOCAL_EXPORT */
 #if defined(CONFIG_SPNFS_BLOCK)
 			if (pnfs_block_enabled(inode, 0)) {
 				err = bl_layoutrecall(inode, RETURN_FILE,
-- 
1.7.3.4

