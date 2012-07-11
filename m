Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f52.google.com ([209.85.213.52]:34087 "EHLO
	mail-yw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486Ab2GKUaH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:30:07 -0400
Received: by mail-yw0-f52.google.com with SMTP id p61so1948409yhp.11
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:30:07 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/15] NFS: State reclaim clears OPEN and LOCK state
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:30:05 -0400
Message-ID: <20120711203004.3767.40190.stgit@degas.1015granger.net>
In-Reply-To: <20120711201718.3767.66867.stgit@degas.1015granger.net>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The "state->flags & flags" test in nfs41_check_expired_stateid()
allows the state manager to squelch a TEST_STATEID operation when
it is known for sure that a state ID is no longer valid.  If the
lease was purged, for example, the client already knows that state
ID is now defunct.

But open recovery is still needed for that inode.

To force a call to nfs4_open_expired(), change the default return
value for nfs41_check_expired_stateid() to force open recovery, and
the default return value for nfs41_check_locks() to force lock
recovery, if the requested flags are clear.  Fix suggested by Bryan
Schumaker.

Also, the presence of a delegation state ID must not prevent normal
open recovery.  The delegation state ID must be cleared if it was
revoked, but once cleared I don't think it's presence or absence has
any bearing on whether open recovery is still needed.  So the logic
is adjusted to ignore the TEST_STATEID result for the delegation
state ID.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2986e65..5d83f88 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1758,8 +1758,8 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 #if defined(CONFIG_NFS_V4_1)
 static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *stateid, unsigned int flags)
 {
-	int status = NFS_OK;
 	struct nfs_server *server = NFS_SERVER(state->inode);
+	int status = -NFS4ERR_BAD_STATEID;
 
 	if (state->flags & flags) {
 		status = nfs41_test_stateid(server, stateid);
@@ -1774,16 +1774,17 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
 
 static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
 {
-	int deleg_status, open_status;
 	int deleg_flags = 1 << NFS_DELEGATED_STATE;
 	int open_flags = (1 << NFS_O_RDONLY_STATE) | (1 << NFS_O_WRONLY_STATE) | (1 << NFS_O_RDWR_STATE);
+	int status;
 
-	deleg_status = nfs41_check_expired_stateid(state, &state->stateid, deleg_flags);
-	open_status = nfs41_check_expired_stateid(state,  &state->open_stateid, open_flags);
+	nfs41_check_expired_stateid(state, &state->stateid, deleg_flags);
+	status = nfs41_check_expired_stateid(state, &state->open_stateid,
+							open_flags);
 
-	if ((deleg_status == NFS_OK) && (open_status == NFS_OK))
-		return NFS_OK;
-	return nfs4_open_expired(sp, state);
+	if (status != NFS_OK)
+		status = nfs4_open_expired(sp, state);
+	return status;
 }
 #endif
 
@@ -4701,7 +4702,7 @@ out:
 #if defined(CONFIG_NFS_V4_1)
 static int nfs41_check_expired_locks(struct nfs4_state *state)
 {
-	int status, ret = NFS_OK;
+	int status, ret = -NFS4ERR_BAD_STATEID;
 	struct nfs4_lock_state *lsp;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
@@ -4727,9 +4728,9 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
 
 	if (test_bit(LK_STATE_IN_USE, &state->flags))
 		status = nfs41_check_expired_locks(state);
-	if (status == NFS_OK)
-		return status;
-	return nfs4_lock_expired(state, request);
+	if (status != NFS_OK)
+		status = nfs4_lock_expired(state, request);
+	return status;
 }
 #endif
 

