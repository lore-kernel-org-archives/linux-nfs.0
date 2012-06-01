Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35487 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964838Ab2FAPjQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2012 11:39:16 -0400
Received: by yenm10 with SMTP id m10so1857987yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 01 Jun 2012 08:39:16 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] NFS: Properly sort TEST_STATEID results
To: linux-nfs@vger.kernel.org
Date: Fri, 01 Jun 2012 11:38:14 -0400
Message-ID: <20120601153814.5626.16055.stgit@degas.1015granger.net>
In-Reply-To: <20120601153231.5626.89559.stgit@degas.1015granger.net>
References: <20120601153231.5626.89559.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The result of a TEST_STATEID operation can indicate a few different
things.  If NFS_OK is returned, then the client can continue using the
state ID under test, and skip recovery.  RFC 5661 says that if and
only if the state ID was revoked, then the client must perform an
explicit FREE_STATEID before trying to re-open.

However, if the server doesn't recognize the state ID at all, then the
client should immediately continue with open recovery.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   38 ++++++++++++++++++++++++++++++++++++--
 1 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4f1e824..39d641a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1733,6 +1733,14 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 }
 
 #if defined(CONFIG_NFS_V4_1)
+/**
+ * nfs41_check_expired_stateid - does a state ID need recovery?
+ *
+ * @state: NFSv4 open state for a file
+ *
+ * Returns NFS_OK if recovery for this state ID is now finished.
+ * Otherwise a negative NFS4ERR value is returned.
+ */
 static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *stateid, unsigned int flags)
 {
 	int status = NFS_OK;
@@ -1740,9 +1748,19 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
 
 	if (state->flags & flags) {
 		status = nfs41_test_stateid(server, stateid);
-		if (status != NFS_OK) {
+		switch (status) {
+		case NFS_OK:
+			/* server recognizes this one, don't re-open */
+			break;
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_DELEG_REVOKED:
+			/* state was revoked, free then re-open */
 			nfs41_free_stateid(server, stateid);
 			state->flags &= ~flags;
+			break;
+		default:
+			/* anything else: go ahead and re-open it */
+			break;
 		}
 	}
 	return status;
@@ -4642,6 +4660,14 @@ out:
 }
 
 #if defined(CONFIG_NFS_V4_1)
+/**
+ * nfs41_check_expired_locks - clear lock state IDs
+ *
+ * @state: NFSv4 open state for a file
+ *
+ * Returns NFS_OK if recovery for this state ID is now finished.
+ * Otherwise a negative NFS4ERR value is returned.
+ */
 static int nfs41_check_expired_locks(struct nfs4_state *state)
 {
 	int status, ret = NFS_OK;
@@ -4651,9 +4677,17 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
 		if (lsp->ls_flags & NFS_LOCK_INITIALIZED) {
 			status = nfs41_test_stateid(server, &lsp->ls_stateid);
-			if (status != NFS_OK) {
+			switch (status) {
+			case NFS_OK:
+				/* server recognizes this one, don't re-lock */
+				break;
+			case -NFS4ERR_ADMIN_REVOKED:
+			case -NFS4ERR_DELEG_REVOKED:
+				/* lock was revoked, free then re-lock */
 				nfs41_free_stateid(server, &lsp->ls_stateid);
 				lsp->ls_flags &= ~NFS_LOCK_INITIALIZED;
+				/*FALLTHROUGH*/
+			default:
 				ret = status;
 			}
 		}

