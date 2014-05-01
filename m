Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:59113 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbaEAK24 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 06:28:56 -0400
Received: by mail-qc0-f176.google.com with SMTP id x13so3136625qcv.21
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2014 03:28:55 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] nfs4: treat lock owners as opaque values
Date: Thu,  1 May 2014 06:28:45 -0400
Message-Id: <1398940127-31150-2-git-send-email-jlayton@poochiereds.net>
In-Reply-To: <1398940127-31150-1-git-send-email-jlayton@poochiereds.net>
References: <1398940127-31150-1-git-send-email-jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do the following set of ops with a file on a NFSv4 mount:

    exec 3>>/file/on/nfsv4
    flock -x 3
    exec 3>&-

You'll see the LOCK request go across the wire, but no LOCKU when the
file is closed.

What happens is that the fd is passed across a fork, and the final close
is done in a different process than the opener. That makes
__nfs4_find_lock_state miss finding the correct lock state because it
uses the fl_pid as a search key. A new one is created, and the locking
code treats it as a delegation stateid (because NFS_LOCK_INITIALIZED
isn't set).

The root cause of this breakage seems to be commit 77041ed9b49a9e
(NFSv4: Ensure the lockowners are labelled using the fl_owner and/or
fl_pid).

That changed it so that flock lockowners are allocated based on the
fl_pid. I think this is incorrect. flock locks should be "owned" by the
struct file, and that is already accounted for in the fl_owner field of
the lock request when it comes through nfs_flock.

This patch basically reverts the above commit and with it, a LOCKU is
sent in the above reproducer.

Signed-off-by: Jeff Layton <jlayton@poochiereds.net>
---
 fs/nfs/nfs4_fs.h   | 13 +------------
 fs/nfs/nfs4state.c | 45 +++++++++------------------------------------
 2 files changed, 10 insertions(+), 48 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e1d1badbe53c..3888dd0b43a1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -129,17 +129,6 @@ enum {
  * LOCK: one nfs4_state (LOCK) to hold the lock stateid nfs4_state(OPEN)
  */
 
-struct nfs4_lock_owner {
-	unsigned int lo_type;
-#define NFS4_ANY_LOCK_TYPE	(0U)
-#define NFS4_FLOCK_LOCK_TYPE	(1U << 0)
-#define NFS4_POSIX_LOCK_TYPE	(1U << 1)
-	union {
-		fl_owner_t posix_owner;
-		pid_t flock_owner;
-	} lo_u;
-};
-
 struct nfs4_lock_state {
 	struct list_head	ls_locks;	/* Other lock stateids */
 	struct nfs4_state *	ls_state;	/* Pointer to open state */
@@ -149,7 +138,7 @@ struct nfs4_lock_state {
 	struct nfs_seqid_counter	ls_seqid;
 	nfs4_stateid		ls_stateid;
 	atomic_t		ls_count;
-	struct nfs4_lock_owner	ls_owner;
+	fl_owner_t		ls_owner;
 };
 
 /* bits for nfs4_state->flags */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2349518eef2c..f43e5016343e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -787,21 +787,12 @@ void nfs4_close_sync(struct nfs4_state *state, fmode_t fmode)
  * that is compatible with current->files
  */
 static struct nfs4_lock_state *
-__nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_pid, unsigned int type)
+__nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
 {
 	struct nfs4_lock_state *pos;
 	list_for_each_entry(pos, &state->lock_states, ls_locks) {
-		if (type != NFS4_ANY_LOCK_TYPE && pos->ls_owner.lo_type != type)
+		if (pos->ls_owner != fl_owner)
 			continue;
-		switch (pos->ls_owner.lo_type) {
-		case NFS4_POSIX_LOCK_TYPE:
-			if (pos->ls_owner.lo_u.posix_owner != fl_owner)
-				continue;
-			break;
-		case NFS4_FLOCK_LOCK_TYPE:
-			if (pos->ls_owner.lo_u.flock_owner != fl_pid)
-				continue;
-		}
 		atomic_inc(&pos->ls_count);
 		return pos;
 	}
@@ -813,7 +804,7 @@ __nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_p
  * exists, return an uninitialized one.
  *
  */
-static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_pid, unsigned int type)
+static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
 {
 	struct nfs4_lock_state *lsp;
 	struct nfs_server *server = state->owner->so_server;
@@ -824,17 +815,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 	nfs4_init_seqid_counter(&lsp->ls_seqid);
 	atomic_set(&lsp->ls_count, 1);
 	lsp->ls_state = state;
-	lsp->ls_owner.lo_type = type;
-	switch (lsp->ls_owner.lo_type) {
-	case NFS4_FLOCK_LOCK_TYPE:
-		lsp->ls_owner.lo_u.flock_owner = fl_pid;
-		break;
-	case NFS4_POSIX_LOCK_TYPE:
-		lsp->ls_owner.lo_u.posix_owner = fl_owner;
-		break;
-	default:
-		goto out_free;
-	}
+	lsp->ls_owner = fl_owner;
 	lsp->ls_seqid.owner_id = ida_simple_get(&server->lockowner_id, 0, 0, GFP_NOFS);
 	if (lsp->ls_seqid.owner_id < 0)
 		goto out_free;
@@ -857,13 +838,13 @@ void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp
  * exists, return an uninitialized one.
  *
  */
-static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_owner_t owner, pid_t pid, unsigned int type)
+static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_owner_t owner)
 {
 	struct nfs4_lock_state *lsp, *new = NULL;
 	
 	for(;;) {
 		spin_lock(&state->state_lock);
-		lsp = __nfs4_find_lock_state(state, owner, pid, type);
+		lsp = __nfs4_find_lock_state(state, owner);
 		if (lsp != NULL)
 			break;
 		if (new != NULL) {
@@ -874,7 +855,7 @@ static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_
 			break;
 		}
 		spin_unlock(&state->state_lock);
-		new = nfs4_alloc_lock_state(state, owner, pid, type);
+		new = nfs4_alloc_lock_state(state, owner);
 		if (new == NULL)
 			return NULL;
 	}
@@ -935,13 +916,7 @@ int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl)
 
 	if (fl->fl_ops != NULL)
 		return 0;
-	if (fl->fl_flags & FL_POSIX)
-		lsp = nfs4_get_lock_state(state, fl->fl_owner, 0, NFS4_POSIX_LOCK_TYPE);
-	else if (fl->fl_flags & FL_FLOCK)
-		lsp = nfs4_get_lock_state(state, NULL, fl->fl_pid,
-				NFS4_FLOCK_LOCK_TYPE);
-	else
-		return -EINVAL;
+	lsp = nfs4_get_lock_state(state, fl->fl_owner);
 	if (lsp == NULL)
 		return -ENOMEM;
 	fl->fl_u.nfs4_fl.owner = lsp;
@@ -955,7 +930,6 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 {
 	struct nfs4_lock_state *lsp;
 	fl_owner_t fl_owner;
-	pid_t fl_pid;
 	int ret = -ENOENT;
 
 
@@ -966,9 +940,8 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 		goto out;
 
 	fl_owner = lockowner->l_owner;
-	fl_pid = lockowner->l_pid;
 	spin_lock(&state->state_lock);
-	lsp = __nfs4_find_lock_state(state, fl_owner, fl_pid, NFS4_ANY_LOCK_TYPE);
+	lsp = __nfs4_find_lock_state(state, fl_owner);
 	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
 		ret = -EIO;
 	else if (lsp != NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) != 0) {
-- 
1.9.0

