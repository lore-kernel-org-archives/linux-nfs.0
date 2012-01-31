Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60805 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753237Ab2AaPjt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jan 2012 10:39:49 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/2] NFS: Call test_stateid() and free_stateid() with correct stateids
Date: Tue, 31 Jan 2012 10:39:30 -0500
Message-Id: <1328024370-20347-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328024370-20347-1-git-send-email-bjschuma@netapp.com>
References: <1328024370-20347-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I noticed that test_stateid() was always using the same stateid for open
and lock recovery.  After poking around a bit, I discovered that it was
always testing with a delegation stateid (even if there was no
delegation present).  I figured this wasn't correct, so now delegation
and open stateids are tested during open_expired() and lock stateids are
tested during lock_expired().

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c |   58 ++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 47 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 09e3341..c02ebe4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1725,15 +1725,32 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 }
 
 #if defined(CONFIG_NFS_V4_1)
-static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
+static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *stateid, unsigned int flags)
 {
-	int status;
+	int status = NFS_OK;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
-	status = nfs41_test_stateid(server, &state->stateid);
-	if (status == NFS_OK)
-		return 0;
-	nfs41_free_stateid(server, &state->stateid);
+	if (state->flags & flags) {
+		status = nfs41_test_stateid(server, stateid);
+		if (status != NFS_OK) {
+			nfs41_free_stateid(server, stateid);
+			state->flags &= ~flags;
+		}
+	}
+	return status;
+}
+
+static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
+{
+	int deleg_status, open_status;
+	int deleg_flags = 1 << NFS_DELEGATED_STATE;
+	int open_flags = (1 << NFS_O_RDONLY_STATE) | (1 << NFS_O_WRONLY_STATE) | (1 << NFS_O_RDWR_STATE);
+
+	deleg_status = nfs41_check_expired_stateid(state, &state->stateid, deleg_flags);
+	open_status = nfs41_check_expired_stateid(state,  &state->open_stateid, open_flags);
+
+	if ((deleg_status == NFS_OK) && (open_status == NFS_OK))
+		return NFS_OK;
 	return nfs4_open_expired(sp, state);
 }
 #endif
@@ -4505,15 +4522,34 @@ out:
 }
 
 #if defined(CONFIG_NFS_V4_1)
-static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *request)
+static int nfs41_check_expired_locks(struct nfs4_state *state)
 {
-	int status;
+	int status, ret = NFS_OK;
+	struct nfs4_lock_state *lsp;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
-	status = nfs41_test_stateid(server, &state->stateid);
+	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
+		if (lsp->ls_flags & NFS_LOCK_INITIALIZED) {
+			status = nfs41_test_stateid(server, &lsp->ls_stateid);
+			if (status != NFS_OK) {
+				nfs41_free_stateid(server, &lsp->ls_stateid);
+				lsp->ls_flags &= ~NFS_LOCK_INITIALIZED;
+				ret = status;
+			}
+		}
+	};
+
+	return ret;
+}
+
+static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *request)
+{
+	int status = NFS_OK;
+
+	if (test_bit(LK_STATE_IN_USE, &state->flags))
+		status = nfs41_check_expired_locks(state);
 	if (status == NFS_OK)
-		return 0;
-	nfs41_free_stateid(server, &state->stateid);
+		return status;
 	return nfs4_lock_expired(state, request);
 }
 #endif
-- 
1.7.8.4

