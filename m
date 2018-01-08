Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33908 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752543AbeAHFch (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Jan 2018 00:32:37 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 08 Jan 2018 16:26:19 +1100
Subject: [PATCH 19/20] SUNRPC: simplify auth_unix.
Cc: linux-nfs@vger.kernel.org
Message-ID: <151538917945.25812.5097319917995721288.stgit@noble>
In-Reply-To: <151538903497.25812.13293229343061416612.stgit@noble>
References: <151538903497.25812.13293229343061416612.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

1/ discard 'struct unx_cred'.  We don't need any data that is
   is not already in 'struct rpc_cred'.
2/ Don't keep these creds in a hash table.  When a credential
   is needed, simply allocate it.  When not needed, discard it.
   This can easily be faster than performing a lookup on
   a shared hash table.
   As the lookup can happen during write-out, use a mempool
   to ensure forward progress.
   This means that we cannot compare two credentials for
   equality by comparing the pointers, but we never do that anyway.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 net/sunrpc/auth.c      |    1 
 net/sunrpc/auth_unix.c |   99 +++++++++++++++---------------------------------
 2 files changed, 31 insertions(+), 69 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 7ffc2b100356..a4d79e4f9b14 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -627,6 +627,7 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 	INIT_LIST_HEAD(&cred->cr_lru);
 	atomic_set(&cred->cr_count, 1);
 	cred->cr_auth = auth;
+	cred->cr_flags = 0;
 	cred->cr_ops = ops;
 	cred->cr_expire = jiffies;
 	cred->cr_cred = get_cred(acred->cred);
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 3409a1426980..eb2ef3c99eec 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -11,16 +11,11 @@
 #include <linux/types.h>
 #include <linux/sched.h>
 #include <linux/module.h>
+#include <linux/mempool.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/user_namespace.h>
 
-struct unx_cred {
-	struct rpc_cred		uc_base;
-	kgid_t			uc_gid;
-	kgid_t			uc_gids[UNX_NGROUPS];
-};
-#define uc_uid			uc_base.cr_uid
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY	RPCDBG_AUTH
@@ -28,6 +23,7 @@ struct unx_cred {
 
 static struct rpc_auth		unix_auth;
 static const struct rpc_credops	unix_credops;
+static mempool_t		*unix_pool;
 
 static struct rpc_auth *
 unx_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
@@ -42,15 +38,6 @@ static void
 unx_destroy(struct rpc_auth *auth)
 {
 	dprintk("RPC:       destroying UNIX authenticator %p\n", auth);
-	rpcauth_clear_credcache(auth->au_credcache);
-}
-
-static int
-unx_hash_cred(struct auth_cred *acred, unsigned int hashbits)
-{
-	return hash_64(from_kgid(&init_user_ns, acred->cred->fsgid) |
-		((u64)from_kuid(&init_user_ns, acred->cred->fsuid) <<
-			(sizeof(gid_t) * 8)), hashbits);
 }
 
 /*
@@ -59,52 +46,23 @@ unx_hash_cred(struct auth_cred *acred, unsigned int hashbits)
 static struct rpc_cred *
 unx_lookup_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 {
-	return rpcauth_lookup_credcache(auth, acred, flags, GFP_NOFS);
-}
-
-static struct rpc_cred *
-unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t gfp)
-{
-	struct unx_cred	*cred;
-	unsigned int groups = 0;
-	unsigned int i;
+	struct rpc_cred *ret = mempool_alloc(unix_pool, GFP_NOFS);
 
 	dprintk("RPC:       allocating UNIX cred for uid %d gid %d\n",
 			from_kuid(&init_user_ns, acred->cred->fsuid),
 			from_kgid(&init_user_ns, acred->cred->fsgid));
 
-	if (!(cred = kmalloc(sizeof(*cred), gfp)))
-		return ERR_PTR(-ENOMEM);
-
-	rpcauth_init_cred(&cred->uc_base, acred, auth, &unix_credops);
-	cred->uc_base.cr_flags = 1UL << RPCAUTH_CRED_UPTODATE;
-
-	if (acred->cred && acred->cred->group_info != NULL)
-		groups = acred->cred->group_info->ngroups;
-	if (groups > UNX_NGROUPS)
-		groups = UNX_NGROUPS;
-
-	cred->uc_gid = acred->cred->fsgid;
-	for (i = 0; i < groups; i++)
-		cred->uc_gids[i] = acred->cred->group_info->gid[i];
-	if (i < UNX_NGROUPS)
-		cred->uc_gids[i] = INVALID_GID;
-
-	return &cred->uc_base;
-}
-
-static void
-unx_free_cred(struct unx_cred *unx_cred)
-{
-	dprintk("RPC:       unx_free_cred %p\n", unx_cred);
-	kfree(unx_cred);
+	rpcauth_init_cred(ret, acred, auth, &unix_credops);
+	ret->cr_flags = 1UL << RPCAUTH_CRED_UPTODATE;
+	return ret;
 }
 
 static void
 unx_free_cred_callback(struct rcu_head *head)
 {
-	struct unx_cred *unx_cred = container_of(head, struct unx_cred, uc_base.cr_rcu);
-	unx_free_cred(unx_cred);
+	struct rpc_cred *rpc_cred = container_of(head, struct rpc_cred, cr_rcu);
+	dprintk("RPC:       unx_free_cred %p\n", rpc_cred);
+	mempool_free(rpc_cred, unix_pool);
 }
 
 static void
@@ -114,30 +72,32 @@ unx_destroy_cred(struct rpc_cred *cred)
 }
 
 /*
- * Match credentials against current process creds.
- * The root_override argument takes care of cases where the caller may
- * request root creds (e.g. for NFS swapping).
+ * Match credentials against current the auth_cred.
  */
 static int
-unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
+unx_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
 {
-	struct unx_cred	*cred = container_of(rcred, struct unx_cred, uc_base);
 	unsigned int groups = 0;
 	unsigned int i;
 
+	if (cred->cr_cred == acred->cred)
+		return 1;
 
-	if (!uid_eq(cred->uc_uid, acred->cred->fsuid) || !gid_eq(cred->uc_gid, acred->cred->fsgid))
+	if (!uid_eq(cred->cr_cred->fsuid, acred->cred->fsuid) || !gid_eq(cred->cr_cred->fsgid, acred->cred->fsgid))
 		return 0;
 
 	if (acred->cred && acred->cred->group_info != NULL)
 		groups = acred->cred->group_info->ngroups;
 	if (groups > UNX_NGROUPS)
 		groups = UNX_NGROUPS;
+	if (cred->cr_cred->group_info == NULL)
+		return groups == 0;
+	if (groups != cred->cr_cred->group_info->ngroups)
+		return 0;
+
 	for (i = 0; i < groups ; i++)
-		if (!gid_eq(cred->uc_gids[i], acred->cred->group_info->gid[i]))
+		if (!gid_eq(cred->cr_cred->group_info->gid[i], acred->cred->group_info->gid[i]))
 			return 0;
-	if (groups < UNX_NGROUPS && gid_valid(cred->uc_gids[groups]))
-		return 0;
 	return 1;
 }
 
@@ -149,9 +109,10 @@ static __be32 *
 unx_marshal(struct rpc_task *task, __be32 *p)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
-	struct unx_cred	*cred = container_of(task->tk_rqstp->rq_cred, struct unx_cred, uc_base);
+	struct rpc_cred	*cred = task->tk_rqstp->rq_cred;
 	__be32		*base, *hold;
 	int		i;
+	struct group_info *gi = cred->cr_cred->group_info;
 
 	*p++ = htonl(RPC_AUTH_UNIX);
 	base = p++;
@@ -162,11 +123,12 @@ unx_marshal(struct rpc_task *task, __be32 *p)
 	 */
 	p = xdr_encode_array(p, clnt->cl_nodename, clnt->cl_nodelen);
 
-	*p++ = htonl((u32) from_kuid(&init_user_ns, cred->uc_uid));
-	*p++ = htonl((u32) from_kgid(&init_user_ns, cred->uc_gid));
+	*p++ = htonl((u32) from_kuid(&init_user_ns, cred->cr_cred->fsuid));
+	*p++ = htonl((u32) from_kgid(&init_user_ns, cred->cr_cred->fsgid));
 	hold = p++;
-	for (i = 0; i < UNX_NGROUPS && gid_valid(cred->uc_gids[i]); i++)
-		*p++ = htonl((u32) from_kgid(&init_user_ns, cred->uc_gids[i]));
+	if (gi)
+		for (i = 0; i < UNX_NGROUPS && i < gi->ngroups; i++)
+			*p++ = htonl((u32) from_kgid(&init_user_ns, gi->gid[i]));
 	*hold = htonl(p - hold - 1);		/* gid array length */
 	*base = htonl((p - base - 1) << 2);	/* cred length */
 
@@ -213,12 +175,13 @@ unx_validate(struct rpc_task *task, __be32 *p)
 
 int __init rpc_init_authunix(void)
 {
-	return rpcauth_init_credcache(&unix_auth);
+	unix_pool = mempool_create_kmalloc_pool(16, sizeof(struct rpc_cred));
+	return unix_pool ? 0 : -ENOMEM;
 }
 
 void rpc_destroy_authunix(void)
 {
-	rpcauth_destroy_credcache(&unix_auth);
+	mempool_destroy(unix_pool);
 }
 
 const struct rpc_authops authunix_ops = {
@@ -227,9 +190,7 @@ const struct rpc_authops authunix_ops = {
 	.au_name	= "UNIX",
 	.create		= unx_create,
 	.destroy	= unx_destroy,
-	.hash_cred	= unx_hash_cred,
 	.lookup_cred	= unx_lookup_cred,
-	.crcreate	= unx_create_cred,
 };
 
 static


