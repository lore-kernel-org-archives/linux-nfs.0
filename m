Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f67.google.com ([209.85.166.67]:41678 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726128AbeIUB51 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Sep 2018 21:57:27 -0400
Received: by mail-io1-f67.google.com with SMTP id q4-v6so9466119iob.8
        for <linux-nfs@vger.kernel.org>; Thu, 20 Sep 2018 13:12:16 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Cc: Anna.Schumaker@Netapp.com
Subject: [PATCH] NFSv4: Split out NFS v4.2 copy completion functions
Date: Thu, 20 Sep 2018 16:12:13 -0400
Message-Id: <20180920201213.31267-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

The convention in the rest of the code is to have a separate function
for anything that might be ifdef-ed out.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4state.c | 41 ++++++++++++++++++++++++++---------------
 1 file changed, 26 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 91fd4049cafc..62ae0fd345ad 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1549,6 +1549,31 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 	return status;
 }
 
+#ifdef CONFIG_NFS_V4_2
+static void nfs42_complete_copies(struct nfs4_state_owner *sp, struct nfs4_state *state)
+{
+	struct nfs4_copy_state *copy;
+
+	if (!test_bit(NFS_CLNT_DST_SSC_COPY_STATE, &state->flags))
+		return;
+
+	spin_lock(&sp->so_server->nfs_client->cl_lock);
+	list_for_each_entry(copy, &sp->so_server->ss_copies, copies) {
+		if (nfs4_stateid_match_other(&state->stateid, &copy->parent_state->stateid))
+			continue;
+		copy->flags = 1;
+		complete(&copy->completion);
+		break;
+	}
+	spin_unlock(&sp->so_server->nfs_client->cl_lock);
+}
+#else /* !CONFIG_NFS_V4_2 */
+static inline void nfs42_complete_copies(struct nfs4_state_owner *sp,
+					 struct nfs4_state *state)
+{
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static int __nfs4_reclaim_open_state(struct nfs4_state_owner *sp, struct nfs4_state *state,
 				     const struct nfs4_state_recovery_ops *ops)
 {
@@ -1572,21 +1597,7 @@ static int __nfs4_reclaim_open_state(struct nfs4_state_owner *sp, struct nfs4_st
 		spin_unlock(&state->state_lock);
 	}
 
-#ifdef CONFIG_NFS_V4_2
-	if (test_bit(NFS_CLNT_DST_SSC_COPY_STATE, &state->flags)) {
-		struct nfs4_copy_state *copy;
-		spin_lock(&sp->so_server->nfs_client->cl_lock);
-		list_for_each_entry(copy, &sp->so_server->ss_copies, copies) {
-			if (nfs4_stateid_match_other(&state->stateid, &copy->parent_state->stateid))
-				continue;
-			copy->flags = 1;
-			complete(&copy->completion);
-			break;
-		}
-		spin_unlock(&sp->so_server->nfs_client->cl_lock);
-	}
-#endif /* CONFIG_NFS_V4_2 */
-
+	nfs42_complete_copies(sp, state);
 	clear_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags);
 	return status;
 }
-- 
2.19.0
