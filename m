Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10384 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752173AbdGDM5X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:57:23 -0400
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
Subject: [PATCH 25/36] net, x25: convert x25_neigh.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:20 +0300
Message-Id: <1499172811-16271-26-git-send-email-elena.reshetova@intel.com>
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
 include/net/x25.h  | 6 +++---
 net/x25/x25_link.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/x25.h b/include/net/x25.h
index 1ac1400..2609b57 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -142,7 +142,7 @@ struct x25_neigh {
 	unsigned long		t20;
 	struct timer_list	t20timer;
 	unsigned long		global_facil_mask;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 };
 
 struct x25_sock {
@@ -243,12 +243,12 @@ void x25_link_free(void);
 /* x25_neigh.c */
 static __inline__ void x25_neigh_hold(struct x25_neigh *nb)
 {
-	atomic_inc(&nb->refcnt);
+	refcount_inc(&nb->refcnt);
 }
 
 static __inline__ void x25_neigh_put(struct x25_neigh *nb)
 {
-	if (atomic_dec_and_test(&nb->refcnt))
+	if (refcount_dec_and_test(&nb->refcnt))
 		kfree(nb);
 }
 
diff --git a/net/x25/x25_link.c b/net/x25/x25_link.c
index bcaa180..e0cd04d 100644
--- a/net/x25/x25_link.c
+++ b/net/x25/x25_link.c
@@ -266,7 +266,7 @@ void x25_link_device_up(struct net_device *dev)
 				       X25_MASK_PACKET_SIZE |
 				       X25_MASK_WINDOW_SIZE;
 	nb->t20      = sysctl_x25_restart_request_timeout;
-	atomic_set(&nb->refcnt, 1);
+	refcount_set(&nb->refcnt, 1);
 
 	write_lock_bh(&x25_neigh_list_lock);
 	list_add(&nb->node, &x25_neigh_list);
-- 
2.7.4

