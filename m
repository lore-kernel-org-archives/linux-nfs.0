Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60155 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932194Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 03/25] nfsd4: extend state lock over seqid replay logic
Date: Wed, 14 Sep 2011 07:44:59 -0400
Message-Id: <1316000721-3289-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

There are currently a couple races in the seqid replay code: a
retransmission could come while we're still encoding the original reply,
or a new seqid-mutating call could come as we're encoding a replay.

So, extend the state lock over the encoding (both encoding of a replayed
reply and caching of the original encoded reply).

I really hate doing this, and previously added the stateowner
reference-counting code to avoid it (which was insufficient)--but I
don't see a less complicated alternative at the moment.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c  |    5 +++--
 fs/nfsd/nfs4state.c |   12 ++++++++----
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 50bae74..50063a8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -408,8 +408,8 @@ out:
 	if (open->op_stateowner) {
 		nfs4_get_stateowner(open->op_stateowner);
 		cstate->replay_owner = open->op_stateowner;
-	}
-	nfs4_unlock_state();
+	} else
+		nfs4_unlock_state();
 	return status;
 }
 
@@ -1227,6 +1227,7 @@ encode_op:
 			be32_to_cpu(status));
 
 		if (cstate->replay_owner) {
+			nfs4_unlock_state();
 			nfs4_put_stateowner(cstate->replay_owner);
 			cstate->replay_owner = NULL;
 		}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bc1a9db..6cf729a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3501,7 +3501,8 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfsd4_create_clid_dir(sop->so_client);
 out:
-	nfs4_unlock_state();
+	if (!cstate->replay_owner)
+		nfs4_unlock_state();
 	return status;
 }
 
@@ -3568,7 +3569,8 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	memcpy(&od->od_stateid, &stp->st_stateid, sizeof(stateid_t));
 	status = nfs_ok;
 out:
-	nfs4_unlock_state();
+	if (!cstate->replay_owner)
+		nfs4_unlock_state();
 	return status;
 }
 
@@ -3609,7 +3611,8 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (list_empty(&so->so_stateids))
 		move_to_close_lru(so);
 out:
-	nfs4_unlock_state();
+	if (!cstate->replay_owner)
+		nfs4_unlock_state();
 	return status;
 }
 
@@ -4071,7 +4074,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out:
 	if (status && lock->lk_is_new && lock_sop)
 		release_lockowner(lock_sop);
-	nfs4_unlock_state();
+	if (!cstate->replay_owner)
+		nfs4_unlock_state();
 	return status;
 }
 
-- 
1.7.4.1

