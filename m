Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34731 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753610AbcKNQUA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2016 11:20:00 -0500
Received: by mail-it0-f66.google.com with SMTP id q124so15178889itd.1
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2016 08:19:59 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] NFSv4: Fix CLOSE races with OPEN
Date: Mon, 14 Nov 2016 11:19:55 -0500
Message-Id: <1479140396-17779-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1479140396-17779-1-git-send-email-trond.myklebust@primarydata.com>
References: <1479140396-17779-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the reply to a successful CLOSE call races with an OPEN to the same
file, we can end up scribbling over the stateid that represents the
new open state.
The race looks like:

  Client				Server
  ======				======

  CLOSE stateid A on file "foo"
					CLOSE stateid A, return stateid C
  OPEN file "foo"
					OPEN "foo", return stateid B
  Receive reply to OPEN
  Reset open state for "foo"
  Associate stateid B to "foo"

  Receive CLOSE for A
  Reset open state for "foo"
  Replace stateid B with C

The fix is to examine the argument of the CLOSE, and check for a match
with the current stateid "other" field. If the two do not match, then
the above race occurred, and we should just ignore the CLOSE.

Reported-by: Benjamin Coddington <bcodding@redhat.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4_fs.h  |  7 +++++++
 fs/nfs/nfs4proc.c | 12 ++++++------
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9b3a82abab07..1452177c822d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -542,6 +542,13 @@ static inline bool nfs4_valid_open_stateid(const struct nfs4_state *state)
 	return test_bit(NFS_STATE_RECOVERY_FAILED, &state->flags) == 0;
 }
 
+static inline bool nfs4_state_match_open_stateid_other(const struct nfs4_state *state,
+		const nfs4_stateid *stateid)
+{
+	return test_bit(NFS_OPEN_STATE, &state->flags) &&
+		nfs4_stateid_match_other(&state->open_stateid, stateid);
+}
+
 #else
 
 #define nfs4_close_state(a, b) do { } while (0)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f550ac69ffa0..b7b0080977c0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1458,7 +1458,6 @@ static void nfs_resync_open_stateid_locked(struct nfs4_state *state)
 }
 
 static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
-		nfs4_stateid *arg_stateid,
 		nfs4_stateid *stateid, fmode_t fmode)
 {
 	clear_bit(NFS_O_RDWR_STATE, &state->flags);
@@ -1476,10 +1475,9 @@ static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
 	}
 	if (stateid == NULL)
 		return;
-	/* Handle races with OPEN */
-	if (!nfs4_stateid_match_other(arg_stateid, &state->open_stateid) ||
-	    (nfs4_stateid_match_other(stateid, &state->open_stateid) &&
-	    !nfs4_stateid_is_newer(stateid, &state->open_stateid))) {
+	/* Handle OPEN+OPEN_DOWNGRADE races */
+	if (nfs4_stateid_match_other(stateid, &state->open_stateid) &&
+	    !nfs4_stateid_is_newer(stateid, &state->open_stateid)) {
 		nfs_resync_open_stateid_locked(state);
 		return;
 	}
@@ -1493,7 +1491,9 @@ static void nfs_clear_open_stateid(struct nfs4_state *state,
 	nfs4_stateid *stateid, fmode_t fmode)
 {
 	write_seqlock(&state->seqlock);
-	nfs_clear_open_stateid_locked(state, arg_stateid, stateid, fmode);
+	/* Ignore, if the CLOSE argment doesn't match the current stateid */
+	if (nfs4_state_match_open_stateid_other(state, arg_stateid))
+		nfs_clear_open_stateid_locked(state, stateid, fmode);
 	write_sequnlock(&state->seqlock);
 	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
 		nfs4_schedule_state_manager(state->owner->so_server->nfs_client);
-- 
2.7.4

