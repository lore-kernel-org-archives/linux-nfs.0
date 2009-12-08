From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH] nfs41: Invoke RECLAIM_COMPLETE on all new client id's
Date: Mon,  7 Dec 2009 17:10:53 -0800
Message-ID: <1260234653-28737-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59035 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965265AbZLHBKr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 20:10:47 -0500
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4.1 spec indicates RECLAIM_COMPLETE is to be issued
whenever a client establishes a new client id, not only after
detecting the server has rebooted.

Set the NFS4CLNT_RECLAIM_REBOOT bit after every new client id has
been established.  This enables us to issue RECLAIM_COMPLETE
during the wrap up of the NFS4CLNT_RECLAIM_REBOOT state.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4state.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1936036..e76427e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1095,12 +1095,12 @@ static void nfs4_state_end_reclaim_reboot(struct nfs_client *clp)
 	struct rb_node *pos;
 	struct nfs4_state *state;
 
-	nfs4_reclaim_complete(clp,
-		nfs4_reboot_recovery_ops[clp->cl_minorversion]);
-
 	if (!test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
 		return;
 
+	nfs4_reclaim_complete(clp,
+		nfs4_reboot_recovery_ops[clp->cl_minorversion]);
+
 	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
 		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
 		spin_lock(&sp->so_lock);
@@ -1335,6 +1335,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				goto out_error;
 			}
 			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
+			set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
 		}
 
 		if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
-- 
1.5.4.3

