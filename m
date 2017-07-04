Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:24205 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752447AbdGDMx7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:53:59 -0400
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
Subject: [PATCH 01/36] net, llc: convert llc_sap.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:52:56 +0300
Message-Id: <1499172811-16271-2-git-send-email-elena.reshetova@intel.com>
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
 include/net/llc.h  | 6 +++---
 net/llc/llc_core.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/llc.h b/include/net/llc.h
index e8e61d4..dc35f25 100644
--- a/include/net/llc.h
+++ b/include/net/llc.h
@@ -55,7 +55,7 @@ struct llc_sap {
 	unsigned char	 state;
 	unsigned char	 p_bit;
 	unsigned char	 f_bit;
-	atomic_t         refcnt;
+	refcount_t		 refcnt;
 	int		 (*rcv_func)(struct sk_buff *skb,
 				     struct net_device *dev,
 				     struct packet_type *pt,
@@ -113,14 +113,14 @@ struct llc_sap *llc_sap_open(unsigned char lsap,
 					struct net_device *orig_dev));
 static inline void llc_sap_hold(struct llc_sap *sap)
 {
-	atomic_inc(&sap->refcnt);
+	refcount_inc(&sap->refcnt);
 }
 
 void llc_sap_close(struct llc_sap *sap);
 
 static inline void llc_sap_put(struct llc_sap *sap)
 {
-	if (atomic_dec_and_test(&sap->refcnt))
+	if (refcount_dec_and_test(&sap->refcnt))
 		llc_sap_close(sap);
 }
 
diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index 842851c..8904126 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -41,7 +41,7 @@ static struct llc_sap *llc_sap_alloc(void)
 		spin_lock_init(&sap->sk_lock);
 		for (i = 0; i < LLC_SK_LADDR_HASH_ENTRIES; i++)
 			INIT_HLIST_NULLS_HEAD(&sap->sk_laddr_hash[i], i);
-		atomic_set(&sap->refcnt, 1);
+		refcount_set(&sap->refcnt, 1);
 	}
 	return sap;
 }
-- 
2.7.4

