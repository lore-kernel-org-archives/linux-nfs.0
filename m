Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62895 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754632Ab2CVFj6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 01:39:58 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/2] NFS4.1: remove duplicate variable declaration in filelayout_clear_request_commit
Date: Thu, 22 Mar 2012 01:39:34 -0400
Message-Id: <1332394775-31783-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

inode is declared twice for no good reason

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 35569af..a8623bb 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -793,7 +793,6 @@ filelayout_clear_request_commit(struct nfs_page *req)
 	if (!test_and_clear_bit(PG_COMMIT_TO_DS, &req->wb_flags))
 		goto out;
 	if (list_is_singular(&req->wb_list)) {
-		struct inode *inode = req->wb_context->dentry->d_inode;
 		struct pnfs_layout_segment *lseg;
 
 		/* From here we can find the bucket, but for the moment,
-- 
1.7.2.1

