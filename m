From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 45/69] sunrpc: fix code that makes auth_gss send
 destroy_cred message (try #2)
Date: Tue, 23 Dec 2008 18:02:19 -0500
Message-ID: <20081223230218.13743.40905.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21081 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752304AbYLWXYj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:39 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOcSW021557
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:38 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

There's a bit of a chicken and egg problem when it comes to destroying
auth_gss credentials. When we destroy the last instance of a GSSAPI RPC
credential, we should send a NULL RPC call with a GSS procedure of
RPCSEC_GSS_DESTROY to hint to the server that it can destroy those
creds.

This isn't happening because we're setting clearing the uptodate bit on
the credentials and then setting the operations to the gss_nullops. When
we go to do the RPC call, we try to refresh the creds. That fails with
-EACCES and the call fails.

Fix this by not clearing the UPTODATE bit for the credentials and adding
a new crdestroy op for gss_nullops that just tears down the cred without
trying to destroy the context.

The only difference between this patch and the first one is the removal
of some minor formatting deltas.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)


diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index b856159..cb19c9d 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -693,7 +693,7 @@ gss_destroying_context(struct rpc_cred *cred)
 	struct rpc_task *task;
 
 	if (gss_cred->gc_ctx == NULL ||
-	    test_and_clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) == 0)
+	    test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) == 0)
 		return 0;
 
 	gss_cred->gc_ctx->gc_proc = RPC_GSS_PROC_DESTROY;
@@ -757,14 +757,12 @@ gss_free_cred_callback(struct rcu_head *head)
 }
 
 static void
-gss_destroy_cred(struct rpc_cred *cred)
+gss_destroy_nullcred(struct rpc_cred *cred)
 {
 	struct gss_cred *gss_cred = container_of(cred, struct gss_cred, gc_base);
 	struct gss_auth *gss_auth = container_of(cred->cr_auth, struct gss_auth, rpc_auth);
 	struct gss_cl_ctx *ctx = gss_cred->gc_ctx;
 
-	if (gss_destroying_context(cred))
-		return;
 	rcu_assign_pointer(gss_cred->gc_ctx, NULL);
 	call_rcu(&cred->cr_rcu, gss_free_cred_callback);
 	if (ctx)
@@ -772,6 +770,15 @@ gss_destroy_cred(struct rpc_cred *cred)
 	kref_put(&gss_auth->kref, gss_free_callback);
 }
 
+static void
+gss_destroy_cred(struct rpc_cred *cred)
+{
+
+	if (gss_destroying_context(cred))
+		return;
+	gss_destroy_nullcred(cred);
+}
+
 /*
  * Lookup RPCSEC_GSS cred for the current process
  */
@@ -1324,7 +1331,7 @@ static const struct rpc_credops gss_credops = {
 
 static const struct rpc_credops gss_nullops = {
 	.cr_name	= "AUTH_GSS",
-	.crdestroy	= gss_destroy_cred,
+	.crdestroy	= gss_destroy_nullcred,
 	.crbind		= rpcauth_generic_bind_cred,
 	.crmatch	= gss_match,
 	.crmarshal	= gss_marshal,

