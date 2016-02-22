Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:38829 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbcBVWv3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2016 17:51:29 -0500
Received: by mail-ig0-f172.google.com with SMTP id y8so91294275igp.1
        for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2016 14:51:29 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.x/pnfs: Fix a race between layoutget and pnfs_destroy_layout
Date: Mon, 22 Feb 2016 17:50:45 -0500
Message-Id: <1456181446-14006-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server reboots while there is a layoutget outstanding, then
the call to pnfs_choose_layoutget_stateid() will fail with an EAGAIN
error, which causes an infinite loop in send_layoutget(). The reason
why we never break out of the loop is that the layout 'plh_block_lgets'
field is never cleared.

Fix is to replace plh_block_lgets with NFS_LAYOUT_INVALID_STID, which
can be reset after a new layoutget.

Fixes: ab7d763e477c5 ("pNFS: Ensure nfs4_layoutget_prepare returns...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5064f23ca8cc..8a41538f1155 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -252,6 +252,27 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
 	}
 }
 
+/*
+ * Mark a pnfs_layout_hdr and all associated layout segments as invalid
+ *
+ * In order to continue using the pnfs_layout_hdr, a full recovery
+ * is required.
+ * Note that caller must hold inode->i_lock.
+ */
+static void
+pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
+		struct list_head *lseg_list)
+{
+	struct pnfs_layout_range range = {
+		.iomode = IOMODE_ANY,
+		.offset = 0,
+		.length = NFS4_MAX_UINT64,
+	};
+
+	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+	pnfs_mark_matching_lsegs_invalid(lo, lseg_list, &range);
+}
+
 static int
 pnfs_iomode_to_fail_bit(u32 iomode)
 {
@@ -554,9 +575,8 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	lo = nfsi->layout;
 	if (lo) {
-		lo->plh_block_lgets++; /* permanently block new LAYOUTGETs */
-		pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
 		pnfs_get_layout_hdr(lo);
+		pnfs_mark_layout_stateid_invalid(lo, &tmp_list);
 		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RO_FAILED);
 		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RW_FAILED);
 		spin_unlock(&nfsi->vfs_inode.i_lock);
-- 
2.5.0

