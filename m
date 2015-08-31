Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36846 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422AbbHaIcv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Aug 2015 04:32:51 -0400
Received: by pacgr6 with SMTP id gr6so2379000pac.3
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2015 01:32:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.1/pnfs: Don't ask for a read layout for an empty file.
Date: Mon, 31 Aug 2015 01:32:48 -0700
Message-Id: <1441009969-14405-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 838e865de8a5..9c32c043ab24 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1453,6 +1453,9 @@ pnfs_update_layout(struct inode *ino,
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		goto out;
 
+	if (iomode == IOMODE_READ && i_size_read(ino) == 0)
+		goto out;
+
 	if (pnfs_within_mdsthreshold(ctx, ino, iomode))
 		goto out;
 
-- 
2.4.3

