Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:1295 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752051AbdGDM5y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:57:54 -0400
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
Subject: [PATCH 28/36] net, xfrm: convert sec_path.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:23 +0300
Message-Id: <1499172811-16271-29-git-send-email-elena.reshetova@intel.com>
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
 include/net/xfrm.h    | 6 +++---
 net/xfrm/xfrm_input.c | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e1bd1de..c0916ab 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1030,7 +1030,7 @@ struct xfrm_offload {
 };
 
 struct sec_path {
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	int			len;
 	int			olen;
 
@@ -1051,7 +1051,7 @@ static inline struct sec_path *
 secpath_get(struct sec_path *sp)
 {
 	if (sp)
-		atomic_inc(&sp->refcnt);
+		refcount_inc(&sp->refcnt);
 	return sp;
 }
 
@@ -1060,7 +1060,7 @@ void __secpath_destroy(struct sec_path *sp);
 static inline void
 secpath_put(struct sec_path *sp)
 {
-	if (sp && atomic_dec_and_test(&sp->refcnt))
+	if (sp && refcount_dec_and_test(&sp->refcnt))
 		__secpath_destroy(sp);
 }
 
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 9de4b1d..923205e 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -116,7 +116,7 @@ struct sec_path *secpath_dup(struct sec_path *src)
 		for (i = 0; i < sp->len; i++)
 			xfrm_state_hold(sp->xvec[i]);
 	}
-	atomic_set(&sp->refcnt, 1);
+	refcount_set(&sp->refcnt, 1);
 	return sp;
 }
 EXPORT_SYMBOL(secpath_dup);
@@ -126,7 +126,7 @@ int secpath_set(struct sk_buff *skb)
 	struct sec_path *sp;
 
 	/* Allocate new secpath or COW existing one. */
-	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
+	if (!skb->sp || refcount_read(&skb->sp->refcnt) != 1) {
 		sp = secpath_dup(skb->sp);
 		if (!sp)
 			return -ENOMEM;
-- 
2.7.4

