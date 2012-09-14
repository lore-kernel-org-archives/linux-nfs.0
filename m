Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:54524 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756132Ab2INVXp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Sep 2012 17:23:45 -0400
Received: by mail-gg0-f174.google.com with SMTP id k6so1097291ggd.19
        for <linux-nfs@vger.kernel.org>; Fri, 14 Sep 2012 14:23:45 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/10] SUNRPC: Use __func__ in dprintk() in auth_gss.c
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 14 Sep 2012 17:23:43 -0400
Message-ID: <20120914212343.1635.20806.stgit@degas.1015granger.net>
In-Reply-To: <20120914211053.1635.74063.stgit@degas.1015granger.net>
References: <20120914211053.1635.74063.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Some function names have changed, but debugging messages
were never updated.  Automate the construction of the function name
in debugging messages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   58 ++++++++++++++++++++--------------------
 1 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 34c5220..909dc0c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -239,7 +239,7 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 	}
 	return q;
 err:
-	dprintk("RPC:       gss_fill_context returning %ld\n", -PTR_ERR(p));
+	dprintk("RPC:       %s returning %ld\n", __func__, -PTR_ERR(p));
 	return p;
 }
 
@@ -301,10 +301,10 @@ __gss_find_upcall(struct rpc_pipe *pipe, uid_t uid)
 		if (pos->uid != uid)
 			continue;
 		atomic_inc(&pos->count);
-		dprintk("RPC:       gss_find_upcall found msg %p\n", pos);
+		dprintk("RPC:       %s found msg %p\n", __func__, pos);
 		return pos;
 	}
-	dprintk("RPC:       gss_find_upcall found nothing\n");
+	dprintk("RPC:       %s found nothing\n", __func__);
 	return NULL;
 }
 
@@ -507,8 +507,8 @@ gss_refresh_upcall(struct rpc_task *task)
 	struct rpc_pipe *pipe;
 	int err = 0;
 
