Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20296 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752138Ab2ACQmA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jan 2012 11:42:00 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Clean up the RPCSEC_GSS service ticket requests
Date: Tue,  3 Jan 2012 11:41:47 -0500
Message-Id: <1325608907-17801-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of hacking specific service names into gss_encode_v1_msg, we should
just allow the caller to specify the service name explicitly.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c                 |    2 +-
 fs/nfsd/nfs4callback.c          |    2 +-
 include/linux/sunrpc/auth.h     |    3 +-
 include/linux/sunrpc/auth_gss.h |    2 +-
 net/sunrpc/auth_generic.c       |    6 +++-
 net/sunrpc/auth_gss/auth_gss.c  |   40 ++++++++++++++++++++++----------------
 6 files changed, 32 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 873bf00..32ea371 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -185,7 +185,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_minorversion = cl_init->minorversion;
 	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
 #endif
-	cred = rpc_lookup_machine_cred();
+	cred = rpc_lookup_machine_cred("*");
 	if (!IS_ERR(cred))
 		clp->cl_machine_cred = cred;
 	nfs_fscache_get_client_cookie(clp);
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7748d6a..6f3ebb4 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -718,7 +718,7 @@ int set_callback_cred(void)
 {
 	if (callback_cred)
 		return 0;
-	callback_cred = rpc_lookup_machine_cred();
+	callback_cred = rpc_lookup_machine_cred("nfs");
 	if (!callback_cred)
 		return -ENOMEM;
 	return 0;
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index febc4db..7874a8a 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -26,6 +26,7 @@ struct auth_cred {
 	uid_t	uid;
 	gid_t	gid;
 	struct group_info *group_info;
+	const char *principal;
 	unsigned char machine_cred : 1;
 };
 
@@ -127,7 +128,7 @@ void			rpc_destroy_generic_auth(void);
 void 			rpc_destroy_authunix(void);
 
 struct rpc_cred *	rpc_lookup_cred(void);
-struct rpc_cred *	rpc_lookup_machine_cred(void);
+struct rpc_cred *	rpc_lookup_machine_cred(const char *service_name);
 int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
 struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt *);
diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 8eee9db..f1cfd4c 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -82,8 +82,8 @@ struct gss_cred {
 	enum rpc_gss_svc	gc_service;
 	struct gss_cl_ctx __rcu	*gc_ctx;
 	struct gss_upcall_msg	*gc_upcall;
+	const char		*gc_principal;
 	unsigned long		gc_upcall_timestamp;
-	unsigned char		gc_machine_cred : 1;
 };
 
 #endif /* __KERNEL__ */
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index e010a01..1426ec3 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -41,15 +41,17 @@ EXPORT_SYMBOL_GPL(rpc_lookup_cred);
 /*
  * Public call interface for looking up machine creds.
  */
-struct rpc_cred *rpc_lookup_machine_cred(void)
+struct rpc_cred *rpc_lookup_machine_cred(const char *service_name)
 {
 	struct auth_cred acred = {
 		.uid = RPC_MACHINE_CRED_USERID,
 		.gid = RPC_MACHINE_CRED_GROUPID,
+		.principal = service_name,
 		.machine_cred = 1,
 	};
 
-	dprintk("RPC:       looking up machine cred\n");
+	dprintk("RPC:       looking up machine cred for service %s\n",
+			service_name);
 	return generic_auth.au_ops->lookup_cred(&generic_auth, &acred, 0);
 }
 EXPORT_SYMBOL_GPL(rpc_lookup_machine_cred);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index afb5655..28d72d2 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -392,7 +392,8 @@ static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
 }
 
 static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
-				struct rpc_clnt *clnt, int machine_cred)
+				struct rpc_clnt *clnt,
+				const char *service_name)
 {
 	struct gss_api_mech *mech = gss_msg->auth->mech;
 	char *p = gss_msg->databuf;
@@ -407,12 +408,8 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 		p += len;
 		gss_msg->msg.len += len;
 	}
