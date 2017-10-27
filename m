Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] NFSv4: Fix OPEN / CLOSE race
Date: Fri, 27 Oct 2017 12:43:16 -0400
Message-Id: <20171027164317.86962-2-trond.myklebust@primarydata.com>
In-Reply-To: <20171027164317.86962-1-trond.myklebust@primarydata.com>
References: <20171027164317.86962-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Ben Coddington has noted the following race between OPEN and CLOSE
on a single client.

Process 1		Process 2		Server
=========		=========		======

1)  OPEN file
2)			OPEN file
3)						Process OPEN (1) seqid=1
4)						Process OPEN (2) seqid=2
5)						Reply OPEN (2)
6)			Receive reply (2)
7)			new stateid, seqid=2

8)			CLOSE file, using
			stateid w/ seqid=2
9)						Reply OPEN (1)
10(						Process CLOSE (8)
11)						Reply CLOSE (8)
12)						Forget stateid
						file closed

13)			Receive reply (7)
14)			Forget stateid
			file closed.

15) Receive reply (1).
16) New stateid seqid=1
    is really the same
    stateid that was
    closed.

IOW: the reply to the first OPEN is delayed. Since "Process 2" does
not wait before closing the file, and it does not cache the closed
stateid, then when the delayed reply is finally received, it is treated
as setting up a new stateid by the client.

The fix is to ensure that the client processes the OPEN and CLOSE calls
in the same order in which the server processed them.

This commit ensures that we examine the seqid of the stateid
returned by OPEN. If it is a new stateid, we assume the seqid
must be equal to the value 1, and that each state transition
increments the seqid value by 1 (See RFC7530, Section 9.1.4.2,
and RFC5661, Section 8.2.2).

If the tracker sees that an OPEN returns with a seqid that is greater
than the cached seqid + 1, then it bumps a flag to ensure that the
caller waits for the RPCs carrying the missing seqids to complete.

Note that there can still be pathologies where the server crashes before
it can even send us the missing seqids. Since the OPEN call is still
holding a slot when it waits here, that could cause the recovery to
stall forever. To avoid that, we time out after a 5 second wait.

