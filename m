Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:60652 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752173AbdGDM5a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:57:30 -0400
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
Subject: [PATCH 24/36] net, x25: convert x25_route.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:19 +0300
Message-Id: <1499172811-16271-25-git-send-email-elena.reshetova@intel.com>
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
 include/net/x25.h   | 7 ++++---
 net/x25/x25_route.c | 2 +-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/x25.h b/include/net/x25.h
index 6d30a01..1ac1400 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -11,6 +11,7 @@
 #define _X25_H 
 #include <linux/x25.h>
 #include <linux/slab.h>
+#include <linux/refcount.h>
 #include <net/sock.h>
 
 #define	X25_ADDR_LEN			16
@@ -129,7 +130,7 @@ struct x25_route {
 	struct x25_address	address;
 	unsigned int		sigdigits;
 	struct net_device	*dev;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 };
 
 struct x25_neigh {
@@ -265,12 +266,12 @@ void x25_route_free(void);
 
 static __inline__ void x25_route_hold(struct x25_route *rt)
 {
-	atomic_inc(&rt->refcnt);
+	refcount_inc(&rt->refcnt);
 }
 
 static __inline__ void x25_route_put(struct x25_route *rt)
 {
-	if (atomic_dec_and_test(&rt->refcnt))
+	if (refcount_dec_and_test(&rt->refcnt))
 		kfree(rt);
 }
 
diff --git a/net/x25/x25_route.c b/net/x25/x25_route.c
index 277c8d2..b85b889 100644
--- a/net/x25/x25_route.c
+++ b/net/x25/x25_route.c
@@ -55,7 +55,7 @@ static int x25_add_route(struct x25_address *address, unsigned int sigdigits,
 
 	rt->sigdigits = sigdigits;
 	rt->dev       = dev;
-	atomic_set(&rt->refcnt, 1);
+	refcount_set(&rt->refcnt, 1);
 
 	list_add(&rt->node, &x25_route_list);
 	rc = 0;
-- 
2.7.4

