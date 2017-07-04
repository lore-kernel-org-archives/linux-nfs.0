Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:45549 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752052AbdGDMyi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:54:38 -0400
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
Subject: [PATCH 05/36] net, decnet: convert dn_fib_info.fib_clntref from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:00 +0300
Message-Id: <1499172811-16271-6-git-send-email-elena.reshetova@intel.com>
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
 include/net/dn_fib.h | 5 +++--
 net/decnet/dn_fib.c  | 6 +++---
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
index f2ca135..81210a8 100644
--- a/include/net/dn_fib.h
+++ b/include/net/dn_fib.h
@@ -2,6 +2,7 @@
 #define _NET_DN_FIB_H
 
 #include <linux/netlink.h>
+#include <linux/refcount.h>
 
 extern const struct nla_policy rtm_dn_policy[];
 
@@ -28,7 +29,7 @@ struct dn_fib_info {
 	struct dn_fib_info	*fib_next;
 	struct dn_fib_info	*fib_prev;
 	int 			fib_treeref;
-	atomic_t		fib_clntref;
+	refcount_t		fib_clntref;
 	int			fib_dead;
 	unsigned int		fib_flags;
 	int			fib_protocol;
@@ -130,7 +131,7 @@ void dn_fib_free_info(struct dn_fib_info *fi);
 
 static inline void dn_fib_info_put(struct dn_fib_info *fi)
 {
-	if (atomic_dec_and_test(&fi->fib_clntref))
+	if (refcount_dec_and_test(&fi->fib_clntref))
 		dn_fib_free_info(fi);
 }
 
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index f9058eb..f9f6fb3 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -389,7 +389,7 @@ struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r, struct nlattr *att
 	}
 
 	fi->fib_treeref++;
-	atomic_inc(&fi->fib_clntref);
+	refcount_set(&fi->fib_clntref, 1);
 	spin_lock(&dn_fib_info_lock);
 	fi->fib_next = dn_fib_info_list;
 	fi->fib_prev = NULL;
@@ -425,7 +425,7 @@ int dn_fib_semantic_match(int type, struct dn_fib_info *fi, const struct flowidn
 		switch (type) {
 		case RTN_NAT:
 			DN_FIB_RES_RESET(*res);
-			atomic_inc(&fi->fib_clntref);
+			refcount_inc(&fi->fib_clntref);
 			return 0;
 		case RTN_UNICAST:
 		case RTN_LOCAL:
@@ -438,7 +438,7 @@ int dn_fib_semantic_match(int type, struct dn_fib_info *fi, const struct flowidn
 			}
 			if (nhsel < fi->fib_nhs) {
 				res->nh_sel = nhsel;
-				atomic_inc(&fi->fib_clntref);
+				refcount_inc(&fi->fib_clntref);
 				return 0;
 			}
 			endfor_nexthops(fi);
-- 
2.7.4

