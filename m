Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:42494 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758836Ab3IBSRJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Sep 2013 14:17:09 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v3 05/17] SUNRPC: Replace clnt->cl_principal
Date: Mon, 2 Sep 2013 14:16:48 -0400
Message-ID: <1378145820-29990-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378145820-29990-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1378145820-29990-1-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-2-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-3-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-4-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The clnt->cl_principal is being used exclusively to store the service
target name for RPCSEC_GSS/krb5 callbacks. Replace it with something that
is stored only in the RPCSEC_GSS-specific code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c              |  5 ++++-
 include/linux/sunrpc/auth.h    | 10 ++++++++--
 include/linux/sunrpc/clnt.h    |  1 -
 net/sunrpc/auth.c              |  6 +++---
 net/sunrpc/auth_gss/auth_gss.c |  7 ++++---
 net/sunrpc/auth_null.c         |  2 +-
 net/sunrpc/auth_unix.c         |  2 +-
 net/sunrpc/clnt.c              | 18 +++++-------------
 8 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1671e1f..09c7e3b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2717,10 +2717,13 @@ out:
 static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 				struct nfs_fsinfo *info, rpc_authflavor_t flavor)
 {
+	struct rpc_auth_create_args auth_args = {
+		.pseudoflavor = flavor,
+	};
 	struct rpc_auth *auth;
 	int ret;
 
-	auth = rpcauth_create(flavor, server->client);
+	auth = rpcauth_create(&auth_args, server->client);
 	if (IS_ERR(auth)) {
 		ret = -EACCES;
 		goto out;
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 0dd00f4..a9ab577 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -87,6 +87,11 @@ struct rpc_auth {
 	/* per-flavor data */
 };
 
+struct rpc_auth_create_args {
+	rpc_authflavor_t pseudoflavor;
+	const char *target_name;
+};
+
 /* Flags for rpcauth_lookupcred() */
 #define RPCAUTH_LOOKUP_NEW		0x01	/* Accept an uninitialised cred */
 
@@ -97,7 +102,7 @@ struct rpc_authops {
 	struct module		*owner;
 	rpc_authflavor_t	au_flavor;	/* flavor (RPC_AUTH_*) */
 	char *			au_name;
-	struct rpc_auth *	(*create)(struct rpc_clnt *, rpc_authflavor_t);
+	struct rpc_auth *	(*create)(struct rpc_auth_create_args *, struct rpc_clnt *);
 	void			(*destroy)(struct rpc_auth *);
 
 	struct rpc_cred *	(*lookup_cred)(struct rpc_auth *, struct auth_cred *, int);
@@ -140,7 +145,8 @@ struct rpc_cred *	rpc_lookup_cred(void);
 struct rpc_cred *	rpc_lookup_machine_cred(const char *service_name);
 int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
-struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt *);
+struct rpc_auth *	rpcauth_create(struct rpc_auth_create_args *,
+				struct rpc_clnt *);
 void			rpcauth_release(struct rpc_auth *);
 rpc_authflavor_t	rpcauth_get_pseudoflavor(rpc_authflavor_t,
 				struct rpcsec_gss_info *);
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 481f9c0..b93b4aa 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -60,7 +60,6 @@ struct rpc_clnt {
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_timeout	cl_timeout_default;
 	const struct rpc_program *cl_program;
-	char			*cl_principal;	/* target to authenticate to */
 };
 
 /*
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index ed2fdd2..5071e43 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -250,11 +250,11 @@ rpcauth_list_flavors(rpc_authflavor_t *array, int size)
 EXPORT_SYMBOL_GPL(rpcauth_list_flavors);
 
 struct rpc_auth *
-rpcauth_create(rpc_authflavor_t pseudoflavor, struct rpc_clnt *clnt)
+rpcauth_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 {
 	struct rpc_auth		*auth;
 	const struct rpc_authops *ops;
-	u32			flavor = pseudoflavor_to_flavor(pseudoflavor);
+	u32			flavor = pseudoflavor_to_flavor(args->pseudoflavor);
 
 	auth = ERR_PTR(-EINVAL);
 	if (flavor >= RPC_AUTH_MAXFLAVOR)
@@ -269,7 +269,7 @@ rpcauth_create(rpc_authflavor_t pseudoflavor, struct rpc_clnt *clnt)
 		goto out;
 	}
 	spin_unlock(&rpc_authflavor_lock);
-	auth = ops->create(clnt, pseudoflavor);
+	auth = ops->create(args, clnt);
 	module_put(ops->owner);
 	if (IS_ERR(auth))
 		return auth;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index b62812a..672a67f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -864,8 +864,9 @@ static int gss_pipes_dentries_create_net(struct rpc_clnt *clnt,
  * parameters based on the input flavor (which must be a pseudoflavor)
  */
 static struct rpc_auth *
-gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
+gss_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 {
+	rpc_authflavor_t flavor = args->pseudoflavor;
 	struct gss_auth *gss_auth;
 	struct rpc_auth * auth;
 	int err = -ENOMEM; /* XXX? */
@@ -877,8 +878,8 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 	if (!(gss_auth = kmalloc(sizeof(*gss_auth), GFP_KERNEL)))
 		goto out_dec;
 	gss_auth->target_name = NULL;
-	if (clnt->cl_principal) {
-		gss_auth->target_name = kstrdup(clnt->cl_principal, GFP_KERNEL);
+	if (args->target_name) {
+		gss_auth->target_name = kstrdup(args->target_name, GFP_KERNEL);
 		if (gss_auth->target_name == NULL)
 			goto err_free;
 	}
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index a5c36c0..4664eb4 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -18,7 +18,7 @@ static struct rpc_auth null_auth;
 static struct rpc_cred null_cred;
 
 static struct rpc_auth *
-nul_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
+nul_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 {
 	atomic_inc(&null_auth.au_count);
 	return &null_auth;
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index dc37021..e52d832 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -33,7 +33,7 @@ static struct rpc_auth		unix_auth;
 static const struct rpc_credops	unix_credops;
 
 static struct rpc_auth *
-unx_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
+unx_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 {
 	dprintk("RPC:       creating UNIX authenticator for client %p\n",
 			clnt);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 79d4bc2..7407f1d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -282,6 +282,10 @@ static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
 static int rpc_client_register(const struct rpc_create_args *args,
 			       struct rpc_clnt *clnt)
 {
+	struct rpc_auth_create_args auth_args = {
+		.pseudoflavor = args->authflavor,
+		.target_name = args->client_name,
+	};
 	struct rpc_auth *auth;
 	struct net *net = rpc_net_ns(clnt);
 	struct super_block *pipefs_sb;
@@ -298,7 +302,7 @@ static int rpc_client_register(const struct rpc_create_args *args,
 	if (pipefs_sb)
 		rpc_put_sb_net(net);
 
-	auth = rpcauth_create(args->authflavor, clnt);
+	auth = rpcauth_create(&auth_args, clnt);
 	if (IS_ERR(auth)) {
 		dprintk("RPC:       Couldn't create auth handle (flavor %u)\n",
 				args->authflavor);
@@ -370,12 +374,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 
 	clnt->cl_rtt = &clnt->cl_rtt_default;
 	rpc_init_rtt(&clnt->cl_rtt_default, clnt->cl_timeout->to_initval);
-	clnt->cl_principal = NULL;
-	if (args->client_name) {
-		clnt->cl_principal = kstrdup(args->client_name, GFP_KERNEL);
-		if (!clnt->cl_principal)
-			goto out_no_principal;
-	}
 
 	atomic_set(&clnt->cl_count, 1);
 
@@ -388,8 +386,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	return clnt;
 
 out_no_path:
-	kfree(clnt->cl_principal);
-out_no_principal:
 	rpc_free_iostats(clnt->cl_metrics);
 out_no_stats:
 	kfree(clnt);
@@ -559,7 +555,6 @@ struct rpc_clnt *rpc_clone_client(struct rpc_clnt *clnt)
 		.prognumber	= clnt->cl_prog,
 		.version	= clnt->cl_vers,
 		.authflavor	= clnt->cl_auth->au_flavor,
-		.client_name	= clnt->cl_principal,
 	};
 	return __rpc_clone_client(&args, clnt);
 }
@@ -581,7 +576,6 @@ rpc_clone_client_set_auth(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 		.prognumber	= clnt->cl_prog,
 		.version	= clnt->cl_vers,
 		.authflavor	= flavor,
-		.client_name	= clnt->cl_principal,
 	};
 	return __rpc_clone_client(&args, clnt);
 }
@@ -654,7 +648,6 @@ rpc_free_client(struct rpc_clnt *clnt)
 	rpc_clnt_remove_pipedir(clnt);
 	rpc_unregister_client(clnt);
 	rpc_free_iostats(clnt->cl_metrics);
-	kfree(clnt->cl_principal);
 	clnt->cl_metrics = NULL;
 	xprt_put(rcu_dereference_raw(clnt->cl_xprt));
 	rpciod_down();
@@ -718,7 +711,6 @@ struct rpc_clnt *rpc_bind_new_program(struct rpc_clnt *old,
 		.prognumber	= program->number,
 		.version	= vers,
 		.authflavor	= old->cl_auth->au_flavor,
-		.client_name	= old->cl_principal,
 	};
 	struct rpc_clnt *clnt;
 	int err;
-- 
1.8.3.1

