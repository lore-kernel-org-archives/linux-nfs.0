Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:42825 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336Ab2FMSUv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jun 2012 14:20:51 -0400
Received: by mail-gh0-f174.google.com with SMTP id r11so679254ghr.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jun 2012 11:20:51 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS: Refactor nfs41_check_expired_stateid()
To: linux-nfs@vger.kernel.org
Date: Wed, 13 Jun 2012 14:20:49 -0400
Message-ID: <20120613182049.5910.45144.stgit@degas.1015granger.net>
In-Reply-To: <20120613181831.5910.74030.stgit@degas.1015granger.net>
References: <20120613181831.5910.74030.stgit@degas.1015granger.net>
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
index 1131877..13ae578 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1736,19 +1736,46 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 
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
@@ -1760,7 +1787,9 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
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
@@ -1768,13 +1797,10 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
 
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

