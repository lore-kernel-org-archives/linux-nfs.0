Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:50956 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbbAXFjf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 00:39:35 -0500
Received: by mail-ie0-f173.google.com with SMTP id tr6so1071885ieb.4
        for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2015 21:39:34 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4: More CLOSE/OPEN races
Date: Sat, 24 Jan 2015 00:39:25 -0500
Message-Id: <1422077968-116473-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1422077968-116473-2-git-send-email-trond.myklebust@primarydata.com>
References: <1422077968-116473-1-git-send-email-trond.myklebust@primarydata.com>
 <1422077968-116473-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an OPEN RPC call races with a CLOSE or OPEN_DOWNGRADE so that it
updates the nfs_state structure before the CLOSE/OPEN_DOWNGRADE has
a chance to do so, then we know that the state->flags need to be
recalculated from scratch.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4863dec10865..a6c04a5812d0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1167,6 +1167,16 @@ static bool nfs_need_update_open_stateid(struct nfs4_state *state,
 	return false;
 }
 
+static void nfs_resync_open_stateid_locked(struct nfs4_state *state)
+{
+	if (state->n_wronly)
+		set_bit(NFS_O_WRONLY_STATE, &state->flags);
+	if (state->n_rdonly)
+		set_bit(NFS_O_RDONLY_STATE, &state->flags);
+	if (state->n_rdwr)
+		set_bit(NFS_O_RDWR_STATE, &state->flags);
+}
+
 static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
 		nfs4_stateid *stateid, fmode_t fmode)
 {
@@ -1185,8 +1195,12 @@ static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
 	}
 	if (stateid == NULL)
 		return;
-	if (!nfs_need_update_open_stateid(state, stateid))
+	/* Handle races with OPEN */
+	if (!nfs4_stateid_match_other(stateid, &state->open_stateid) ||
+	    !nfs4_stateid_is_newer(stateid, &state->open_stateid)) {
+		nfs_resync_open_stateid_locked(state);
 		return;
+	}
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
-- 
2.1.0

