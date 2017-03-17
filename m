Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:18856 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751087AbdCQMQv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 08:16:51 -0400
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
Subject: [PATCH 13/23] net, xfrm: convert xfrm_state.refcnt from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:10:36 +0200
Message-Id: <1489752646-8749-14-git-send-email-elena.reshetova@intel.com>
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
 include/net/xfrm.h    | 9 +++++----
 net/xfrm/xfrm_state.c | 4 ++--
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 14d82bf..163cda5 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -13,6 +13,7 @@
 #include <linux/mutex.h>
 #include <linux/audit.h>
 #include <linux/slab.h>
+#include <linux/refcount.h>
 
 #include <net/sock.h>
 #include <net/dst.h>
@@ -130,7 +131,7 @@ struct xfrm_state {
 	struct hlist_node	bysrc;
 	struct hlist_node	byspi;
 
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	spinlock_t		lock;
 
 	struct xfrm_id		id;
@@ -802,18 +803,18 @@ void __xfrm_state_destroy(struct xfrm_state *);
 
 static inline void __xfrm_state_put(struct xfrm_state *x)
 {
-	atomic_dec(&x->refcnt);
+	refcount_dec(&x->refcnt);
 }
 
 static inline void xfrm_state_put(struct xfrm_state *x)
 {
-	if (atomic_dec_and_test(&x->refcnt))
+	if (refcount_dec_and_test(&x->refcnt))
 		__xfrm_state_destroy(x);
 }
 
 static inline void xfrm_state_hold(struct xfrm_state *x)
 {
-	atomic_inc(&x->refcnt);
+	refcount_inc(&x->refcnt);
 }
 
 static inline bool addr_match(const void *token1, const void *token2,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5a597db..a91109f 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -48,7 +48,7 @@ static HLIST_HEAD(xfrm_state_gc_list);
 
 static inline bool xfrm_state_hold_rcu(struct xfrm_state __rcu *x)
 {
-	return atomic_inc_not_zero(&x->refcnt);
+	return refcount_inc_not_zero(&x->refcnt);
 }
 
 static inline unsigned int xfrm_dst_hash(struct net *net,
@@ -486,7 +486,7 @@ struct xfrm_state *xfrm_state_alloc(struct net *net)
 
 	if (x) {
 		write_pnet(&x->xs_net, net);
-		atomic_set(&x->refcnt, 1);
+		refcount_set(&x->refcnt, 1);
 		atomic_set(&x->tunnel_users, 0);
 		INIT_LIST_HEAD(&x->km.all);
 		INIT_HLIST_NODE(&x->bydst);
-- 
2.7.4

