Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:42825 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254Ab2FMSUd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jun 2012 14:20:33 -0400
Received: by ghrr11 with SMTP id r11so679254ghr.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jun 2012 11:20:33 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] NFS: Properly sort TEST_STATEID results
To: linux-nfs@vger.kernel.org
Date: Wed, 13 Jun 2012 14:20:31 -0400
Message-ID: <20120613182031.5910.11331.stgit@degas.1015granger.net>
In-Reply-To: <20120613181831.5910.74030.stgit@degas.1015granger.net>
References: <20120613181831.5910.74030.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The result of a TEST_STATEID operation can indicate a few different
things:

  o If NFS_OK is returned, then the client can continue using the
    state ID under test, and skip recovery.

  o RFC 5661 says that if and only if the state ID was revoked, then
    the client must perform an explicit FREE_STATEID before trying to
    re-open.

  o If the server doesn't recognize the state ID at all, then no
    FREE_STATEID is needed, and the client can immediately continue
    with open recovery.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   36 ++++++++++++++++++++++++++++++++++--
 1 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ef69cc5..65bee35 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1735,6 +1735,14 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 }
 
 #if defined(CONFIG_NFS_V4_1)
+/**
+ * nfs41_check_expired_stateid - does a state ID need recovery?
+ *
+ * @state: NFSv4 open state for an inode
+ *
+ * Returns NFS_OK if recovery for this state ID is now finished.
+ * Otherwise a negative NFS4ERR value is returned.
+ */
 static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *stateid, unsigned int flags)
 {
 	int status = NFS_OK;
@@ -1742,8 +1750,16 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
 
 	if (state->flags & flags) {
 		status = nfs41_test_stateid(server, stateid);
-		if (status != NFS_OK) {
+		switch (status) {
+		case NFS_OK:
+			/* server recognizes this one, don't recover */
+			break;
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_DELEG_REVOKED:
+			/* state was revoked, free then re-open */
 			nfs41_free_stateid(server, stateid);
+		default:
+			/* anything else: just re-open it */
 			state->flags &= ~flags;
 		}
 	}
@@ -4671,6 +4687,14 @@ out:
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
@@ -4680,8 +4704,16 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
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
+			default:
+				/* anything else: just re-lock it */
 				lsp->ls_flags &= ~NFS_LOCK_INITIALIZED;
 				ret = status;
 			}

