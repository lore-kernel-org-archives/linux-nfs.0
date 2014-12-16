Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f169.google.com ([209.85.192.169]:53733 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbaLPTCn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:43 -0500
Received: by mail-pd0-f169.google.com with SMTP id z10so14514229pdj.28
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:43 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 20/50] nfs41: close a small race window when adding new layout to global list
Date: Tue, 16 Dec 2014 11:01:23 -0800
Message-Id: <1418756513-95187-21-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
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

