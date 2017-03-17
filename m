Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:61611 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751035AbdCQMLF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 08:11:05 -0400
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
Subject: [PATCH 01/23] net, sunrpc: convert rpc_cred.cr_count from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:10:24 +0200
Message-Id: <1489752646-8749-2-git-send-email-elena.reshetova@intel.com>
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
 include/linux/sunrpc/auth.h |  8 ++++----
 net/sunrpc/auth.c           | 12 ++++++------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index b1bc62b..bd36e0b 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -15,7 +15,7 @@
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/xdr.h>
 
-#include <linux/atomic.h>
+#include <linux/refcount.h>
 #include <linux/rcupdate.h>
 #include <linux/uidgid.h>
 #include <linux/utsname.h>
@@ -68,7 +68,7 @@ struct rpc_cred {
 #endif
 	unsigned long		cr_expire;	/* when to gc */
 	unsigned long		cr_flags;	/* various flags */
-	atomic_t		cr_count;	/* ref count */
+	refcount_t		cr_count;	/* ref count */
 
 	kuid_t			cr_uid;
 
@@ -209,7 +209,7 @@ static inline
 struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
 {
 	if (cred != NULL)
-		atomic_inc(&cred->cr_count);
+		refcount_inc(&cred->cr_count);
 	return cred;
 }
 
@@ -226,7 +226,7 @@ struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
 static inline struct rpc_cred *
 get_rpccred_rcu(struct rpc_cred *cred)
 {
-	if (atomic_inc_not_zero(&cred->cr_count))
+	if (refcount_inc_not_zero(&cred->cr_count))
 		return cred;
 	return NULL;
 }
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 2bff63a..b6439b9 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -310,7 +310,7 @@ rpcauth_unhash_cred(struct rpc_cred *cred)
 
 	cache_lock = &cred->cr_auth->au_credcache->lock;
 	spin_lock(cache_lock);
-	ret = atomic_read(&cred->cr_count) == 0;
+	ret = refcount_read(&cred->cr_count) == 0;
 	if (ret)
 		rpcauth_unhash_cred_locked(cred);
 	spin_unlock(cache_lock);
@@ -470,12 +470,12 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 		list_del_init(&cred->cr_lru);
 		number_cred_unused--;
 		freed++;
-		if (atomic_read(&cred->cr_count) != 0)
+		if (refcount_read(&cred->cr_count) != 0)
 			continue;
 
 		cache_lock = &cred->cr_auth->au_credcache->lock;
 		spin_lock(cache_lock);
-		if (atomic_read(&cred->cr_count) == 0) {
+		if (refcount_read(&cred->cr_count) == 0) {
 			get_rpccred(cred);
 			list_add_tail(&cred->cr_lru, free);
 			rpcauth_unhash_cred_locked(cred);
@@ -642,7 +642,7 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 {
 	INIT_HLIST_NODE(&cred->cr_hash);
 	INIT_LIST_HEAD(&cred->cr_lru);
-	atomic_set(&cred->cr_count, 1);
+	refcount_set(&cred->cr_count, 1);
 	cred->cr_auth = auth;
 	cred->cr_ops = ops;
 	cred->cr_expire = jiffies;
@@ -715,12 +715,12 @@ put_rpccred(struct rpc_cred *cred)
 		return;
 	/* Fast path for unhashed credentials */
 	if (test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) == 0) {
-		if (atomic_dec_and_test(&cred->cr_count))
+		if (refcount_dec_and_test(&cred->cr_count))
 			cred->cr_ops->crdestroy(cred);
 		return;
 	}
 
-	if (!atomic_dec_and_lock(&cred->cr_count, &rpc_credcache_lock))
+	if (!refcount_dec_and_lock(&cred->cr_count, &rpc_credcache_lock))
 		return;
 	if (!list_empty(&cred->cr_lru)) {
 		number_cred_unused--;
-- 
2.7.4

