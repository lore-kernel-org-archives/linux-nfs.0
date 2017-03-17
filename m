Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:48164 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751142AbdCQMLl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 08:11:41 -0400
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
Subject: [PATCH 05/23] net, ceph: convert ceph_osd.o_ref from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:10:28 +0200
Message-Id: <1489752646-8749-6-git-send-email-elena.reshetova@intel.com>
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
 include/linux/ceph/osd_client.h |  3 ++-
 net/ceph/osd_client.c           | 16 ++++++++--------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/linux/ceph/osd_client.h b/include/linux/ceph/osd_client.h
index 2ea0c28..5ce0cd6 100644
--- a/include/linux/ceph/osd_client.h
+++ b/include/linux/ceph/osd_client.h
@@ -5,6 +5,7 @@
 #include <linux/kref.h>
 #include <linux/mempool.h>
 #include <linux/rbtree.h>
+#include <linux/refcount.h>
 
 #include <linux/ceph/types.h>
 #include <linux/ceph/osdmap.h>
@@ -27,7 +28,7 @@ typedef void (*ceph_osdc_callback_t)(struct ceph_osd_request *);
 
 /* a given osd we're communicating with */
 struct ceph_osd {
-	atomic_t o_ref;
+	refcount_t o_ref;
 	struct ceph_osd_client *o_osdc;
 	int o_osd;
 	int o_incarnation;
diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index b65bbf9..99a51f0 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -1005,7 +1005,7 @@ static bool osd_registered(struct ceph_osd *osd)
  */
 static void osd_init(struct ceph_osd *osd)
 {
-	atomic_set(&osd->o_ref, 1);
+	refcount_set(&osd->o_ref, 1);
 	RB_CLEAR_NODE(&osd->o_node);
 	osd->o_requests = RB_ROOT;
 	osd->o_linger_requests = RB_ROOT;
@@ -1050,9 +1050,9 @@ static struct ceph_osd *create_osd(struct ceph_osd_client *osdc, int onum)
 
 static struct ceph_osd *get_osd(struct ceph_osd *osd)
 {
-	if (atomic_inc_not_zero(&osd->o_ref)) {
-		dout("get_osd %p %d -> %d\n", osd, atomic_read(&osd->o_ref)-1,
-		     atomic_read(&osd->o_ref));
+	if (refcount_inc_not_zero(&osd->o_ref)) {
+		dout("get_osd %p %d -> %d\n", osd, refcount_read(&osd->o_ref)-1,
+		     refcount_read(&osd->o_ref));
 		return osd;
 	} else {
 		dout("get_osd %p FAIL\n", osd);
@@ -1062,9 +1062,9 @@ static struct ceph_osd *get_osd(struct ceph_osd *osd)
 
 static void put_osd(struct ceph_osd *osd)
 {
-	dout("put_osd %p %d -> %d\n", osd, atomic_read(&osd->o_ref),
-	     atomic_read(&osd->o_ref) - 1);
-	if (atomic_dec_and_test(&osd->o_ref)) {
+	dout("put_osd %p %d -> %d\n", osd, refcount_read(&osd->o_ref),
+	     refcount_read(&osd->o_ref) - 1);
+	if (refcount_dec_and_test(&osd->o_ref)) {
 		osd_cleanup(osd);
 		kfree(osd);
 	}
@@ -4092,7 +4092,7 @@ void ceph_osdc_stop(struct ceph_osd_client *osdc)
 		close_osd(osd);
 	}
 	up_write(&osdc->lock);
-	WARN_ON(atomic_read(&osdc->homeless_osd.o_ref) != 1);
+	WARN_ON(refcount_read(&osdc->homeless_osd.o_ref) != 1);
 	osd_cleanup(&osdc->homeless_osd);
 
 	WARN_ON(!list_empty(&osdc->osd_lru));
-- 
2.7.4

