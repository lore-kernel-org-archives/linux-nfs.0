Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34772 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755284Ab1FOQbZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2011 12:31:25 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/1] nfs4.1: prevent race that allowed use of freed layout in _pnfs_return_layout
Date: Wed, 15 Jun 2011 12:31:02 -0400
Message-Id: <1308155462-29517-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

mark_matching_lsegs_invalid could put the last ref to the layout, so
the get_layout_hdr needs to be called first.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d25f66d..f99f068 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -646,10 +646,10 @@ _pnfs_return_layout(struct inode *ino)
 		return status;
 	}
 	stateid = nfsi->layout->plh_stateid;
-	mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
-	lo->plh_block_lgets++;
 	/* Reference matched in nfs4_layoutreturn_release */
 	get_layout_hdr(lo);
+	mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
+	lo->plh_block_lgets++;
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 
-- 
1.7.2.1