-	if (machine_cred) {
-		len = sprintf(p, "service=* ");
-		p += len;
-		gss_msg->msg.len += len;
-	} else if (!strcmp(clnt->cl_program->name, "nfs4_cb")) {
-		len = sprintf(p, "service=nfs ");
+	if (service_name != NULL) {
+		len = sprintf(p, "service=%s ", service_name);
 		p += len;
 		gss_msg->msg.len += len;
 	}
@@ -429,17 +426,18 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 }
 
 static void gss_encode_msg(struct gss_upcall_msg *gss_msg,
-				struct rpc_clnt *clnt, int machine_cred)
+				struct rpc_clnt *clnt,
+				const char *service_name)
 {
 	if (pipe_version == 0)
 		gss_encode_v0_msg(gss_msg);
 	else /* pipe_version == 1 */
-		gss_encode_v1_msg(gss_msg, clnt, machine_cred);
+		gss_encode_v1_msg(gss_msg, clnt, service_name);
 }
 
-static inline struct gss_upcall_msg *
-gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid, struct rpc_clnt *clnt,
-		int machine_cred)
+static struct gss_upcall_msg *
+gss_alloc_msg(struct gss_auth *gss_auth, struct rpc_clnt *clnt,
+		uid_t uid, const char *service_name)
 {
 	struct gss_upcall_msg *gss_msg;
 	int vers;
@@ -459,7 +457,7 @@ gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid, struct rpc_clnt *clnt,
 	atomic_set(&gss_msg->count, 1);
 	gss_msg->uid = uid;
 	gss_msg->auth = gss_auth;
-	gss_encode_msg(gss_msg, clnt, machine_cred);
+	gss_encode_msg(gss_msg, clnt, service_name);
 	return gss_msg;
 }
 
@@ -471,7 +469,7 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
 	struct gss_upcall_msg *gss_new, *gss_msg;
 	uid_t uid = cred->cr_uid;
 
-	gss_new = gss_alloc_msg(gss_auth, uid, clnt, gss_cred->gc_machine_cred);
+	gss_new = gss_alloc_msg(gss_auth, clnt, uid, gss_cred->gc_principal);
 	if (IS_ERR(gss_new))
 		return gss_new;
 	gss_msg = gss_add_msg(gss_new);
@@ -995,7 +993,9 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	 */
 	cred->gc_base.cr_flags = 1UL << RPCAUTH_CRED_NEW;
 	cred->gc_service = gss_auth->service;
-	cred->gc_machine_cred = acred->machine_cred;
+	cred->gc_principal = NULL;
+	if (acred->machine_cred)
+		cred->gc_principal = acred->principal;
 	kref_get(&gss_auth->kref);
 	return &cred->gc_base;
 
@@ -1030,7 +1030,12 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 	if (!test_bit(RPCAUTH_CRED_UPTODATE, &rc->cr_flags))
 		return 0;
 out:
-	if (acred->machine_cred != gss_cred->gc_machine_cred)
+	if (acred->principal != NULL) {
+		if (gss_cred->gc_principal == NULL)
+			return 0;
+		return strcmp(acred->principal, gss_cred->gc_principal) == 0;
+	}
+	if (gss_cred->gc_principal != NULL)
 		return 0;
 	return rc->cr_uid == acred->uid;
 }
@@ -1104,7 +1109,8 @@ static int gss_renew_cred(struct rpc_task *task)
 	struct rpc_auth *auth = oldcred->cr_auth;
 	struct auth_cred acred = {
 		.uid = oldcred->cr_uid,
-		.machine_cred = gss_cred->gc_machine_cred,
+		.principal = gss_cred->gc_principal,
+		.machine_cred = (gss_cred->gc_principal != NULL ? 1 : 0),
 	};
 	struct rpc_cred *new;
 
-- 
1.7.7.5

