Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60805 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754712Ab2AaPjt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jan 2012 10:39:49 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/2] NFS: Pass a stateid to test_stateid() and free_stateid()
Date: Tue, 31 Jan 2012 10:39:29 -0500
Message-Id: <1328024370-20347-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This takes the guesswork out of what stateid to use.  The caller is
expected to figure this out and pass in the correct one.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
v2: Rebase against latest nfs-for-next branch

 fs/nfs/nfs4proc.c |   37 ++++++++++++++++++++++---------------
 fs/nfs/nfs4xdr.c  |    3 ++-
 2 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7672620..09e3341 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -82,8 +82,8 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
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
@@ -1730,10 +1730,10 @@ static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
 	int status;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
-	status = nfs41_test_stateid(server, state);
+	status = nfs41_test_stateid(server, &state->stateid);
 	if (status == NFS_OK)
 		return 0;
-	nfs41_free_stateid(server, state);
+	nfs41_free_stateid(server, &state->stateid);
 	return nfs4_open_expired(sp, state);
 }
 #endif
@@ -4510,10 +4510,10 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
 	int status;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
-	status = nfs41_test_stateid(server, state);
+	status = nfs41_test_stateid(server, &state->stateid);
 	if (status == NFS_OK)
 		return 0;
-	nfs41_free_stateid(server, state);
+	nfs41_free_stateid(server, &state->stateid);
 	return nfs4_lock_expired(state, request);
 }
 #endif
@@ -6143,10 +6143,12 @@ out_freepage:
 out:
 	return err;
 }
-static int _nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *state)
+
+static int _nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
+	int status;
 	struct nfs41_test_stateid_args args = {
-		.stateid = &state->stateid,
+		.stateid = stateid,
 	};
 	struct nfs41_test_stateid_res res;
 	struct rpc_message msg = {
@@ -6154,26 +6156,31 @@ static int _nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *sta
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+
 	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
-	return nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
+
+	if (status == NFS_OK)
+		return res.status;
+	return status;
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
 	struct nfs41_free_stateid_args args = {
-		.stateid = &state->stateid,
+		.stateid = stateid,
 	};
 	struct nfs41_free_stateid_res res;
 	struct rpc_message msg = {
@@ -6186,13 +6193,13 @@ static int _nfs4_free_stateid(struct nfs_server *server, struct nfs4_state *stat
 	return nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
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
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ca288d1..5d1caac 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5671,7 +5671,8 @@ static int decode_test_stateid(struct xdr_stream *xdr,
 	if (unlikely(!p))
 		goto out_overflow;
 	res->status = be32_to_cpup(p++);
-	return res->status;
+
+	return status;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
 out:
-- 
1.7.8.4

