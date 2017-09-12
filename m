Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:38126 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751289AbdILN1x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Sep 2017 09:27:53 -0400
Received: by mail-io0-f193.google.com with SMTP id j141so8521745ioj.5
        for <linux-nfs@vger.kernel.org>; Tue, 12 Sep 2017 06:27:52 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: Use the standard I/O stateid when calling LAYOUTGET
Date: Tue, 12 Sep 2017 09:27:48 -0400
Message-Id: <20170912132748.6403-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of having a private method for copying the open/delegation stateid,
use the same call that is used for standard I/O through the MDS.

Note that this means we transmit the stateid with a zero seqid, avoiding
issues with NFS4ERR_OLD_STATEID.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7879ed8ceb76..3bcd669a3152 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1664,7 +1664,7 @@ pnfs_update_layout(struct inode *ino,
 		.offset = pos,
 		.length = count,
 	};
-	unsigned pg_offset, seq;
+	unsigned pg_offset;
 	struct nfs_server *server = NFS_SERVER(ino);
 	struct nfs_client *clp = server->nfs_client;
 	struct pnfs_layout_hdr *lo = NULL;
@@ -1754,10 +1754,14 @@ pnfs_update_layout(struct inode *ino,
 		}
 
 		first = true;
-		do {
-			seq = read_seqbegin(&ctx->state->seqlock);
-			nfs4_stateid_copy(&stateid, &ctx->state->stateid);
-		} while (read_seqretry(&ctx->state->seqlock, seq));
+		if (nfs4_select_rw_stateid(ctx->state,
+					iomode == IOMODE_RW ? FMODE_WRITE : FMODE_READ,
+					NULL, &stateid, NULL) != 0) {
+			trace_pnfs_update_layout(ino, pos, count,
+					iomode, lo, lseg,
+					PNFS_UPDATE_LAYOUT_INVALID_OPEN);
+			goto out_unlock;
+		}
 	} else {
 		nfs4_stateid_copy(&stateid, &lo->plh_stateid);
 	}
-- 
2.13.5

