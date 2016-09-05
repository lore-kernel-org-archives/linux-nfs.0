Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34238 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932294AbcIENrA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2016 09:47:00 -0400
Received: by mail-it0-f66.google.com with SMTP id e124so8909945ith.1
        for <linux-nfs@vger.kernel.org>; Mon, 05 Sep 2016 06:47:00 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] pNFS: Don't forget the layout stateid if there are outstanding LAYOUTGETs
Date: Mon,  5 Sep 2016 09:46:02 -0400
Message-Id: <1473083162-4697-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473083162-4697-4-git-send-email-trond.myklebust@primarydata.com>
References: <1473083162-4697-1-git-send-email-trond.myklebust@primarydata.com>
 <1473083162-4697-2-git-send-email-trond.myklebust@primarydata.com>
 <1473083162-4697-3-git-send-email-trond.myklebust@primarydata.com>
 <1473083162-4697-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there are outstanding LAYOUTGET rpc calls, then we want to ensure that
we keep the layout stateid around so we that don't inadvertently pick up
an old/misordered sequence id.
The race is as follows:

Client				Server
======				======
LAYOUTGET(seqid)
LAYOUTGET(seqid)
				return LAYOUTGET(seqid+1)
				return LAYOUTGET(seqid+2)
process LAYOUTGET(seqid+2)
	forget layout
process LAYOUTGET(seqid+1)

If it forgets the layout stateid before processing seqid+1, then
the client will not check the layout->plh_barrier, and so will set
the stateid with seqid+1.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cd8b5fca33f6..2c93a85eda51 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -365,7 +365,8 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
 	atomic_dec(&lo->plh_refcount);
 	if (list_empty(&lo->plh_segs)) {
-		set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+		if (atomic_read(&lo->plh_outstanding) == 0)
+			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 		clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 	}
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
-- 
2.7.4

