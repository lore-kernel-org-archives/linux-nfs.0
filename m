From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 61/67] nfs41: introduce get_state_renewal_cred
Date: Thu,  2 Apr 2009 16:59:14 +0300
Message-ID: <1238680754-15310-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:29679 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757242AbZDBN7g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:59:36 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use the machine cred for sending SEQUENCE to renew
the client's lease.

[revamp patch for new state management design starting 2.6.29]
[nfs41: support minorversion 1 for nfs4_check_lease]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: get cred in exchange_id when cred arg is NULL]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: use cl_machined_cred instead of cl_ex_cred]
    Since EXCHANGE_ID insists on using the machine credential, cl_ex_cred is
    not needed. nfs4_proc_exchange_id() is only called if the machine credential
    is available. Remove the credential logic from nfs4_proc_exchange_id.
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h    |    5 +++++
 fs/nfs/nfs4proc.c   |    3 +++
 fs/nfs/nfs4renewd.c |    2 +-
 fs/nfs/nfs4state.c  |   18 +++++-------------
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c2c54e1..757245e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -182,6 +182,7 @@ struct nfs4_state_recovery_ops {
 
 struct nfs4_state_maintenance_ops {
 	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *);
+	struct rpc_cred * (*get_state_renewal_cred_locked)(struct nfs_client *);
 	int (*renew_lease)(struct nfs_client *, struct rpc_cred *);
 };
 
@@ -240,7 +241,11 @@ extern void nfs4_kill_renewd(struct nfs_client *);
 extern void nfs4_renew_state(struct work_struct *);
 
 /* nfs4state.c */
+struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
+#if defined(CONFIG_NFS_V4_1)
+struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
+#endif /* CONFIG_NFS_V4_1 */
 
 extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *);
 extern void nfs4_put_state_owner(struct nfs4_state_owner *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9d25c0d..fd8a950 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4251,6 +4251,7 @@ static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 
 	dprintk("--> %s\n", __func__);
 	BUG_ON(clp == NULL);
+
 	p = (u32 *)verifier.data;
 	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
@@ -4810,12 +4811,14 @@ struct nfs4_state_recovery_ops nfs4_nograce_recovery_ops = {
 
 struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
 	.sched_state_renewal = nfs4_proc_async_renew,
+	.get_state_renewal_cred_locked = nfs4_get_renew_cred_locked,
 	.renew_lease = nfs4_proc_renew,
 };
 
 #if defined(CONFIG_NFS_V4_1)
 struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 	.sched_state_renewal = nfs41_proc_async_sequence,
+	.get_state_renewal_cred_locked = nfs4_get_machine_cred_locked,
 	.renew_lease = nfs4_proc_sequence,
 };
 #endif
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 92b43e8..e27c6ce 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -78,7 +78,7 @@ nfs4_renew_state(struct work_struct *work)
 	timeout = (2 * lease) / 3 + (long)last - (long)now;
 	/* Are we close to a lease timeout? */
 	if (time_after(now, last + lease/3)) {
-		cred = nfs4_get_renew_cred_locked(clp);
+		cred = ops->get_state_renewal_cred_locked(clp);
 		spin_unlock(&clp->cl_lock);
 		if (cred == NULL) {
 			if (list_empty(&clp->cl_delegations)) {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index dc5599c..da940ab 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -77,7 +77,7 @@ static int nfs4_init_client(struct nfs_client *clp, struct rpc_cred *cred)
 	return status;
 }
 
-static struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
+struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
 {
 	struct rpc_cred *cred = NULL;
 
@@ -114,17 +114,7 @@ struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
 	return cred;
 }
 
-static struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp)
-{
-	struct rpc_cred *cred;
-
-	spin_lock(&clp->cl_lock);
-	cred = nfs4_get_renew_cred_locked(clp);
-	spin_unlock(&clp->cl_lock);
-	return cred;
-}
-
-static struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
+struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
 {
 	struct nfs4_state_owner *sp;
 	struct rb_node *pos;
@@ -1090,7 +1080,9 @@ static int nfs4_check_lease(struct nfs_client *clp)
 	/* Is the client already known to have an expired lease? */
 	if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 		return 0;
-	cred = nfs4_get_renew_cred(clp);
+	spin_lock(&clp->cl_lock);
+	cred = ops->get_state_renewal_cred_locked(clp);
+	spin_unlock(&clp->cl_lock);
 	if (cred == NULL) {
 		cred = nfs4_get_setclientid_cred(clp);
 		if (cred == NULL)
-- 
1.6.2.1

