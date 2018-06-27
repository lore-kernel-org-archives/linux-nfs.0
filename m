Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:39262 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965026AbeF0UxY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jun 2018 16:53:24 -0400
Received: by mail-it0-f67.google.com with SMTP id p185-v6so9376096itp.4
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jun 2018 13:53:24 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([50.105.87.45])
        by smtp.gmail.com with ESMTPSA id 16-v6sm2201887itv.19.2018.06.27.13.53.22
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Jun 2018 13:53:22 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Allow optimisation of lseek(fd, SEEK_CUR, 0) on directories
Date: Wed, 27 Jun 2018 16:53:01 -0400
Message-Id: <20180627205301.31401-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There should be no need to grab the inode lock if we're only reading
the file offset.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 7a9c14426855..8f8e9e9f2a79 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -904,23 +904,29 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int whence)
 	dfprintk(FILE, "NFS: llseek dir(%pD2, %lld, %d)\n",
 			filp, offset, whence);
 
-	inode_lock(inode);
 	switch (whence) {
-		case 1:
-			offset += filp->f_pos;
-		case 0:
-			if (offset >= 0)
-				break;
-		default:
-			offset = -EINVAL;
-			goto out;
+	default:
+		return -EINVAL;
+	case SEEK_SET:
+		if (offset < 0)
+			return -EINVAL;
+		inode_lock(inode);
+		break;
+	case SEEK_CUR:
+		if (offset == 0)
+			return filp->f_pos;
+		inode_lock(inode);
+		offset += filp->f_pos;
+		if (offset < 0) {
+			inode_unlock(inode);
+			return -EINVAL;
+		}
 	}
 	if (offset != filp->f_pos) {
 		filp->f_pos = offset;
 		dir_ctx->dir_cookie = 0;
 		dir_ctx->duped = 0;
 	}
-out:
 	inode_unlock(inode);
 	return offset;
 }
-- 
2.17.1

