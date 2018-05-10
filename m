Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:38288 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751764AbeEJT3V (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 15:29:21 -0400
Received: by mail-it0-f65.google.com with SMTP id q4-v6so4521823ite.3
        for <linux-nfs@vger.kernel.org>; Thu, 10 May 2018 12:29:21 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i12-v6sm713921iod.85.2018.05.10.12.29.19
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 May 2018 12:29:19 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS: Optimise away the close-to-open GETATTR when we have NFSv4 OPEN
Date: Thu, 10 May 2018 15:28:56 -0400
Message-Id: <20180510192858.18539-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 should not need to perform an extra close-to-open GETATTR as part
of the process of looking up a regular file, since the OPEN call will
do that for us.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 73f8b43d988c..4a73bd8b4517 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1012,13 +1012,25 @@ int nfs_lookup_verify_inode(struct inode *inode, unsigned int flags)
 
 	if (IS_AUTOMOUNT(inode))
 		return 0;
+
+	if (flags & LOOKUP_OPEN) {
+		switch (inode->i_mode & S_IFMT) {
+		case S_IFREG:
+			/* A NFSv4 OPEN will revalidate later */
+			if (server->caps & NFS_CAP_ATOMIC_OPEN)
+				goto out;
+			/* Fallthrough */
+		case S_IFDIR:
+			if (server->flags & NFS_MOUNT_NOCTO)
+				break;
+			/* NFS close-to-open cache consistency validation */
+			goto out_force;
+		}
+	}
+
 	/* VFS wants an on-the-wire revalidation */
 	if (flags & LOOKUP_REVAL)
 		goto out_force;
-	/* This is an open(2) */
-	if ((flags & LOOKUP_OPEN) && !(server->flags & NFS_MOUNT_NOCTO) &&
-	    (S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)))
-		goto out_force;
 out:
 	return (inode->i_nlink == 0) ? -ENOENT : 0;
 out_force:
-- 
2.17.0

