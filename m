From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 29/33] SUNRPC: Fix a race in gss_refresh_upcall()
Date: Sat, 19 Apr 2008 16:40:54 -0400
Message-ID: <20080419204054.14124.69744.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756257AbYDSUua (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:30 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoTbc026078
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:29 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the downcall completes before we get the spin_lock then we currently
fail to refresh the credential.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 46f7ec8..6f1b4e2 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -117,6 +117,7 @@ gss_cred_set_ctx(struct rpc_cred *cred, struct gss_cl_ctx *ctx)
 	struct gss_cl_ctx *old;
 
 	old = gss_cred->gc_ctx;
+	gss_get_ctx(ctx);
 	rcu_assign_pointer(gss_cred->gc_ctx, ctx);
 	set_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	clear_bit(RPCAUTH_CRED_NEW, &cred->cr_flags);
@@ -340,7 +341,7 @@ gss_upcall_callback(struct rpc_task *task)
 
 	spin_lock(&inode->i_lock);
 	if (gss_msg->ctx)
-		gss_cred_set_ctx(task->tk_msg.rpc_cred, gss_get_ctx(gss_msg->ctx));
+		gss_cred_set_ctx(task->tk_msg.rpc_cred, gss_msg->ctx);
 	else
 		task->tk_status = gss_msg->msg.errno;
 	gss_cred->gc_upcall = NULL;
@@ -417,7 +418,11 @@ gss_refresh_upcall(struct rpc_task *task)
 	spin_lock(&inode->i_lock);
 	if (gss_cred->gc_upcall != NULL)
 		rpc_sleep_on(&gss_cred->gc_upcall->rpc_waitqueue, task, NULL);
-	else if (gss_msg->ctx == NULL && gss_msg->msg.errno >= 0) {
+	else if (gss_msg->ctx != NULL) {
+		gss_cred_set_ctx(task->tk_msg.rpc_cred, gss_msg->ctx);
+		gss_cred->gc_upcall = NULL;
+		rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
+	} else if (gss_msg->msg.errno >= 0) {
 		task->tk_timeout = 0;
 		gss_cred->gc_upcall = gss_msg;
 		/* gss_upcall_callback will release the reference to gss_upcall_msg */
@@ -462,7 +467,7 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 		schedule();
 	}
 	if (gss_msg->ctx)
-		gss_cred_set_ctx(cred, gss_get_ctx(gss_msg->ctx));
+		gss_cred_set_ctx(cred, gss_msg->ctx);
 	else
 		err = gss_msg->msg.errno;
 	spin_unlock(&inode->i_lock);

