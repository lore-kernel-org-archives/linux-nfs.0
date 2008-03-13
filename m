From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 5/6] SUNRPC: Add an rpc_credop callback for binding a
	credential to an rpc_task
Date: Thu, 13 Mar 2008 13:48:10 -0400
Message-ID: <20080313174809.13840.9683.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47380 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027AbYCMSCN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 14:02:13 -0400
In-Reply-To: <20080313174806.13840.90325.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need the ability to treat 'generic' creds specially, since they want to
bind instances of the auth cred instead of binding themselves.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/auth.h    |    2 ++
 net/sunrpc/auth.c              |    5 +++--
 net/sunrpc/auth_generic.c      |   15 +++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c |    2 ++
 net/sunrpc/auth_null.c         |    1 +
 net/sunrpc/auth_unix.c         |    1 +
 6 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 70644ed..e93cd8a 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -112,6 +112,7 @@ struct rpc_credops {
 	void			(*crdestroy)(struct rpc_cred *);
 
 	int			(*crmatch)(struct auth_cred *, struct rpc_cred *, int);
+	void			(*crbind)(struct rpc_task *, struct rpc_cred *);
 	__be32 *		(*crmarshal)(struct rpc_task *, __be32 *);
 	int			(*crrefresh)(struct rpc_task *);
 	__be32 *		(*crvalidate)(struct rpc_task *, __be32 *);
@@ -139,6 +140,7 @@ struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *
 void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
 struct rpc_cred *	rpcauth_lookupcred(struct rpc_auth *, int);
 void			rpcauth_bindcred(struct rpc_task *, struct rpc_cred *, int);
+void			rpcauth_generic_bind_cred(struct rpc_task *, struct rpc_cred *);
 void			put_rpccred(struct rpc_cred *);
 void			rpcauth_unbindcred(struct rpc_task *);
 __be32 *		rpcauth_marshcred(struct rpc_task *, __be32 *);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 012f2a3..d65dd79 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -375,13 +375,14 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 }
 EXPORT_SYMBOL_GPL(rpcauth_init_cred);
 
-static void
+void
 rpcauth_generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred)
 {
 	task->tk_msg.rpc_cred = get_rpccred(cred);
 	dprintk("RPC: %5u holding %s cred %p\n", task->tk_pid,
 			cred->cr_auth->au_ops->au_name, cred);
 }
+EXPORT_SYMBOL_GPL(rpcauth_generic_bind_cred);
 
 static void
 rpcauth_bind_root_cred(struct rpc_task *task)
@@ -421,7 +422,7 @@ void
 rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 {
 	if (cred != NULL)
-		rpcauth_generic_bind_cred(task, cred);
+		cred->cr_ops->crbind(task, cred);
 	else if (flags & RPC_TASK_ROOTCREDS)
 		rpcauth_bind_root_cred(task);
 	else
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 6f129b1..6a3f77c 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -35,6 +35,20 @@ struct rpc_cred *rpc_lookup_cred(void)
 }
 EXPORT_SYMBOL_GPL(rpc_lookup_cred);
 
+static void
+generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred)
+{
+	struct rpc_auth *auth = task->tk_client->cl_auth;
+	struct auth_cred *acred = &container_of(cred, struct generic_cred, gc_base)->acred;
+	struct rpc_cred *ret;
+
+	ret = auth->au_ops->lookup_cred(auth, acred, 0);
+	if (!IS_ERR(ret))
+		task->tk_msg.rpc_cred = ret;
+	else
+		task->tk_status = PTR_ERR(ret);
+}
+
 /*
  * Lookup generic creds for current process
  */
@@ -138,5 +152,6 @@ static struct rpc_auth generic_auth = {
 static const struct rpc_credops generic_credops = {
 	.cr_name = "Generic cred",
 	.crdestroy = generic_destroy_cred,
+	.crbind = generic_bind_cred,
 	.crmatch = generic_match,
 };
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index ef63849..d34f6df 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1300,6 +1300,7 @@ static const struct rpc_credops gss_credops = {
 	.cr_name	= "AUTH_GSS",
 	.crdestroy	= gss_destroy_cred,
 	.cr_init	= gss_cred_init,
+	.crbind		= rpcauth_generic_bind_cred,
 	.crmatch	= gss_match,
 	.crmarshal	= gss_marshal,
 	.crrefresh	= gss_refresh,
@@ -1311,6 +1312,7 @@ static const struct rpc_credops gss_credops = {
 static const struct rpc_credops gss_nullops = {
 	.cr_name	= "AUTH_GSS",
 	.crdestroy	= gss_destroy_cred,
+	.crbind		= rpcauth_generic_bind_cred,
 	.crmatch	= gss_match,
 	.crmarshal	= gss_marshal,
 	.crrefresh	= gss_refresh_null,
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index 537d0e8..3c26c18 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -125,6 +125,7 @@ static
 const struct rpc_credops null_credops = {
 	.cr_name	= "AUTH_NULL",
 	.crdestroy	= nul_destroy_cred,
+	.crbind		= rpcauth_generic_bind_cred,
 	.crmatch	= nul_match,
 	.crmarshal	= nul_marshal,
 	.crrefresh	= nul_refresh,
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index b763710..04e936a 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -237,6 +237,7 @@ static
 const struct rpc_credops unix_credops = {
 	.cr_name	= "AUTH_UNIX",
 	.crdestroy	= unx_destroy_cred,
+	.crbind		= rpcauth_generic_bind_cred,
 	.crmatch	= unx_match,
 	.crmarshal	= unx_marshal,
 	.crrefresh	= unx_refresh,

