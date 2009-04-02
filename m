From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 60/67] nfs41: support minorversion 1 for nfs4_check_lease
Date: Thu,  2 Apr 2009 16:59:07 +0300
Message-ID: <1238680747-15278-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1833 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757064AbZDBN7f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:59:35 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[moved nfs4_get_renew_cred related changes to
 "nfs41: introduce get_state_renewal_cred"]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4proc.c  |    2 ++
 fs/nfs/nfs4state.c |    4 +++-
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 43310ee..c2c54e1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -182,6 +182,7 @@ struct nfs4_state_recovery_ops {
 
 struct nfs4_state_maintenance_ops {
 	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *);
+	int (*renew_lease)(struct nfs_client *, struct rpc_cred *);
 };
 
 extern struct dentry_operations nfs4_dentry_operations;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f047185..9d25c0d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4810,11 +4810,13 @@ struct nfs4_state_recovery_ops nfs4_nograce_recovery_ops = {
 
 struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
 	.sched_state_renewal = nfs4_proc_async_renew,
+	.renew_lease = nfs4_proc_renew,
 };
 
 #if defined(CONFIG_NFS_V4_1)
 struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 	.sched_state_renewal = nfs41_proc_async_sequence,
+	.renew_lease = nfs4_proc_sequence,
 };
 #endif
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 8b7f007..dc5599c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1083,6 +1083,8 @@ restart:
 static int nfs4_check_lease(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;
+	struct nfs4_state_maintenance_ops *ops =
+		nfs4_state_renewal_ops[clp->cl_minorversion];
 	int status = -NFS4ERR_EXPIRED;
 
 	/* Is the client already known to have an expired lease? */
@@ -1094,7 +1096,7 @@ static int nfs4_check_lease(struct nfs_client *clp)
 		if (cred == NULL)
 			goto out;
 	}
-	status = nfs4_proc_renew(clp, cred);
+	status = ops->renew_lease(clp, cred);
 	put_rpccred(cred);
 out:
 	nfs4_recovery_handle_error(clp, status);
-- 
1.6.2.1

