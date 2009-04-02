From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 64/67] nfs41: get_clid_cred for EXCHANGE_ID
Date: Thu,  2 Apr 2009 16:59:48 +0300
Message-ID: <1238680788-15404-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1859 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756215AbZDBOAT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 10:00:19 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Unlike SETCLIENTID, EXCHANGE_ID requires a machine credential. Do not search
for credentials other than the machine credential.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4proc.c  |    2 ++
 fs/nfs/nfs4state.c |   14 ++++++++++++++
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 90eebff..72a4a0a 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -248,6 +248,7 @@ struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
 #if defined(CONFIG_NFS_V4_1)
 struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
+struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp);
 #endif /* CONFIG_NFS_V4_1 */
 
 extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d7a320f..cd773c1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4811,6 +4811,7 @@ struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
 	.establish_clid = nfs4_proc_exchange_id,
+	.get_clid_cred	= nfs4_get_exchange_id_cred,
 };
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -4830,6 +4831,7 @@ struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
 	.establish_clid = nfs4_proc_exchange_id,
+	.get_clid_cred	= nfs4_get_exchange_id_cred,
 };
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 90e5607..7dc9713 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -114,6 +114,20 @@ struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
 	return cred;
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
+struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp)
+{
+	struct rpc_cred *cred;
+
+	spin_lock(&clp->cl_lock);
+	cred = nfs4_get_machine_cred_locked(clp);
+	spin_unlock(&clp->cl_lock);
+	return cred;
+}
+
+#endif /* CONFIG_NFS_V4_1 */
+
 struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
 {
 	struct nfs4_state_owner *sp;
-- 
1.6.2.1

