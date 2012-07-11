Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:50255 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486Ab2GKUaQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:30:16 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so1697031ggl.19
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:30:16 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/15] NFS: Clean up nfs41_check_expired_stateid()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:30:14 -0400
Message-ID: <20120711203013.3767.51989.stgit@degas.1015granger.net>
In-Reply-To: <20120711201718.3767.66867.stgit@degas.1015granger.net>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Instead of open-coded flag manipulation, use test_bit() and
clear_bit() just like all other accessors of the state->flag field.
This also eliminates several unnecessary implicit integer type
conversions.

To make it absolutely clear what is going on, a number of comments
are introduced.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   77 ++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 61 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5d83f88..c4df35b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1756,32 +1756,67 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 }
 
 #if defined(CONFIG_NFS_V4_1)
-static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *stateid, unsigned int flags)
+static void nfs41_clear_delegation_stateid(struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	int status = -NFS4ERR_BAD_STATEID;
-
-	if (state->flags & flags) {
-		status = nfs41_test_stateid(server, stateid);
-		if (status != NFS_OK) {
-			if (status != -NFS4ERR_BAD_STATEID)
-				nfs41_free_stateid(server, stateid);
-			state->flags &= ~flags;
-		}
+	nfs4_stateid *stateid = &state->stateid;
+	int status;
+
+	/* If a state reset has been done, test_stateid is unneeded */
+	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
+		return;
+
+	status = nfs41_test_stateid(server, stateid);
+	if (status != NFS_OK) {
+		/* Free the stateid unless the server explicitly
+		 * informs us the stateid is unrecognized. */
+		if (status != -NFS4ERR_BAD_STATEID)
+			nfs41_free_stateid(server, stateid);
+
+		clear_bit(NFS_DELEGATED_STATE, &state->flags);
+	}
+}
+
+/**
+ * nfs41_check_open_stateid - possibly free an open stateid
+ *
+ * @state: NFSv4 state for an inode
+ *
+ * Returns NFS_OK if recovery for this stateid is now finished.
+ * Otherwise a negative NFS4ERR value is returned.
+ */
+static int nfs41_check_open_stateid(struct nfs4_state *state)
+{
+	struct nfs_server *server = NFS_SERVER(state->inode);
+	nfs4_stateid *stateid = &state->stateid;
+	int status;
+
+	/* If a state reset has been done, test_stateid is unneeded */
+	if ((test_bit(NFS_O_RDONLY_STATE, &state->flags) == 0) &&
+	    (test_bit(NFS_O_WRONLY_STATE, &state->flags) == 0) &&
+	    (test_bit(NFS_O_RDWR_STATE, &state->flags) == 0))
+		return -NFS4ERR_BAD_STATEID;
+
+	status = nfs41_test_stateid(server, stateid);
+	if (status != NFS_OK) {
+		/* Free the stateid unless the server explicitly
+		 * informs us the stateid is unrecognized. */
+		if (status != -NFS4ERR_BAD_STATEID)
+			nfs41_free_stateid(server, stateid);
+
+		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
+		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
+		clear_bit(NFS_O_RDWR_STATE, &state->flags);
 	}
 	return status;
 }
 
 static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
 {
-	int deleg_flags = 1 << NFS_DELEGATED_STATE;
-	int open_flags = (1 << NFS_O_RDONLY_STATE) | (1 << NFS_O_WRONLY_STATE) | (1 << NFS_O_RDWR_STATE);
 	int status;
 
-	nfs41_check_expired_stateid(state, &state->stateid, deleg_flags);
-	status = nfs41_check_expired_stateid(state, &state->open_stateid,
-							open_flags);
-
+	nfs41_clear_delegation_stateid(state);
+	status = nfs41_check_open_stateid(state);
 	if (status != NFS_OK)
 		status = nfs4_open_expired(sp, state);
 	return status;
@@ -4700,6 +4735,14 @@ out:
 }
 
 #if defined(CONFIG_NFS_V4_1)
+/**
+ * nfs41_check_expired_locks - possibly free a lock stateid
+ *
+ * @state: NFSv4 state for an inode
+ *
+ * Returns NFS_OK if recovery for this stateid is now finished.
+ * Otherwise a negative NFS4ERR value is returned.
+ */
 static int nfs41_check_expired_locks(struct nfs4_state *state)
 {
 	int status, ret = -NFS4ERR_BAD_STATEID;
@@ -4710,6 +4753,8 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 		if (lsp->ls_flags & NFS_LOCK_INITIALIZED) {
 			status = nfs41_test_stateid(server, &lsp->ls_stateid);
 			if (status != NFS_OK) {
+				/* Free the stateid unless the server
+				 * informs us the stateid is unrecognized. */
 				if (status != -NFS4ERR_BAD_STATEID)
 					nfs41_free_stateid(server,
 							&lsp->ls_stateid);

