From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 63/67] nfs41: add a get_clid_cred function to nfs4_state_recovery_ops
Date: Thu,  2 Apr 2009 16:59:35 +0300
Message-ID: <1238680775-15372-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31932 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757005AbZDBN7u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:59:50 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

EXCHANGE_ID has different credential requirements than SETCLIENTID.
Prepare for a separate credential function.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4proc.c  |    2 ++
 fs/nfs/nfs4state.c |    2 +-
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e74d310..90eebff 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -179,6 +179,7 @@ struct nfs4_state_recovery_ops {
 	int (*recover_open)(struct nfs4_state_owner *, struct nfs4_state *);
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
 	int (*establish_clid)(struct nfs_client *, struct rpc_cred *);
+	struct rpc_cred * (*get_clid_cred)(struct nfs_client *);
 };
 
 struct nfs4_state_maintenance_ops {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7ad40fa..d7a320f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4801,6 +4801,7 @@ struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
 	.establish_clid = nfs4_init_clientid,
+	.get_clid_cred	= nfs4_get_setclientid_cred,
 };
 
 #if defined(CONFIG_NFS_V4_1)
@@ -4819,6 +4820,7 @@ struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
 	.establish_clid = nfs4_init_clientid,
+	.get_clid_cred	= nfs4_get_setclientid_cred,
 };
 
 #if defined(CONFIG_NFS_V4_1)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e17bd44..90e5607 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1102,7 +1102,7 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 		nfs4_reboot_recovery_ops[clp->cl_minorversion];
 	int status = -ENOENT;
 
-	cred = nfs4_get_setclientid_cred(clp);
+	cred = ops->get_clid_cred(clp);
 	if (cred != NULL) {
 		status = ops->establish_clid(clp, cred);
 		put_rpccred(cred);
-- 
1.6.2.1

