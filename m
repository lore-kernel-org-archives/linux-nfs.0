Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31117 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030562Ab2CTQZu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Mar 2012 12:25:50 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/2] NFS4.1: filelayout_commit_pagelist needs to pass back error
Date: Tue, 20 Mar 2012 12:25:45 -0400
Message-Id: <1332260746-8351-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It was reporting success even if it did nothing.

Note this is still not right.  Caller nfs_commit_unstable_pages
assumes this is all or none, and count is going to be off.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e0bdbf4..08625a8 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -1027,6 +1027,7 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 	struct nfs_write_data	*data, *tmp;
 	LIST_HEAD(list);
 	unsigned int nreq = 0;
+	int status = PNFS_ATTEMPTED;
 
 	if (!list_empty(mds_pages)) {
 		data = nfs_commitdata_alloc();
@@ -1042,6 +1043,7 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 
 	if (nreq == 0) {
 		nfs_commit_clear_lock(NFS_I(inode));
+		status = -ENOMEM;
 		goto out;
 	}
 
@@ -1059,7 +1061,7 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 		}
 	}
 out:
-	return PNFS_ATTEMPTED;
+	return status;
 }
 
 static void
-- 
1.7.2.1