Reported-by: Benjamin Coddington <bcodding@redhat.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4_fs.h  |   1 +
 fs/nfs/nfs4proc.c | 130 ++++++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 103 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b547d935aaf0..46aeaa2ee700 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -161,6 +161,7 @@ enum {
 	NFS_STATE_POSIX_LOCKS,		/* Posix locks are supported */
 	NFS_STATE_RECOVERY_FAILED,	/* OPEN stateid state recovery failed */
 	NFS_STATE_MAY_NOTIFY_LOCK,	/* server may CB_NOTIFY_LOCK */
+	NFS_STATE_CHANGE_WAIT,		/* A state changing operation is outstanding */
 };
 
 struct nfs4_state {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 96b2077e691d..985fe45596e2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1378,6 +1378,28 @@ static bool nfs_open_stateid_recover_openmode(struct nfs4_state *state)
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+static void nfs_state_log_update_open_stateid(struct nfs4_state *state)
+{
+	if (test_and_clear_bit(NFS_STATE_CHANGE_WAIT, &state->flags))
+		wake_up_bit(&state->flags, NFS_STATE_CHANGE_WAIT);
+}
+
+static void nfs_state_reset_open_stateid(struct nfs4_state *state)
+{
+	state->open_stateid.seqid = 0;
+	nfs_state_log_update_open_stateid(state);
+}
+
+static void nfs_state_log_out_of_order_open_stateid(struct nfs4_state *state,
+		const nfs4_stateid *stateid)
+{
+	u32 state_seqid = be32_to_cpu(state->open_stateid.seqid);
+	u32 stateid_seqid = be32_to_cpu(stateid->seqid);
+
+	if (stateid_seqid != state_seqid + 1U)
+		set_bit(NFS_STATE_CHANGE_WAIT, &state->flags);
+}
+
 static void nfs_test_and_clear_all_open_stateid(struct nfs4_state *state)
 {
 	struct nfs_client *clp = state->owner->so_server->nfs_client;
@@ -1393,18 +1415,34 @@ static void nfs_test_and_clear_all_open_stateid(struct nfs4_state *state)
 		nfs4_state_mark_reclaim_nograce(clp, state);
 }
 
+/*
+ * Check for whether or not the caller may update the open stateid
+ * to the value passed in by stateid.
+ *
+ * Note: This function relies heavily on the server implementing
+ * RFC7530 Section 9.1.4.2, and RFC5661 Section 8.2.2
+ * correctly.
+ * i.e. The stateid seqids have to be initialised to 1, and
+ * are then incremented on every state transition.
+ */
 static bool nfs_need_update_open_stateid(struct nfs4_state *state,
 		const nfs4_stateid *stateid, nfs4_stateid *freeme)
 {
-	if (test_and_set_bit(NFS_OPEN_STATE, &state->flags) == 0)
-		return true;
-	if (!nfs4_stateid_match_other(stateid, &state->open_stateid)) {
-		nfs4_stateid_copy(freeme, &state->open_stateid);
-		nfs_test_and_clear_all_open_stateid(state);
+	if (test_and_set_bit(NFS_OPEN_STATE, &state->flags) == 0) {
+		nfs_state_reset_open_stateid(state);
+	} else if (!nfs4_stateid_match_other(stateid, &state->open_stateid)) {
+		if (stateid->seqid == cpu_to_be32(1)) {
+			nfs4_stateid_copy(freeme, &state->open_stateid);
+			nfs_test_and_clear_all_open_stateid(state);
+			nfs_state_reset_open_stateid(state);
+		} else
+			set_bit(NFS_STATE_CHANGE_WAIT, &state->flags);
 		return true;
 	}
-	if (nfs4_stateid_is_newer(stateid, &state->open_stateid))
+	if (nfs4_stateid_is_newer(stateid, &state->open_stateid)) {
+		nfs_state_log_out_of_order_open_stateid(state, stateid);
 		return true;
+	}
 	return false;
 }
 
@@ -1439,15 +1477,19 @@ static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
 	}
 	if (stateid == NULL)
 		return;
+	/* Handle reboot/state expire races */
+	if (!nfs4_stateid_match_other(stateid, &state->open_stateid))
+		return;
 	/* Handle OPEN+OPEN_DOWNGRADE races */
-	if (nfs4_stateid_match_other(stateid, &state->open_stateid) &&
-	    !nfs4_stateid_is_newer(stateid, &state->open_stateid)) {
+	if (!nfs4_stateid_is_newer(stateid, &state->open_stateid)) {
 		nfs_resync_open_stateid_locked(state);
-		return;
+		goto out;
 	}
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
+out:
+	nfs_state_log_update_open_stateid(state);
 }
 
 static void nfs_clear_open_stateid(struct nfs4_state *state,
@@ -1467,7 +1509,10 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 		const nfs4_stateid *stateid, fmode_t fmode,
 		nfs4_stateid *freeme)
 {
-	switch (fmode) {
+	int status = 0;
+	for (;;) {
+
+		switch (fmode) {
 		case FMODE_READ:
 			set_bit(NFS_O_RDONLY_STATE, &state->flags);
 			break;
@@ -1476,17 +1521,36 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 			break;
 		case FMODE_READ|FMODE_WRITE:
 			set_bit(NFS_O_RDWR_STATE, &state->flags);
+		}
+		if (!nfs_need_update_open_stateid(state, stateid, freeme))
+			return;
+		if (!test_bit(NFS_STATE_CHANGE_WAIT, &state->flags))
+			break;
+		if (status)
+			break;
+		/*
+		 * Ensure we process the state changes in the same order
+		 * in which the server processed them by delaying the
+		 * update of the stateid until we are in sequence.
+		 */
+		write_sequnlock(&state->seqlock);
+		spin_unlock(&state->owner->so_lock);
+		rcu_read_unlock();
+		status = wait_on_bit_timeout(&state->flags,
+				NFS_STATE_CHANGE_WAIT,
+				TASK_KILLABLE, 5*HZ);
+		rcu_read_lock();
+		spin_lock(&state->owner->so_lock);
+		write_seqlock(&state->seqlock);
 	}
-	if (!nfs_need_update_open_stateid(state, stateid, freeme))
-		return;
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
+	nfs_state_log_update_open_stateid(state);
 }
 
-static void __update_open_stateid(struct nfs4_state *state,
+static void nfs_state_set_open_stateid(struct nfs4_state *state,
 		const nfs4_stateid *open_stateid,
-		const nfs4_stateid *deleg_stateid,
 		fmode_t fmode,
 		nfs4_stateid *freeme)
 {
@@ -1494,17 +1558,25 @@ static void __update_open_stateid(struct nfs4_state *state,
 	 * Protect the call to nfs4_state_set_mode_locked and
 	 * serialise the stateid update
 	 */
-	spin_lock(&state->owner->so_lock);
 	write_seqlock(&state->seqlock);
-	if (deleg_stateid != NULL) {
-		nfs4_stateid_copy(&state->stateid, deleg_stateid);
-		set_bit(NFS_DELEGATED_STATE, &state->flags);
-	}
-	if (open_stateid != NULL)
-		nfs_set_open_stateid_locked(state, open_stateid, fmode, freeme);
+	nfs_set_open_stateid_locked(state, open_stateid, fmode, freeme);
+	write_sequnlock(&state->seqlock);
+	update_open_stateflags(state, fmode);
+}
+
+static void nfs_state_set_delegation(struct nfs4_state *state,
+		const nfs4_stateid *deleg_stateid,
+		fmode_t fmode)
+{
+	/*
+	 * Protect the call to nfs4_state_set_mode_locked and
+	 * serialise the stateid update
+	 */
+	write_seqlock(&state->seqlock);
+	nfs4_stateid_copy(&state->stateid, deleg_stateid);
+	set_bit(NFS_DELEGATED_STATE, &state->flags);
 	write_sequnlock(&state->seqlock);
 	update_open_stateflags(state, fmode);
-	spin_unlock(&state->owner->so_lock);
 }
 
 static int update_open_stateid(struct nfs4_state *state,
@@ -1522,6 +1594,12 @@ static int update_open_stateid(struct nfs4_state *state,
 	fmode &= (FMODE_READ|FMODE_WRITE);
 
 	rcu_read_lock();
+	spin_lock(&state->owner->so_lock);
+	if (open_stateid != NULL) {
+		nfs_state_set_open_stateid(state, open_stateid, fmode, &freeme);
+		ret = 1;
+	}
+
 	deleg_cur = rcu_dereference(nfsi->delegation);
 	if (deleg_cur == NULL)
 		goto no_delegation;
@@ -1538,18 +1616,14 @@ static int update_open_stateid(struct nfs4_state *state,
 		goto no_delegation_unlock;
 
 	nfs_mark_delegation_referenced(deleg_cur);
-	__update_open_stateid(state, open_stateid, &deleg_cur->stateid,
-			fmode, &freeme);
+	nfs_state_set_delegation(state, &deleg_cur->stateid, fmode);
 	ret = 1;
 no_delegation_unlock:
 	spin_unlock(&deleg_cur->lock);
 no_delegation:
+	spin_unlock(&state->owner->so_lock);
 	rcu_read_unlock();
 
-	if (!ret && open_stateid != NULL) {
-		__update_open_stateid(state, open_stateid, NULL, fmode, &freeme);
-		ret = 1;
-	}
 	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
 		nfs4_schedule_state_manager(clp);
 	if (freeme.type != 0)
-- 
2.13.6
