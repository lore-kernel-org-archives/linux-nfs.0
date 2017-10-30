Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 2/2] NFSv4: Add a tracepoint to document open stateid updates
Date: Mon, 30 Oct 2017 19:49:04 -0400
Message-Id: <20171030234904.17857-3-trond.myklebust@primarydata.com>
In-Reply-To: <20171030234904.17857-2-trond.myklebust@primarydata.com>
References: <20171030234904.17857-1-trond.myklebust@primarydata.com>
 <20171030234904.17857-2-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c  | 3 +++
 fs/nfs/nfs4trace.h | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0f4cb96f66e8..248cf362ce8a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1489,6 +1489,7 @@ static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
+	trace_nfs4_open_stateid_update(state->inode, stateid, 0);
 out:
 	nfs_state_log_update_open_stateid(state);
 }
@@ -1529,6 +1530,7 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 		write_sequnlock(&state->seqlock);
 		spin_unlock(&state->owner->so_lock);
 		rcu_read_unlock();
+		trace_nfs4_open_stateid_update_wait(state->inode, stateid, 0);
 		status = wait_on_bit_timeout(&state->flags,
 				NFS_STATE_CHANGE_WAIT,
 				TASK_KILLABLE, 5*HZ);
@@ -1539,6 +1541,7 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
+	trace_nfs4_open_stateid_update(state->inode, stateid, status);
 }
 
 static void nfs_state_set_open_stateid(struct nfs4_state *state,
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
