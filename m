Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60596 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290AbbAVXhR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:37:17 -0500
Received: by mail-pa0-f47.google.com with SMTP id lj1so4863213pab.6
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:37:17 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 20/51] nfs41: close a small race window when adding new layout to global list
Date: Thu, 22 Jan 2015 15:35:52 -0800
Message-Id: <1421969783-92997-21-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/pnfs.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2d25670..fa00b56 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1288,7 +1288,6 @@ pnfs_update_layout(struct inode *ino,
 	struct nfs_client *clp = server->nfs_client;
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg = NULL;
-	bool first;
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		goto out;
@@ -1321,16 +1320,15 @@ pnfs_update_layout(struct inode *ino,
 	if (pnfs_layoutgets_blocked(lo, 0))
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
-
-	first = list_empty(&lo->plh_layouts) ? true : false;
 	spin_unlock(&ino->i_lock);
 
-	if (first) {
+	if (list_empty(&lo->plh_layouts)) {
 		/* The lo must be on the clp list if there is any
 		 * chance of a CB_LAYOUTRECALL(FILE) coming in.
 		 */
 		spin_lock(&clp->cl_lock);
-		list_add_tail(&lo->plh_layouts, &server->layouts);
+		if (list_empty(&lo->plh_layouts))
+			list_add_tail(&lo->plh_layouts, &server->layouts);
 		spin_unlock(&clp->cl_lock);
 	}
 
-- 
1.9.3

