From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 23/33] NFSv4: Reintroduce machine creds
Date: Sat, 19 Apr 2008 16:40:53 -0400
Message-ID: <20080419204052.14124.21436.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35010 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756077AbYDSUuZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:25 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoONP002611
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:24 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to try to ensure that we always use the same credentials whenever
we re-establish the clientid on the server. If not, the server won't
recognise that we're the same client, and so may not allow us to recover
state.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c                 |    7 +++++++
 include/linux/nfs_fs_sb.h       |    2 ++
 include/linux/sunrpc/auth.h     |    2 ++
 include/linux/sunrpc/auth_gss.h |    1 +
 net/sunrpc/auth_generic.c       |   26 ++++++++++++++++++++++++--
 net/sunrpc/auth_gss/auth_gss.c  |   12 +++++++++++-
 6 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 93dfd75..f2f3b28 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -112,6 +112,7 @@ struct nfs_client_initdata {
 static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 {
 	struct nfs_client *clp;
+	struct rpc_cred *cred;
 
 	if ((clp = kzalloc(sizeof(*clp), GFP_KERNEL)) == NULL)
 		goto error_0;
@@ -150,6 +151,9 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_boot_time = CURRENT_TIME;
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 #endif
+	cred = rpc_lookup_machine_cred();
+	if (!IS_ERR(cred))
+		clp->cl_machine_cred = cred;
 
 	return clp;
 
@@ -191,6 +195,9 @@ static void nfs_free_client(struct nfs_client *clp)
 	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
 		nfs_callback_down();
 
+	if (clp->cl_machine_cred != NULL)
+		put_rpccred(clp->cl_machine_cred);
+
 	kfree(clp->cl_hostname);
 	kfree(clp);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index ac7e4fb..c9beacd 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -32,6 +32,8 @@ struct nfs_client {
 	const struct nfs_rpc_ops *rpc_ops;	/* NFS protocol vector */
 	int			cl_proto;	/* Network transport protocol */
 
+	struct rpc_cred		*cl_machine_cred;
+
 #ifdef CONFIG_NFS_V4
 	u64			cl_clientid;	/* constant */
 	nfs4_verifier		cl_confirm;
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index a19c3af..3f63218 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -26,6 +26,7 @@ struct auth_cred {
 	uid_t	uid;
 	gid_t	gid;
 	struct group_info *group_info;
+	unsigned char machine_cred : 1;
 };
 
 /*
@@ -130,6 +131,7 @@ void __exit		rpcauth_remove_module(void);
 void __exit		rpc_destroy_generic_auth(void);
 
 struct rpc_cred *	rpc_lookup_cred(void);
+struct rpc_cred *	rpc_lookup_machine_cred(void);
 int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
 struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt *);
diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 67658e1..fec6899 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -84,6 +84,7 @@ struct gss_cred {
 	enum rpc_gss_svc	gc_service;
 	struct gss_cl_ctx	*gc_ctx;
 	struct gss_upcall_msg	*gc_upcall;
+	unsigned char		gc_machine_cred : 1;
 };
 
 #endif /* __KERNEL__ */
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index b6f124c..d927d9f 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -17,6 +17,9 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
+#define RPC_ANONYMOUS_USERID	((uid_t)-2)
+#define RPC_ANONYMOUS_GROUPID	((gid_t)-2)
+
 struct generic_cred {
 	struct rpc_cred gc_base;
 	struct auth_cred acred;
@@ -35,6 +38,22 @@ struct rpc_cred *rpc_lookup_cred(void)
 }
 EXPORT_SYMBOL_GPL(rpc_lookup_cred);
 
+/*
+ * Public call interface for looking up machine creds.
+ */
+struct rpc_cred *rpc_lookup_machine_cred(void)
+{
+	struct auth_cred acred = {
+		.uid = RPC_ANONYMOUS_USERID,
+		.gid = RPC_ANONYMOUS_GROUPID,
+		.machine_cred = 1,
+	};
+
+	dprintk("RPC:       looking up machine cred\n");
+	return generic_auth.au_ops->lookup_cred(&generic_auth, &acred, 0);
+}
+EXPORT_SYMBOL_GPL(rpc_lookup_machine_cred);
+
 static void
 generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred)
 {
@@ -75,8 +94,10 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	gcred->acred.group_info = acred->group_info;
 	if (gcred->acred.group_info != NULL)
 		get_group_info(gcred->acred.group_info);
+	gcred->acred.machine_cred = acred->machine_cred;
 
-	dprintk("RPC:       allocated generic cred %p for uid %d gid %d\n",
+	dprintk("RPC:       allocated %s cred %p for uid %d gid %d\n",
+			gcred->acred.machine_cred ? "machine" : "generic",
 			gcred, acred->uid, acred->gid);
 	return &gcred->gc_base;
 }
@@ -115,7 +136,8 @@ generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
 
 	if (gcred->acred.uid != acred->uid ||
 	    gcred->acred.gid != acred->gid ||
-	    gcred->acred.group_info != acred->group_info)
+	    gcred->acred.group_info != acred->group_info ||
+	    gcred->acred.machine_cred != acred->machine_cred)
 		return 0;
 	return 1;
 }
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 7567eb9..46f7ec8 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -371,9 +371,16 @@ gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid)
 static struct gss_upcall_msg *
 gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cred *cred)
 {
+	struct gss_cred *gss_cred = container_of(cred,
+			struct gss_cred, gc_base);
 	struct gss_upcall_msg *gss_new, *gss_msg;
+	uid_t uid = cred->cr_uid;
 
-	gss_new = gss_alloc_msg(gss_auth, cred->cr_uid);
+	/* Special case: rpc.gssd assumes that uid == 0 implies machine creds */
+	if (gss_cred->gc_machine_cred != 0)
+		uid = 0;
+
+	gss_new = gss_alloc_msg(gss_auth, uid);
 	if (gss_new == NULL)
 		return ERR_PTR(-ENOMEM);
 	gss_msg = gss_add_msg(gss_auth, gss_new);
@@ -818,6 +825,7 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	 */
 	cred->gc_base.cr_flags = 1UL << RPCAUTH_CRED_NEW;
 	cred->gc_service = gss_auth->service;
+	cred->gc_machine_cred = acred->machine_cred;
 	kref_get(&gss_auth->kref);
 	return &cred->gc_base;
 
@@ -855,6 +863,8 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 	if (gss_cred->gc_ctx && time_after(jiffies, gss_cred->gc_ctx->gc_expiry))
 		return 0;
 out:
+	if (acred->machine_cred != gss_cred->gc_machine_cred)
+		return 0;
 	return (rc->cr_uid == acred->uid);
 }
 

