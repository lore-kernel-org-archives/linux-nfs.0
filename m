Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:58984 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592Ab0L1RDP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Dec 2010 12:03:15 -0500
From: Namhyung Kim <namhyung@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: use ERR_CAST()
Date: Wed, 29 Dec 2010 02:02:46 +0900
Message-Id: <1293555766-14333-1-git-send-email-namhyung@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Use ERR_CAST() intead of wierd-looking cast.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 fs/nfs/dir.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 996dd8989a91..fece122cdd65 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1217,7 +1217,7 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 		goto out_unblock_sillyrename;
 	}
 	inode = nfs_fhget(dentry->d_sb, fhandle, fattr);
-	res = (struct dentry *)inode;
+	res = ERR_CAST(inode);
 	if (IS_ERR(res))
 		goto out_unblock_sillyrename;
 
-- 
1.7.3.4.600.g982838b0

