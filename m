Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:31654 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752804AbeFKTcI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Jun 2018 15:32:08 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] [PNFS] skip LAYOUTRETURN if layout is invalid
Date: Mon, 11 Jun 2018 15:32:06 -0400
Message-ID: <20180611193206.29582-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <olga.kornievskaia@gmail.com>

Currently, when IO to DS fails, client returns the layout and
retries against the MDS. However, then on umounting (inode eviction)
it returns the layout again.

This is because pnfs_return_layout() was changed in
commit d78471d32bb6 ("pnfs/blocklayout: set PNFS_LAYOUTRETURN_ON_ERROR")
to always set NFS_LAYOUT_RETURN_REQUESTED so even if we returned
the layout, it will be returned again. Instead, let's also check
if we have already marked the layout invalid.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/pnfs.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d93942f..bcc3add 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1211,7 +1211,7 @@ static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo)
 	LIST_HEAD(tmp_list);
 	nfs4_stateid stateid;
 	int status = 0;
-	bool send;
+	bool send, valid_layout;
 
 	dprintk("NFS: %s for inode %lu\n", __func__, ino->i_ino);
 
@@ -1232,6 +1232,7 @@ static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo)
 			goto out_put_layout_hdr;
 		spin_lock(&ino->i_lock);
 	}
+	valid_layout = pnfs_layout_is_valid(lo);
 	pnfs_clear_layoutcommit(ino, &tmp_list);
 	pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL, 0);
 
@@ -1245,7 +1246,8 @@ static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo)
 	}
 
 	/* Don't send a LAYOUTRETURN if list was initially empty */
-	if (!test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags)) {
+	if (!test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags) ||
+			!valid_layout) {
 		spin_unlock(&ino->i_lock);
 		dprintk("NFS: %s no layout segments to return\n", __func__);
 		goto out_put_layout_hdr;
-- 
1.8.3.1

