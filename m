Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:43537 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752152AbdFSUgO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Jun 2017 16:36:14 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] NFS fix race in state recovery
Date: Mon, 19 Jun 2017 16:36:09 -0400
Message-ID: <20170619203609.62597-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An application can fail with EIO when the server reboots and the
client while doing the recovery is getting into the following
situation where it incorrectly chooses "nograce" recovery instead
of "reboot" recovery. The necessary trigger is a pnfs mount and 2 DS
reads on the same file fail with BAD_STATEID each read uses its own
lock stateid (and MDS server reboots losing state). Since  server
rebooted it will fail recovery ops with BAD_SESSION and then also
STALE_ID triggering session and clientid recovery.

1. Thread1 gets BAD_STATEID initiates stateid recovery calls
nfs4_state_mark_reclaim_no_grace() which sets the cl_state->flags and
state->flags respective _NOGRACE flags.

2. State manager gets to run and it clears the _NOGRACE from the
cl_state. Calls nfs4_do_reclaim() which sends TEST_STATEID which gets
a BAD_SESSION.

3. Thread2 now gets control and it also processing its BAD_STATEID and
calls nfs4_state_mark_reclaim_no_grace() and it again sets the
state/cl_state->flags to have _NOGRACE.

4. State manager runs and continues with state recovery by sending
DESTROY_SESSION, and then CREATE_SESSION which fails with
STALE_CLIENTID. Now we are recovering the lease.

5. State manager in nfs4_recovery_handle_error for STALE_CLIENTID,
calls nfs4_state_start_reclaim_reboot() calls
nfs4_state_mark_reclaim_reboot() which has a check

/* Don't recover state that expired before the reboot */
if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags)) {
  clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
  return 0;
}

Because the _NOGRACE was set again in Step3, we end up clearing
_RECLAIM_REBOOT and not setting _RECLAIM_REBOOT in the cl_state->flags
and choose to do "nograce" operation instead of recovery.

Proposing to introduce a new state flag indicating recovery is
going on and when set in nfs4_state_mark_reclaim_nograce() return.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4_fs.h   | 1 +
 fs/nfs/nfs4state.c | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index af285cc..0f20f12 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -158,6 +158,7 @@ enum {
 	NFS_O_RDWR_STATE,		/* OPEN stateid has read/write state */
 	NFS_STATE_RECLAIM_REBOOT,	/* OPEN stateid server rebooted */
 	NFS_STATE_RECLAIM_NOGRACE,	/* OPEN stateid needs to recover state */
+	NFS_STATE_RECLAIM_INPROGRESS,	/* OPEN stateid is in progress */
 	NFS_STATE_POSIX_LOCKS,		/* Posix locks are supported */
 	NFS_STATE_RECOVERY_FAILED,	/* OPEN stateid state recovery failed */
 	NFS_STATE_MAY_NOTIFY_LOCK,	/* server may CB_NOTIFY_LOCK */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b34de03..4eef2eb 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1335,6 +1335,8 @@ int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *s
 {
 	if (!nfs4_valid_open_stateid(state))
 		return 0;
+	if (test_bit(NFS_STATE_RECLAIM_INPROGRESS, &state->flags))
+		return 1;
 	set_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags);
 	clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
 	set_bit(NFS_OWNER_RECLAIM_NOGRACE, &state->owner->so_flags);
@@ -1522,6 +1524,7 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 			continue;
 		atomic_inc(&state->count);
 		spin_unlock(&sp->so_lock);
+		set_bit(NFS_STATE_RECLAIM_INPROGRESS, &state->flags);
 		status = ops->recover_open(sp, state);
 		if (status >= 0) {
 			status = nfs4_reclaim_locks(state, ops);
@@ -1538,6 +1541,8 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 				}
 				clear_bit(NFS_STATE_RECLAIM_NOGRACE,
 					&state->flags);
+				clear_bit(NFS_STATE_RECLAIM_INPROGRESS,
+					&state->flags);
 				nfs4_put_open_state(state);
 				spin_lock(&sp->so_lock);
 				goto restart;
-- 
1.8.3.1

