Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55385 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753009AbdGDM4f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:56:35 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, 3chas3@gmail.com, ralf@linux-mips.org,
        stephen@networkplumber.org, jchapman@katalix.com, jhs@mojatatu.com,
        bridge@lists.linux-foundation.org, linux-hams@vger.kernel.org,
        linux-x25@vger.kernel.org, peterz@infradead.org,
        keescook@chromium.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-nfs@vger.kernel.org, zyan@redhat.com,
        sage@redhat.com, bfields@fieldses.org, jlayton@poochiereds.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        santosh.shilimkar@oracle.com, jreuter@yaina.de,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 19/36] net, sunrpc: convert gss_upcall_msg.count from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:14 +0300
Message-Id: <1499172811-16271-20-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
References: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 72f129c..9463af4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -287,7 +287,7 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 #define UPCALL_BUF_LEN 128
 
 struct gss_upcall_msg {
-	atomic_t count;
+	refcount_t count;
 	kuid_t	uid;
 	struct rpc_pipe_msg msg;
 	struct list_head list;
@@ -328,7 +328,7 @@ static void
 gss_release_msg(struct gss_upcall_msg *gss_msg)
 {
 	struct net *net = gss_msg->auth->net;
-	if (!atomic_dec_and_test(&gss_msg->count))
+	if (!refcount_dec_and_test(&gss_msg->count))
 		return;
 	put_pipe_version(net);
 	BUG_ON(!list_empty(&gss_msg->list));
@@ -348,7 +348,7 @@ __gss_find_upcall(struct rpc_pipe *pipe, kuid_t uid, const struct gss_auth *auth
 			continue;
 		if (auth && pos->auth->service != auth->service)
 			continue;
-		atomic_inc(&pos->count);
+		refcount_inc(&pos->count);
 		dprintk("RPC:       %s found msg %p\n", __func__, pos);
 		return pos;
 	}
@@ -369,7 +369,7 @@ gss_add_msg(struct gss_upcall_msg *gss_msg)
 	spin_lock(&pipe->lock);
 	old = __gss_find_upcall(pipe, gss_msg->uid, gss_msg->auth);
 	if (old == NULL) {
-		atomic_inc(&gss_msg->count);
+		refcount_inc(&gss_msg->count);
 		list_add(&gss_msg->list, &pipe->in_downcall);
 	} else
 		gss_msg = old;
@@ -383,7 +383,7 @@ __gss_unhash_msg(struct gss_upcall_msg *gss_msg)
 	list_del_init(&gss_msg->list);
 	rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
 	wake_up_all(&gss_msg->waitqueue);
-	atomic_dec(&gss_msg->count);
+	refcount_dec(&gss_msg->count);
 }
 
 static void
@@ -506,7 +506,7 @@ gss_alloc_msg(struct gss_auth *gss_auth,
 	INIT_LIST_HEAD(&gss_msg->list);
 	rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
 	init_waitqueue_head(&gss_msg->waitqueue);
-	atomic_set(&gss_msg->count, 1);
+	refcount_set(&gss_msg->count, 1);
 	gss_msg->uid = uid;
 	gss_msg->auth = gss_auth;
 	switch (vers) {
@@ -542,11 +542,11 @@ gss_setup_upcall(struct gss_auth *gss_auth, struct rpc_cred *cred)
 	gss_msg = gss_add_msg(gss_new);
 	if (gss_msg == gss_new) {
 		int res;
-		atomic_inc(&gss_msg->count);
+		refcount_inc(&gss_msg->count);
 		res = rpc_queue_upcall(gss_new->pipe, &gss_new->msg);
 		if (res) {
 			gss_unhash_msg(gss_new);
-			atomic_dec(&gss_msg->count);
+			refcount_dec(&gss_msg->count);
 			gss_release_msg(gss_new);
 			gss_msg = ERR_PTR(res);
 		}
@@ -595,7 +595,7 @@ gss_refresh_upcall(struct rpc_task *task)
 		task->tk_timeout = 0;
 		gss_cred->gc_upcall = gss_msg;
 		/* gss_upcall_callback will release the reference to gss_upcall_msg */
-		atomic_inc(&gss_msg->count);
+		refcount_inc(&gss_msg->count);
 		rpc_sleep_on(&gss_msg->rpc_waitqueue, task, gss_upcall_callback);
 	} else {
 		gss_handle_downcall_result(gss_cred, gss_msg);
@@ -815,7 +815,7 @@ gss_pipe_release(struct inode *inode)
 		if (!list_empty(&gss_msg->msg.list))
 			continue;
 		gss_msg->msg.errno = -EPIPE;
-		atomic_inc(&gss_msg->count);
+		refcount_inc(&gss_msg->count);
 		__gss_unhash_msg(gss_msg);
 		spin_unlock(&pipe->lock);
 		gss_release_msg(gss_msg);
@@ -834,7 +834,7 @@ gss_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 	if (msg->errno < 0) {
 		dprintk("RPC:       %s releasing msg %p\n",
 			__func__, gss_msg);
-		atomic_inc(&gss_msg->count);
+		refcount_inc(&gss_msg->count);
 		gss_unhash_msg(gss_msg);
 		if (msg->errno == -ETIMEDOUT)
 			warn_gssd();
-- 
2.7.4

