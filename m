Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35487 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964838Ab2FAPj0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2012 11:39:26 -0400
Received: by mail-yx0-f174.google.com with SMTP id m10so1857987yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 01 Jun 2012 08:39:25 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] NFS: state reclaim clears OPEN state
To: linux-nfs@vger.kernel.org
Date: Fri, 01 Jun 2012 11:39:22 -0400
Message-ID: <20120601153922.5626.96177.stgit@degas.1015granger.net>
In-Reply-To: <20120601153231.5626.89559.stgit@degas.1015granger.net>
References: <20120601153231.5626.89559.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Before beginning state recovery, the state manager zaps open and lock
state for each open file, thus the "state->flags & flags" test always
fails during reclaim.  But open recovery is still needed for these
files.

To force a call to nfs4_open_expired(), change the default return
value for nfs41_check_expired_stateid() to force open recovery and
nfs41_check_locks() to force lock recovery if the requested flags are
clear.  Fix suggested by Bryan Schumaker.

The presence of a delegation state ID must not prevent normal open
recovery.  The delegation state ID must be cleared if it was revoked,
but once cleared I don't think it's presence or absence has any
bearing on whether open recovery is still needed.

The logic in nfs41_lock_expired() is cleaned up to match the form of
nfs41_open_expired(), but no change in behavior is expected there.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 39d641a..676d341 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1743,8 +1743,8 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
  */
 static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *stateid, unsigned int flags)
 {
-	int status = NFS_OK;
 	struct nfs_server *server = NFS_SERVER(state->inode);
+	int status = -NFS4ERR_BAD_STATEID;
 
 	if (state->flags & flags) {
 		status = nfs41_test_stateid(server, stateid);
@@ -1768,16 +1768,16 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
 
 static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
 {
-	int deleg_status, open_status;
 	int deleg_flags = 1 << NFS_DELEGATED_STATE;
 	int open_flags = (1 << NFS_O_RDONLY_STATE) | (1 << NFS_O_WRONLY_STATE) | (1 << NFS_O_RDWR_STATE);
+	int status;
 
-	deleg_status = nfs41_check_expired_stateid(state, &state->stateid, deleg_flags);
-	open_status = nfs41_check_expired_stateid(state,  &state->open_stateid, open_flags);
+	nfs41_check_expired_stateid(state, &state->stateid, deleg_flags);
+	status = nfs41_check_expired_stateid(state,  &state->open_stateid, open_flags);
 
-	if ((deleg_status == NFS_OK) && (open_status == NFS_OK))
-		return NFS_OK;
-	return nfs4_open_expired(sp, state);
+	if (status != NFS_OK)
+		status = nfs4_open_expired(sp, state);
+	return status;
 }
 #endif
 
@@ -4670,7 +4670,7 @@ out:
  */
 static int nfs41_check_expired_locks(struct nfs4_state *state)
 {
-	int status, ret = NFS_OK;
+	int status, ret = -NFS4ERR_BAD_STATEID;
 	struct nfs4_lock_state *lsp;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
@@ -4702,9 +4702,9 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
 
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
 

