From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 24/69] NFSv4: Add a recovery marking scheme for state owners
Date: Tue, 23 Dec 2008 18:02:12 -0500
Message-ID: <20081223230212.13743.80205.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44861 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752461AbYLWXXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:44 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7W021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4_fs.h   |    7 +++++++
 fs/nfs/nfs4proc.c  |    2 ++
 fs/nfs/nfs4state.c |   21 +++++++++++++++++----
 3 files changed, 26 insertions(+), 4 deletions(-)


diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 76eda46..a4e7b3f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -94,12 +94,18 @@ struct nfs4_state_owner {
 
 	spinlock_t	     so_lock;
 	atomic_t	     so_count;
+	unsigned long	     so_flags;
 	struct list_head     so_states;
 	struct list_head     so_delegations;
 	struct nfs_seqid_counter so_seqid;
 	struct rpc_sequence  so_sequence;
 };
 
+enum {
+	NFS_OWNER_RECLAIM_REBOOT,
+	NFS_OWNER_RECLAIM_NOGRACE
+};
+
 /*
  * struct nfs4_state maintains the client-side state for a given
  * (state_owner,inode) tuple (OPEN) or state_owner (LOCK).
@@ -166,6 +172,7 @@ struct nfs4_exception {
 };
 
 struct nfs4_state_recovery_ops {
+	int owner_flag_bit;
 	int state_flag_bit;
 	int (*recover_open)(struct nfs4_state_owner *, struct nfs4_state *);
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 780ba00..019c8d6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3690,12 +3690,14 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 }
 
 struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
+	.owner_flag_bit = NFS_OWNER_RECLAIM_REBOOT,
 	.state_flag_bit	= NFS_STATE_RECLAIM_REBOOT,
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
 };
 
 struct nfs4_state_recovery_ops nfs4_nograce_recovery_ops = {
+	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
 	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a780518..7dcca23 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -832,6 +832,7 @@ static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_st
 		clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
 		return 0;
 	}
+	set_bit(NFS_OWNER_RECLAIM_REBOOT, &state->owner->so_flags);
 	set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
 	return 1;
 }
@@ -840,6 +841,7 @@ static int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_s
 {
 	set_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags);
 	clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
+	set_bit(NFS_OWNER_RECLAIM_NOGRACE, &state->owner->so_flags);
 	set_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state);
 	return 1;
 }
@@ -1043,14 +1045,25 @@ static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recov
 	struct rb_node *pos;
 	int status = 0;
 
-	/* Note: list is protected by exclusive lock on cl->cl_sem */
+restart:
+	spin_lock(&clp->cl_lock);
 	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
 		struct nfs4_state_owner *sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
+		if (!test_and_clear_bit(ops->owner_flag_bit, &sp->so_flags))
+			continue;
+		atomic_inc(&sp->so_count);
+		spin_unlock(&clp->cl_lock);
 		status = nfs4_reclaim_open_state(sp, ops);
-		if (status < 0)
-			break;
+		if (status < 0) {
+			set_bit(ops->owner_flag_bit, &sp->so_flags);
+			nfs4_put_state_owner(sp);
+			nfs4_recovery_handle_error(clp, status);
+			return status;
+		}
+		nfs4_put_state_owner(sp);
+		goto restart;
 	}
-	nfs4_recovery_handle_error(clp, status);
+	spin_unlock(&clp->cl_lock);
 	return status;
 }
 

