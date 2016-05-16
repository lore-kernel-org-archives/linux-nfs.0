Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35425 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183AbcEPSln (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2016 14:41:43 -0400
Received: by mail-qg0-f42.google.com with SMTP id f74so93783959qge.2
        for <linux-nfs@vger.kernel.org>; Mon, 16 May 2016 11:41:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: Fix a leaked layoutstats flag
Date: Mon, 16 May 2016 14:41:14 -0400
Message-Id: <1463424074-56665-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 89a5ef4df08a..d48e23b76594 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2405,7 +2405,7 @@ pnfs_report_layoutstat(struct inode *inode, gfp_t gfp_flags)
 	spin_lock(&inode->i_lock);
 	if (!NFS_I(inode)->layout) {
 		spin_unlock(&inode->i_lock);
-		goto out;
+		goto out_clear_layoutstats;
 	}
 	hdr = NFS_I(inode)->layout;
 	pnfs_get_layout_hdr(hdr);
@@ -2434,6 +2434,7 @@ out_free:
 	kfree(data);
 out_put:
 	pnfs_put_layout_hdr(hdr);
+out_clear_layoutstats:
 	smp_mb__before_atomic();
 	clear_bit(NFS_INO_LAYOUTSTATS, &nfsi->flags);
 	smp_mb__after_atomic();
-- 
2.5.5

