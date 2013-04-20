Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:5858 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802Ab3DTFls (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Apr 2013 01:41:48 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Use the open stateid if the delegation has the wrong mode
Date: Sat, 20 Apr 2013 01:41:45 -0400
Message-Id: <1366436506-25033-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix nfs4_select_rw_stateid() so that it chooses the open stateid
(or an all-zero stateid) if the delegation does not match the selected
read/write mode.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   | 1 +
 fs/nfs/nfs4proc.c  | 1 +
 fs/nfs/nfs4state.c | 6 +++++-
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 7ef19ce..553a83c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -144,6 +144,7 @@ struct nfs4_lock_state {
 enum {
 	LK_STATE_IN_USE,
 	NFS_DELEGATED_STATE,		/* Current stateid is delegation */
+	NFS_OPEN_STATE,			/* OPEN stateid is set */
 	NFS_O_RDONLY_STATE,		/* OPEN stateid has read-only state */
 	NFS_O_WRONLY_STATE,		/* OPEN stateid has write-only state */
 	NFS_O_RDWR_STATE,		/* OPEN stateid has read/write state */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 282d9fa..3984936 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -978,6 +978,7 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
+	set_bit(NFS_OPEN_STATE, &state->flags);
 	switch (fmode) {
 		case FMODE_READ:
 			set_bit(NFS_O_RDONLY_STATE, &state->flags);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1eb1728..b779695 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1024,12 +1024,16 @@ out:
 
 static int nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 {
+	const nfs4_stateid *src;
 	int ret;
 	int seq;
 
 	do {
+		src = &zero_stateid;
 		seq = read_seqbegin(&state->seqlock);
-		nfs4_stateid_copy(dst, &state->stateid);
+		if (test_bit(NFS_OPEN_STATE, &state->flags))
+			src = &state->open_stateid;
+		nfs4_stateid_copy(dst, src);
 		ret = 0;
 		smp_rmb();
 		if (!list_empty(&state->owner->so_seqid.list))
-- 
1.8.1.4

