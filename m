Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v8 02/11] NFSv4: Add a tracepoint to document open stateid updates
Date: Mon,  6 Nov 2017 15:28:02 -0500
Message-Id: <20171106202811.70202-3-trond.myklebust@primarydata.com>
In-Reply-To: <20171106202811.70202-2-trond.myklebust@primarydata.com>
References: <20171106202811.70202-1-trond.myklebust@primarydata.com>
 <20171106202811.70202-2-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c  | 3 +++
 fs/nfs/nfs4trace.h | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c0d6b48f9e45..f44eef8c92fe 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1481,6 +1481,7 @@ static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
+	trace_nfs4_open_stateid_update(state->inode, stateid, 0);
 out:
 	nfs_state_log_update_open_stateid(state);
 }
@@ -1524,6 +1525,7 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 		write_sequnlock(&state->seqlock);
 		spin_unlock(&state->owner->so_lock);
 		rcu_read_unlock();
+		trace_nfs4_open_stateid_update_wait(state->inode, stateid, 0);
 		if (!signal_pending(current)) {
 			if (schedule_timeout(5*HZ) == 0)
 				status = -EAGAIN;
@@ -1545,6 +1547,7 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
+	trace_nfs4_open_stateid_update(state->inode, stateid, status);
 	nfs_state_log_update_open_stateid(state);
 }
 
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index e7c6275519b0..bf92cfd627fe 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1066,6 +1066,8 @@ DECLARE_EVENT_CLASS(nfs4_inode_stateid_event,
 
 DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_setattr);
 DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_delegreturn);
+DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_open_stateid_update);
+DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_open_stateid_update_wait);
 
 DECLARE_EVENT_CLASS(nfs4_getattr_event,
 		TP_PROTO(
-- 
2.13.6
