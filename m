Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20894 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751102AbdCQMQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 08:16:50 -0400
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
Subject: [PATCH 09/23] net, rds: convert rds_mr.r_refcount from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:10:32 +0200
Message-Id: <1489752646-8749-10-git-send-email-elena.reshetova@intel.com>
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
 net/rds/rdma.c | 10 +++++-----
 net/rds/rds.h  |  4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index f06fac4..8886f15 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -84,7 +84,7 @@ static struct rds_mr *rds_mr_tree_walk(struct rb_root *root, u64 key,
 	if (insert) {
 		rb_link_node(&insert->r_rb_node, parent, p);
 		rb_insert_color(&insert->r_rb_node, root);
-		atomic_inc(&insert->r_refcount);
+		refcount_inc(&insert->r_refcount);
 	}
 	return NULL;
 }
@@ -99,7 +99,7 @@ static void rds_destroy_mr(struct rds_mr *mr)
 	unsigned long flags;
 
 	rdsdebug("RDS: destroy mr key is %x refcnt %u\n",
-			mr->r_key, atomic_read(&mr->r_refcount));
+			mr->r_key, refcount_read(&mr->r_refcount));
 
 	if (test_and_set_bit(RDS_MR_DEAD, &mr->r_state))
 		return;
@@ -223,7 +223,7 @@ static int __rds_rdma_map(struct rds_sock *rs, struct rds_get_mr_args *args,
 		goto out;
 	}
 
-	atomic_set(&mr->r_refcount, 1);
+	refcount_set(&mr->r_refcount, 1);
 	RB_CLEAR_NODE(&mr->r_rb_node);
 	mr->r_trans = rs->rs_transport;
 	mr->r_sock = rs;
@@ -307,7 +307,7 @@ static int __rds_rdma_map(struct rds_sock *rs, struct rds_get_mr_args *args,
 
 	rdsdebug("RDS: get_mr key is %x\n", mr->r_key);
 	if (mr_ret) {
-		atomic_inc(&mr->r_refcount);
+		refcount_inc(&mr->r_refcount);
 		*mr_ret = mr;
 	}
 
@@ -756,7 +756,7 @@ int rds_cmsg_rdma_dest(struct rds_sock *rs, struct rds_message *rm,
 	if (!mr)
 		err = -EINVAL;	/* invalid r_key */
 	else
-		atomic_inc(&mr->r_refcount);
+		refcount_inc(&mr->r_refcount);
 	spin_unlock_irqrestore(&rs->rs_rdma_lock, flags);
 
 	if (mr) {
diff --git a/net/rds/rds.h b/net/rds/rds.h
index d8070c7..7487597 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -276,7 +276,7 @@ struct rds_incoming {
 
 struct rds_mr {
 	struct rb_node		r_rb_node;
-	atomic_t		r_refcount;
+	refcount_t		r_refcount;
 	u32			r_key;
 
 	/* A copy of the creation flags */
@@ -855,7 +855,7 @@ int rds_cmsg_atomic(struct rds_sock *rs, struct rds_message *rm,
 void __rds_put_mr_final(struct rds_mr *mr);
 static inline void rds_mr_put(struct rds_mr *mr)
 {
-	if (atomic_dec_and_test(&mr->r_refcount))
+	if (refcount_dec_and_test(&mr->r_refcount))
 		__rds_put_mr_final(mr);
 }
 
-- 
2.7.4

