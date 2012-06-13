Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:42825 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374Ab2FMSUm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jun 2012 14:20:42 -0400
Received: by mail-gh0-f174.google.com with SMTP id r11so679254ghr.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jun 2012 11:20:42 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] NFS: State reclaim clears OPEN and LOCK state
To: linux-nfs@vger.kernel.org
Date: Wed, 13 Jun 2012 14:20:40 -0400
Message-ID: <20120613182040.5910.18431.stgit@degas.1015granger.net>
In-Reply-To: <20120613181831.5910.74030.stgit@degas.1015granger.net>
References: <20120613181831.5910.74030.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Before beginning state recovery, the state manager zaps open and lock
state for each open file, thus the "state->flags & flags" test in
nfs41_{open,lock}_expired() always fails during reclaim.  But open
recovery is still needed for these files.

To force a call to nfs4_open_expired(), change the default return
value for nfs41_check_expired_stateid() to force open recovery, and
the default return value for nfs41_check_locks() to force lock
recovery, if the requested flags are clear.  Fix suggested by Bryan
Schumaker.

The presence of a delegation state ID must not prevent normal open
recovery.  The delegation state ID must be cleared if it was revoked,
but once cleared I don't think it's presence or absence has any
bearing on whether open recovery is still needed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 65bee35..1131877 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1745,8 +1745,8 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
  */
 static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *stateid, unsigned int flags)
 {
-	int status = NFS_OK;
 	struct nfs_server *server = NFS_SERVER(state->inode);
+	int status = -NFS4ERR_BAD_STATEID;
 
 	if (state->flags & flags) {
 		status = nfs41_test_stateid(server, stateid);
@@ -1768,16 +1768,17 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
 
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
 
@@ -4697,7 +4698,7 @@ out:
  */
 static int nfs41_check_expired_locks(struct nfs4_state *state)
 {
-	int status, ret = NFS_OK;
+	int status, ret = -NFS4ERR_BAD_STATEID;
 	struct nfs4_lock_state *lsp;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
@@ -4729,9 +4730,9 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
 
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
 

