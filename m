Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:52828 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754809AbcJUQrv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2016 12:47:51 -0400
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, tglx@linutronix.de,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [RFC PATCH] NFSv4: replace seqcount_t with a seqlock_t
Date: Fri, 21 Oct 2016 18:47:27 +0200
Message-Id: <20161021164727.24485-1-bigeasy@linutronix.de>
MIME-Version: 1.0
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
I don't understand how it is possible that we don't end up with two
writers for the same resource because the `sp->so_lock' lock is dropped
is soon in the list_for_each_entry() loop. It might be the
test_and_clear_bit() check in nfs4_do_reclaim() but it might clear one
bit on each iteration so I *think* we could have two invocations of the
same struct nfs4_state_owner in nfs4_reclaim_open_state().
So there is that.

But back to the list_for_each_entry() macro.
It seems that this `so_lock' lock protects the ->so_states list among
other atomic_t & flags members. So at the begin of the loop we inc ->count
ensuring that this field is not removed while we use it. So we drop the
->so_lock lock during the loop. And after nfs4_reclaim_locks() invocation we
nfs4_put_open_state() and then grab the ->so_lock again. So if we were the =
last
user of this struct and we remove it, then the following list_next_entry()
invocation is a use-after-free. Even if we use list_for_each_entry_safe() t=
here
is no guarantee that the following member is still valid because it might h=
ave
been removed by something that invoked nfs4_put_open_state(), right?
So there is this.

However to address my initial problem I have here a patch :) So it uses
a seqlock_t which ensures that there is only one writer at a time. So it
should be basically what is happening now plus a tiny tiny tiny lock
plus lockdep coverage. I tried to test this myself but I don't manage to get
into this code path at all so I might be doing something wrong.

Could you please check if this patch is working for you and whether my
list_for_each_entry() observation is correct or not?

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 fs/nfs/delegation.c |  4 ++--
 fs/nfs/nfs4_fs.h    |  2 +-
 fs/nfs/nfs4proc.c   |  4 ++--
 fs/nfs/nfs4state.c  | 10 ++++------
 4 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index dff600ae0d74..d726d2e09353 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -150,11 +150,11 @@ static int nfs_delegation_claim_opens(struct inode *i=
node,
 		sp =3D state->owner;
 		/* Block nfs4_proc_unlck */
 		mutex_lock(&sp->so_delegreturn_mutex);
-		seq =3D raw_seqcount_begin(&sp->so_reclaim_seqcount);
+		seq =3D read_seqbegin(&sp->so_reclaim_seqlock);
 		err =3D nfs4_open_delegation_recall(ctx, state, stateid, type);
 		if (!err)
 			err =3D nfs_delegation_claim_locks(ctx, state, stateid);
-		if (!err && read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
+		if (!err && read_seqretry(&sp->so_reclaim_seqlock, seq))
 			err =3D -EAGAIN;
 		mutex_unlock(&sp->so_delegreturn_mutex);
 		put_nfs_open_context(ctx);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9b3a82abab07..9b5089bf0f2e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -111,7 +111,7 @@ struct nfs4_state_owner {
 	unsigned long	     so_flags;
 	struct list_head     so_states;
 	struct nfs_seqid_counter so_seqid;
-	seqcount_t	     so_reclaim_seqcount;
+	seqlock_t	     so_reclaim_seqlock;
 	struct mutex	     so_delegreturn_mutex;
 };
=20
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ad917bd72b38..3d6be8405c08 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2685,7 +2685,7 @@ static int _nfs4_open_and_get_state(struct nfs4_opend=
ata *opendata,
 	unsigned int seq;
 	int ret;
=20
-	seq =3D raw_seqcount_begin(&sp->so_reclaim_seqcount);
+	seq =3D raw_seqcount_begin(&sp->so_reclaim_seqlock.seqcount);
=20
 	ret =3D _nfs4_proc_open(opendata);
 	if (ret !=3D 0)
@@ -2723,7 +2723,7 @@ static int _nfs4_open_and_get_state(struct nfs4_opend=
ata *opendata,
 	ctx->state =3D state;
 	if (d_inode(dentry) =3D=3D state->inode) {
 		nfs_inode_attach_open_context(ctx);
-		if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
+		if (read_seqretry(&sp->so_reclaim_seqlock, seq))
 			nfs4_schedule_stateid_recovery(server, state);
 	}
 out:
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5f4281ec5f72..74be6378ca08 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -488,7 +488,7 @@ nfs4_alloc_state_owner(struct nfs_server *server,
 	nfs4_init_seqid_counter(&sp->so_seqid);
 	atomic_set(&sp->so_count, 1);
 	INIT_LIST_HEAD(&sp->so_lru);
-	seqcount_init(&sp->so_reclaim_seqcount);
+	seqlock_init(&sp->so_reclaim_seqlock);
 	mutex_init(&sp->so_delegreturn_mutex);
 	return sp;
 }
@@ -1497,8 +1497,8 @@ static int nfs4_reclaim_open_state(struct nfs4_state_=
owner *sp, const struct nfs
 	 * recovering after a network partition or a reboot from a
 	 * server that doesn't support a grace period.
 	 */
+	write_seqlock(&sp->so_reclaim_seqlock);
 	spin_lock(&sp->so_lock);
-	raw_write_seqcount_begin(&sp->so_reclaim_seqcount);
 restart:
 	list_for_each_entry(state, &sp->so_states, open_states) {
 		if (!test_and_clear_bit(ops->state_flag_bit, &state->flags))
@@ -1566,14 +1566,12 @@ static int nfs4_reclaim_open_state(struct nfs4_stat=
e_owner *sp, const struct nfs
 		spin_lock(&sp->so_lock);
 		goto restart;
 	}
-	raw_write_seqcount_end(&sp->so_reclaim_seqcount);
 	spin_unlock(&sp->so_lock);
+	write_sequnlock(&sp->so_reclaim_seqlock);
 	return 0;
 out_err:
 	nfs4_put_open_state(state);
-	spin_lock(&sp->so_lock);
-	raw_write_seqcount_end(&sp->so_reclaim_seqcount);
-	spin_unlock(&sp->so_lock);
+	write_sequnlock(&sp->so_reclaim_seqlock);
 	return status;
 }
=20
--=20
2.9.3

