Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18651 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753128AbdGDM4y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:56:54 -0400
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
Subject: [PATCH 21/36] net, rds: convert rds_incoming.i_refcount from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:16 +0300
Message-Id: <1499172811-16271-22-git-send-email-elena.reshetova@intel.com>
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
 net/rds/rds.h  |  3 ++-
 net/rds/recv.c | 12 ++++++------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/rds/rds.h b/net/rds/rds.h
index 4a25db7..35ceaa2 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -8,6 +8,7 @@
 #include <linux/mutex.h>
 #include <linux/rds.h>
 #include <linux/rhashtable.h>
+#include <linux/refcount.h>
 
 #include "info.h"
 
@@ -261,7 +262,7 @@ struct rds_ext_header_rdma_dest {
 #define	RDS_MSG_RX_CMSG		3
 
 struct rds_incoming {
-	atomic_t		i_refcount;
+	refcount_t		i_refcount;
 	struct list_head	i_item;
 	struct rds_connection	*i_conn;
 	struct rds_conn_path	*i_conn_path;
diff --git a/net/rds/recv.c b/net/rds/recv.c
index 373a6aa1..b25bcfe 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -45,7 +45,7 @@ void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
 {
 	int i;
 
-	atomic_set(&inc->i_refcount, 1);
+	refcount_set(&inc->i_refcount, 1);
 	INIT_LIST_HEAD(&inc->i_item);
 	inc->i_conn = conn;
 	inc->i_saddr = saddr;
@@ -61,7 +61,7 @@ EXPORT_SYMBOL_GPL(rds_inc_init);
 void rds_inc_path_init(struct rds_incoming *inc, struct rds_conn_path *cp,
 		       __be32 saddr)
 {
-	atomic_set(&inc->i_refcount, 1);
+	refcount_set(&inc->i_refcount, 1);
 	INIT_LIST_HEAD(&inc->i_item);
 	inc->i_conn = cp->cp_conn;
 	inc->i_conn_path = cp;
@@ -74,14 +74,14 @@ EXPORT_SYMBOL_GPL(rds_inc_path_init);
 
 static void rds_inc_addref(struct rds_incoming *inc)
 {
-	rdsdebug("addref inc %p ref %d\n", inc, atomic_read(&inc->i_refcount));
-	atomic_inc(&inc->i_refcount);
+	rdsdebug("addref inc %p ref %d\n", inc, refcount_read(&inc->i_refcount));
+	refcount_inc(&inc->i_refcount);
 }
 
 void rds_inc_put(struct rds_incoming *inc)
 {
-	rdsdebug("put inc %p ref %d\n", inc, atomic_read(&inc->i_refcount));
-	if (atomic_dec_and_test(&inc->i_refcount)) {
+	rdsdebug("put inc %p ref %d\n", inc, refcount_read(&inc->i_refcount));
+	if (refcount_dec_and_test(&inc->i_refcount)) {
 		BUG_ON(!list_empty(&inc->i_item));
 
 		inc->i_conn->c_trans->inc_free(inc);
-- 
2.7.4

