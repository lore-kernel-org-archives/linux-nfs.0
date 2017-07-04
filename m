Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:60885 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752051AbdGDM5l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:57:41 -0400
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
Subject: [PATCH 27/36] net, xfrm: convert xfrm_policy.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:22 +0300
Message-Id: <1499172811-16271-28-git-send-email-elena.reshetova@intel.com>
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
 include/net/xfrm.h     | 6 +++---
 net/key/af_key.c       | 2 +-
 net/xfrm/xfrm_policy.c | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f5272a2..e1bd1de 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -560,7 +560,7 @@ struct xfrm_policy {
 
 	/* This lock only affects elements except for entry. */
 	rwlock_t		lock;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	struct timer_list	timer;
 
 	struct flow_cache_object flo;
@@ -816,14 +816,14 @@ static inline void xfrm_audit_state_icvfail(struct xfrm_state *x,
 static inline void xfrm_pol_hold(struct xfrm_policy *policy)
 {
 	if (likely(policy != NULL))
-		atomic_inc(&policy->refcnt);
+		refcount_inc(&policy->refcnt);
 }
 
 void xfrm_policy_destroy(struct xfrm_policy *policy);
 
 static inline void xfrm_pol_put(struct xfrm_policy *policy)
 {
-	if (atomic_dec_and_test(&policy->refcnt))
+	if (refcount_dec_and_test(&policy->refcnt))
 		xfrm_policy_destroy(policy);
 }
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index edcf1d0..ca9d3ae 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2177,7 +2177,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	}
 
 	hdr->sadb_msg_len = size / sizeof(uint64_t);
-	hdr->sadb_msg_reserved = atomic_read(&xp->refcnt);
+	hdr->sadb_msg_reserved = refcount_read(&xp->refcnt);
 
 	return 0;
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4706df6..ff61d85 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -62,7 +62,7 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 
 static inline bool xfrm_pol_hold_rcu(struct xfrm_policy *policy)
 {
-	return atomic_inc_not_zero(&policy->refcnt);
+	return refcount_inc_not_zero(&policy->refcnt);
 }
 
 static inline bool
@@ -292,7 +292,7 @@ struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp)
 		INIT_HLIST_NODE(&policy->bydst);
 		INIT_HLIST_NODE(&policy->byidx);
 		rwlock_init(&policy->lock);
-		atomic_set(&policy->refcnt, 1);
+		refcount_set(&policy->refcnt, 1);
 		skb_queue_head_init(&policy->polq.hold_queue);
 		setup_timer(&policy->timer, xfrm_policy_timer,
 				(unsigned long)policy);
-- 
2.7.4

