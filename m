Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37914 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934614Ab1ESVfG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2011 17:35:06 -0400
Received: by bwz15 with SMTP id 15so2472238bwz.19
        for <linux-nfs@vger.kernel.org>; Thu, 19 May 2011 14:35:05 -0700 (PDT)
From: Vitaliy Gusev <gusev.vitaliy@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: andros@netapp.com, linux-nfs@vger.kernel.org,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Subject: [PATCH] nfs41: Correct offset for LAYOUTCOMMIT v2
Date: Fri, 20 May 2011 01:34:46 +0400
Message-Id: <1305840886-18945-1-git-send-email-gusev.vitaliy@nexenta.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A client sends offset to MDS as it was seen by DS. As result,
file size after copy is only half of original file size in case
of 2 DS.

Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f57f528..101c85a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1009,7 +1009,7 @@ void
 pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 {
 	struct nfs_inode *nfsi = NFS_I(wdata->inode);
-	loff_t end_pos = wdata->args.offset + wdata->res.count;
+	loff_t end_pos = wdata->mds_offset + wdata->res.count;
 	bool mark_as_dirty = false;
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
-- 
1.7.4.1

