Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:50570 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188Ab1HIUc5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Aug 2011 16:32:57 -0400
Received: from zenyatta.panasas.com (zenyatta.int.panasas.com [172.17.28.63])
	by natasha.panasas.com (8.13.1/8.13.1) with ESMTP id p79KWuA3026275
	for <linux-nfs@vger.kernel.org>; Tue, 9 Aug 2011 16:32:56 -0400
Message-ID: <4E419971.8040006@panasas.com>
Date: Tue, 9 Aug 2011 13:32:49 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] SQUASHME: pnfsd: Fix compile breakage when !CONFIG_PNFSD
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


The _roc patch broke the !CONFIG_PNFSD compilation. Fix that!

Benny sorry for the breakage.

BTW:
	[PATCH] pnfsd: rename pnfs_roc to pnfsd_roc
  should be:
	[PATCH] SQUASHME: pnfsd: rename pnfs_roc to pnfsd_roc

This patch is ontop of that one

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/pnfsd.h |    1 -
 fs/nfsd/state.h |    2 ++
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 541376e..8e7dd71 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -125,7 +125,6 @@ int nfs4_pnfs_cb_change_state(struct pnfs_get_state *);
 void nfs4_ds_get_verifier(stateid_t *, struct super_block *, u32 *);
 int put_layoutrecall(struct nfs4_layoutrecall *);
 void nomatching_layout(struct nfs4_layoutrecall *);
-void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp);
 void *layoutrecall_done(struct nfs4_layoutrecall *);
 void nfsd4_cb_layout(struct nfs4_layoutrecall *);
 int nfsd_layout_recall_cb(struct super_block *, struct inode *,
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 9b7552c..cba9140 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -519,12 +519,14 @@ extern void nfs4_pnfs_state_init(void);
 extern void nfs4_pnfs_state_shutdown(void);
 extern void nfs4_ds_get_verifier(stateid_t *, struct super_block *, u32 *);
 extern int nfs4_preprocess_pnfs_ds_stateid(struct svc_fh *, stateid_t *);
+extern void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp);
 #else /* CONFIG_PNFSD */
 static inline void nfsd4_free_pnfs_slabs(void) {}
 static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
 static inline void pnfs_expire_client(struct nfs4_client *clp) {}
 static inline void release_pnfs_ds_dev_list(struct nfs4_stateid *stp) {}
 static inline void nfs4_pnfs_state_shutdown(void) {}
+static inline void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp){}
 #endif /* CONFIG_PNFSD */
 
 static inline void
-- 
1.7.6

