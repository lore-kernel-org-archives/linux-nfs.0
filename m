Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-it0-f65.google.com ([209.85.214.65]:36148 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965253AbcIVRkJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:40:09 -0400
Received: by mail-it0-f65.google.com with SMTP id n143so5337213ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:40:08 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 31/31] NFSv4.1: Even if the stateid is OK, we may need to recover the open modes
Date: Thu, 22 Sep 2016 13:39:21 -0400
Message-Id: <1474565961-21303-32-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-31-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-15-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-16-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-17-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-18-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-19-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-20-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-21-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-22-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-23-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-24-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-25-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-26-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-27-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-28-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-29-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-30-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-31-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

TEST_STATEID only tells you that you have a valid open stateid. It doesn't
tell the client anything about whether or not it holds the required share
locks.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 30 +++++++++++++++++++++---------
 1 file changed, 21 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 72858f900abf..7b8054db5e0f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1387,6 +1387,17 @@ static void update_open_stateflags(struct nfs4_state *state, fmode_t fmode)
 	nfs4_state_set_mode_locked(state, state->state | fmode);
 }
 
+static bool nfs_open_stateid_recover_openmode(struct nfs4_state *state)
+{
+	if (state->n_rdonly && !test_bit(NFS_O_RDONLY_STATE, &state->flags))
+		return true;
+	if (state->n_wronly && !test_bit(NFS_O_WRONLY_STATE, &state->flags))
+		return true;
+	if (state->n_rdwr && !test_bit(NFS_O_RDWR_STATE, &state->flags))
+		return true;
+	return false;
+}
+
 static void nfs_test_and_clear_all_open_stateid(struct nfs4_state *state)
 {
 	struct nfs_client *clp = state->owner->so_server->nfs_client;
@@ -2589,16 +2600,13 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 	int status;
 
 	if (test_bit(NFS_OPEN_STATE, &state->flags) == 0) {
-		if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
-			return NFS_OK;
+		if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)  {
+			if (nfs4_have_delegation(state->inode, state->state))
+				return NFS_OK;
+			return -NFS4ERR_OPENMODE;
+		}
 		return -NFS4ERR_BAD_STATEID;
 	}
-	/* If a state reset has been done, test_stateid is unneeded */
-	if ((test_bit(NFS_O_RDONLY_STATE, &state->flags) == 0) &&
-	    (test_bit(NFS_O_WRONLY_STATE, &state->flags) == 0) &&
-	    (test_bit(NFS_O_RDWR_STATE, &state->flags) == 0))
-		return -NFS4ERR_BAD_STATEID;
-
 	status = nfs41_test_and_free_expired_stateid(server, stateid, cred);
 	trace_nfs4_test_open_stateid(state, NULL, status);
 	if (status == -NFS4ERR_EXPIRED || status == -NFS4ERR_BAD_STATEID) {
@@ -2608,7 +2616,11 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 		clear_bit(NFS_OPEN_STATE, &state->flags);
 		stateid->type = NFS4_INVALID_STATEID_TYPE;
 	}
-	return status;
+	if (status != NFS_OK)
+		return status;
+	if (nfs_open_stateid_recover_openmode(state))
+		return -NFS4ERR_OPENMODE;
+	return NFS_OK;
 }
 
 static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
-- 
2.7.4

