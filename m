Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:30545 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621Ab1EVC4h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 22:56:37 -0400
Message-ID: <4DD87B5B.30309@panasas.com>
Date: Sun, 22 May 2011 05:56:27 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [OUT-OF-TREE] DEBUGME: pnfs: DEBUGING of lseg ref counting
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


With this patch it is possible to find lseg ref counting
problems. It might help some one in the future

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs.c |    9 +++++----
 fs/nfs/pnfs.h |   10 ++++++++--
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 17d0c4c..8d2baf8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -239,6 +239,7 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	smp_mb();
 	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
 	lseg->pls_layout = lo;
+	printk(KERN_ERR "@@@%s: lseg %p ref 1 valid 1\n", __func__, lseg);
 }
 
 static void free_lseg(struct pnfs_layout_segment *lseg)
@@ -266,14 +267,14 @@ put_lseg_common(struct pnfs_layout_segment *lseg)
 }
 
 void
-put_lseg(struct pnfs_layout_segment *lseg)
+__put_lseg(struct pnfs_layout_segment *lseg, const char* f)
 {
 	struct inode *inode;
 
 	if (!lseg)
 		return;
 
-	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
+	dprintk("@@@%s: %s: lseg %p ref %d valid %d\n", __func__, f, lseg,
 		atomic_read(&lseg->pls_refcount),
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	inode = lseg->pls_layout->plh_inode;
@@ -286,7 +287,7 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		pnfs_free_lseg_list(&free_me);
 	}
 }
-EXPORT_SYMBOL_GPL(put_lseg);
+EXPORT_SYMBOL_GPL(__put_lseg);
 
 static inline u64
 end_offset(u64 start, u64 len)
@@ -367,7 +368,7 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 		 * list.  It will now be removed when all
 		 * outstanding io is finished.
 		 */
-		dprintk("%s: lseg %p ref %d\n", __func__, lseg,
+		dprintk("@@@%s: lseg %p ref %d\n", __func__, lseg,
 			atomic_read(&lseg->pls_refcount));
 		if (atomic_dec_and_test(&lseg->pls_refcount)) {
 			put_lseg_common(lseg);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 322daba..fa6fe2b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -166,7 +166,9 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 
 /* pnfs.c */
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
-void put_lseg(struct pnfs_layout_segment *lseg);
+void __put_lseg(struct pnfs_layout_segment *lseg, const char *f);
+#define put_lseg(l) __put_lseg(l, __func__)
+
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   loff_t pos, u64 count, enum pnfs_iomode access_type);
@@ -211,14 +213,18 @@ static inline int lo_fail_bit(u32 iomode)
 }
 
 static inline struct pnfs_layout_segment *
-get_lseg(struct pnfs_layout_segment *lseg)
+__get_lseg(struct pnfs_layout_segment *lseg, const char *f)
 {
 	if (lseg) {
 		atomic_inc(&lseg->pls_refcount);
 		smp_mb__after_atomic_inc();
+	printk(KERN_ERR "@@@%s: %s lseg %p ref %d valid %d\n", __func__, f, lseg,
+		atomic_read(&lseg->pls_refcount),
+		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	}
 	return lseg;
 }
+#define get_lseg(l) __get_lseg(l, __func__)
 
 /* Return true if a layout driver is being used for this mountpoint */
 static inline int pnfs_enabled_sb(struct nfs_server *nfss)
-- 
1.7.2.3

