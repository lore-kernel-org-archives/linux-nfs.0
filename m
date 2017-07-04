Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54356 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752226AbdGDMzM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:55:12 -0400
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
Subject: [PATCH 10/36] net, bridge: convert net_bridge_vlan.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:05 +0300
Message-Id: <1499172811-16271-11-git-send-email-elena.reshetova@intel.com>
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
 net/bridge/br_private.h | 3 ++-
 net/bridge/br_vlan.c    | 8 ++++----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c18682f..fd9ee73 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -21,6 +21,7 @@
 #include <net/ip6_fib.h>
 #include <linux/if_vlan.h>
 #include <linux/rhashtable.h>
+#include <linux/refcount.h>
 
 #define BR_HASH_BITS 8
 #define BR_HASH_SIZE (1 << BR_HASH_BITS)
@@ -127,7 +128,7 @@ struct net_bridge_vlan {
 		struct net_bridge_port	*port;
 	};
 	union {
-		atomic_t		refcnt;
+		refcount_t		refcnt;
 		struct net_bridge_vlan	*brvlan;
 	};
 
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 26a1a56..233a300 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -158,7 +158,7 @@ static struct net_bridge_vlan *br_vlan_get_master(struct net_bridge *br, u16 vid
 		if (WARN_ON(!masterv))
 			return NULL;
 	}
-	atomic_inc(&masterv->refcnt);
+	refcount_inc(&masterv->refcnt);
 
 	return masterv;
 }
@@ -182,7 +182,7 @@ static void br_vlan_put_master(struct net_bridge_vlan *masterv)
 		return;
 
 	vg = br_vlan_group(masterv->br);
-	if (atomic_dec_and_test(&masterv->refcnt)) {
+	if (refcount_dec_and_test(&masterv->refcnt)) {
 		rhashtable_remove_fast(&vg->vlan_hash,
 				       &masterv->vnode, br_vlan_rht_params);
 		__vlan_del_list(masterv);
@@ -573,7 +573,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 				br_err(br, "failed insert local address into bridge forwarding table\n");
 				return ret;
 			}
-			atomic_inc(&vlan->refcnt);
+			refcount_inc(&vlan->refcnt);
 			vlan->flags |= BRIDGE_VLAN_INFO_BRENTRY;
 			vg->num_vlans++;
 		}
@@ -595,7 +595,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 	vlan->flags &= ~BRIDGE_VLAN_INFO_PVID;
 	vlan->br = br;
 	if (flags & BRIDGE_VLAN_INFO_BRENTRY)
-		atomic_set(&vlan->refcnt, 1);
+		refcount_set(&vlan->refcnt, 1);
 	ret = __vlan_add(vlan, flags);
 	if (ret) {
 		free_percpu(vlan->stats);
-- 
2.7.4

