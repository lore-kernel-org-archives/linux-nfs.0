Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38582 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751012AbeBSFFa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:05:30 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:29 +1100
Subject: [PATCH 23/23] SUNRPC: discard cr_uid from struct rpc_cred.
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901654957.17421.3074361668759071102.stgit@noble>
In-Reply-To: <151901634940.17421.7637564368419392071.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just use ->cr_cred->fsuid directly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/auth.h    |    2 --
 net/sunrpc/auth.c              |    1 -
 net/sunrpc/auth_gss/auth_gss.c |   12 ++++++------
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index a98ce75b1994..815d21b8f284 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -58,8 +58,6 @@ struct rpc_cred {
 	atomic_t		cr_count;	/* ref count */
 	const struct cred	*cr_cred;
 
-	kuid_t			cr_uid;
-
 	/* per-flavor data */
 };
 #define RPCAUTH_CRED_NEW	0
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 58197cb15cbd..0a0f515c708a 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -631,7 +631,6 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 	cred->cr_ops = ops;
 	cred->cr_expire = jiffies;
 	cred->cr_cred = get_cred(acred->cred);
-	cred->cr_uid = acred->cred->fsuid;
 }
 EXPORT_SYMBOL_GPL(rpcauth_init_cred);
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index eab38e217eef..207074c0dbaf 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -534,7 +534,7 @@ gss_setup_upcall(struct gss_auth *gss_auth, struct rpc_cred *cred)
 	struct gss_cred *gss_cred = container_of(cred,
 			struct gss_cred, gc_base);
 	struct gss_upcall_msg *gss_new, *gss_msg;
-	kuid_t uid = cred->cr_uid;
+	kuid_t uid = cred->cr_cred->fsuid;
 
 	gss_new = gss_alloc_msg(gss_auth, uid, gss_cred->gc_principal);
 	if (IS_ERR(gss_new))
@@ -573,7 +573,7 @@ gss_refresh_upcall(struct rpc_task *task)
 	int err = 0;
 
 	dprintk("RPC: %5u %s for uid %u\n",
-		task->tk_pid, __func__, from_kuid(&init_user_ns, cred->cr_uid));
+		task->tk_pid, __func__, from_kuid(&init_user_ns, cred->cr_cred->fsuid));
 	gss_msg = gss_setup_upcall(gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		/* XXX: warning on the first, under the assumption we
@@ -606,7 +606,7 @@ gss_refresh_upcall(struct rpc_task *task)
 out:
 	dprintk("RPC: %5u %s for uid %u result %d\n",
 		task->tk_pid, __func__,
-		from_kuid(&init_user_ns, cred->cr_uid),	err);
+		from_kuid(&init_user_ns, cred->cr_cred->fsuid),	err);
 	return err;
 }
 
@@ -622,7 +622,7 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	int err;
 
 	dprintk("RPC:       %s for uid %u\n",
-		__func__, from_kuid(&init_user_ns, cred->cr_uid));
+		__func__, from_kuid(&init_user_ns, cred->cr_cred->fsuid));
 retry:
 	err = 0;
 	/* if gssd is down, just skip upcalling altogether */
@@ -670,7 +670,7 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	gss_release_msg(gss_msg);
 out:
 	dprintk("RPC:       %s for uid %u result %d\n",
-		__func__, from_kuid(&init_user_ns, cred->cr_uid), err);
+		__func__, from_kuid(&init_user_ns, cred->cr_cred->fsuid), err);
 	return err;
 }
 
@@ -1465,7 +1465,7 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 	} else {
 		if (gss_cred->gc_principal != NULL)
 			return 0;
-		ret = uid_eq(rc->cr_uid, acred->cred->fsuid);
+		ret = uid_eq(rc->cr_cred->fsuid, acred->cred->fsuid);
 	}
 	return ret;
 }


