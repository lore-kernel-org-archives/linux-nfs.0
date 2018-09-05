Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:39494 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727303AbeIEWj2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 18:39:28 -0400
Received: by mail-io0-f193.google.com with SMTP id l7-v6so6719375iok.6
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 11:08:10 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] NFSv4.1 fix infinite loop on I/O.
Date: Wed,  5 Sep 2018 14:07:14 -0400
Message-Id: <20180905180715.99485-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180905180715.99485-2-trond.myklebust@hammerspace.com>
References: <20180905180715.99485-1-trond.myklebust@hammerspace.com>
 <20180905180715.99485-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The previous fix broke recovery of delegated stateids because it assumes
that if we did not mark the delegation as suspect, then the delegation has
effectively been revoked, and so it removes that delegation irrespectively
of whether or not it is valid and still in use. While this is "mostly
harmless" for ordinary I/O, we've seen pNFS fail with LAYOUTGET spinning
in an infinite loop while complaining that we're using an invalid stateid
(in this case the all-zero stateid).

What we rather want to do here is ensure that the delegation is always
correctly marked as needing testing when that is the case. So we want
to close the loophole offered by nfs4_schedule_stateid_recovery(),
which marks the state as needing to be reclaimed, but not the
delegation that may be backing it.

Fixes: 0e3d3e5df07dc ("NFSv4.1 fix infinite loop on IO BAD_STATEID error")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c  | 10 +++++++---
 fs/nfs/nfs4state.c |  2 ++
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 34830f6457ea..2e4456ac9556 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2676,14 +2676,18 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 	}
 
 	nfs4_stateid_copy(&stateid, &delegation->stateid);
-	if (test_bit(NFS_DELEGATION_REVOKED, &delegation->flags) ||
-		!test_and_clear_bit(NFS_DELEGATION_TEST_EXPIRED,
-			&delegation->flags)) {
+	if (test_bit(NFS_DELEGATION_REVOKED, &delegation->flags)) {
 		rcu_read_unlock();
 		nfs_finish_clear_delegation_stateid(state, &stateid);
 		return;
 	}
 
+	if (!test_and_clear_bit(NFS_DELEGATION_TEST_EXPIRED,
+				&delegation->flags)) {
+		rcu_read_unlock();
+		return;
+	}
+
 	cred = get_rpccred(delegation->cred);
 	rcu_read_unlock();
 	status = nfs41_test_and_free_expired_stateid(server, &stateid, cred);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 3df0eb52da1c..40a08cd483f0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1390,6 +1390,8 @@ int nfs4_schedule_stateid_recovery(const struct nfs_server *server, struct nfs4_
 
 	if (!nfs4_state_mark_reclaim_nograce(clp, state))
 		return -EBADF;
+	nfs_inode_find_delegation_state_and_recover(state->inode,
+			&state->stateid);
 	dprintk("%s: scheduling stateid recovery for server %s\n", __func__,
 			clp->cl_hostname);
 	nfs4_schedule_state_manager(clp);
-- 
2.17.1
