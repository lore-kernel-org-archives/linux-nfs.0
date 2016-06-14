Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36048 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbcFNUIb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 16:08:31 -0400
Received: by mail-it0-f66.google.com with SMTP id h190so607868ith.3
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 13:08:31 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1/pnfs: Mark the layout stateid invalid when all segments are removed
Date: Tue, 14 Jun 2016 16:08:02 -0400
Message-Id: <1465934882-35976-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to RFC5661, section 12.5.3. the layout stateid is no longer
valid once the client no longer holds any layout segments. Ensure that
we mark it invalid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ca488b52cbfb..0fbe734cc38c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -361,8 +361,10 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	list_del_init(&lseg->pls_list);
 	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
 	atomic_dec(&lo->plh_refcount);
-	if (list_empty(&lo->plh_segs))
+	if (list_empty(&lo->plh_segs)) {
+		set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 		clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
+	}
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
-- 
2.5.5

