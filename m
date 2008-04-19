From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 30/33] SUNRPC: Don't change the RPCSEC_GSS context on a
	credential that is in use
Date: Sat, 19 Apr 2008 16:40:54 -0400
Message-ID: <20080419204054.14124.78391.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54051 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756253AbYDSUuZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:25 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoPR2026058
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:25 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a server rejects our credential with an AUTH_REJECTEDCRED or similar,
we need to refresh the credential and then retry the request.
However, we do want to allow any requests that are in flight to finish
executing, so that we can at least attempt to process the replies that
depend on this instance of the credential.

The solution is to ensure that gss_refresh() looks up an entirely new
RPCSEC_GSS credential instead of attempting to create a context for the
existing invalid credential.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   69 ++++++++++++++++++++++++----------------
 1 files changed, 42 insertions(+), 27 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 6f1b4e2..621c07f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -114,28 +114,14 @@ static void
 gss_cred_set_ctx(struct rpc_cred *cred, struct gss_cl_ctx *ctx)
 {
 	struct gss_cred *gss_cred = container_of(cred, struct gss_cred, gc_base);
-	struct gss_cl_ctx *old;
 
-	old = gss_cred->gc_ctx;
+	if (!test_bit(RPCAUTH_CRED_NEW, &cred->cr_flags))
+		return;
 	gss_get_ctx(ctx);
 	rcu_assign_pointer(gss_cred->gc_ctx, ctx);
 	set_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
+	smp_mb__before_clear_bit();
 	clear_bit(RPCAUTH_CRED_NEW, &cred->cr_flags);
-	if (old)
-		gss_put_ctx(old);
-}
-
-static int
-gss_cred_is_uptodate_ctx(struct rpc_cred *cred)
-{
-	struct gss_cred *gss_cred = container_of(cred, struct gss_cred, gc_base);
-	int res = 0;
-
-	rcu_read_lock();
-	if (test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) && gss_cred->gc_ctx)
-		res = 1;
-	rcu_read_unlock();
-	return res;
 }
 
 static const void *
@@ -857,15 +843,12 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 {
 	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
 
-	/*
-	 * If the searchflags have set RPCAUTH_LOOKUP_NEW, then
-	 * we don't really care if the credential has expired or not,
-	 * since the caller should be prepared to reinitialise it.
-	 */
-	if ((flags & RPCAUTH_LOOKUP_NEW) && test_bit(RPCAUTH_CRED_NEW, &rc->cr_flags))
+	if (test_bit(RPCAUTH_CRED_NEW, &rc->cr_flags))
 		goto out;
 	/* Don't match with creds that have expired. */
-	if (gss_cred->gc_ctx && time_after(jiffies, gss_cred->gc_ctx->gc_expiry))
+	if (time_after(jiffies, gss_cred->gc_ctx->gc_expiry))
+		return 0;
+	if (!test_bit(RPCAUTH_CRED_UPTODATE, &rc->cr_flags))
 		return 0;
 out:
 	if (acred->machine_cred != gss_cred->gc_machine_cred)
@@ -933,16 +916,48 @@ out_put_ctx:
 	return NULL;
 }
 
+static int gss_renew_cred(struct rpc_task *task)
+{
+	struct rpc_cred *oldcred = task->tk_msg.rpc_cred;
+	struct gss_cred *gss_cred = container_of(oldcred,
+						 struct gss_cred,
+						 gc_base);
+	struct rpc_auth *auth = oldcred->cr_auth;
+	struct auth_cred acred = {
+		.uid = oldcred->cr_uid,
+		.machine_cred = gss_cred->gc_machine_cred,
+	};
+	struct rpc_cred *new;
+
+	new = gss_lookup_cred(auth, &acred, RPCAUTH_LOOKUP_NEW);
+	if (IS_ERR(new))
+		return PTR_ERR(new);
+	task->tk_msg.rpc_cred = new;
+	put_rpccred(oldcred);
+	return 0;
+}
+
 /*
 * Refresh credentials. XXX - finish
 */
 static int
 gss_refresh(struct rpc_task *task)
 {
+	struct rpc_cred *cred = task->tk_msg.rpc_cred;
+	int ret = 0;
+
+	if (!test_bit(RPCAUTH_CRED_NEW, &cred->cr_flags) &&
+			!test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags)) {
+		ret = gss_renew_cred(task);
+		if (ret < 0)
+			goto out;
+		cred = task->tk_msg.rpc_cred;
+	}
 
-	if (!gss_cred_is_uptodate_ctx(task->tk_msg.rpc_cred))
-		return gss_refresh_upcall(task);
-	return 0;
+	if (test_bit(RPCAUTH_CRED_NEW, &cred->cr_flags))
+		ret = gss_refresh_upcall(task);
+out:
+	return ret;
 }
 
 /* Dummy refresh routine: used only when destroying the context */

