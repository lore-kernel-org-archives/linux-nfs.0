Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33468 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757450AbcIVRjp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:39:45 -0400
Received: by mail-it0-f65.google.com with SMTP id x192so5346729itb.0
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 12/31] NFSv4.1: Allow revoked stateids to skip the call to TEST_STATEID
Date: Thu, 22 Sep 2016 13:39:02 -0400
Message-Id: <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In some cases (e.g. when the SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED sequence
flag is set) we may already know that the stateid was revoked and that the
only valid operation we can call is FREE_STATEID. In those cases, allow
the stateid to carry the information in the type field, so that we skip
the redundant call to TEST_STATEID.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c    | 32 +++++++++++++++++++++++---------
 include/linux/nfs4.h |  1 +
 2 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 97a614370604..3c1b8cb7dd95 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2422,18 +2422,29 @@ static int nfs41_test_and_free_expired_stateid(struct nfs_server *server,
 {
 	int status;
 
-	status = nfs41_test_stateid(server, stateid, cred);
+	switch (stateid->type) {
+	default:
+		break;
+	case NFS4_INVALID_STATEID_TYPE:
+	case NFS4_SPECIAL_STATEID_TYPE:
+		return -NFS4ERR_BAD_STATEID;
+	case NFS4_REVOKED_STATEID_TYPE:
+		goto out_free;
+	}
 
+	status = nfs41_test_stateid(server, stateid, cred);
 	switch (status) {
 	case -NFS4ERR_EXPIRED:
 	case -NFS4ERR_ADMIN_REVOKED:
 	case -NFS4ERR_DELEG_REVOKED:
-		/* Ack the revoked state to the server */
-		nfs41_free_stateid(server, stateid, cred);
-	case -NFS4ERR_BAD_STATEID:
+		break;
+	default:
 		return status;
 	}
-	return NFS_OK;
+out_free:
+	/* Ack the revoked state to the server */
+	nfs41_free_stateid(server, stateid, cred);
+	return -NFS4ERR_EXPIRED;
 }
 
 static void nfs41_check_delegation_stateid(struct nfs4_state *state)
@@ -2468,7 +2479,7 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 	rcu_read_unlock();
 	status = nfs41_test_and_free_expired_stateid(server, &stateid, cred);
 	trace_nfs4_test_delegation_stateid(state, NULL, status);
-	if (status != NFS_OK)
+	if (status == -NFS4ERR_EXPIRED || status == -NFS4ERR_BAD_STATEID)
 		nfs_finish_clear_delegation_stateid(state, &stateid);
 
 	put_rpccred(cred);
@@ -2497,7 +2508,7 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 
 	status = nfs41_test_and_free_expired_stateid(server, stateid, cred);
 	trace_nfs4_test_open_stateid(state, NULL, status);
-	if (status != NFS_OK) {
+	if (status == -NFS4ERR_EXPIRED || status == -NFS4ERR_BAD_STATEID) {
 		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 		clear_bit(NFS_O_RDWR_STATE, &state->flags);
@@ -6124,7 +6135,7 @@ out:
  */
 static int nfs41_check_expired_locks(struct nfs4_state *state)
 {
-	int status, ret = -NFS4ERR_BAD_STATEID;
+	int status, ret = NFS_OK;
 	struct nfs4_lock_state *lsp;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
@@ -6136,9 +6147,12 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 					&lsp->ls_stateid,
 					cred);
 			trace_nfs4_test_lock_stateid(state, lsp, status);
-			if (status != NFS_OK) {
+			if (status == -NFS4ERR_EXPIRED ||
+			    status == -NFS4ERR_BAD_STATEID)
 				clear_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
+			else if (status != NFS_OK) {
 				ret = status;
+				break;
 			}
 		}
 	};
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index c6564ada9beb..9094faf0699d 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -67,6 +67,7 @@ struct nfs4_stateid_struct {
 		NFS4_DELEGATION_STATEID_TYPE,
 		NFS4_LAYOUT_STATEID_TYPE,
 		NFS4_PNFS_DS_STATEID_TYPE,
+		NFS4_REVOKED_STATEID_TYPE,
 	} type;
 };
 
-- 
2.7.4

