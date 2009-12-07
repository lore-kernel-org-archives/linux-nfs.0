From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 4/5] nfs41: New NFS4CLNT_RECLAIM_COMPLETE_PENDING state
Date: Mon,  7 Dec 2009 00:21:50 -0800
Message-ID: <1260174111-23160-5-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1260174111-23160-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260174111-23160-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260174111-23160-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260174111-23160-4-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759120AbZLGI1p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 03:27:45 -0500
In-Reply-To: <1260174111-23160-4-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_state_end_reclaim_reboot() can also be invoked as a
result of error processing, so it is not a safe place to
invoke RECLAIM_COMPLETE.  Instead, create a new state
flag that tracks the fact that a RECLAIM_COMPLETE needs
to be issued when all state has been reclaimed, or when
we're done establishing the session for the first time.

If an error occurs in the main state manager loop, just clear the
flag.  No sense in checking if the flag is set in order to clear it.
We're not going to issue the RECLAIM_COMPLETE since there's a high
probability that we had some kind of communication or session problem
which is s how we ended up in the error case.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4state.c |   12 +++++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 19f04cc..9962e28 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -46,6 +46,7 @@ enum nfs4_client_state {
 	NFS4CLNT_DELEGRETURN,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_SESSION_DRAINING,
+	NFS4CLNT_RECLAIM_COMPLETE_PENDING,
 };
 
 /*
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d741ec6..3bb43df 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1096,9 +1096,6 @@ static void nfs4_state_end_reclaim_reboot(struct nfs_client *clp)
 	struct rb_node *pos;
 	struct nfs4_state *state;
 
-	nfs4_reclaim_complete(clp,
-		nfs4_reboot_recovery_ops[clp->cl_minorversion]);
-
 	if (!test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
 		return;
 
@@ -1335,6 +1332,8 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				goto out_error;
 			}
 			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
+			set_bit(NFS4CLNT_RECLAIM_COMPLETE_PENDING,
+				&clp->cl_state);
 		}
 
 		if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
@@ -1386,6 +1385,12 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			continue;
 		}
 
+		if (test_and_clear_bit(NFS4CLNT_RECLAIM_COMPLETE_PENDING,
+				&clp->cl_state)) {
+			nfs4_reclaim_complete(clp,
+				nfs4_reboot_recovery_ops[clp->cl_minorversion]);
+		}
+
 		nfs4_clear_state_manager_bit(clp);
 		/* Did we race with an attempt to give us more work? */
 		if (clp->cl_state == 0)
@@ -1397,6 +1402,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 out_error:
 	printk(KERN_WARNING "Error: state manager failed on NFSv4 server %s"
 			" with error %d\n", clp->cl_hostname, -status);
+	clear_bit(NFS4CLNT_RECLAIM_COMPLETE_PENDING, &clp->cl_state);
 	nfs4_clear_state_manager_bit(clp);
 }
 
-- 
1.5.4.3

