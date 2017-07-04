Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3794 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752051AbdGDM6D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:58:03 -0400
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
Subject: [PATCH 29/36] net, sctp: convert sctp_auth_bytes.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:24 +0300
Message-Id: <1499172811-16271-30-git-send-email-elena.reshetova@intel.com>
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
 include/net/sctp/auth.h | 5 +++--
 net/sctp/auth.c         | 4 ++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/auth.h b/include/net/sctp/auth.h
index 171244b..e5c57d0 100644
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
index 8ffa598..e001b01 100644
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

