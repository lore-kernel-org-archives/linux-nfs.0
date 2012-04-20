Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28519 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757385Ab2DTSsG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:06 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 01/25] NFS: check for req==NULL in nfs_try_to_update_request cleanup
Date: Fri, 20 Apr 2012 14:47:33 -0400
Message-Id: <1334947677-28864-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
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

