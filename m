Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:48365 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751272AbdCQMQ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 08:16:58 -0400
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
Subject: [PATCH 22/23] net, ax25: convert ax25_route.refcount from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:10:45 +0200
Message-Id: <1489752646-8749-23-git-send-email-elena.reshetova@intel.com>
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
 include/net/ax25.h    | 6 +++---
 net/ax25/ax25_route.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index edd82f0..e3467ba 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -185,7 +185,7 @@ typedef struct {
 
 typedef struct ax25_route {
 	struct ax25_route	*next;
-	atomic_t		refcount;
+	refcount_t		refcount;
 	ax25_address		callsign;
 	struct net_device	*dev;
 	ax25_digi		*digipeat;
@@ -194,14 +194,14 @@ typedef struct ax25_route {
 
 static inline void ax25_hold_route(ax25_route *ax25_rt)
 {
-	atomic_inc(&ax25_rt->refcount);
+	refcount_inc(&ax25_rt->refcount);
 }
 
 void __ax25_put_route(ax25_route *ax25_rt);
 
 static inline void ax25_put_route(ax25_route *ax25_rt)
 {
-	if (atomic_dec_and_test(&ax25_rt->refcount))
+	if (refcount_dec_and_test(&ax25_rt->refcount))
 		__ax25_put_route(ax25_rt);
 }
 
diff --git a/net/ax25/ax25_route.c b/net/ax25/ax25_route.c
index e1fda27..0446b89 100644
--- a/net/ax25/ax25_route.c
+++ b/net/ax25/ax25_route.c
@@ -114,7 +114,7 @@ static int __must_check ax25_rt_add(struct ax25_routes_struct *route)
 		return -ENOMEM;
 	}
 
-	atomic_set(&ax25_rt->refcount, 1);
+	refcount_set(&ax25_rt->refcount, 1);
 	ax25_rt->callsign     = route->dest_addr;
 	ax25_rt->dev          = ax25_dev->dev;
 	ax25_rt->digipeat     = NULL;
-- 
2.7.4

