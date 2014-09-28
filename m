Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:46543 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbaI1DzF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2014 23:55:05 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn18so1613379igb.9
        for <linux-nfs@vger.kernel.org>; Sat, 27 Sep 2014 20:55:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] NFSv4: fix open/lock state recovery error handling
Date: Sat, 27 Sep 2014 23:54:58 -0400
Message-Id: <1411876498-12039-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1411876498-12039-2-git-send-email-trond.myklebust@primarydata.com>
References: <1411876498-12039-1-git-send-email-trond.myklebust@primarydata.com>
 <1411876498-12039-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current open/lock state recovery unfortunately does not handle errors
such as NFS4ERR_CONN_NOT_BOUND_TO_SESSION correctly. Instead of looping,
just proceeds as if the state manager is finished recovering.
This patch ensures that we loop back, handle higher priority errors
and complete the open/lock state recovery.

Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 26d510d11efd..87b2d0e79797 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1705,7 +1705,8 @@ restart:
 			if (status < 0) {
 				set_bit(ops->owner_flag_bit, &sp->so_flags);
 				nfs4_put_state_owner(sp);
-				return nfs4_recovery_handle_error(clp, status);
+				status = nfs4_recovery_handle_error(clp, status);
+				return (status != 0) ? status : -EAGAIN;
 			}
 
 			nfs4_put_state_owner(sp);
@@ -1714,7 +1715,7 @@ restart:
 		spin_unlock(&clp->cl_lock);
 	}
 	rcu_read_unlock();
-	return status;
+	return 0;
 }
 
 static int nfs4_check_lease(struct nfs_client *clp)
@@ -2365,14 +2366,11 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			section = "reclaim reboot";
 			status = nfs4_do_reclaim(clp,
 				clp->cl_mvops->reboot_recovery_ops);
-			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) ||
-			    test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state))
-				continue;
-			nfs4_state_end_reclaim_reboot(clp);
-			if (test_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state))
+			if (status == -EAGAIN)
 				continue;
 			if (status < 0)
 				goto out_error;
+			nfs4_state_end_reclaim_reboot(clp);
 		}
 
 		/* Now recover expired state... */
@@ -2380,9 +2378,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			section = "reclaim nograce";
 			status = nfs4_do_reclaim(clp,
 				clp->cl_mvops->nograce_recovery_ops);
-			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) ||
-			    test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state) ||
-			    test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
+			if (status == -EAGAIN)
 				continue;
 			if (status < 0)
 				goto out_error;
-- 
1.9.3

