Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33020 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965881AbcIVRj1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:39:27 -0400
Received: by mail-io0-f196.google.com with SMTP id r145so5603187ior.0
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 01/31] NFSv4.1: Don't deadlock the state manager on the SEQUENCE status flags
Date: Thu, 22 Sep 2016 13:38:51 -0400
Message-Id: <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As described in RFC5661, section 18.46, some of the status flags exist
in order to tell the client when it needs to acknowledge the existence of
revoked state on the server and/or to recover state.
Those flags will then remain set until the recovery procedure is done.

In order to avoid looping, the client therefore needs to ignore
those particular flags while recovering.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4_fs.h     |  2 +-
 fs/nfs/nfs4proc.c    |  5 ++++-
 fs/nfs/nfs4session.h |  1 +
 fs/nfs/nfs4state.c   | 12 +++++++++++-
 4 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f230aa62ca59..4390d73a92e5 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -439,7 +439,7 @@ extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern int nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
 extern int nfs4_schedule_migration_recovery(const struct nfs_server *);
 extern void nfs4_schedule_lease_moved_recovery(struct nfs_client *);
-extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
+extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags, bool);
 extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct nfs41_server_scope **);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 251e48e7ba16..6b700c59eede 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -616,6 +616,7 @@ int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
 	}
 	spin_unlock(&tbl->slot_tbl_lock);
 
+	slot->privileged = args->sa_privileged ? 1 : 0;
 	args->sa_slot = slot;
 	res->sr_slot = slot;
 
@@ -728,7 +729,8 @@ static int nfs41_sequence_process(struct rpc_task *task,
 		clp = session->clp;
 		do_renew_lease(clp, res->sr_timestamp);
 		/* Check sequence flags */
-		nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
+		nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags,
+				!!slot->privileged);
 		nfs41_update_target_slotid(slot->table, slot, res);
 		break;
 	case 1:
@@ -875,6 +877,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	}
 	spin_unlock(&tbl->slot_tbl_lock);
 
+	slot->privileged = args->sa_privileged ? 1 : 0;
 	args->sa_slot = slot;
 
 	dprintk("<-- %s slotid=%u seqid=%u\n", __func__,
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 3bb6af70973c..dae385500005 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -23,6 +23,7 @@ struct nfs4_slot {
 	u32			slot_nr;
 	u32		 	seq_nr;
 	unsigned int		interrupted : 1,
+				privileged : 1,
 				seq_done : 1;
 };
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index cada00aa5096..9801b5bb5fac 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2227,13 +2227,22 @@ static void nfs41_handle_cb_path_down(struct nfs_client *clp)
 		nfs4_schedule_state_manager(clp);
 }
 
-void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
+void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags,
+		bool recovery)
 {
 	if (!flags)
 		return;
 
 	dprintk("%s: \"%s\" (client ID %llx) flags=0x%08x\n",
 		__func__, clp->cl_hostname, clp->cl_clientid, flags);
+	/*
+	 * If we're called from the state manager thread, then assume we're
+	 * already handling the RECLAIM_NEEDED and/or STATE_REVOKED.
+	 * Those flags are expected to remain set until we're done
+	 * recovering (see RFC5661, section 18.46.3).
+	 */
+	if (recovery)
+		goto out_recovery;
 
 	if (flags & SEQ4_STATUS_RESTART_RECLAIM_NEEDED)
 		nfs41_handle_server_reboot(clp);
@@ -2246,6 +2255,7 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 		nfs4_schedule_lease_moved_recovery(clp);
 	if (flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
 		nfs41_handle_recallable_state_revoked(clp);
+out_recovery:
 	if (flags & SEQ4_STATUS_BACKCHANNEL_FAULT)
 		nfs41_handle_backchannel_fault(clp);
 	else if (flags & (SEQ4_STATUS_CB_PATH_DOWN |
-- 
2.7.4

