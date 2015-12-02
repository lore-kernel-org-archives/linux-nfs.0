Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:47777 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753431AbbLBOVH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2015 09:21:07 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH RFC] nfs: Fix race in __update_open_stateid()
Date: Wed,  2 Dec 2015 09:20:57 -0500
Message-Id: <1449066057-26807-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've seen this in a packet capture - I've intermixed what I
think was going on. The fix here is to grab the so_lock sooner.

1964379 -> #1 open (for write) reply seqid=1
1964393 -> #2 open (for read) reply seqid=2

  __nfs4_close(), state->n_wronly--
  nfs4_state_set_mode_locked(), changes state->state = [R]
  state->flags is [RW]
  state->state is [R], state->n_wronly == 0, state->n_rdonly == 1

1964398 -> #3 open (for write) call -> because close is already running
1964399 -> downgrade (to read) call seqid=2 (close of #1)
1964402 -> #3 open (for write) reply seqid=3

 __update_open_stateid()
   nfs_set_open_stateid_locked(), changes state->flags
   state->flags is [RW]
   state->state is [R], state->n_wronly == 0, state->n_rdonly == 1
   new sequence number is exposed now via nfs4_stateid_copy()

   next step would be update_open_stateflags(), pending so_lock

1964403 -> downgrade reply seqid=2, fails with OLD_STATEID (close of #1)

   nfs4_close_prepare() gets so_lock and recalcs flags -> send close

1964405 -> downgrade (to read) call seqid=3 (close of #1 retry)

   __update_open_stateid() gets so_lock
 * update_open_stateflags() updates state->n_wronly.
   nfs4_state_set_mode_locked() updates state->state

   state->flags is [RW]
   state->state is [RW], state->n_wronly == 1, state->n_rdonly == 1

 * should have suppressed the preceding nfs4_close_prepare() from
   sending open_downgrade

1964406 -> write call
1964408 -> downgrade (to read) reply seqid=4 (close of #1 retry)

   nfs_clear_open_stateid_locked()
   state->flags is [R]
   state->state is [RW], state->n_wronly == 1, state->n_rdonly == 1

1964409 -> write reply (fails, openmode)

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f7f45792676d..b05215691156 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1385,6 +1385,7 @@ static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_s
 	 * Protect the call to nfs4_state_set_mode_locked and
 	 * serialise the stateid update
 	 */
+	spin_lock(&state->owner->so_lock);
 	write_seqlock(&state->seqlock);
 	if (deleg_stateid != NULL) {
 		nfs4_stateid_copy(&state->stateid, deleg_stateid);
@@ -1393,7 +1394,6 @@ static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_s
 	if (open_stateid != NULL)
 		nfs_set_open_stateid_locked(state, open_stateid, fmode);
 	write_sequnlock(&state->seqlock);
-	spin_lock(&state->owner->so_lock);
 	update_open_stateflags(state, fmode);
 	spin_unlock(&state->owner->so_lock);
 }
-- 
2.6.3

