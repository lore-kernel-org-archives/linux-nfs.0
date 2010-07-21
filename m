From: andros@netapp.com
Subject: [PATCH 1/2] SQUASHME pnfs-submit remove pnfs4_layout_reclaim
Date: Wed, 21 Jul 2010 10:43:35 -0400
Message-ID: <1279723416-4467-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60914 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758326Ab0GUOoN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 10:44:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Not used. Destroy all layouts on lease expiration instead.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   13 -------------
 1 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fd6438d..05f072c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1094,17 +1094,6 @@ static struct nfs_open_context *nfs4_state_find_open_context(struct nfs4_state *
 	return ERR_PTR(-ENOENT);
 }
 
-static void pnfs4_layout_reclaim(struct nfs4_state *state)
-{
-#if defined(CONFIG_NFS_V4_1)
-	/* FIXME: send gratuitous layout commits and return with the reclaim
-	 * flag during grace period
-	 */
-	pnfs_destroy_layout(NFS_I(state->inode));
-	pnfs_set_layout_stateid(NFS_I(state->inode)->layout, &zero_stateid);
-#endif /* CONFIG_NFS_V4_1 */
-}
-
 static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context *ctx, struct nfs4_state *state)
 {
 	struct nfs4_opendata *opendata;
@@ -1181,7 +1170,6 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
 			       sizeof(state->stateid.u.data));
 		write_sequnlock(&state->seqlock);
 	}
-	pnfs4_layout_reclaim(state);
 	return 0;
 }
 
@@ -1236,7 +1224,6 @@ static int nfs4_open_reclaim(struct nfs4_state_owner *sp, struct nfs4_state *sta
 		return PTR_ERR(ctx);
 	ret = nfs4_do_open_reclaim(ctx, state);
 	put_nfs_open_context(ctx);
-	pnfs4_layout_reclaim(state);
 	return ret;
 }
 
-- 
1.6.6

