Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:58418 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751501Ab3JURKW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 13:10:22 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 4/5] NFSv4: don't reprocess cached open CLAIM_PREVIOUS
Date: Mon, 21 Oct 2013 13:10:13 -0400
Message-ID: <1382375414-5854-5-git-send-email-dros@netapp.com>
In-Reply-To: <1382375414-5854-1-git-send-email-dros@netapp.com>
References: <1382375414-5854-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cached opens have already been handled by _nfs4_opendata_reclaim_to_nfs4_state
and can safely skip being reprocessed, but must still call update_open_stateid
to make sure that all active fmodes are recovered.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8ae1589..a3b78df 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1315,12 +1315,15 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 {
 	struct inode *inode = data->state->inode;
 	struct nfs4_state *state = data->state;
+	bool cached_open = false;
 	int ret;
 
-	/* allow cached opens (!rpc_done && !rpc_status) */
-	if (!data->rpc_done && data->rpc_status) {
-		ret = data->rpc_status;
-		goto err;
+	if (!data->rpc_done) {
+		if (data->rpc_status) {
+			ret = data->rpc_status;
+			goto err;
+		} else
+			cached_open = true;
 	}
 
 	/* referenced the passed state */
@@ -1328,6 +1331,10 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 	if (state == NULL || !atomic_inc_not_zero(&state->count))
 		goto err;
 
+	/* cached opens have already been processed */
+	if (cached_open)
+		goto update;
+
 	ret = nfs_refresh_inode(inode, &data->f_attr);
 	if (ret)
 		goto err_put;
@@ -1336,6 +1343,8 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 
 	if (data->o_res.delegation_type != 0)
 		nfs4_opendata_check_deleg(data, state);
+
+update:
 	update_open_stateid(state, &data->o_res.stateid, NULL,
 			    data->o_arg.fmode);
 
-- 
1.7.12.4 (Apple Git-37)

