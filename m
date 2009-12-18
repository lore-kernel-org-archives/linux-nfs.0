From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] sunrpc: on successful gss error pipe write, don't return error
Date: Fri, 18 Dec 2009 08:56:14 -0500
Message-ID: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121]:53246 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361AbZLRN4Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Dec 2009 08:56:16 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When handling the gssd downcall, the kernel should distinguish between a
successful downcall that contains an error code and a failed downcall
(i.e. where the parsing failed or some other sort of problem occurred).

In the former case, gss_pipe_downcall should be returning the number of
bytes written to the pipe instead of an error.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3c3c50f..03cc5a4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -184,7 +184,8 @@ gss_alloc_context(void)
 
 #define GSSD_MIN_TIMEOUT (60 * 60)
 static const void *
-gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct gss_api_mech *gm)
+gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx,
+		 struct gss_api_mech *gm, ssize_t *downcall_err)
 {
 	const void *q;
 	unsigned int seclen;
@@ -208,6 +209,7 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 	if (ctx->gc_win == 0) {
 		/* in which case, p points to  an error code which we ignore */
 		p = ERR_PTR(-EACCES);
+		*downcall_err = -EACCES;
 		goto err;
 	}
 	/* copy the opaque wire context */
@@ -641,10 +643,21 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	list_del_init(&gss_msg->list);
 	spin_unlock(&inode->i_lock);
 
-	p = gss_fill_context(p, end, ctx, gss_msg->auth->mech);
+	err = 0;
+	p = gss_fill_context(p, end, ctx, gss_msg->auth->mech, &err);
 	if (IS_ERR(p)) {
-		err = PTR_ERR(p);
-		gss_msg->msg.errno = (err == -EAGAIN) ? -EAGAIN : -EACCES;
+		/*
+		 * a non-zero downcall_err indicates that downcall write was
+		 * OK, but contained a zero gc_win (and hence an error code).
+		 */
+		if (err) {
+			gss_msg->msg.errno = err;
+			err = mlen;
+		} else {
+			err = PTR_ERR(p);
+			gss_msg->msg.errno = (err == -EAGAIN) ?
+							-EAGAIN : -EACCES;
+		}
 		goto err_release_msg;
 	}
 	gss_msg->ctx = gss_get_ctx(ctx);
-- 
1.6.5.2

