Return-Path: <SRS0=4cvb=NS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAE8BC0044C
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:14:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8853C2081D
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:14:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8853C2081D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389061AbeKGNnb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Nov 2018 08:43:31 -0500
Received: from mx2.suse.de ([195.135.220.15]:56714 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388530AbeKGNnb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Nov 2018 08:43:31 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 914F2B11C;
        Wed,  7 Nov 2018 04:14:47 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Wed, 07 Nov 2018 15:12:31 +1100
Subject: [PATCH 12/23] NFS/SUNRPC: don't lookup machine credential until
 rpcauth_bindcred().
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154156395117.24086.12738019247425162006.stgit@noble>
In-Reply-To: <154156285766.24086.14262073575778354276.stgit@noble>
References: <154156285766.24086.14262073575778354276.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When NFS creates a machine credential, it is a "generic" credential,
not tied to any auth protocol, and is really just a container for
the princpal name.
This doesn't get linked to a genuine credential until rpcauth_bindcred()
is called.
The lookup always succeeds, so various places that test if the machine
credential is NULL, are pointless.

As a step towards getting rid of generic credentials, this patch gets
rid of generic machine credentials.  The nfs_client and rpc_client
just hold a pointer to a constant principal name.
When a machine credential is wanted, a special static 'struct rpc_cred'
pointer is used. rpcauth_bindcred() recognizes this, finds the
principal from the client, and binds the correct credential.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/client.c             |   11 ++---------
 fs/nfs/nfs4_fs.h            |    9 +--------
 fs/nfs/nfs4state.c          |   21 ++++-----------------
 fs/nfsd/nfs4callback.c      |   12 ++++--------
 include/linux/nfs_fs_sb.h   |    3 +--
 include/linux/sunrpc/auth.h |    3 ++-
 include/linux/sunrpc/clnt.h |    1 +
 net/sunrpc/auth.c           |   42 +++++++++++++++++++++++++++++++++++++++---
 net/sunrpc/auth_generic.c   |   21 ---------------------
 net/sunrpc/clnt.c           |    1 +
 10 files changed, 55 insertions(+), 69 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index cce151776709..fb1cf1a4bda2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -151,7 +151,6 @@ EXPORT_SYMBOL_GPL(unregister_nfs_version);
 struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 {
 	struct nfs_client *clp;
-	struct rpc_cred *cred;
 	int err = -ENOMEM;
 
 	if ((clp = kzalloc(sizeof(*clp), GFP_KERNEL)) == NULL)
@@ -182,9 +181,7 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 	clp->cl_proto = cl_init->proto;
 	clp->cl_net = get_net(cl_init->net);
 
-	cred = rpc_lookup_machine_cred("*");
-	if (!IS_ERR(cred))
-		clp->cl_machine_cred = cred;
+	clp->cl_principal = "*";
 	nfs_fscache_get_client_cookie(clp);
 
 	return clp;
@@ -246,11 +243,6 @@ void nfs_free_client(struct nfs_client *clp)
 	if (!IS_ERR(clp->cl_rpcclient))
 		rpc_shutdown_client(clp->cl_rpcclient);
 
-	if (clp->cl_machine_cred != NULL)
-		put_rpccred(clp->cl_machine_cred);
-	if (clp->cl_root_cred != NULL)
-		put_rpccred(clp->cl_root_cred);
-
 	put_net(clp->cl_net);
 	put_nfs_version(clp->cl_nfs_mod);
 	kfree(clp->cl_hostname);
@@ -529,6 +521,7 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 		return PTR_ERR(clnt);
 	}
 
+	clnt->cl_principal = clp->cl_principal;
 	clp->cl_rpcclient = clnt;
 	return 0;
 }
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 0f393eb6b4e4..431fbac63a09 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -336,7 +336,6 @@ static inline bool
 _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
 		    struct rpc_clnt **clntp, struct rpc_message *msg)
 {
-	struct rpc_cred *newcred = NULL;
 	rpc_authflavor_t flavor;
 
 	if (sp4_mode == NFS_SP4_MACH_CRED_CLEANUP ||
@@ -351,13 +350,7 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
 			return false;
 	}
 	if (test_bit(sp4_mode, &clp->cl_sp4_flags)) {
-		spin_lock(&clp->cl_lock);
-		if (clp->cl_machine_cred != NULL)
-			/* don't call get_rpccred on the machine cred -
-			 * a reference will be held for life of clp */
-			newcred = clp->cl_machine_cred;
-		spin_unlock(&clp->cl_lock);
-		msg->rpc_cred = newcred;
+		msg->rpc_cred = rpc_machine_cred();
 
 		flavor = clp->cl_rpcclient->cl_auth->au_flavor;
 		WARN_ON_ONCE(flavor != RPC_AUTH_GSS_KRB5I &&
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index dde17424c4f4..f6f984d8a94b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -166,28 +166,15 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
 
 struct rpc_cred *nfs4_get_machine_cred(struct nfs_client *clp)
 {
-	struct rpc_cred *cred = clp->cl_root_cred;
-
-	if (!cred)
-		cred = clp->cl_machine_cred;
-	if (cred)
-		return get_rpccred(cred);
-	return cred;
+	return get_rpccred(rpc_machine_cred());
 }
 
 static void nfs4_root_machine_cred(struct nfs_client *clp)
 {
-	struct rpc_cred *new;
 
-	new = rpc_lookup_machine_cred(NULL);
-	spin_lock(&clp->cl_lock);
-	if (clp->cl_root_cred == NULL) {
-		clp->cl_root_cred = new;
-		new = NULL;
-	}
-	spin_unlock(&clp->cl_lock);
-	if (new != NULL)
-		put_rpccred(new);
+	/* Force root creds instead of machine */
+	clp->cl_principal = NULL;
+	clp->cl_rpcclient->cl_principal = NULL;
 }
 
 static struct rpc_cred *
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c032e4c24a8d..1dcee1fd32d9 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -847,14 +847,10 @@ static int max_cb_time(struct net *net)
 static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc_clnt *client, struct nfsd4_session *ses)
 {
 	if (clp->cl_minorversion == 0) {
-		char *principal = clp->cl_cred.cr_targ_princ ?
-					clp->cl_cred.cr_targ_princ : "nfs";
-		struct rpc_cred *cred;
-
-		cred = rpc_lookup_machine_cred(principal);
-		if (!IS_ERR(cred))
-			get_rpccred(cred);
-		return cred;
+		client->cl_principal = clp->cl_cred.cr_targ_princ ?
+			clp->cl_cred.cr_targ_princ : "nfs";
+
+		return get_rpccred(rpc_machine_cred());
 	} else {
 		struct rpc_auth *auth = client->cl_auth;
 		struct auth_cred acred = {};
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index fea51b44fe50..6aa8cc83c3b6 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -58,8 +58,7 @@ struct nfs_client {
 	struct nfs_subversion *	cl_nfs_mod;	/* pointer to nfs version module */
 
 	u32			cl_minorversion;/* NFSv4 minorversion */
-	struct rpc_cred		*cl_machine_cred;
-	struct rpc_cred		*cl_root_cred;	/* Use when machine_cred is ineffective */
+	const char *		cl_principal;  /* used for machine cred */
 
 #if IS_ENABLED(CONFIG_NFS_V4)
 	struct list_head	cl_ds_clients; /* auth flavor data servers */
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 1c0468f39479..28b34c740c43 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -75,6 +75,8 @@ struct rpc_cred {
 #define RPCAUTH_CRED_HASHED	2
 #define RPCAUTH_CRED_NEGATIVE	3
 
+struct rpc_cred *rpc_machine_cred(void);
+
 /* rpc_auth au_flags */
 #define RPCAUTH_AUTH_NO_CRKEY_TIMEOUT	0x0001 /* underlying cred has no key timeout */
 
@@ -170,7 +172,6 @@ void 			rpc_destroy_authunix(void);
 struct rpc_cred *	rpc_lookup_cred(void);
 struct rpc_cred *	rpc_lookup_cred_nonblock(void);
 struct rpc_cred *	rpc_lookup_generic_cred(struct auth_cred *, int, gfp_t);
-struct rpc_cred *	rpc_lookup_machine_cred(const char *service_name);
 int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
 struct rpc_auth *	rpcauth_create(const struct rpc_auth_create_args *,
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 73d5c4a870fa..fc6dfbf77a9d 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -66,6 +66,7 @@ struct rpc_clnt {
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_timeout	cl_timeout_default;
 	const struct rpc_program *cl_program;
+	const char *		cl_principal;	/* use for machine cred */
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	struct dentry		*cl_debugfs;	/* debugfs directory */
 #endif
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 63e2d35c10d5..9e709dcc8c39 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -39,6 +39,20 @@ static const struct rpc_authops __rcu *auth_flavors[RPC_AUTH_MAXFLAVOR] = {
 static LIST_HEAD(cred_unused);
 static unsigned long number_cred_unused;
 
+static struct rpc_cred machine_cred = {
+	.cr_count = REFCOUNT_INIT(1),
+};
+
+/*
+ * Return the machine_cred pointer to be used whenever
+ * the a generic machine credential is needed.
+ */
+struct rpc_cred *rpc_machine_cred(void)
+{
+	return &machine_cred;
+}
+EXPORT_SYMBOL_GPL(rpc_machine_cred);
+
 #define MAX_HASHTABLE_BITS (14)
 static int param_set_hashtbl_sz(const char *val, const struct kernel_param *kp)
 {
@@ -702,6 +716,22 @@ rpcauth_bind_root_cred(struct rpc_task *task, int lookupflags)
 	return ret;
 }
 
+static struct rpc_cred *
+rpcauth_bind_machine_cred(struct rpc_task *task, int lookupflags)
+{
+	struct rpc_auth *auth = task->tk_client->cl_auth;
+	struct auth_cred acred = {
+		.principal = task->tk_client->cl_principal,
+		.cred = init_task.cred,
+	};
+
+	if (!acred.principal)
+		return NULL;
+	dprintk("RPC: %5u looking up %s machine cred\n",
+		task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
+	return auth->au_ops->lookup_cred(auth, &acred, lookupflags);
+}
+
 static struct rpc_cred *
 rpcauth_bind_new_cred(struct rpc_task *task, int lookupflags)
 {
@@ -716,14 +746,20 @@ static int
 rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	struct rpc_cred *new;
+	struct rpc_cred *new = NULL;
 	int lookupflags = 0;
 
 	if (flags & RPC_TASK_ASYNC)
 		lookupflags |= RPCAUTH_LOOKUP_NEW;
-	if (cred != NULL)
+	if (cred != NULL && cred != &machine_cred)
 		new = cred->cr_ops->crbind(task, cred, lookupflags);
-	else if (flags & RPC_TASK_ROOTCREDS)
+	else if (cred == &machine_cred)
+		new = rpcauth_bind_machine_cred(task, lookupflags);
+
+	/* If machine cred couldn't be bound, try a root cred */
+	if (new)
+		;
+	else if (cred == &machine_cred || (flags & RPC_TASK_ROOTCREDS))
 		new = rpcauth_bind_root_cred(task, lookupflags);
 	else
 		new = rpcauth_bind_new_cred(task, lookupflags);
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 810d535c79b8..8cf5aa515c51 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -48,27 +48,6 @@ struct rpc_cred *rpc_lookup_cred_nonblock(void)
 }
 EXPORT_SYMBOL_GPL(rpc_lookup_cred_nonblock);
 
-/*
- * Public call interface for looking up machine creds.
- * Note that if service_name is NULL, we actually look up
- * "root" credential.
- */
-struct rpc_cred *rpc_lookup_machine_cred(const char *service_name)
-{
-	struct auth_cred acred = {
-		.principal = service_name,
-		.cred = get_task_cred(&init_task),
-	};
-	struct rpc_cred *ret;
-
-	dprintk("RPC:       looking up machine cred for service %s\n",
-			service_name);
-	ret = generic_auth.au_ops->lookup_cred(&generic_auth, &acred, 0);
-	put_cred(acred.cred);
-	return ret;
-}
-EXPORT_SYMBOL_GPL(rpc_lookup_machine_cred);
-
 static struct rpc_cred *generic_bind_cred(struct rpc_task *task,
 		struct rpc_cred *cred, int lookupflags)
 {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ae3b8145da35..7c720b60f482 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -627,6 +627,7 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 	new->cl_noretranstimeo = clnt->cl_noretranstimeo;
 	new->cl_discrtry = clnt->cl_discrtry;
 	new->cl_chatty = clnt->cl_chatty;
+	new->cl_principal = clnt->cl_principal;
 	return new;
 
 out_err:


