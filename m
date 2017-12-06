Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33864 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752111AbdLFTBL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Dec 2017 14:01:11 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] auth_rpcgss: Add a timer to the gss upcall.
Date: Wed,  6 Dec 2017 14:01:08 -0500
Message-Id: <20171206190108.11678-2-steved@redhat.com>
In-Reply-To: <20171206190108.11678-1-steved@redhat.com>
References: <20171206190108.11678-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So mounts will not hang forever, waiting for a user land
daemon that never come back, set a 10 sec timer
before the upcall is made. If the timer pops,
error out the mount with a timeout error.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 43 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 9463af4b32e8..9c866812bc2d 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -66,6 +66,9 @@ static unsigned int gss_expired_cred_retry_delay = GSS_RETRY_EXPIRED;
 #define GSS_KEY_EXPIRE_TIMEO 240
 static unsigned int gss_key_expire_timeo = GSS_KEY_EXPIRE_TIMEO;
 
+#define GSS_MSG_TIMEO 10 /* seconds */
+static unsigned int gss_msg_timeo = GSS_MSG_TIMEO;
+
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
@@ -295,6 +298,7 @@ struct gss_upcall_msg {
 	struct rpc_pipe *pipe;
 	struct rpc_wait_queue rpc_waitqueue;
 	wait_queue_head_t waitqueue;
+	struct timer_list timeout;
 	struct gss_cl_ctx *ctx;
 	char databuf[UPCALL_BUF_LEN];
 };
@@ -399,6 +403,36 @@ gss_unhash_msg(struct gss_upcall_msg *gss_msg)
 	spin_unlock(&pipe->lock);
 }
 
+static void
+gss_msg_timeout(struct timer_list *t)
+{
+	struct gss_upcall_msg *gss_msg = from_timer(gss_msg, t, timeout);
+	struct rpc_pipe *pipe = gss_msg->pipe;
+
+	dprintk("RPC:       %s gss_msg 0x%p\n", __func__, gss_msg);
+	spin_lock(&pipe->lock);
+	gss_msg->msg.errno = -ETIMEDOUT;
+	__gss_unhash_msg(gss_msg);
+	spin_unlock(&pipe->lock);
+}
+
+static inline void
+gss_msg_timer(struct gss_upcall_msg *gss_msg)
+{
+	if (!timer_pending(&gss_msg->timeout)) {
+		timer_setup(&gss_msg->timeout, gss_msg_timeout, 0);
+		mod_timer(&gss_msg->timeout, (jiffies + (gss_msg_timeo * HZ)));
+	}
+}
+
+static inline void
+gss_msg_del_timer(struct gss_upcall_msg *gss_msg)
+{
+	if (timer_pending(&gss_msg->timeout))
+		del_timer(&gss_msg->timeout);
+}
+
 static void
 gss_handle_downcall_result(struct gss_cred *gss_cred, struct gss_upcall_msg *gss_msg)
 {
@@ -587,6 +621,10 @@ gss_refresh_upcall(struct rpc_task *task)
 		err = PTR_ERR(gss_msg);
 		goto out;
 	}
+
+	/* Set a timer so this upcall does not get stuck in userland */
+	gss_msg_timer(gss_msg);
+
 	pipe = gss_msg->pipe;
 	spin_lock(&pipe->lock);
 	if (gss_cred->gc_upcall != NULL)
@@ -646,6 +684,9 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 		err = PTR_ERR(gss_msg);
 		goto out;
 	}
+	/* Set a timer so this upcall does not get stuck in userland */
+	gss_msg_timer(gss_msg);
+
 	pipe = gss_msg->pipe;
 	for (;;) {
 		prepare_to_wait(&gss_msg->waitqueue, &wait, TASK_KILLABLE);
@@ -726,6 +767,8 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 		goto err_put_ctx;
 	}
 	list_del_init(&gss_msg->list);
+	/* Cancel the timer */
+	gss_msg_del_timer(gss_msg);
 	spin_unlock(&pipe->lock);
 
 	p = gss_fill_context(p, end, ctx, gss_msg->auth->mech);
-- 
2.14.3

