Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33789 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422869AbdD0UkD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Apr 2017 16:40:03 -0400
Received: by mail-io0-f195.google.com with SMTP id k87so6210690ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 27 Apr 2017 13:40:03 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: Ensure we check layout validity before marking it for return
Date: Thu, 27 Apr 2017 16:39:59 -0400
Message-Id: <20170427203959.27610-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_error_mark_layout_for_return needs to check that the layout is
valid before calling pnfs_set_plh_return_info().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d423faaba8e3..c284dc5dc72f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2170,6 +2170,10 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 	bool return_now = false;
 
 	spin_lock(&inode->i_lock);
+	if (!pnfs_layout_is_valid(lo)) {
+		spin_unlock(&inode->i_lock);
+		return;
+	}
 	pnfs_set_plh_return_info(lo, range.iomode, 0);
 	/* Block LAYOUTGET */
 	set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
-- 
2.9.3

