Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:56787 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbAYASS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 19:18:18 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so3201666igk.1
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 16:18:18 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Optimise layout return-on-close
Date: Sat, 24 Jan 2015 19:18:16 -0500
Message-Id: <1422145096-81768-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Optimise the layout return on close code by ensuring that

1) Add a check for whether we hold a layout before taking any spinlocks
2) Only take the spin lock once
3) Use nfs_state->state to speed up open file checks

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 37 +------------------------------------
 fs/nfs/pnfs.c     | 24 ++++++++++++++++++++----
 fs/nfs/pnfs.h     | 10 ++++++++++
 3 files changed, 31 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 66befb0dd241..0f75b9276726 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2714,45 +2714,10 @@ static const struct rpc_call_ops nfs4_close_ops = {
 	.rpc_release = nfs4_free_closedata,
 };
 
-static bool nfs4_state_has_opener(struct nfs4_state *state)
-{
-	/* first check existing openers */
-	if (test_bit(NFS_O_RDONLY_STATE, &state->flags) != 0 &&
-	    state->n_rdonly != 0)
-		return true;
-
-	if (test_bit(NFS_O_WRONLY_STATE, &state->flags) != 0 &&
-	    state->n_wronly != 0)
-		return true;
-
-	if (test_bit(NFS_O_RDWR_STATE, &state->flags) != 0 &&
-	    state->n_rdwr != 0)
-		return true;
-
-	return false;
-}
-
 static bool nfs4_roc(struct inode *inode)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
-	struct nfs_open_context *ctx;
-	struct nfs4_state *state;
-
-	spin_lock(&inode->i_lock);
-	list_for_each_entry(ctx, &nfsi->open_files, list) {
-		state = ctx->state;
-		if (state == NULL)
-			continue;
-		if (nfs4_state_has_opener(state)) {
-			spin_unlock(&inode->i_lock);
-			return false;
-		}
-	}
-	spin_unlock(&inode->i_lock);
-
-	if (nfs4_check_delegation(inode, FMODE_READ))
+	if (!nfs_have_layout(inode))
 		return false;
-
 	return pnfs_roc(inode);
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0a5dda4d85c2..4d69076a6028 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -34,6 +34,7 @@
 #include "pnfs.h"
 #include "iostat.h"
 #include "nfs4trace.h"
+#include "delegation.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS
 #define PNFS_LAYOUTGET_RETRY_TIMEOUT (120*HZ)
@@ -954,30 +955,45 @@ pnfs_commit_and_return_layout(struct inode *inode)
 
 bool pnfs_roc(struct inode *ino)
 {
+	struct nfs_inode *nfsi = NFS_I(ino);
+	struct nfs_open_context *ctx;
+	struct nfs4_state *state;
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg, *tmp;
 	LIST_HEAD(tmp_list);
 	bool found = false;
 
 	spin_lock(&ino->i_lock);
-	lo = NFS_I(ino)->layout;
+	lo = nfsi->layout;
 	if (!lo || !test_and_clear_bit(NFS_LAYOUT_ROC, &lo->plh_flags) ||
 	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
-		goto out_nolayout;
+		goto out_noroc;
+
+	/* Don't return layout if we hold a delegation */
+	if (nfs4_check_delegation(ino, FMODE_READ))
+		goto out_noroc;
+
+	list_for_each_entry(ctx, &nfsi->open_files, list) {
+		state = ctx->state;
+		/* Don't return layout if there is open file state */
+		if (state != NULL && state->state != 0)
+			goto out_noroc;
+	}
+
 	list_for_each_entry_safe(lseg, tmp, &lo->plh_segs, pls_list)
 		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
 			mark_lseg_invalid(lseg, &tmp_list);
 			found = true;
 		}
 	if (!found)
-		goto out_nolayout;
+		goto out_noroc;
 	lo->plh_block_lgets++;
 	pnfs_get_layout_hdr(lo); /* matched in pnfs_roc_release */
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 	return true;
 
-out_nolayout:
+out_noroc:
 	spin_unlock(&ino->i_lock);
 	return false;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9ae5b765b073..a98d8fd9637f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -275,6 +275,11 @@ void nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node);
 bool nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node);
 void nfs4_deviceid_purge_client(const struct nfs_client *);
 
+static inline bool nfs_have_layout(struct inode *inode)
+{
+	return NFS_I(inode)->layout != NULL;
+}
+
 static inline struct nfs4_deviceid_node *
 nfs4_get_deviceid(struct nfs4_deviceid_node *d)
 {
@@ -427,6 +432,11 @@ static inline void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id)
 #endif /* NFS_DEBUG */
 #else  /* CONFIG_NFS_V4_1 */
 
+static inline bool nfs_have_layout(struct inode *inode)
+{
+	return false;
+}
+
 static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
 {
 }
-- 
2.1.0

