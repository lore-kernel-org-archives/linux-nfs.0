Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:10680 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752095AbdCBQep (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:34:45 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 17/19] NFS skip recovery of copy open on dest server
Date: Thu, 2 Mar 2017 11:01:21 -0500
Message-ID: <20170302160123.30375-18-kolga@netapp.com>
In-Reply-To: <20170302160123.30375-1-kolga@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mark the open created for the source file on the destination
server. Then if this open is going thru a recovery, then fail
the recovery as we don't need to be recoving a "fake" open.
We need to fail the ongoing READs and vfs_copy_file_range().

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4_fs.h   |  3 +++
 fs/nfs/nfs4file.c  |  2 +-
 fs/nfs/nfs4state.c | 14 ++++++++++++++
 3 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c23089e..07b93fde 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -161,6 +161,9 @@ enum {
 	NFS_STATE_POSIX_LOCKS,		/* Posix locks are supported */
 	NFS_STATE_RECOVERY_FAILED,	/* OPEN stateid state recovery failed */
 	NFS_STATE_MAY_NOTIFY_LOCK,	/* server may CB_NOTIFY_LOCK */
+#ifdef CONFIG_NFS_V4_2
+	NFS_SRV_SSC_COPY_STATE,		/* ssc state on the dst server */
+#endif /* CONFIG_NFS_V4_2 */
 };
 
 struct nfs4_state {
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 43a2346..f6ccc6f 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -347,7 +347,7 @@ struct file *
 	ctx->state = nfs4_get_open_state(r_ino, sp);
 	if (ctx->state == NULL)
 		goto out_stateowner;
-
+	set_bit(NFS_SRV_SSC_COPY_STATE, &ctx->state->flags);
 	update_open_stateid(ctx->state, stateid, NULL, filep->f_mode);
 
 	nfs_file_set_open_context(filep, ctx);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5827d95..af5d8d7 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1501,6 +1501,9 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 	struct nfs4_state *state;
 	struct nfs4_lock_state *lock;
 	int status = 0;
+#ifdef CONFIG_NFS_V4_2
+	bool found_ssc_copy_state = false;
+#endif /* CONFIG_NFS_V4_2 */
 
 	/* Note: we rely on the sp->so_states list being ordered 
 	 * so that we always reclaim open(O_RDWR) and/or open(O_WRITE)
@@ -1520,6 +1523,13 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 			continue;
 		if (state->state == 0)
 			continue;
+#ifdef CONFIG_NFS_V4_2
+		if (test_bit(NFS_SRV_SSC_COPY_STATE, &state->flags)) {
+			nfs4_state_mark_recovery_failed(state, -EIO);
+			found_ssc_copy_state = true;
+			continue;
+		}
+#endif /* CONFIG_NFS_V4_2 */
 		atomic_inc(&state->count);
 		spin_unlock(&sp->so_lock);
 		status = ops->recover_open(sp, state);
@@ -1582,6 +1592,10 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 	}
 	raw_write_seqcount_end(&sp->so_reclaim_seqcount);
 	spin_unlock(&sp->so_lock);
+#ifdef CONFIG_NFS_V4_2
+	if (found_ssc_copy_state)
+		return -EIO;
+#endif /* CONFIG_NFS_V4_2 */
 	return 0;
 out_err:
 	nfs4_put_open_state(state);
-- 
1.8.3.1

