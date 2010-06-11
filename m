From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/7] SQUASHME: pnfs: export get_lseg and put_lseg
Date: Fri, 11 Jun 2010 03:40:33 -0400
Message-ID: <1276242039-18649-2-git-send-email-iisaman@netapp.com>
References: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32582 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628Ab0FKHkx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:40:53 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7eoVb027834
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:40:53 -0700 (PDT)
In-Reply-To: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c             |    8 ++++++++
 fs/nfs/pnfs.h             |    6 ------
 include/linux/nfs4_pnfs.h |    3 +++
 3 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ab47308..d6ba358 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -454,6 +454,14 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		wake_up(&nfsi->lo_waitq);
 }
 
+EXPORT_SYMBOL(put_lseg);
+
+void get_lseg(struct pnfs_layout_segment *lseg)
+{
+	kref_get(&lseg->kref);
+}
+EXPORT_SYMBOL(get_lseg);
+
 static inline u64
 end_offset(u64 start, u64 len)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 810ce9e..fd7c532 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -34,7 +34,6 @@ extern int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait
 /* pnfs.c */
 extern const nfs4_stateid zero_stateid;
 
-void put_lseg(struct pnfs_layout_segment *lseg);
 void _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 	loff_t pos, u64 count, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp);
@@ -95,11 +94,6 @@ static inline int lo_fail_bit(u32 iomode)
 			 NFS_INO_RW_LAYOUT_FAILED : NFS_INO_RO_LAYOUT_FAILED;
 }
 
-static inline void get_lseg(struct pnfs_layout_segment *lseg)
-{
-	kref_get(&lseg->kref);
-}
-
 /* Return true if a layout driver is being used for this mountpoint */
 static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 {
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 744ca33..b7772c8 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -92,6 +92,9 @@ layoutcommit_needed(struct nfs_inode *nfsi)
 	return nfsi->layout.lo_cred != NULL;
 }
 
+extern void put_lseg(struct pnfs_layout_segment *lseg);
+extern void get_lseg(struct pnfs_layout_segment *lseg);
+
 #else /* CONFIG_NFS_V4_1 */
 
 static inline bool
-- 
1.6.6.1

