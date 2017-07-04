Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17674 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751852AbdGDM6z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:58:55 -0400
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
Subject: [PATCH 34/36] net, ax25: convert ax25_uid_assoc.refcount from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:29 +0300
Message-Id: <1499172811-16271-35-git-send-email-elena.reshetova@intel.com>
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
 include/net/ax25.h  | 8 ++++----
 net/ax25/ax25_uid.c | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index e602f81..edd82f0 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -11,7 +11,7 @@
 #include <linux/timer.h>
 #include <linux/list.h>
 #include <linux/slab.h>
-#include <linux/atomic.h>
+#include <linux/refcount.h>
 #include <net/neighbour.h>
 #include <net/sock.h>
 
@@ -158,7 +158,7 @@ enum {
 
 typedef struct ax25_uid_assoc {
 	struct hlist_node	uid_node;
-	atomic_t		refcount;
+	refcount_t		refcount;
 	kuid_t			uid;
 	ax25_address		call;
 } ax25_uid_assoc;
@@ -167,11 +167,11 @@ typedef struct ax25_uid_assoc {
 	hlist_for_each_entry(__ax25, list, uid_node)
 
 #define ax25_uid_hold(ax25) \
-	atomic_inc(&((ax25)->refcount))
+	refcount_inc(&((ax25)->refcount))
 
 static inline void ax25_uid_put(ax25_uid_assoc *assoc)
 {
-	if (atomic_dec_and_test(&assoc->refcount)) {
+	if (refcount_dec_and_test(&assoc->refcount)) {
 		kfree(assoc);
 	}
 }
diff --git a/net/ax25/ax25_uid.c b/net/ax25/ax25_uid.c
index 0403b0d..83b035f 100644
--- a/net/ax25/ax25_uid.c
+++ b/net/ax25/ax25_uid.c
@@ -107,7 +107,7 @@ int ax25_uid_ioctl(int cmd, struct sockaddr_ax25 *sax)
 		if ((ax25_uid = kmalloc(sizeof(*ax25_uid), GFP_KERNEL)) == NULL)
 			return -ENOMEM;
 
-		atomic_set(&ax25_uid->refcount, 1);
+		refcount_set(&ax25_uid->refcount, 1);
 		ax25_uid->uid  = sax25_kuid;
 		ax25_uid->call = sax->sax25_call;
 
-- 
2.7.4

