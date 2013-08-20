Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36912 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751289Ab3HTRNp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Aug 2013 13:13:45 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: Remove the NFSv4 "open optimisation" from nfs_permission
Date: Tue, 20 Aug 2013 13:13:41 -0400
Message-ID: <1377018821-18925-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ever since commit 6168f62cb (Add ACCESS operation to OPEN compound)
the NFSv4 atomic open has primed the access cache, and so nfs_permission
will no longer do an RPC call on the wire.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 39e69d4..5d737bd 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2245,11 +2245,6 @@ int nfs_permission(struct inode *inode, int mask)
 		case S_IFLNK:
 			goto out;
 		case S_IFREG:
-			/* NFSv4 has atomic_open... */
-			if (nfs_server_capable(inode, NFS_CAP_ATOMIC_OPEN)
-					&& (mask & MAY_OPEN)
-					&& !(mask & MAY_EXEC))
-				goto out;
 			break;
 		case S_IFDIR:
 			/*
-- 
1.8.3.1

