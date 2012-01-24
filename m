Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15547 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164Ab2AXVvw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jan 2012 16:51:52 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/2] NFS: Pass a stateid to test_stateid() and free_stateid()
Date: Tue, 24 Jan 2012 16:51:48 -0500
Message-Id: <1327441909-1445-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This takes the guesswork out of what stateid to use.  The caller is
expected to figure this out and pass in the correct one.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c |   33 +++++++++++++++++++--------------
 fs/nfs/nfs4xdr.c  |    3 ++-
 2 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index df3d306..21a78bb 100644
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
@@ -1716,10 +1716,10 @@ static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
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
@@ -4483,10 +4483,10 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
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
@@ -6110,11 +6110,12 @@ out_freepage:
 out:
 	return err;
 }
-static int _nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *state)
+
+static int _nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	int status;
 	struct nfs41_test_stateid_args args = {
-		.stateid = &state->stateid,
+		.stateid = stateid,
 	};
 	struct nfs41_test_stateid_res res;
 	struct rpc_message msg = {
@@ -6122,28 +6123,32 @@ static int _nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *sta
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+
 	args.seq_args.sa_session = res.seq_res.sr_session = NULL;
 	status = nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 1);
+
+	if (status == NFS_OK)
+		return res.status;
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
@@ -6157,13 +6162,13 @@ static int _nfs4_free_stateid(struct nfs_server *server, struct nfs4_state *stat
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
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 95e92e4..2dee989 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5667,7 +5667,8 @@ static int decode_test_stateid(struct xdr_stream *xdr,
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

