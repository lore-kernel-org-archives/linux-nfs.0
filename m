Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] NFSv4: Add a tracepoint to document open stateid updates
Date: Fri, 27 Oct 2017 12:43:17 -0400
Message-Id: <20171027164317.86962-3-trond.myklebust@primarydata.com>
In-Reply-To: <20171027164317.86962-2-trond.myklebust@primarydata.com>
References: <20171027164317.86962-1-trond.myklebust@primarydata.com>
 <20171027164317.86962-2-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c  | 3 +++
 fs/nfs/nfs4trace.h | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 985fe45596e2..9f64b4eeea59 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1488,6 +1488,7 @@ static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
+	trace_nfs4_open_stateid_update(state->inode, stateid, 0);
 out:
 	nfs_state_log_update_open_stateid(state);
 }
@@ -1536,6 +1537,7 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 		write_sequnlock(&state->seqlock);
 		spin_unlock(&state->owner->so_lock);
 		rcu_read_unlock();
+		trace_nfs4_open_stateid_update_wait(state->inode, stateid, 0);
 		status = wait_on_bit_timeout(&state->flags,
 				NFS_STATE_CHANGE_WAIT,
 				TASK_KILLABLE, 5*HZ);
@@ -1546,6 +1548,7 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
+	trace_nfs4_open_stateid_update(state->inode, stateid, status);
 	nfs_state_log_update_open_stateid(state);
 }
 
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index be1da19c65d6..b9962d93e746 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1065,6 +1065,8 @@ DECLARE_EVENT_CLASS(nfs4_inode_stateid_event,
 
 DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_setattr);
 DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_delegreturn);
+DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_open_stateid_update);
+DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_open_stateid_update_wait);
 
 DECLARE_EVENT_CLASS(nfs4_getattr_event,
 		TP_PROTO(
-- 
2.13.6
