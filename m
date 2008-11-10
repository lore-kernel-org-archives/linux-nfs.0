From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 16/85] nfs41: pass recovery status from reclaimer kthread up to nfs4_wait_clnt_recover
Date: Mon, 10 Nov 2008 22:20:38 +0200
Message-ID: <1226348438-7718-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60749 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbYKJUUn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:20:43 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

status is cleared on recovery start and may be left as non-zero
if recovery failed so it can be picked up by an upper layer caller
(e.g. nfs4_create_server)

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c         |    2 ++
 fs/nfs/nfs4state.c        |    5 ++++-
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ef3370f..f87d4de 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2802,6 +2802,8 @@ static int nfs4_wait_clnt_recover(struct rpc_clnt *clnt, struct nfs_client *clp)
 
 	res = wait_on_bit(&clp->cl_state, NFS4CLNT_STATE_RECOVER,
 			nfs4_wait_bit_killable, TASK_KILLABLE);
+	if (!res)
+		res = clp->cl_recovery_status;
 
 	rwsem_release(&clp->cl_sem.dep_map, 1, _RET_IP_);
 	return res;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c391caf..09ca7b1 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -814,8 +814,10 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
 {
 	if (!clp)
 		return;
-	if (test_and_set_bit(NFS4CLNT_STATE_RECOVER, &clp->cl_state) == 0)
+	if (test_and_set_bit(NFS4CLNT_STATE_RECOVER, &clp->cl_state) == 0) {
+		clp->cl_recovery_status = 0;
 		nfs4_recover_state(clp);
+	}
 }
 
 static int nfs4_reclaim_locks(struct nfs4_state_recovery_ops *ops, struct nfs4_state *state)
@@ -1018,6 +1020,7 @@ out:
 out_error:
 	printk(KERN_WARNING "Error: state recovery failed on NFSv4 server %s"
 			" with error %d\n", clp->cl_hostname, -status);
+	clp->cl_recovery_status = status;
 	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 	goto out;
 }
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c5cb574..80e0fc3 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -38,6 +38,7 @@ struct nfs_client {
 	u64			cl_clientid;	/* constant */
 	nfs4_verifier		cl_confirm;
 	unsigned long		cl_state;
+	int			cl_recovery_status;
 
 	struct rb_root		cl_openowner_id;
 	struct rb_root		cl_lockowner_id;
-- 
1.6.0.2

