Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:62452 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751035AbdCQMLL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 08:11:11 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
        davem@davemloft.net, linux-x25@vger.kernel.org,
        linux-sctp@vger.kernel.org, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-hams@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        zyan@redhat.com, sage@redhat.com, bfields@fieldses.org,
        jlayton@poochiereds.net, steffen.klassert@secunet.com,
        herbert@gondor.apana.org.au, santosh.shilimkar@oracle.com,
        jreuter@yaina.de, ralf@linux-mips.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 02/23] net, sunrpc: convert gss_cl_ctx.count from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:10:25 +0200
Message-Id: <1489752646-8749-3-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com>
References: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com>
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
 include/linux/sunrpc/auth_gss.h | 3 ++-
 net/sunrpc/auth_gss/auth_gss.c  | 6 +++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 36eebc4..cebdf87 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -13,6 +13,7 @@
 #define _LINUX_SUNRPC_AUTH_GSS_H
 
 #ifdef __KERNEL__
+#include <linux/refcount.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/gss_api.h>
@@ -65,7 +66,7 @@ struct rpc_gss_init_res {
  * the wire when communicating with a server. */
 
 struct gss_cl_ctx {
-	atomic_t		count;
+	refcount_t		count;
 	enum rpc_gss_proc	gc_proc;
 	u32			gc_seq;
 	spinlock_t		gc_seq_lock;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 4f16953..72f129c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -117,14 +117,14 @@ static const struct rpc_pipe_ops gss_upcall_ops_v1;
 static inline struct gss_cl_ctx *
 gss_get_ctx(struct gss_cl_ctx *ctx)
 {
-	atomic_inc(&ctx->count);
+	refcount_inc(&ctx->count);
 	return ctx;
 }
 
 static inline void
 gss_put_ctx(struct gss_cl_ctx *ctx)
 {
-	if (atomic_dec_and_test(&ctx->count))
+	if (refcount_dec_and_test(&ctx->count))
 		gss_free_ctx(ctx);
 }
 
@@ -200,7 +200,7 @@ gss_alloc_context(void)
 		ctx->gc_proc = RPC_GSS_PROC_DATA;
 		ctx->gc_seq = 1;	/* NetApp 6.4R1 doesn't accept seq. no. 0 */
 		spin_lock_init(&ctx->gc_seq_lock);
-		atomic_set(&ctx->count,1);
+		refcount_set(&ctx->count,1);
 	}
 	return ctx;
 }
-- 
2.7.4

