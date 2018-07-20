Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36697 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728110AbeGTVRV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jul 2018 17:17:21 -0400
Received: by mail-it0-f68.google.com with SMTP id j185-v6so16210099ite.1
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jul 2018 13:27:29 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Olga Kornievskaia <aglo@umich.edu>
Subject: [PATCH] NFS: Fix excessive attribute revalidation in nfs_execute_ok()
Date: Fri, 20 Jul 2018 16:27:06 -0400
Message-Id: <20180720202706.7883-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When nfs_update_inode() sets NFS_INO_INVALID_ACCESS it is a sign that
we want to revalidate the access cache, not the inode attributes.
In fact we only want to revalidate here if we see that the mode bits
are invalid, so check for NFS_INO_INVALID_OTHER instead.

Reported-by: Olga Kornievskaia <aglo@umich.edu>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8f8e9e9f2a79..e7bc68fcbdf4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2500,7 +2500,7 @@ static int nfs_execute_ok(struct inode *inode, int mask)
 	struct nfs_server *server = NFS_SERVER(inode);
 	int ret = 0;
 
-	if (nfs_check_cache_invalid(inode, NFS_INO_INVALID_ACCESS)) {
+	if (nfs_check_cache_invalid(inode, NFS_INO_INVALID_OTHER)) {
 		if (mask & MAY_NOT_BLOCK)
 			return -ECHILD;
 		ret = __nfs_revalidate_inode(server, inode);
-- 
2.17.1

