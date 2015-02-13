Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f176.google.com ([209.85.192.176]:45000 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378AbbBMVUH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Feb 2015 16:20:07 -0500
Received: by pdbnh10 with SMTP id nh10so17576173pdb.11
        for <linux-nfs@vger.kernel.org>; Fri, 13 Feb 2015 13:20:06 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 2/2] nfs: Can call nfs_clear_page_commit() instead
Date: Fri, 13 Feb 2015 13:19:54 -0800
Message-Id: <1423862394-74977-3-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1423862394-74977-1-git-send-email-loghyr@primarydata.com>
References: <1423862394-74977-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/write.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 76c278a..595d81e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1600,11 +1600,8 @@ void nfs_retry_commit(struct list_head *page_list,
 		req = nfs_list_entry(page_list->next);
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req, lseg, cinfo, ds_commit_idx);
-		if (!cinfo->dreq) {
-			dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-			dec_bdi_stat(inode_to_bdi(page_file_mapping(req->wb_page)->host),
-				     BDI_RECLAIMABLE);
-		}
+		if (!cinfo->dreq)
+			nfs_clear_page_commit(req->wb_page);
 		nfs_unlock_and_release_request(req);
 	}
 }
-- 
1.9.3

