Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:51110 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402AbaBKThN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 14:37:13 -0500
Received: by mail-ig0-f177.google.com with SMTP id k19so9403707igc.4
        for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 11:37:13 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4: Don't update the open stateid unless it is newer than the old one
Date: Tue, 11 Feb 2014 14:37:04 -0500
Message-Id: <1392147428-23087-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392147428-23087-1-git-send-email-trond.myklebust@primarydata.com>
References: <1392147428-23087-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch is in preparation for the NFSv4.1 parallel open capability.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4_fs.h  | 10 ++++++++++
 fs/nfs/nfs4proc.c | 21 +++++++++++++++++----
 2 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a5b27c2d9689..df81fcc138a7 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -500,6 +500,16 @@ static inline bool nfs4_stateid_match(const nfs4_stateid *dst, const nfs4_statei
 	return memcmp(dst, src, sizeof(*dst)) == 0;
 }
 
+static inline bool nfs4_stateid_match_other(const nfs4_stateid *dst, const nfs4_stateid *src)
+{
+	return memcmp(dst->other, src->other, NFS4_STATEID_OTHER_SIZE) == 0;
+}
+
+static inline bool nfs4_stateid_is_newer(const nfs4_stateid *s1, const nfs4_stateid *s2)
+{
+	return (s32)(be32_to_cpu(s1->seqid) - be32_to_cpu(s2->seqid)) > 0;
+}
+
 static inline bool nfs4_valid_open_stateid(const struct nfs4_state *state)
 {
 	return test_bit(NFS_STATE_RECOVERY_FAILED, &state->flags) == 0;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2da6a698b8f7..96e0bd42f38c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1137,12 +1137,20 @@ static void update_open_stateflags(struct nfs4_state *state, fmode_t fmode)
 	nfs4_state_set_mode_locked(state, state->state | fmode);
 }
 
+static bool nfs_need_update_open_stateid(struct nfs4_state *state,
+		nfs4_stateid *stateid)
+{
+	if (test_and_set_bit(NFS_OPEN_STATE, &state->flags) == 0)
+		return true;
+	if (!nfs4_stateid_match_other(stateid, &state->open_stateid))
+		return true;
+	if (nfs4_stateid_is_newer(stateid, &state->open_stateid))
+		return true;
+	return false;
+}
+
 static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
 {
-	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
-		nfs4_stateid_copy(&state->stateid, stateid);
-	nfs4_stateid_copy(&state->open_stateid, stateid);
-	set_bit(NFS_OPEN_STATE, &state->flags);
 	switch (fmode) {
 		case FMODE_READ:
 			set_bit(NFS_O_RDONLY_STATE, &state->flags);
@@ -1153,6 +1161,11 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *
 		case FMODE_READ|FMODE_WRITE:
 			set_bit(NFS_O_RDWR_STATE, &state->flags);
 	}
+	if (!nfs_need_update_open_stateid(state, stateid))
+		return;
+	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
+		nfs4_stateid_copy(&state->stateid, stateid);
+	nfs4_stateid_copy(&state->open_stateid, stateid);
 }
 
 static void nfs_set_open_stateid(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
-- 
1.8.5.3

