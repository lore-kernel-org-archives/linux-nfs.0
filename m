Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30151 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756932Ab2EITSx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 15:18:53 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 5/5] NFS: Clean up - Simplify reference counting in fs/nfs/direct.c
Date: Wed,  9 May 2012 15:18:43 -0400
Message-Id: <1336591123-23400-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1336591123-23400-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1336591123-23400-1-git-send-email-Trond.Myklebust@netapp.com>
 <1336591123-23400-2-git-send-email-Trond.Myklebust@netapp.com>
 <1336591123-23400-3-git-send-email-Trond.Myklebust@netapp.com>
 <1336591123-23400-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 845e201..c47a46e 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -486,10 +486,8 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	}
 	nfs_pageio_complete(&desc);
 
-	while (!list_empty(&failed)) {
-		nfs_release_request(req);
+	while (!list_empty(&failed))
 		nfs_unlock_and_release_request(req);
-	}
 
 	if (put_dreq(dreq))
 		nfs_direct_write_complete(dreq, dreq->inode);
@@ -518,9 +516,9 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 		nfs_list_remove_request(req);
 		if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES) {
 			/* Note the rewrite will go through mds */
+			kref_get(&req->wb_kref);
 			nfs_mark_request_commit(req, NULL, &cinfo);
-		} else
-			nfs_release_request(req);
+		}
 		nfs_unlock_and_release_request(req);
 	}
 
@@ -657,13 +655,11 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 				break;
 			}
 			nfs_lock_request(req);
-			kref_get(&req->wb_kref);
 			req->wb_index = pos >> PAGE_SHIFT;
 			req->wb_offset = pos & ~PAGE_MASK;
 			if (!nfs_pageio_add_request(desc, req)) {
 				result = desc->pg_error;
 				nfs_unlock_and_release_request(req);
-				nfs_release_request(req);
 				break;
 			}
 			pgbase = 0;
@@ -734,10 +730,8 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 		switch (bit) {
 		case NFS_IOHDR_NEED_RESCHED:
 		case NFS_IOHDR_NEED_COMMIT:
+			kref_get(&req->wb_kref);
 			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
-			break;
-		default:
-			nfs_release_request(req);
 		}
 		nfs_unlock_and_release_request(req);
 	}
@@ -755,7 +749,6 @@ static void nfs_write_sync_pgio_error(struct list_head *head)
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		nfs_release_request(req);
 		nfs_unlock_and_release_request(req);
 	}
 }
-- 
1.7.7.6

