Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:64233 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751074AbdCQMQv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
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
Subject: [PATCH 17/23] net, sctp: convert sctp_datamsg.refcnt from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:10:40 +0200
Message-Id: <1489752646-8749-18-git-send-email-elena.reshetova@intel.com>
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
 include/net/sctp/structs.h | 2 +-
 net/sctp/chunk.c           | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index a244db5..106e1d3 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -491,7 +491,7 @@ struct sctp_datamsg {
 	/* Chunks waiting to be submitted to lower layer. */
 	struct list_head chunks;
 	/* Reference counting. */
-	atomic_t refcnt;
+	refcount_t refcnt;
 	/* When is this message no longer interesting to the peer? */
 	unsigned long expires_at;
 	/* Did the messenge fail to send? */
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index e3621cb..30c73ce 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -49,7 +49,7 @@
 /* Initialize datamsg from memory. */
 static void sctp_datamsg_init(struct sctp_datamsg *msg)
 {
-	atomic_set(&msg->refcnt, 1);
+	refcount_set(&msg->refcnt, 1);
 	msg->send_failed = 0;
 	msg->send_error = 0;
 	msg->can_delay = 1;
@@ -136,13 +136,13 @@ static void sctp_datamsg_destroy(struct sctp_datamsg *msg)
 /* Hold a reference. */
 static void sctp_datamsg_hold(struct sctp_datamsg *msg)
 {
-	atomic_inc(&msg->refcnt);
+	refcount_inc(&msg->refcnt);
 }
 
 /* Release a reference. */
 void sctp_datamsg_put(struct sctp_datamsg *msg)
 {
-	if (atomic_dec_and_test(&msg->refcnt))
+	if (refcount_dec_and_test(&msg->refcnt))
 		sctp_datamsg_destroy(msg);
 }
 
-- 
2.7.4

