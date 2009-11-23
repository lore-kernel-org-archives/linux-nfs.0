From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 10/10] nfs41: check SEQUENCE status flag
Date: Mon, 23 Nov 2009 13:54:47 -0800
Message-ID: <1259013287-3349-10-git-send-email-batsakis@netapp.com>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
 <1259013287-3349-2-git-send-email-batsakis@netapp.com>
 <1259013287-3349-3-git-send-email-batsakis@netapp.com>
 <1259013287-3349-4-git-send-email-batsakis@netapp.com>
 <1259013287-3349-5-git-send-email-batsakis@netapp.com>
 <1259013287-3349-6-git-send-email-batsakis@netapp.com>
 <1259013287-3349-7-git-send-email-batsakis@netapp.com>
 <1259013287-3349-8-git-send-email-batsakis@netapp.com>
 <1259013287-3349-9-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42997 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757294AbZKWV70 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 16:59:26 -0500
In-Reply-To: <1259013287-3349-9-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the server can indicate a number of error conditions by setting the
appropriate bits in the SEQUENCE operation. The client re-establishes
state with the server when it receives one of those, with the action
depending on the specific case.

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4_fs.h        |    1 +
 fs/nfs/nfs4proc.c       |    2 ++
 fs/nfs/nfs4state.c      |   22 ++++++++++++++++++++++
 fs/nfs/nfs4xdr.c        |    4 ++--
 include/linux/nfs4.h    |    2 ++
 include/linux/nfs_xdr.h |    1 +
 6 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index df1299e..d792b7d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -267,6 +267,7 @@ extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_state_recovery(struct nfs_client *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
+extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
 extern void nfs4_copy_stateid(nfs4_stateid *, struct nfs4_state *, fl_owner_t);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6a0f9ea..4b1938b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -388,6 +388,8 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 		if (time_before(clp->cl_last_renewal, timestamp))
 			clp->cl_last_renewal = timestamp;
 		spin_unlock(&clp->cl_lock);
+		/* Check sequence flags */
+		nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
 		return;
 	}
 out:
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2ef4fec..340cdee 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1151,6 +1151,28 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 }
 
 #ifdef CONFIG_NFS_V4_1
+void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
+{
+	if (!flags)
+		return;
+	else if (flags & SEQ4_STATUS_RESTART_RECLAIM_NEEDED) {
+		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+		nfs4_state_start_reclaim_reboot(clp);
+		nfs4_schedule_state_recovery(clp);
+	} else if (flags & (SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED |
+			    SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED |
+			    SEQ4_STATUS_ADMIN_STATE_REVOKED |
+			    SEQ4_STATUS_RECALLABLE_STATE_REVOKED |
+			    SEQ4_STATUS_LEASE_MOVED)) {
+		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+		nfs4_state_start_reclaim_nograce(clp);
+		nfs4_schedule_state_recovery(clp);
+	} else if (flags & (SEQ4_STATUS_CB_PATH_DOWN |
+			    SEQ4_STATUS_BACKCHANNEL_FAULT |
+			    SEQ4_STATUS_CB_PATH_DOWN_SESSION))
+		nfs_expire_all_delegations(clp);
+}
+
 static void nfs4_session_recovery_handle_error(struct nfs_client *clp, int err)
 {
 	switch (err) {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 3875759..ec5aec1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4614,8 +4614,8 @@ static int decode_sequence(struct xdr_stream *xdr,
 	dummy = be32_to_cpup(p++);
 	/* target highest slot id - currently not processed */
 	dummy = be32_to_cpup(p++);
-	/* result flags - currently not processed */
-	dummy = be32_to_cpup(p);
+	/* result flags */
+	res->sr_status_flags = be32_to_cpup(p);
 	status = 0;
 out_err:
 	res->sr_status = status;
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index c4c0602..89404bf 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -128,6 +128,8 @@
 #define SEQ4_STATUS_RECALLABLE_STATE_REVOKED	0x00000040
 #define SEQ4_STATUS_LEASE_MOVED			0x00000080
 #define SEQ4_STATUS_RESTART_RECLAIM_NEEDED	0x00000100
+#define SEQ4_STATUS_CB_PATH_DOWN_SESSION	0x00000200
+#define SEQ4_STATUS_BACKCHANNEL_FAULT		0x00000400
 
 #define NFS4_MAX_UINT64	(~(u64)0)
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 62f63fb..b0c65e4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -172,6 +172,7 @@ struct nfs4_sequence_res {
 	u8			sr_slotid;	/* slot used to send request */
 	unsigned long		sr_renewal_time;
 	int			sr_status;	/* sequence operation status */
+	u32			sr_status_flags;
 };
 
 struct nfs4_get_lease_time_args {
-- 
1.6.2.5

