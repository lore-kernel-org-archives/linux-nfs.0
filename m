Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11723 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754525Ab2FHUsf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jun 2012 16:48:35 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/1] NFS: fix directio refcount bug on commit
Date: Fri,  8 Jun 2012 16:48:33 -0400
Message-Id: <1339188513-23442-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts a hunk from commit 04277086577
"NFS: Clean up - Simplify reference counting in fs/nfs/direct.c"

The cleanups in that patch affect the write path, but by the time
processing hits commit the removed reference has been added back by
nfs_scan_commit_list().  Without this reversion, any page that is
sent to commit holds on to an unbalanced reference that is never
freed.  The immediate effect is an imbalance over the wire between
OPENs and CLOSEs.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 4c300f9..3168f6e 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -523,9 +523,9 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 		nfs_list_remove_request(req);
 		if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES) {
 			/* Note the rewrite will go through mds */
-			kref_get(&req->wb_kref);
 			nfs_mark_request_commit(req, NULL, &cinfo);
-		}
+		} else
+			nfs_release_request(req);
 		nfs_unlock_and_release_request(req);
 	}
 
-- 
1.7.2.1

