Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:45502 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752707Ab3JVOVX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 10:21:23 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/5] SUNRPC: register the gss-ctx key type
Date: Tue, 22 Oct 2013 10:21:12 -0400
Message-ID: <1382451676-2963-2-git-send-email-andros@netapp.com>
In-Reply-To: <1382451676-2963-1-git-send-email-andros@netapp.com>
References: <1382451676-2963-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The gss-ctx key is used for gss_credential and gss_context management to
sync kernel gss_cred and gss_context lifetimes with Kerberos credential
lifetimes. It will be created upon kinit and destroyed upon kdestroy.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 0846566..ae42a83 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -52,6 +52,8 @@
 #include <linux/sunrpc/gss_api.h>
 #include <asm/uaccess.h>
 #include <linux/hashtable.h>
+#include <linux/key-type.h>
+#include <keys/user-type.h>
 
 #include "../netns.h"
 
@@ -113,6 +115,32 @@ static void gss_free_ctx(struct gss_cl_ctx *);
 static const struct rpc_pipe_ops gss_upcall_ops_v0;
 static const struct rpc_pipe_ops gss_upcall_ops_v1;
 
+static struct key_type key_type_gss_ctx = {
+	.name		= "gss-ctx",
+	.instantiate	= user_instantiate,
+	.match		= user_match,
+	.revoke		= user_revoke,
+	.destroy	= user_destroy,
+	.describe	= user_describe,
+	.read		= user_read,
+};
+
+/* Register the gss-ctx key type for use by nfslogin and nfslogout */
+static int gss_register_ctx_keytype(void)
+{
+	int ret;
+
+	ret = register_key_type(&key_type_gss_ctx);
+	pr_notice("NFS: Registering the %s key type ret %d\n",
+		key_type_gss_ctx.name, ret);
+	return ret;
+}
+
+static void gss_unregister_ctx_keytype(void)
+{
+	unregister_key_type(&key_type_gss_ctx);
+}
+
 static inline struct gss_cl_ctx *
 gss_get_ctx(struct gss_cl_ctx *ctx)
 {
@@ -1959,6 +1987,7 @@ static int __init init_rpcsec_gss(void)
 	if (err)
 		goto out_svc_exit;
 	rpc_init_wait_queue(&pipe_version_rpc_waitqueue, "gss pipe version");
+	gss_register_ctx_keytype();
 	return 0;
 out_svc_exit:
 	gss_svc_shutdown();
@@ -1972,6 +2001,7 @@ static void __exit exit_rpcsec_gss(void)
 {
 	unregister_pernet_subsys(&rpcsec_gss_net_ops);
 	gss_svc_shutdown();
+	gss_unregister_ctx_keytype();
 	rpcauth_unregister(&authgss_ops);
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
-- 
1.8.3.1

