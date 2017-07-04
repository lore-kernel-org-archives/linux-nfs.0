Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54915 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751648AbdGDM4C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:56:02 -0400
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
Subject: [PATCH 15/36] net, ipx: convert ipx_route.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:10 +0300
Message-Id: <1499172811-16271-16-git-send-email-elena.reshetova@intel.com>
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
 include/net/ipx.h   | 6 +++---
 net/ipx/ipx_route.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ipx.h b/include/net/ipx.h
index 2de1281..af32b97 100644
--- a/include/net/ipx.h
+++ b/include/net/ipx.h
@@ -81,7 +81,7 @@ struct ipx_route {
 	unsigned char		ir_routed;
 	unsigned char		ir_router_node[IPX_NODE_LEN];
 	struct list_head	node; /* node in ipx_routes list */
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 };
 
 struct ipx_cb {
@@ -164,12 +164,12 @@ static __inline__ void ipxitf_put(struct ipx_interface *intrfc)
 
 static __inline__ void ipxrtr_hold(struct ipx_route *rt)
 {
-	        atomic_inc(&rt->refcnt);
+	        refcount_inc(&rt->refcnt);
 }
 
 static __inline__ void ipxrtr_put(struct ipx_route *rt)
 {
-	        if (atomic_dec_and_test(&rt->refcnt))
+	        if (refcount_dec_and_test(&rt->refcnt))
 			                kfree(rt);
 }
 #endif /* _NET_INET_IPX_H_ */
diff --git a/net/ipx/ipx_route.c b/net/ipx/ipx_route.c
index 3e2a32a..b5d9144 100644
--- a/net/ipx/ipx_route.c
+++ b/net/ipx/ipx_route.c
@@ -59,7 +59,7 @@ int ipxrtr_add_route(__be32 network, struct ipx_interface *intrfc,
 		if (!rt)
 			goto out;
 
-		atomic_set(&rt->refcnt, 1);
+		refcount_set(&rt->refcnt, 1);
 		ipxrtr_hold(rt);
 		write_lock_bh(&ipx_routes_lock);
 		list_add(&rt->node, &ipx_routes);
-- 
2.7.4

