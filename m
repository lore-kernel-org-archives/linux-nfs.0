Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36238 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbcFNTFi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:05:38 -0400
Received: by mail-it0-f65.google.com with SMTP id h190so412479ith.3
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:05:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/12] NFS: Don't flush caches for a getattr that races with writeback
Date: Tue, 14 Jun 2016 15:05:04 -0400
Message-Id: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there were outstanding writes then chalk up the unexpected change
attribute on the server to them.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 52e7d6869e3b..60051e62d3f1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1729,12 +1729,15 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		if (inode->i_version != fattr->change_attr) {
 			dprintk("NFS: change_attr change on server for file %s/%ld\n",
 					inode->i_sb->s_id, inode->i_ino);
-			invalid |= NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_DATA
-				| NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL;
-			if (S_ISDIR(inode->i_mode))
-				nfs_force_lookup_revalidate(inode);
+			/* Could it be a race with writeback? */
+			if (nfsi->nrequests == 0) {
+				invalid |= NFS_INO_INVALID_ATTR
+					| NFS_INO_INVALID_DATA
+					| NFS_INO_INVALID_ACCESS
+					| NFS_INO_INVALID_ACL;
+				if (S_ISDIR(inode->i_mode))
+					nfs_force_lookup_revalidate(inode);
+			}
 			inode->i_version = fattr->change_attr;
 		}
 	} else {
-- 
2.5.5

