Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15740 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754265Ab3H1Tkh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Aug 2013 15:40:37 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v2 16/16] RPCSEC_GSS: Share all credential caches on a per-transport basis
Date: Wed, 28 Aug 2013 15:40:21 -0400
Message-ID: <1377718821-28159-16-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377718821-28159-15-git-send-email-Trond.Myklebust@netapp.com>
References: <1377718821-28159-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-8-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-9-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-10-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-11-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-12-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-13-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-14-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-15-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that all struct rpc_clnt for any given socket/rdma channel
share the same RPCSEC_GSS/krb5,krb5i,krb5p caches.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 92 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 89 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 67ada62..087b1e2 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -51,6 +51,7 @@
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/gss_api.h>
 #include <asm/uaccess.h>
+#include <linux/hashtable.h>
 
 #include "../netns.h"
 
@@ -71,6 +72,9 @@ static unsigned int gss_expired_cred_retry_delay = GSS_RETRY_EXPIRED;
  * using integrity (two 4-byte integers): */
 #define GSS_VERF_SLACK		100
 
+DEFINE_HASHTABLE(gss_auth_hash_table, 16);
+DEFINE_SPINLOCK(gss_auth_hash_lock);
+
 struct gss_pipe {
 	struct rpc_pipe_dir_object pdo;
 	struct rpc_pipe *pipe;
@@ -81,6 +85,7 @@ struct gss_pipe {
 
 struct gss_auth {
 	struct kref kref;
+	struct hlist_node hash;
 	struct rpc_auth rpc_auth;
 	struct gss_api_mech *mech;
 	enum rpc_gss_svc service;
@@ -940,8 +945,8 @@ static void gss_pipe_free(struct gss_pipe *p)
  * NOTE: we have the opportunity to use different
  * parameters based on the input flavor (which must be a pseudoflavor)
  */
-static struct rpc_auth *
-gss_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
+static struct gss_auth *
+gss_create_new(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 {
 	rpc_authflavor_t flavor = args->pseudoflavor;
 	struct gss_auth *gss_auth;
@@ -955,6 +960,7 @@ gss_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 		return ERR_PTR(err);
 	if (!(gss_auth = kmalloc(sizeof(*gss_auth), GFP_KERNEL)))
 		goto out_dec;
+	INIT_HLIST_NODE(&gss_auth->hash);
 	gss_auth->target_name = NULL;
 	if (args->target_name) {
 		gss_auth->target_name = kstrdup(args->target_name, GFP_KERNEL);
@@ -1003,7 +1009,7 @@ gss_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 		goto err_destroy_pipe_1;
 	}
 
-	return auth;
+	return gss_auth;
 err_destroy_pipe_1:
 	gss_pipe_free(gss_auth->gss_pipe[1]);
 err_destroy_credcache:
@@ -1050,6 +1056,12 @@ gss_destroy(struct rpc_auth *auth)
 	dprintk("RPC:       destroying GSS authenticator %p flavor %d\n",
 			auth, auth->au_flavor);
 
+	if (hash_hashed(&gss_auth->hash)) {
+		spin_lock(&gss_auth_hash_lock);
+		hash_del(&gss_auth->hash);
+		spin_unlock(&gss_auth_hash_lock);
+	}
+
 	gss_pipe_free(gss_auth->gss_pipe[0]);
 	gss_auth->gss_pipe[0] = NULL;
 	gss_pipe_free(gss_auth->gss_pipe[1]);
@@ -1059,6 +1071,80 @@ gss_destroy(struct rpc_auth *auth)
 	kref_put(&gss_auth->kref, gss_free_callback);
 }
 
+static struct gss_auth *
+gss_auth_find_or_add_hashed(struct rpc_auth_create_args *args,
+		struct rpc_clnt *clnt,
+		struct gss_auth *new)
+{
+	struct gss_auth *gss_auth;
+	unsigned long hashval = (unsigned long)clnt;
+
+	spin_lock(&gss_auth_hash_lock);
+	hash_for_each_possible(gss_auth_hash_table,
+			gss_auth,
+			hash,
+			hashval) {
+		if (gss_auth->rpc_auth.au_flavor != args->pseudoflavor)
+			continue;
+		if (gss_auth->target_name != args->target_name) {
+			if (gss_auth->target_name == NULL)
+				continue;
+			if (args->target_name == NULL)
+				continue;
+			if (strcmp(gss_auth->target_name, args->target_name))
+				continue;
+		}
+		if (!atomic_inc_not_zero(&gss_auth->rpc_auth.au_count))
+			continue;
+		goto out;
+	}
+	if (new)
+		hash_add(gss_auth_hash_table, &new->hash, hashval);
+	gss_auth = new;
+out:
+	spin_unlock(&gss_auth_hash_lock);
+	return gss_auth;
+}
+
+static struct gss_auth *
+gss_create_hashed(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
+{
+	struct gss_auth *gss_auth;
+	struct gss_auth *new;
+
+	gss_auth = gss_auth_find_or_add_hashed(args, clnt, NULL);
+	if (gss_auth != NULL)
+		goto out;
+	new = gss_create_new(args, clnt);
+	if (IS_ERR(new))
+		return new;
+	gss_auth = gss_auth_find_or_add_hashed(args, clnt, new);
+	if (gss_auth != new)
+		gss_destroy(&new->rpc_auth);
+out:
+	return gss_auth;
+}
+
+static struct rpc_auth *
+gss_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
+{
+	struct gss_auth *gss_auth;
+	struct rpc_clnt *parent;
+
+	for (parent = clnt->cl_parent;
+	     parent != clnt;
+	     clnt = parent, parent = parent->cl_parent) {
+		/* Find the original parent for this transport */
+		if (clnt->cl_xprt != parent->cl_xprt)
+			break;
+	}
+
+	gss_auth = gss_create_hashed(args, clnt);
+	if (IS_ERR(gss_auth))
+		return ERR_CAST(gss_auth);
+	return &gss_auth->rpc_auth;
+}
+
 /*
  * gss_destroying_context will cause the RPCSEC_GSS to send a NULL RPC call
  * to the server with the GSS control procedure field set to
-- 
1.8.3.1

