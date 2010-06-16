From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/2] SQUASHME: pnfs-submit: destroy layout rather than return on state reclaim
Date: Wed, 16 Jun 2010 12:38:07 -0400
Message-ID: <1276706287-20123-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9831 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755881Ab0FPQiD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jun 2010 12:38:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the nograce path we already lost the state and there's no point
in returning the layout.  The sync layoutreturn apparently caused a deadlock
since layoutreturn needed the state_manager to make progress.

squash into "pnfs: return layout on state recovery"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6b266dd..c8053a6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1092,8 +1092,7 @@ static void pnfs4_layout_reclaim(struct nfs4_state *state)
 	/* FIXME: send gratuitous layout commits and return with the reclaim
 	 * flag during grace period
 	 */
-	pnfs_return_layout(state->inode, NULL, &state->open_stateid,
-			   RETURN_FILE, true);
+	pnfs_destroy_layout(NFS_I(state->inode));
 	pnfs_set_layout_stateid(&NFS_I(state->inode)->layout, &zero_stateid);
 #endif /* CONFIG_NFS_V4_1 */
 }
-- 
1.6.4.4

