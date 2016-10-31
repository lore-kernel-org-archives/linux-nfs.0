Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:52660 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942673AbcJaNUN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2016 09:20:13 -0400
Date: Mon, 31 Oct 2016 14:19:59 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        List Linux Kernel Mailing <linux-kernel@vger.kernel.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>
Subject: [PATCH v3] NFSv4: replace seqcount_t with a rw_semaphore
Message-ID: <20161031131958.mrrez5t7sow75p6v@linutronix.de>
References: <20161021164727.24485-1-bigeasy@linutronix.de>
 <20161028210511.k7hrsfxovti7gqtu@linutronix.de>
 <747E2CCB-3D83-40FD-8B31-46AB5A5E8592@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <747E2CCB-3D83-40FD-8B31-46AB5A5E8592@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The raw_write_seqcount_begin() in nfs4_reclaim_open_state() bugs me
because it maps to preempt_disable() in -RT which I can't have at this
point. So I took a look at the code.
It the lockdep part was removed in commit abbec2da13f0 ("NFS: Use
raw_write_seqcount_begin/end int nfs4_reclaim_open_state") because
lockdep complained. The whole seqcount thing was introduced in commit
c137afabe330 ("NFSv4: Allow the state manager to mark an open_owner as
being recovered").
Trond Myklebust confirms that there i only one writer thread at
nfs4_reclaim_open_state()

The list_for_each_entry() in nfs4_reclaim_open_state:
It seems that this lock protects the ->so_states list among other
atomic_t & flags members. So at the begin of the loop we inc ->count
ensuring that this field is not removed while we use it. So we drop the
->so_lock loc during the loop it seems. And after nfs4_reclaim_locks()
invocation we nfs4_put_open_state() and grab the ->so_lock again. So if
we were the last user of this struct and we remove it, then the
following list_next_entry() invocation is a use-after-free. Even if we
use list_for_each_entry_safe() there is no guarantee that the following
member is still valid because it might have been removed by someone
invoking nfs4_put_open_state() on it, right?
So there is this.

However to address my initial problem I have here a patch :) So it uses
a rw_semaphore which ensures that there is only one writer at a time or
multiple reader. So it should be basically what is happening now plus a
tiny tiny tiny lock plus lockdep coverage. I tried to this myself but I
don't manage to get into this code path at all so I might be doing
something wrong.

Could you please check if this patch is working for you and whether my
list_for_each_entry() observation is correct or not?

v2…v3: replace the seqlock with a RW semaphore.

v1…v2: write_seqlock() disables preemption and some function need it
(thread_run(), non-GFP_ATOMIC memory alloction()). We don't want
preemption enabled because a preempted writer would stall the reader
spinning. This is a duct tape mutex. Maybe the seqlock should go.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 fs/nfs/delegation.c |  6 ++----
 fs/nfs/nfs4_fs.h    |  2 +-
 fs/nfs/nfs4proc.c   |  9 +++------
 fs/nfs/nfs4state.c  | 10 ++++------
 4 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index dff600ae0d74..55d5531aedbb 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -130,7 +130,6 @@ static int nfs_delegation_claim_opens(struct inode *inode,
 	struct nfs_open_context *ctx;
 	struct nfs4_state_owner *sp;
 	struct nfs4_state *state;
-	unsigned int seq;
 	int err;
 
 again:
@@ -150,12 +149,11 @@ static int nfs_delegation_claim_opens(struct inode *inode,
 		sp = state->owner;
 		/* Block nfs4_proc_unlck */
 		mutex_lock(&sp->so_delegreturn_mutex);
-		seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
+		down_read(&sp->so_reclaim_rw);
 		err = nfs4_open_delegation_recall(ctx, state, stateid, type);
 		if (!err)
 			err = nfs_delegation_claim_locks(ctx, state, stateid);
-		if (!err && read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
-			err = -EAGAIN;
+		up_read(&sp->so_reclaim_rw);
 		mutex_unlock(&sp->so_delegreturn_mutex);
 		put_nfs_open_context(ctx);
 		if (err != 0)
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9b3a82abab07..03d37826a183 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -111,7 +111,7 @@ struct nfs4_state_owner {
 	unsigned long	     so_flags;
 	struct list_head     so_states;
 	struct nfs_seqid_counter so_seqid;
-	seqcount_t	     so_reclaim_seqcount;
+	struct rw_semaphore  so_reclaim_rw;
 	struct mutex	     so_delegreturn_mutex;
 };
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7897826d7c51..ba6589d1fd36 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2682,10 +2682,9 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	struct nfs_server *server = sp->so_server;
 	struct dentry *dentry;
 	struct nfs4_state *state;
-	unsigned int seq;
 	int ret;
 
-	seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
+	down_read(&sp->so_reclaim_rw);
 
 	ret = _nfs4_proc_open(opendata);
 	if (ret != 0)
@@ -2721,12 +2720,10 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 		goto out;
 
 	ctx->state = state;
-	if (d_inode(dentry) == state->inode) {
+	if (d_inode(dentry) == state->inode)
 		nfs_inode_attach_open_context(ctx);
-		if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
-			nfs4_schedule_stateid_recovery(server, state);
-	}
 out:
+	up_read(&sp->so_reclaim_rw);
 	return ret;
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5f4281ec5f72..61c431fa2fe3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -488,7 +488,7 @@ nfs4_alloc_state_owner(struct nfs_server *server,
 	nfs4_init_seqid_counter(&sp->so_seqid);
 	atomic_set(&sp->so_count, 1);
 	INIT_LIST_HEAD(&sp->so_lru);
-	seqcount_init(&sp->so_reclaim_seqcount);
+	init_rwsem(&sp->so_reclaim_rw);
 	mutex_init(&sp->so_delegreturn_mutex);
 	return sp;
 }
@@ -1497,8 +1497,8 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 	 * recovering after a network partition or a reboot from a
 	 * server that doesn't support a grace period.
 	 */
+	down_write(&sp->so_reclaim_rw);
 	spin_lock(&sp->so_lock);
-	raw_write_seqcount_begin(&sp->so_reclaim_seqcount);
 restart:
 	list_for_each_entry(state, &sp->so_states, open_states) {
 		if (!test_and_clear_bit(ops->state_flag_bit, &state->flags))
@@ -1566,14 +1566,12 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 		spin_lock(&sp->so_lock);
 		goto restart;
 	}
-	raw_write_seqcount_end(&sp->so_reclaim_seqcount);
 	spin_unlock(&sp->so_lock);
+	up_write(&sp->so_reclaim_rw);
 	return 0;
 out_err:
 	nfs4_put_open_state(state);
-	spin_lock(&sp->so_lock);
-	raw_write_seqcount_end(&sp->so_reclaim_seqcount);
-	spin_unlock(&sp->so_lock);
+	up_write(&sp->so_reclaim_rw);
 	return status;
 }
 
-- 
2.10.2

