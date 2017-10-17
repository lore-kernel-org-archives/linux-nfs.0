Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35828 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932493AbdJQOqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 10:46:16 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFSv4: Move nfs_set_open_stateid_locked into update_open_stateid()
Date: Tue, 17 Oct 2017 10:46:14 -0400
Message-Id: <6c23817e219e5b4fe3761dfefffbb046ad295159.1508248965.git.bcodding@redhat.com>
In-Reply-To: <cover.1508248965.git.bcodding@redhat.com>
References: <cover.1508248965.git.bcodding@redhat.com>
In-Reply-To: <cover.1508248965.git.bcodding@redhat.com>
References: <cover.1508248965.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_set_open_stateid_locked() has only a singler caller and can be
open-coded within update_open_stateid().  This prepares
update_open_stateid() to be able to report if the state's stateid needed an
update.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c | 37 +++++++++++++++----------------------
 1 file changed, 15 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7e0ae74ceb4f..40e431ea1bdc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1419,27 +1419,6 @@ static void nfs_clear_open_stateid(struct nfs4_state *state,
 		nfs4_schedule_state_manager(state->owner->so_server->nfs_client);
 }
 
-static void nfs_set_open_stateid_locked(struct nfs4_state *state,
-		const nfs4_stateid *stateid, fmode_t fmode,
-		nfs4_stateid *freeme)
-{
-	switch (fmode) {
-		case FMODE_READ:
-			set_bit(NFS_O_RDONLY_STATE, &state->flags);
-			break;
-		case FMODE_WRITE:
-			set_bit(NFS_O_WRONLY_STATE, &state->flags);
-			break;
-		case FMODE_READ|FMODE_WRITE:
-			set_bit(NFS_O_RDWR_STATE, &state->flags);
-	}
-	if (!nfs_need_update_open_stateid(state, stateid, freeme))
-		return;
-	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
-		nfs4_stateid_copy(&state->stateid, stateid);
-	nfs4_stateid_copy(&state->open_stateid, stateid);
-}
-
 static int update_open_stateid(struct nfs4_state *state,
 		const nfs4_stateid *open_stateid,
 		const nfs4_stateid *delegation,
@@ -1490,7 +1469,21 @@ static int update_open_stateid(struct nfs4_state *state,
 	}
 
 	if (open_stateid) {
-		nfs_set_open_stateid_locked(state, open_stateid, fmode, &freeme);
+		switch (fmode) {
+			case FMODE_READ:
+				set_bit(NFS_O_RDONLY_STATE, &state->flags);
+				break;
+			case FMODE_WRITE:
+				set_bit(NFS_O_WRONLY_STATE, &state->flags);
+				break;
+			case FMODE_READ|FMODE_WRITE:
+				set_bit(NFS_O_RDWR_STATE, &state->flags);
+		}
+		if (nfs_need_update_open_stateid(state, open_stateid, &freeme)) {
+			if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
+				nfs4_stateid_copy(&state->stateid, open_stateid);
+			nfs4_stateid_copy(&state->open_stateid, open_stateid);
+		}
 		ret = 1;
 	}
 
-- 
2.9.3

