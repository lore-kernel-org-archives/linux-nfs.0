From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 34/69] NFSv4: Fix a BAD_SEQUENCEID condition.
Date: Tue, 23 Dec 2008 18:02:15 -0500
Message-ID: <20081223230215.13743.95648.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752524AbYLWXXq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:46 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7e021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We really shouldn't be resetting the sequence ids when doing state
expiration recovery, since we don't know if the server still remembers our
previous state owners. There are servers out there that do attempt to
preserve client state even if the lease has expired. Such a server would
only release that state if a conflicting OPEN request occurs.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4state.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 9e76712..6dc36a0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -951,7 +951,6 @@ static void nfs4_clear_open_state(struct nfs4_state *state)
 	clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 	clear_bit(NFS_O_RDWR_STATE, &state->flags);
 	list_for_each_entry(lock, &state->lock_states, ls_locks) {
-		lock->ls_seqid.counter = 0;
 		lock->ls_seqid.flags = 0;
 		lock->ls_flags &= ~NFS_LOCK_INITIALIZED;
 	}
@@ -966,7 +965,6 @@ static void nfs4_state_mark_reclaim_helper(struct nfs_client *clp, int (*mark_re
 	/* Reset all sequence ids to zero */
 	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
 		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
-		sp->so_seqid.counter = 0;
 		sp->so_seqid.flags = 0;
 		spin_lock(&sp->so_lock);
 		list_for_each_entry(state, &sp->so_states, open_states) {

