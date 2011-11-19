Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45723 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab1KSQyM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Nov 2011 11:54:12 -0500
Received: by ghbz2 with SMTP id z2so1578580ghb.19
        for <linux-nfs@vger.kernel.org>; Sat, 19 Nov 2011 08:54:11 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com,
        Peng Tao <peng_tao@emc.com>
Subject: [PATCH RFC 4/4] pnfsblock: do ask for layout in pg_init
Date: Sat, 19 Nov 2011 08:53:16 -0800
Message-Id: <1321721596-3293-5-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1321721596-3293-1-git-send-email-bergwolf@gmail.com>
References: <1321721596-3293-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Asking for layout in pg_init will always make client ask for only 4KB
layout in every layoutget. This way, client drops the IO size information
that is meaningful for MDS in handing out layout.

In stead, if layout is not find in cache, do not send layoutget
at once. Wait until before issuing IO in pnfs_do_multiple_reads/writes
because that is where we know the real size of current IO. By telling the
real IO size to MDS, MDS will have a better chance to give proper layout.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   54 ++++++++++++++++++++++++++++++++++++-
 1 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 48cfac3..fd585fe 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -39,6 +39,7 @@
 #include <linux/prefetch.h>
 
 #include "blocklayout.h"
+#include "../internal.h"
 
 #define NFSDBG_FACILITY	NFSDBG_PNFS_LD
 
@@ -990,14 +991,63 @@ bl_clear_layoutdriver(struct nfs_server *server)
 	return 0;
 }
 
+/* While RFC doesn't limit maximum size of layout, we better limit ourself. */
+#define PNFSBLK_MAXRSIZE (0x1<<22)
+#define PNFSBLK_MAXWSIZE (0x1<<21)
+static void
+bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	struct inode *ino = pgio->pg_inode;
+	struct pnfs_layout_hdr *lo;
+
+	BUG_ON(pgio->pg_lseg != NULL);
+	spin_lock(&ino->i_lock);
+	lo = pnfs_find_alloc_layout(ino, req->wb_context, GFP_KERNEL);
+	if (!lo || test_bit(lo_fail_bit(IOMODE_READ), &lo->plh_flags)) {
+		spin_unlock(&ino->i_lock);
+		nfs_pageio_reset_read_mds(pgio);
+		return;
+	}
+
+	pgio->pg_bsize = PNFSBLK_MAXRSIZE;
+	pgio->pg_lseg = pnfs_find_get_layout_locked(ino,
+						req_offset(req),
+						req->wb_bytes,
+						IOMODE_READ);
+	spin_unlock(&ino->i_lock);
+}
+
+static void
+bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	struct inode *ino = pgio->pg_inode;
+	struct pnfs_layout_hdr *lo;
+
+	BUG_ON(pgio->pg_lseg != NULL);
+	spin_lock(&ino->i_lock);
+	lo = pnfs_find_alloc_layout(ino, req->wb_context, GFP_NOFS);
+	if (!lo || test_bit(lo_fail_bit(IOMODE_RW), &lo->plh_flags)) {
+		spin_unlock(&ino->i_lock);
+		nfs_pageio_reset_write_mds(pgio);
+		return;
+	}
+
+	pgio->pg_bsize = PNFSBLK_MAXWSIZE;
+	pgio->pg_lseg = pnfs_find_get_layout_locked(ino,
+						req_offset(req),
+						req->wb_bytes,
+						IOMODE_RW);
+	spin_unlock(&ino->i_lock);
+}
+
 static const struct nfs_pageio_ops bl_pg_read_ops = {
-	.pg_init = pnfs_generic_pg_init_read,
+	.pg_init = bl_pg_init_read,
 	.pg_test = pnfs_generic_pg_test,
 	.pg_doio = pnfs_generic_pg_readpages,
 };
 
 static const struct nfs_pageio_ops bl_pg_write_ops = {
-	.pg_init = pnfs_generic_pg_init_write,
+	.pg_init = bl_pg_init_write,
 	.pg_test = pnfs_generic_pg_test,
 	.pg_doio = pnfs_generic_pg_writepages,
 };
-- 
1.7.1.262.g5ef3d

