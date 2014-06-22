Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:34269 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbaFVAw2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Jun 2014 20:52:28 -0400
Received: by mail-qa0-f54.google.com with SMTP id v10so4474363qac.13
        for <linux-nfs@vger.kernel.org>; Sat, 21 Jun 2014 17:52:27 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] sunrpc: add a new "stringify_acceptor" rpc_credop
Date: Sat, 21 Jun 2014 20:52:16 -0400
Message-Id: <1403398337-4174-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403398337-4174-1-git-send-email-jlayton@primarydata.com>
References: <1403398337-4174-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@poochiereds.net>

...and add an new rpc_auth function to call it when it exists. This
is only applicable for AUTH_GSS mechanisms, so we only specify this
for those sorts of credentials.

Signed-off-by: Jeff Layton <jlayton@poochiereds.net>
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
index f77366717420..1481efff6aa2 100644
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
index e34af68603bd..73854314fb85 100644
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
1.9.3

