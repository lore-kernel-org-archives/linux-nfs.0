Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41166 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121Ab2FSXCP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jun 2012 19:02:15 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/2] NFS: Fix a refcounting issue in O_DIRECT
Date: Tue, 19 Jun 2012 19:02:08 -0400
Message-Id: <1340146929-21242-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In nfs_direct_write_reschedule(), the requests from nfs_scan_commit_list
have a refcount of 2, whereas the operations in
nfs_direct_write_completion_ops expect them to have a refcount of 1.

This patch adds a call to release the extra references.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 3168f6e..9a4cbfc 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -490,6 +490,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 			dreq->error = -EIO;
 			spin_unlock(cinfo.lock);
 		}
+		nfs_release_request(req);
 	}
 	nfs_pageio_complete(&desc);
 
-- 
1.7.10.2

