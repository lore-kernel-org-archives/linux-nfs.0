Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:36490 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbbG0LAK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 07:00:10 -0400
Received: by qges31 with SMTP id s31so1660290qge.3
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2015 04:00:09 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: hold state_lock when updating open stateid
Date: Mon, 27 Jul 2015 06:59:49 -0400
Message-Id: <1437994789-14133-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we check to see if an open stateid needs updating, and then
update the stateid if so. The check and update however are not atomic,
so it's easily possible to end up finding an old seqid when we check
it only to have it updated by a newer one before we can get around to
updating it ourselves.

We could try to play games with atomic ops here, but the simple fix
is to just ensure that we hold the per-stateid state_lock when
updating an open stateid.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4proc.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 780accb962dd..bc6a7b5d81aa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1234,14 +1234,17 @@ static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
 	if (stateid == NULL)
 		return;
 	/* Handle races with OPEN */
+	spin_lock(&state->state_lock);
 	if (!nfs4_stateid_match_other(stateid, &state->open_stateid) ||
 	    !nfs4_stateid_is_newer(stateid, &state->open_stateid)) {
 		nfs_resync_open_stateid_locked(state);
+		spin_unlock(&state->state_lock);
 		return;
 	}
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
+	spin_unlock(&state->state_lock);
 }
 
 static void nfs_clear_open_stateid(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
@@ -1265,11 +1268,13 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *
 		case FMODE_READ|FMODE_WRITE:
 			set_bit(NFS_O_RDWR_STATE, &state->flags);
 	}
-	if (!nfs_need_update_open_stateid(state, stateid))
-		return;
-	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
-		nfs4_stateid_copy(&state->stateid, stateid);
-	nfs4_stateid_copy(&state->open_stateid, stateid);
+	spin_lock(&state->state_lock);
+	if (nfs_need_update_open_stateid(state, stateid)) {
+		if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
+			nfs4_stateid_copy(&state->stateid, stateid);
+		nfs4_stateid_copy(&state->open_stateid, stateid);
+	}
+	spin_unlock(&state->state_lock);
 }
 
 static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, const nfs4_stateid *deleg_stateid, fmode_t fmode)
-- 
2.4.3

