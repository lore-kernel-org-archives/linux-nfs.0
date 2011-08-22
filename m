Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12050 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668Ab1HVVMs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Aug 2011 17:12:48 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/4] NFSv4: The NFSv4.0 client must send RENEW calls if it holds a delegation
Date: Mon, 22 Aug 2011 17:12:39 -0400
Message-Id: <1314047560-24534-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1314047560-24534-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1314047560-24534-1-git-send-email-Trond.Myklebust@netapp.com>
 <1314047560-24534-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

RFC3530 states that if the client holds a delegation, then it is obliged
to continue to send RENEW calls once every lease period in order to allow
the server to return NFS4ERR_CB_PATH_DOWN if the callback path is
unreachable.

This is not required for NFSv4.1, since the server can at any time set
the SEQ4_STATUS_CB_PATH_DOWN_SESSION in any SEQUENCE operation.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h    |    5 ++++-
 fs/nfs/nfs4proc.c   |    8 ++++++--
 fs/nfs/nfs4renewd.c |   12 +++++++++---
 3 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 58adfb6..e1b6607 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -56,6 +56,9 @@ enum nfs4_session_state {
 	NFS4_SESSION_DRAINING,
 };
 
+#define NFS4_RENEW_TIMEOUT		0x01
+#define NFS4_RENEW_DELEGATION_CB	0x02
+
 struct nfs4_minor_version_ops {
 	u32	minor_version;
 
@@ -225,7 +228,7 @@ struct nfs4_state_recovery_ops {
 };
 
 struct nfs4_state_maintenance_ops {
-	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *);
+	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *, unsigned);
 	struct rpc_cred * (*get_state_renewal_cred_locked)(struct nfs_client *);
 	int (*renew_lease)(struct nfs_client *, struct rpc_cred *);
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b358ec1..e89940a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3386,7 +3386,7 @@ static const struct rpc_call_ops nfs4_renew_ops = {
 	.rpc_release = nfs4_renew_release,
 };
 
-static int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
+static int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred, unsigned renew_flags)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_RENEW],
@@ -3395,6 +3395,8 @@ static int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
 	};
 	struct nfs4_renewdata *data;
 
+	if (renew_flags == 0)
+		return 0;
 	if (!atomic_inc_not_zero(&clp->cl_count))
 		return -EIO;
 	data = kmalloc(sizeof(*data), GFP_NOFS);
@@ -5504,11 +5506,13 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_
 	return rpc_run_task(&task_setup_data);
 }
 
-static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cred)
+static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cred, unsigned renew_flags)
 {
 	struct rpc_task *task;
 	int ret = 0;
 
+	if ((renew_flags & NFS4_RENEW_TIMEOUT) == 0)
+		return 0;
 	task = _nfs41_proc_sequence(clp, cred);
 	if (IS_ERR(task))
 		ret = PTR_ERR(task);
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index df8e7f3..dc484c0 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -60,6 +60,7 @@ nfs4_renew_state(struct work_struct *work)
 	struct rpc_cred *cred;
 	long lease;
 	unsigned long last, now;
+	unsigned renew_flags = 0;
 
 	ops = clp->cl_mvops->state_renewal_ops;
 	dprintk("%s: start\n", __func__);
@@ -72,18 +73,23 @@ nfs4_renew_state(struct work_struct *work)
 	last = clp->cl_last_renewal;
 	now = jiffies;
 	/* Are we close to a lease timeout? */
-	if (time_after(now, last + lease/3)) {
+	if (time_after(now, last + lease/3))
+		renew_flags |= NFS4_RENEW_TIMEOUT;
+	if (nfs_delegations_present(clp))
+		renew_flags |= NFS4_RENEW_DELEGATION_CB;
+
+	if (renew_flags != 0) {
 		cred = ops->get_state_renewal_cred_locked(clp);
 		spin_unlock(&clp->cl_lock);
 		if (cred == NULL) {
-			if (!nfs_delegations_present(clp)) {
+			if (!(renew_flags & NFS4_RENEW_DELEGATION_CB)) {
 				set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 				goto out;
 			}
 			nfs_expire_all_delegations(clp);
 		} else {
 			/* Queue an asynchronous RENEW. */
-			ops->sched_state_renewal(clp, cred);
+			ops->sched_state_renewal(clp, cred, renew_flags);
 			put_rpccred(cred);
 			goto out_exp;
 		}
-- 
1.7.6

