Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:46138 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754731Ab1G1Soj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 14:44:39 -0400
From: Frank van Maarseveen <frankvm@frankvm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] Minor NLM cleanup preparing for a per-mount based grace time.
Date: Thu, 28 Jul 2011 20:44:19 +0200
Message-Id: <1311878660-24482-2-git-send-email-frankvm@frankvm.com>
In-Reply-To: <1311878660-24482-1-git-send-email-frankvm@frankvm.com>
References: <1311878660-24482-1-git-send-email-frankvm@frankvm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
---
 fs/lockd/svc.c              |    8 ++++++--
 fs/lockd/svc4proc.c         |   24 ------------------------
 fs/lockd/svclock.c          |    4 +++-
 fs/lockd/svcproc.c          |   24 ------------------------
 fs/lockd/svcshare.c         |    8 ++++++++
 fs/nfsd/nfs4proc.c          |    2 +-
 fs/nfsd/nfs4state.c         |    2 +-
 include/linux/lockd/lockd.h |    2 +-
 8 files changed, 20 insertions(+), 54 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index abfff9d..0efbbfc 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -74,7 +74,10 @@ static const int		nlm_port_min = 0, nlm_port_max = 65535;
 static struct ctl_table_header * nlm_sysctl_table;
 #endif
 
-static unsigned long get_lockd_grace_period(void)
+/**
+ * nlmsvc_grace_period - return configured grace period in jiffies.
+ */
+unsigned long nlmsvc_grace_period(void)
 {
 	/* Note: nlm_timeout should always be nonzero */
 	if (nlm_grace_period)
@@ -82,6 +85,7 @@ static unsigned long get_lockd_grace_period(void)
 	else
 		return nlm_timeout * 5 * HZ;
 }
+EXPORT_SYMBOL_GPL(nlmsvc_grace_period);
 
 static struct lock_manager lockd_manager = {
 };
@@ -95,7 +99,7 @@ static DECLARE_DELAYED_WORK(grace_period_end, grace_ender);
 
 static void set_grace_period(void)
 {
-	unsigned long grace_period = get_lockd_grace_period();
+	unsigned long grace_period = nlmsvc_grace_period();
 
 	locks_start_grace(&lockd_manager);
 	cancel_delayed_work_sync(&grace_period_end);
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 9a41fdc..16e9b3b 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -150,12 +150,6 @@ nlm4svc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -183,12 +177,6 @@ nlm4svc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -320,12 +308,6 @@ nlm4svc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace() && !argp->reclaim) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -353,12 +335,6 @@ nlm4svc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index f0179c3..ab62c57 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -587,7 +587,9 @@ nlmsvc_unlock(struct nlm_file *file, struct nlm_lock *lock)
 				(long long)lock->fl.fl_end);
 
 	/* First, cancel any lock that might be there */
-	nlmsvc_cancel_blocked(file, lock);
+	error = nlmsvc_cancel_blocked(file, lock);
+	if (error == nlm_lck_denied_grace_period)
+		return error;
 
 	lock->fl.fl_type = F_UNLCK;
 	error = vfs_lock_file(file->f_file, F_SETLK, &lock->fl, NULL);
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index d27aab1..4048362 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -180,12 +180,6 @@ nlmsvc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -213,12 +207,6 @@ nlmsvc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -360,12 +348,6 @@ nlmsvc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace() && !argp->reclaim) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -393,12 +375,6 @@ nlmsvc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
diff --git a/fs/lockd/svcshare.c b/fs/lockd/svcshare.c
index b0ae070..ccad267 100644
--- a/fs/lockd/svcshare.c
+++ b/fs/lockd/svcshare.c
@@ -31,6 +31,10 @@ nlmsvc_share_file(struct nlm_host *host, struct nlm_file *file,
 	struct xdr_netobj	*oh = &argp->lock.oh;
 	u8			*ohdata;
 
+	/* Don't accept new share requests during grace period */
+	if (locks_in_grace() && !argp->reclaim)
+		return nlm_lck_denied_grace_period;
+
 	for (share = file->f_shares; share; share = share->s_next) {
 		if (share->s_host == host && nlm_cmp_owner(share, oh))
 			goto update;
@@ -71,6 +75,10 @@ nlmsvc_unshare_file(struct nlm_host *host, struct nlm_file *file,
 	struct nlm_share	*share, **shpp;
 	struct xdr_netobj	*oh = &argp->lock.oh;
 
+	/* Don't accept unshare requests during grace period */
+	if (locks_in_grace())
+		return nlm_lck_denied_grace_period;
+
 	for (shpp = &file->f_shares; (share = *shpp) != NULL;
 					shpp = &share->s_next) {
 		if (share->s_host == host && nlm_cmp_owner(share, oh)) {
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e807776..e248b9e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -333,7 +333,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (locks_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
 		goto out;
 	status = nfserr_no_grace;
-	if (!locks_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
+	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS && !locks_in_grace())
 		goto out;
 
 	switch (open->op_claim_type) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3787ec1..741e03a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4061,7 +4061,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (locks_in_grace() && !lock->lk_reclaim)
 		goto out;
 	status = nfserr_no_grace;
-	if (!locks_in_grace() && lock->lk_reclaim)
+	if (lock->lk_reclaim && !locks_in_grace())
 		goto out;
 
 	locks_init_lock(&file_lock);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index ff9abff..b1845cb 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -193,7 +193,6 @@ extern struct svc_procedure	nlmsvc_procedures[];
 #ifdef CONFIG_LOCKD_V4
 extern struct svc_procedure	nlmsvc_procedures4[];
 #endif
-extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
 extern int			nsm_use_hostnames;
 extern u32			nsm_local_state;
@@ -269,6 +268,7 @@ void		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
 					nlm_host_match_fn_t match);
 void		  nlmsvc_grant_reply(struct nlm_cookie *, __be32);
 void		  nlmsvc_release_call(struct nlm_rqst *);
+unsigned long	  nlmsvc_grace_period(void);
 
 /*
  * File handling for the server personality
-- 
1.7.4.4