-	dprintk("RPC: %5u gss_refresh_upcall for uid %u\n", task->tk_pid,
-								cred->cr_uid);
+	dprintk("RPC: %5u %s for uid %u\n",
+		task->tk_pid, __func__, cred->cr_uid);
 	gss_msg = gss_setup_upcall(task->tk_client, gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		/* XXX: warning on the first, under the assumption we
@@ -539,8 +539,8 @@ gss_refresh_upcall(struct rpc_task *task)
 	spin_unlock(&pipe->lock);
 	gss_release_msg(gss_msg);
 out:
-	dprintk("RPC: %5u gss_refresh_upcall for uid %u result %d\n",
-			task->tk_pid, cred->cr_uid, err);
+	dprintk("RPC: %5u %s for uid %u result %d\n",
+		task->tk_pid, __func__, cred->cr_uid, err);
 	return err;
 }
 
@@ -553,7 +553,7 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	DEFINE_WAIT(wait);
 	int err = 0;
 
-	dprintk("RPC:       gss_upcall for uid %u\n", cred->cr_uid);
+	dprintk("RPC:       %s for uid %u\n", __func__, cred->cr_uid);
 retry:
 	gss_msg = gss_setup_upcall(gss_auth->client, gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
@@ -594,8 +594,8 @@ out_intr:
 	finish_wait(&gss_msg->waitqueue, &wait);
 	gss_release_msg(gss_msg);
 out:
-	dprintk("RPC:       gss_create_upcall for uid %u result %d\n",
-			cred->cr_uid, err);
+	dprintk("RPC:       %s for uid %u result %d\n",
+		__func__, cred->cr_uid, err);
 	return err;
 }
 
@@ -681,7 +681,7 @@ err_put_ctx:
 err:
 	kfree(buf);
 out:
-	dprintk("RPC:       gss_pipe_downcall returning %Zd\n", err);
+	dprintk("RPC:       %s returning %Zd\n", __func__, err);
 	return err;
 }
 
@@ -747,8 +747,8 @@ gss_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 	struct gss_upcall_msg *gss_msg = container_of(msg, struct gss_upcall_msg, msg);
 
 	if (msg->errno < 0) {
-		dprintk("RPC:       gss_pipe_destroy_msg releasing msg %p\n",
-				gss_msg);
+		dprintk("RPC:       %s releasing msg %p\n",
+			__func__, gss_msg);
 		atomic_inc(&gss_msg->count);
 		gss_unhash_msg(gss_msg);
 		if (msg->errno == -ETIMEDOUT)
@@ -976,7 +976,7 @@ gss_destroying_context(struct rpc_cred *cred)
 static void
 gss_do_free_ctx(struct gss_cl_ctx *ctx)
 {
-	dprintk("RPC:       gss_free_ctx\n");
+	dprintk("RPC:       %s\n", __func__);
 
 	gss_delete_sec_context(&ctx->gc_gss_ctx);
 	kfree(ctx->gc_wire_ctx.data);
@@ -999,7 +999,7 @@ gss_free_ctx(struct gss_cl_ctx *ctx)
 static void
 gss_free_cred(struct gss_cred *gss_cred)
 {
-	dprintk("RPC:       gss_free_cred %p\n", gss_cred);
+	dprintk("RPC:       %s cred=%p\n", __func__, gss_cred);
 	kfree(gss_cred);
 }
 
@@ -1049,8 +1049,8 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	struct gss_cred	*cred = NULL;
 	int err = -ENOMEM;
 
-	dprintk("RPC:       gss_create_cred for uid %d, flavor %d\n",
-		acred->uid, auth->au_flavor);
+	dprintk("RPC:       %s for uid %d, flavor %d\n",
+		__func__, acred->uid, auth->au_flavor);
 
 	if (!(cred = kzalloc(sizeof(*cred), GFP_NOFS)))
 		goto out_err;
@@ -1069,7 +1069,7 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	return &cred->gc_base;
 
 out_err:
-	dprintk("RPC:       gss_create_cred failed with error %d\n", err);
+	dprintk("RPC:       %s failed with error %d\n", __func__, err);
 	return ERR_PTR(err);
 }
 
@@ -1127,7 +1127,7 @@ gss_marshal(struct rpc_task *task, __be32 *p)
 	struct kvec	iov;
 	struct xdr_buf	verf_buf;
 
-	dprintk("RPC: %5u gss_marshal\n", task->tk_pid);
+	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
 
 	*p++ = htonl(RPC_AUTH_GSS);
 	cred_len = p++;
@@ -1253,7 +1253,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	u32		flav,len;
 	u32		maj_stat;
 
-	dprintk("RPC: %5u gss_validate\n", task->tk_pid);
+	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
 
 	flav = ntohl(*p++);
 	if ((len = ntohl(*p++)) > RPC_MAX_AUTH_SIZE)
@@ -1271,20 +1271,20 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	if (maj_stat) {
-		dprintk("RPC: %5u gss_validate: gss_verify_mic returned "
-				"error 0x%08x\n", task->tk_pid, maj_stat);
+		dprintk("RPC: %5u %s: gss_verify_mic returned error 0x%08x\n",
+			task->tk_pid, __func__, maj_stat);
 		goto out_bad;
 	}
 	/* We leave it to unwrap to calculate au_rslack. For now we just
 	 * calculate the length of the verifier: */
 	cred->cr_auth->au_verfsize = XDR_QUADLEN(len) + 2;
 	gss_put_ctx(ctx);
-	dprintk("RPC: %5u gss_validate: gss_verify_mic succeeded.\n",
-			task->tk_pid);
+	dprintk("RPC: %5u %s: gss_verify_mic succeeded.\n",
+			task->tk_pid, __func__);
 	return p + XDR_QUADLEN(len);
 out_bad:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %5u gss_validate failed.\n", task->tk_pid);
+	dprintk("RPC: %5u %s failed.\n", task->tk_pid, __func__);
 	return NULL;
 }
 
@@ -1466,7 +1466,7 @@ gss_wrap_req(struct rpc_task *task,
 	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
 	int             status = -EIO;
 
-	dprintk("RPC: %5u gss_wrap_req\n", task->tk_pid);
+	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
 	if (ctx->gc_proc != RPC_GSS_PROC_DATA) {
 		/* The spec seems a little ambiguous here, but I think that not
 		 * wrapping context destruction requests makes the most sense.
@@ -1489,7 +1489,7 @@ gss_wrap_req(struct rpc_task *task,
 	}
 out:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %5u gss_wrap_req returning %d\n", task->tk_pid, status);
+	dprintk("RPC: %5u %s returning %d\n", task->tk_pid, __func__, status);
 	return status;
 }
 
@@ -1604,8 +1604,8 @@ out_decode:
 	status = gss_unwrap_req_decode(decode, rqstp, p, obj);
 out:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %5u gss_unwrap_resp returning %d\n", task->tk_pid,
-			status);
+	dprintk("RPC: %5u %s returning %d\n",
+		task->tk_pid, __func__, status);
 	return status;
 }
 

