Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52412 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936049AbdJQOqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 10:46:16 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4.1: Detect and retry after OPEN and CLOSE/DOWNGRADE race
Date: Tue, 17 Oct 2017 10:46:15 -0400
Message-Id: <fb76d86caca02c277eea7cb1d469c209b59d06ab.1508248965.git.bcodding@redhat.com>
In-Reply-To: <cover.1508248965.git.bcodding@redhat.com>
References: <cover.1508248965.git.bcodding@redhat.com>
In-Reply-To: <cover.1508248965.git.bcodding@redhat.com>
References: <cover.1508248965.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client issues two simultaneous OPEN calls, and the response to the
first OPEN call (sequence id 1) is delayed before updating the nfs4_state,
then the client's nfs4_state can transition through a complete lifecycle of
OPEN (state sequence id 2), and CLOSE (state sequence id 3).  When the
first OPEN is finally processed, the nfs4_state is incorrectly transitioned
back to NFS_OPEN_STATE for the first OPEN (sequence id 1).  Subsequent calls
to LOCK or CLOSE will receive NFS4ERR_BAD_STATEID, and trigger state
recovery.

Fix this by passing back the result of need_update_open_stateid() to the
open() path, with the result to try again if the OPEN's stateid should not
be updated.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 40e431ea1bdc..632136bfd3b3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1352,9 +1352,9 @@ static void nfs_test_and_clear_all_open_stateid(struct nfs4_state *state)
 static bool nfs_need_update_open_stateid(struct nfs4_state *state,
 		const nfs4_stateid *stateid, nfs4_stateid *freeme)
 {
-	if (test_and_set_bit(NFS_OPEN_STATE, &state->flags) == 0)
-		return true;
 	if (!nfs4_stateid_match_other(stateid, &state->open_stateid)) {
+		if (test_and_set_bit(NFS_OPEN_STATE, &state->flags) == 0)
+			return true;
 		nfs4_stateid_copy(freeme, &state->open_stateid);
 		nfs_test_and_clear_all_open_stateid(state);
 		return true;
@@ -1468,7 +1468,8 @@ static int update_open_stateid(struct nfs4_state *state,
 		ret = 1;
 	}
 
-	if (open_stateid) {
+	if (open_stateid &&
+		nfs_need_update_open_stateid(state, open_stateid, &freeme)) {
 		switch (fmode) {
 			case FMODE_READ:
 				set_bit(NFS_O_RDONLY_STATE, &state->flags);
@@ -1479,11 +1480,10 @@ static int update_open_stateid(struct nfs4_state *state,
 			case FMODE_READ|FMODE_WRITE:
 				set_bit(NFS_O_RDWR_STATE, &state->flags);
 		}
-		if (nfs_need_update_open_stateid(state, open_stateid, &freeme)) {
-			if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
-				nfs4_stateid_copy(&state->stateid, open_stateid);
-			nfs4_stateid_copy(&state->open_stateid, open_stateid);
-		}
+
+		if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
+			nfs4_stateid_copy(&state->stateid, open_stateid);
+		nfs4_stateid_copy(&state->open_stateid, open_stateid);
 		ret = 1;
 	}
 
@@ -1675,8 +1675,12 @@ _nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 		goto err_put_inode;
 	if (data->o_res.delegation_type != 0)
 		nfs4_opendata_check_deleg(data, state);
-	update_open_stateid(state, &data->o_res.stateid, NULL,
-			data->o_arg.fmode);
+	ret = -EAGAIN;
+	if (!update_open_stateid(state, &data->o_res.stateid, NULL,
+			data->o_arg.fmode)) {
+		nfs4_put_open_state(state);
+		goto err_put_inode;
+	}
 	iput(inode);
 out:
 	nfs_release_seqid(data->o_arg.seqid);
-- 
2.9.3

