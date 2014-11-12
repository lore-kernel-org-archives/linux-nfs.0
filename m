Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:63421 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbaKLWcQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 17:32:16 -0500
Received: by mail-ig0-f179.google.com with SMTP id r10so3868531igi.12
        for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2014 14:32:15 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/5] NFSv4.1: nfs41_clear_delegation_stateid shouldn't trust NFS_DELEGATED_STATE
Date: Wed, 12 Nov 2014 17:31:51 -0500
Message-Id: <1415831514-47005-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1415831514-47005-2-git-send-email-trond.myklebust@primarydata.com>
References: <1415831514-47005-1-git-send-email-trond.myklebust@primarydata.com>
 <1415831514-47005-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch removes the assumption made previously, that we only need to
check the delegation stateid when it matches the stateid on a cached
open.

If we believe that we hold a delegation for this file, then we must assume
that its stateid may have been revoked or expired too. If we don't test it
then our state recovery process may end up caching open/lock state in a
situation where it should not.
We therefore rename the function nfs41_clear_delegation_stateid as
nfs41_check_delegation_stateid, and change it to always run through the
delegation stateid test and recovery process as outlined in RFC5661.

http://lkml.kernel.org/r/CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 42 +++++++++++++++++-------------------------
 1 file changed, 17 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bdd880bddba4..3b98fe752ef8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2132,45 +2132,37 @@ static int nfs40_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
 }
 
 #if defined(CONFIG_NFS_V4_1)
-static void nfs41_clear_delegation_stateid(struct nfs4_state *state)
+static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	nfs4_stateid *stateid = &state->stateid;
+	nfs4_stateid stateid;
 	struct nfs_delegation *delegation;
-	struct rpc_cred *cred = NULL;
-	int status = -NFS4ERR_BAD_STATEID;
-
-	/* If a state reset has been done, test_stateid is unneeded */
-	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
-		return;
+	struct rpc_cred *cred;
+	int status;
 
 	/* Get the delegation credential for use by test/free_stateid */
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(state->inode)->delegation);
-	if (delegation != NULL &&
-	    nfs4_stateid_match(&delegation->stateid, stateid)) {
-		cred = get_rpccred(delegation->cred);
-		rcu_read_unlock();
-		status = nfs41_test_stateid(server, stateid, cred);
-		trace_nfs4_test_delegation_stateid(state, NULL, status);
-	} else
+	if (delegation == NULL) {
 		rcu_read_unlock();
+		return;
+	}
+
+	nfs4_stateid_copy(&stateid, &delegation->stateid);
+	cred = get_rpccred(delegation->cred);
+	rcu_read_unlock();
+	status = nfs41_test_stateid(server, &stateid, cred);
+	trace_nfs4_test_delegation_stateid(state, NULL, status);
 
 	if (status != NFS_OK) {
 		/* Free the stateid unless the server explicitly
 		 * informs us the stateid is unrecognized. */
 		if (status != -NFS4ERR_BAD_STATEID)
-			nfs41_free_stateid(server, stateid, cred);
-		nfs_remove_bad_delegation(state->inode);
-
-		write_seqlock(&state->seqlock);
-		nfs4_stateid_copy(&state->stateid, &state->open_stateid);
-		write_sequnlock(&state->seqlock);
-		clear_bit(NFS_DELEGATED_STATE, &state->flags);
+			nfs41_free_stateid(server, &stateid, cred);
+		nfs_finish_clear_delegation_stateid(state);
 	}
 
-	if (cred != NULL)
-		put_rpccred(cred);
+	put_rpccred(cred);
 }
 
 /**
@@ -2214,7 +2206,7 @@ static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
 {
 	int status;
 
-	nfs41_clear_delegation_stateid(state);
+	nfs41_check_delegation_stateid(state);
 	status = nfs41_check_open_stateid(state);
 	if (status != NFS_OK)
 		status = nfs4_open_expired(sp, state);
-- 
1.9.3

