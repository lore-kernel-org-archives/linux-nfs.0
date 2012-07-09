Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:47984 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851Ab2GIPoT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2012 11:44:19 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so10194450ggl.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jul 2012 08:44:19 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/14] NFS: Refactor nfs41_check_expired_stateid()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 Jul 2012 11:44:18 -0400
Message-ID: <20120709154417.1604.70897.stgit@degas.1015granger.net>
In-Reply-To: <20120709153355.1604.14102.stgit@degas.1015granger.net>
References: <20120709153355.1604.14102.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The logic for dealing with a delegation state ID and an
open state ID is now sufficiently distinct that I've refactored
nfs41_check_expired_stateid() into two separate functions.

Instead of open-coded flag manipulation, use test_bit() and
clear_bit() just like all other accessors of the state->flag field.

This also eliminates several unnecessary implicit integer type
conversions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   44 +++++++++++++++++++++++++++++++++++---------
 1 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4bc21a3..f368e37 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1757,19 +1757,46 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 
 #if defined(CONFIG_NFS_V4_1)
 /**
- * nfs41_check_expired_stateid - does a state ID need recovery?
+ * nfs41_clear_delegation_stateid - possibly clear revoked delegation state ID
+ *
+ * @state: NFSv4 open state for an inode
+ */
+static void nfs41_clear_delegation_stateid(struct nfs4_state *state)
+{
+	struct nfs_server *server = NFS_SERVER(state->inode);
+	nfs4_stateid *stateid = &state->stateid;
+
+	if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
+		switch (nfs41_test_stateid(server, stateid)) {
+		case NFS_OK:
+			/* delegation still OK, preserve it */
+			break;
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_DELEG_REVOKED:
+			/* delegation was revoked, must free */
+			nfs41_free_stateid(server, stateid);
+		default:
+			clear_bit(NFS_DELEGATED_STATE, &state->flags);
+		}
+}
+
+/**
+ * nfs41_check_open_stateid - clear open state ID
  *
  * @state: NFSv4 open state for an inode
  *
  * Returns NFS_OK if recovery for this state ID is now finished.
  * Otherwise a negative NFS4ERR value is returned.
  */
-static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *stateid, unsigned int flags)
+static int nfs41_check_open_stateid(struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
+	nfs4_stateid *stateid = &state->stateid;
 	int status = -NFS4ERR_BAD_STATEID;
 
-	if (state->flags & flags) {
+	if ((test_bit(NFS_O_RDONLY_STATE, &state->flags) != 0) ||
+	    (test_bit(NFS_O_WRONLY_STATE, &state->flags) != 0) ||
+	    (test_bit(NFS_O_RDWR_STATE, &state->flags) != 0)) {
 		status = nfs41_test_stateid(server, stateid);
 		switch (status) {
 		case NFS_OK:
@@ -1781,7 +1808,9 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
 			nfs41_free_stateid(server, stateid);
 		default:
 			/* anything else: just re-open it */
-			state->flags &= ~flags;
+			clear_bit(NFS_O_RDONLY_STATE, &state->flags);
+			clear_bit(NFS_O_WRONLY_STATE, &state->flags);
+			clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		}
 	}
 	return status;
@@ -1789,13 +1818,10 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
 
 static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
 {
-	int deleg_flags = 1 << NFS_DELEGATED_STATE;
-	int open_flags = (1 << NFS_O_RDONLY_STATE) | (1 << NFS_O_WRONLY_STATE) | (1 << NFS_O_RDWR_STATE);
 	int status;
 
-	nfs41_check_expired_stateid(state, &state->stateid, deleg_flags);
-	status = nfs41_check_expired_stateid(state, &state->open_stateid,
-							open_flags);
+	nfs41_clear_delegation_stateid(state);
+	status = nfs41_check_open_stateid(state);
 
 	if (status != NFS_OK)
 		status = nfs4_open_expired(sp, state);

