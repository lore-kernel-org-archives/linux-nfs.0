Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8246 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932864Ab2JCAS0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 20:18:26 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4.1: Fix another refcount issue in pnfs_find_alloc_layout
Date: Tue,  2 Oct 2012 17:18:21 -0700
Message-Id: <1349223505-59248-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d737557..fe9968a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -907,18 +907,19 @@ pnfs_find_alloc_layout(struct inode *ino,
 
 	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
 
-	if (nfsi->layout) {
-		pnfs_get_layout_hdr(nfsi->layout);
-		return nfsi->layout;
-	}
+	if (nfsi->layout != NULL)
+		goto out_existing;
 	spin_unlock(&ino->i_lock);
 	new = alloc_init_layout_hdr(ino, ctx, gfp_flags);
 	spin_lock(&ino->i_lock);
 
-	if (likely(nfsi->layout == NULL))	/* Won the race? */
+	if (likely(nfsi->layout == NULL)) {	/* Won the race? */
 		nfsi->layout = new;
-	else
-		pnfs_free_layout_hdr(new);
+		return new;
+	}
+	pnfs_free_layout_hdr(new);
+out_existing:
+	pnfs_get_layout_hdr(nfsi->layout);
 	return nfsi->layout;
 }
 
-- 
1.7.11.4

