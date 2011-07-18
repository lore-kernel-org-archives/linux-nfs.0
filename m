Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37301 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149Ab1GRRxi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jul 2011 13:53:38 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 1/2] NFS: Test and Free stateid should take a stateid argument
Date: Mon, 18 Jul 2011 13:53:35 -0400
Message-Id: <1311011616-11503-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

Passing the nfs4_state doesn't guarantee that the correct stateid will
be used.  The correct stateid can be determined during lock_expired() or
open_expired() and then passed to these functions.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c |   31 +++++++++++++++++--------------
 1 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 93ef776..f37218b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -81,8 +81,8 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
 			    struct nfs4_state *state);
 #ifdef CONFIG_NFS_V4_1
-static int nfs41_test_stateid(struct nfs_server *, struct nfs4_state *);
-static int nfs41_free_stateid(struct nfs_server *, struct nfs4_state *);
+static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *);
+static int nfs41_free_stateid(struct nfs_server *, nfs4_stateid *);
 #endif
 /* Prevent leaks of NFSv4 errors into userland */
 static int nfs4_map_errors(int err)
@@ -1696,10 +1696,10 @@ static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
 	int status;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
-	status = nfs41_test_stateid(server, state);
+	status = nfs41_test_stateid(server, &state->open_stateid);
 	if (status == NFS_OK)
 		return 0;
-	nfs41_free_stateid(server, state);
+	nfs41_free_stateid(server, &state->open_stateid);
 	return nfs4_open_expired(sp, state);
 }
 #endif
@@ -4466,11 +4466,14 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
 {
 	int status;
 	struct nfs_server *server = NFS_SERVER(state->inode);
+	struct nfs4_lock_state *lock_state = request->fl_u.nfs4_fl.owner;
+	nfs4_stateid *stateid = &lock_state->ls_stateid;
 
-	status = nfs41_test_stateid(server, state);
+	status = nfs41_test_stateid(server, stateid);
 	if (status == NFS_OK)
 		return 0;
-	nfs41_free_stateid(server, state);
+	nfs41_free_stateid(server, stateid);
+	lock_state->ls_seqid.flags &= !NFS_SEQID_CONFIRMED;
 	return nfs4_lock_expired(state, request);
 }
 #endif
@@ -6046,11 +6049,11 @@ out_freepage:
 out:
 	return err;
 }
-static int _nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *state)
+static int _nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	int status;
 	struct nfs41_test_stateid_args args = {
-		.stateid = &state->stateid,
+		.stateid = stateid,
 	};
 	struct nfs41_test_stateid_res res;
 	struct rpc_message msg = {
@@ -6063,23 +6066,23 @@ static int _nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *sta
 	return status;
 }
 
-static int nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *state)
+static int nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
-				_nfs41_test_stateid(server, state),
+				_nfs41_test_stateid(server, stateid),
 				&exception);
 	} while (exception.retry);
 	return err;
 }
 
-static int _nfs4_free_stateid(struct nfs_server *server, struct nfs4_state *state)
+static int _nfs4_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	int status;
 	struct nfs41_free_stateid_args args = {
-		.stateid = &state->stateid,
+		.stateid = stateid,
 	};
 	struct nfs41_free_stateid_res res;
 	struct rpc_message msg = {
@@ -6093,13 +6096,13 @@ static int _nfs4_free_stateid(struct nfs_server *server, struct nfs4_state *stat
 	return status;
 }
 
-static int nfs41_free_stateid(struct nfs_server *server, struct nfs4_state *state)
+static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
-				_nfs4_free_stateid(server, state),
+				_nfs4_free_stateid(server, stateid),
 				&exception);
 	} while (exception.retry);
 	return err;
-- 
1.7.6

