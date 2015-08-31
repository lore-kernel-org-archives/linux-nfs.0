Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34517 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbbHaJIH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Aug 2015 05:08:07 -0400
Received: by pabzx8 with SMTP id zx8so133251095pab.1
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2015 02:08:07 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] NFSv4.1/pnfs: Don't ask for a read layout for an empty file.
Date: Mon, 31 Aug 2015 02:08:03 -0700
Message-Id: <1441012085-4071-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4eec540de9ea..c4f918eca3d2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1494,6 +1494,9 @@ pnfs_update_layout(struct inode *ino,
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		goto out;
 
+	if (iomode == IOMODE_READ && i_size_read(ino) == 0)
+		goto out;
+
 	if (pnfs_within_mdsthreshold(ctx, ino, iomode))
 		goto out;
 
-- 
2.4.3

