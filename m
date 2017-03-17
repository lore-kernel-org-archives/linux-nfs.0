Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:57529 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750926AbdCQMQv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 08:16:51 -0400
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
Subject: [PATCH 16/23] net, sctp: convert sctp_auth_bytes.refcnt from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:10:39 +0200
Message-Id: <1489752646-8749-17-git-send-email-elena.reshetova@intel.com>
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
 include/net/sctp/auth.h | 5 +++--
 net/sctp/auth.c         | 4 ++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/auth.h b/include/net/sctp/auth.h
index 9b9fb12..328fccc 100644
--- a/include/net/sctp/auth.h
+++ b/include/net/sctp/auth.h
@@ -31,6 +31,7 @@
 #define __sctp_auth_h__
 
 #include <linux/list.h>
+#include <linux/refcount.h>
 
 struct sctp_endpoint;
 struct sctp_association;
@@ -53,7 +54,7 @@ struct sctp_hmac {
  * over SCTP-AUTH
  */
 struct sctp_auth_bytes {
-	atomic_t refcnt;
+	refcount_t refcnt;
 	__u32 len;
 	__u8  data[];
 };
@@ -76,7 +77,7 @@ static inline void sctp_auth_key_hold(struct sctp_auth_bytes *key)
 	if (!key)
 		return;
 
-	atomic_inc(&key->refcnt);
+	refcount_inc(&key->refcnt);
 }
 
 void sctp_auth_key_put(struct sctp_auth_bytes *key);
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index f99d485..b6c98fe 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -63,7 +63,7 @@ void sctp_auth_key_put(struct sctp_auth_bytes *key)
 	if (!key)
 		return;
 
-	if (atomic_dec_and_test(&key->refcnt)) {
+	if (refcount_dec_and_test(&key->refcnt)) {
 		kzfree(key);
 		SCTP_DBG_OBJCNT_DEC(keys);
 	}
@@ -84,7 +84,7 @@ static struct sctp_auth_bytes *sctp_auth_create_key(__u32 key_len, gfp_t gfp)
 		return NULL;
 
 	key->len = key_len;
-	atomic_set(&key->refcnt, 1);
+	refcount_set(&key->refcnt, 1);
 	SCTP_DBG_OBJCNT_INC(keys);
 
 	return key;
-- 
2.7.4

