Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25983 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754128Ab2DET0j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Apr 2012 15:26:39 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/1] NFS: check for req==NULL in nfs_try_to_update_request cleanup
Date: Thu,  5 Apr 2012 15:26:36 -0400
Message-Id: <1333653996-4951-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2c68818..9b8d4d4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -682,7 +682,8 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		req->wb_bytes = rqend - req->wb_offset;
 out_unlock:
 	spin_unlock(&inode->i_lock);
-	nfs_clear_request_commit(req);
+	if (req)
+		nfs_clear_request_commit(req);
 	return req;
 out_flushme:
 	spin_unlock(&inode->i_lock);
-- 
1.7.2.1

