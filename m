Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36478 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751087AbdEIU2x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 16:28:53 -0400
Received: by mail-io0-f194.google.com with SMTP id f102so197532ioi.3
        for <linux-nfs@vger.kernel.org>; Tue, 09 May 2017 13:28:53 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: Always attempt to call layoutstats when flexfiles is enabled
Date: Tue,  9 May 2017 16:28:50 -0400
Message-Id: <20170509202850.117701-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Layoutstats is always desirable when using the flexfiles driver, so
we should enable it if that driver is being loaded. It is safe to do
so, because even when the mount specifies NFSv4.1, we will turn it
off if the server tells us it is unsupported.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 4e8bf02a62f9..f5714ee01000 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2361,10 +2361,21 @@ ff_layout_prepare_layoutstats(struct nfs42_layoutstat_args *args)
 	return 0;
 }
 
+static int
+ff_layout_set_layoutdriver(struct nfs_server *server,
+		const struct nfs_fh *dummy)
+{
+#if IS_ENABLED(CONFIG_NFS_V4_2)
+	server->caps |= NFS_CAP_LAYOUTSTATS;
+#endif
+	return 0;
+}
+
 static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.id			= LAYOUT_FLEX_FILES,
 	.name			= "LAYOUT_FLEX_FILES",
 	.owner			= THIS_MODULE,
+	.set_layoutdriver	= ff_layout_set_layoutdriver,
 	.alloc_layout_hdr	= ff_layout_alloc_layout_hdr,
 	.free_layout_hdr	= ff_layout_free_layout_hdr,
 	.alloc_lseg		= ff_layout_alloc_lseg,
-- 
2.9.3

