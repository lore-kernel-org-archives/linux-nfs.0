Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:57242 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934686AbaDJUaE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 16:30:04 -0400
Received: by mail-qc0-f176.google.com with SMTP id m20so4921512qcx.21
        for <linux-nfs@vger.kernel.org>; Thu, 10 Apr 2014 13:30:04 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] sunrpc: add a new "stringify_acceptor" rpc_credop
Date: Thu, 10 Apr 2014 16:29:50 -0400
Message-Id: <1397161791-29144-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1397161791-29144-1-git-send-email-jlayton@redhat.com>
References: <1397161791-29144-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and add an new rpc_auth function to call it when it exists. This
is only applicable for AUTH_GSS mechanisms, so we only specify this
for those sorts of credentials.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/auth.h    |  2 ++
 net/sunrpc/auth.c              |  9 ++++++
 net/sunrpc/auth_gss/auth_gss.c | 62 ++++++++++++++++++++++++++++--------------
 3 files changed, 53 insertions(+), 20 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 790be1472792..c683b9a06913 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -140,6 +140,7 @@ struct rpc_credops {
 						void *, __be32 *, void *);
 	int			(*crkey_timeout)(struct rpc_cred *);
 	bool			(*crkey_to_expire)(struct rpc_cred *);
+	char *			(*crstringify_acceptor)(struct rpc_cred *);
 };
 
 extern const struct rpc_authops	authunix_ops;
@@ -182,6 +183,7 @@ void			rpcauth_clear_credcache(struct rpc_cred_cache *);
 int			rpcauth_key_timeout_notify(struct rpc_auth *,
 						struct rpc_cred *);
 bool			rpcauth_cred_key_to_expire(struct rpc_cred *);
+char *			rpcauth_stringify_acceptor(struct rpc_cred *);
 
 static inline
 struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 5285ead196c0..ef51bb77c465 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -363,6 +363,15 @@ rpcauth_cred_key_to_expire(struct rpc_cred *cred)
 }
 EXPORT_SYMBOL_GPL(rpcauth_cred_key_to_expire);
 
+char *
+rpcauth_stringify_acceptor(struct rpc_cred *cred)
+{
+	if (!cred->cr_ops->crstringify_acceptor)
+		return NULL;
+	return cred->cr_ops->crstringify_acceptor(cred);
+}
+EXPORT_SYMBOL_GPL(rpcauth_stringify_acceptor);
+
 /*
  * Destroy a list of credentials
  */
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index f341aabb92db..2f5b860f3491 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1346,6 +1346,26 @@ gss_cred_init(struct rpc_auth *auth, struct rpc_cred *cred)
 	return err;
 }
 
+static char *
+gss_stringify_acceptor(struct rpc_cred *cred)
+{
+	char *string;
+	struct gss_cred *gss_cred = container_of(cred, struct gss_cred, gc_base);
+	struct xdr_netobj *acceptor = &gss_cred->gc_ctx->gc_acceptor;
+
+	/* no point if there's no string */
+	if (!acceptor->len)
+		return NULL;
+
+	string = kmalloc(acceptor->len + 1, GFP_KERNEL);
+	if (!string)
+		return string;
+
+	memcpy(string, acceptor->data, acceptor->len);
+	string[acceptor->len] = '\0';
+	return string;
+}
+
 /*
  * Returns -EACCES if GSS context is NULL or will expire within the
  * timeout (miliseconds)
@@ -1923,29 +1943,31 @@ static const struct rpc_authops authgss_ops = {
 };
 
 static const struct rpc_credops gss_credops = {
-	.cr_name	= "AUTH_GSS",
-	.crdestroy	= gss_destroy_cred,
-	.cr_init	= gss_cred_init,
-	.crbind		= rpcauth_generic_bind_cred,
-	.crmatch	= gss_match,
-	.crmarshal	= gss_marshal,
-	.crrefresh	= gss_refresh,
-	.crvalidate	= gss_validate,
-	.crwrap_req	= gss_wrap_req,
-	.crunwrap_resp	= gss_unwrap_resp,
-	.crkey_timeout	= gss_key_timeout,
+	.cr_name		= "AUTH_GSS",
+	.crdestroy		= gss_destroy_cred,
+	.cr_init		= gss_cred_init,
+	.crbind			= rpcauth_generic_bind_cred,
+	.crmatch		= gss_match,
+	.crmarshal		= gss_marshal,
+	.crrefresh		= gss_refresh,
+	.crvalidate		= gss_validate,
+	.crwrap_req		= gss_wrap_req,
+	.crunwrap_resp		= gss_unwrap_resp,
+	.crkey_timeout		= gss_key_timeout,
+	.crstringify_acceptor	= gss_stringify_acceptor,
 };
 
 static const struct rpc_credops gss_nullops = {
-	.cr_name	= "AUTH_GSS",
-	.crdestroy	= gss_destroy_nullcred,
-	.crbind		= rpcauth_generic_bind_cred,
-	.crmatch	= gss_match,
-	.crmarshal	= gss_marshal,
-	.crrefresh	= gss_refresh_null,
-	.crvalidate	= gss_validate,
-	.crwrap_req	= gss_wrap_req,
-	.crunwrap_resp	= gss_unwrap_resp,
+	.cr_name		= "AUTH_GSS",
+	.crdestroy		= gss_destroy_nullcred,
+	.crbind			= rpcauth_generic_bind_cred,
+	.crmatch		= gss_match,
+	.crmarshal		= gss_marshal,
+	.crrefresh		= gss_refresh_null,
+	.crvalidate		= gss_validate,
+	.crwrap_req		= gss_wrap_req,
+	.crunwrap_resp		= gss_unwrap_resp,
+	.crstringify_acceptor	= gss_stringify_acceptor,
 };
 
 static const struct rpc_pipe_ops gss_upcall_ops_v0 = {
-- 
1.9.0

