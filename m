Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35626 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbcGSUea (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jul 2016 16:34:30 -0400
Received: by mail-it0-f65.google.com with SMTP id f6so2157624ith.2
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jul 2016 13:34:30 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/4] pNFS: Handle NFS4ERR_RECALLCONFLICT correctly in LAYOUTGET
Date: Tue, 19 Jul 2016 16:33:56 -0400
Message-Id: <1468960437-21449-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1468960437-21449-3-git-send-email-trond.myklebust@primarydata.com>
References: <1468960437-21449-1-git-send-email-trond.myklebust@primarydata.com>
 <1468960437-21449-2-git-send-email-trond.myklebust@primarydata.com>
 <1468960437-21449-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of giving up altogether and falling back to doing I/O
through the MDS, which may make the situation worse, wait for
2 lease periods for the callback to resolve itself, and then
try destroying the existing layout.

Only if this was an attempt at getting a first layout, do we
give up altogether, as the server is clearly crazy.

Fixes: 183d9e7b112aa ("pnfs: rework LAYOUTGET retry handling")
Cc: stable@vger.kernel.org # 4.7
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/pnfs.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c50d4ebab5c5..7d992362ff04 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1505,7 +1505,7 @@ pnfs_update_layout(struct inode *ino,
 	struct pnfs_layout_segment *lseg = NULL;
 	nfs4_stateid stateid;
 	long timeout = 0;
-	unsigned long giveup = jiffies + rpc_get_timeout(server->client);
+	unsigned long giveup = jiffies + (clp->cl_lease_time << 1);
 	bool first;
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino))) {
@@ -1649,9 +1649,18 @@ lookup_again:
 	if (IS_ERR(lseg)) {
 		switch(PTR_ERR(lseg)) {
 		case -EBUSY:
-		case -ERECALLCONFLICT:
 			if (time_after(jiffies, giveup))
 				lseg = NULL;
+			break;
+		case -ERECALLCONFLICT:
+			/* Huh? We hold no layouts, how is there a recall? */
+			if (first) {
+				lseg = NULL;
+				break;
+			}
+			/* Destroy the existing layout and start over */
+			if (time_after(jiffies, giveup))
+				pnfs_destroy_layout(NFS_I(ino));
 			/* Fallthrough */
 		case -EAGAIN:
 			break;
-- 
2.7.4

