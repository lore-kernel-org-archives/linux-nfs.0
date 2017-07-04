Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19647 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753056AbdGDM4t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:56:49 -0400
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
Subject: [PATCH 20/36] net, rds: convert rds_ib_device.refcount from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:15 +0300
Message-Id: <1499172811-16271-21-git-send-email-elena.reshetova@intel.com>
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
 net/rds/ib.c      | 12 ++++++------
 net/rds/ib.h      |  2 +-
 net/rds/ib_rdma.c |  4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 7a64c8d..a0954ac 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -118,8 +118,8 @@ static void rds_ib_dev_free(struct work_struct *work)
 
 void rds_ib_dev_put(struct rds_ib_device *rds_ibdev)
 {
-	BUG_ON(atomic_read(&rds_ibdev->refcount) <= 0);
-	if (atomic_dec_and_test(&rds_ibdev->refcount))
+	BUG_ON(refcount_read(&rds_ibdev->refcount) == 0);
+	if (refcount_dec_and_test(&rds_ibdev->refcount))
 		queue_work(rds_wq, &rds_ibdev->free_work);
 }
 
@@ -137,7 +137,7 @@ static void rds_ib_add_one(struct ib_device *device)
 		return;
 
 	spin_lock_init(&rds_ibdev->spinlock);
-	atomic_set(&rds_ibdev->refcount, 1);
+	refcount_set(&rds_ibdev->refcount, 1);
 	INIT_WORK(&rds_ibdev->free_work, rds_ib_dev_free);
 
 	rds_ibdev->max_wrs = device->attrs.max_qp_wr;
@@ -205,10 +205,10 @@ static void rds_ib_add_one(struct ib_device *device)
 	down_write(&rds_ib_devices_lock);
 	list_add_tail_rcu(&rds_ibdev->list, &rds_ib_devices);
 	up_write(&rds_ib_devices_lock);
-	atomic_inc(&rds_ibdev->refcount);
+	refcount_inc(&rds_ibdev->refcount);
 
 	ib_set_client_data(device, &rds_ib_client, rds_ibdev);
-	atomic_inc(&rds_ibdev->refcount);
+	refcount_inc(&rds_ibdev->refcount);
 
 	rds_ib_nodev_connect();
 
@@ -239,7 +239,7 @@ struct rds_ib_device *rds_ib_get_client_data(struct ib_device *device)
 	rcu_read_lock();
 	rds_ibdev = ib_get_client_data(device, &rds_ib_client);
 	if (rds_ibdev)
-		atomic_inc(&rds_ibdev->refcount);
+		refcount_inc(&rds_ibdev->refcount);
 	rcu_read_unlock();
 	return rds_ibdev;
 }
diff --git a/net/rds/ib.h b/net/rds/ib.h
index ec55062..bf48224 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -230,7 +230,7 @@ struct rds_ib_device {
 	unsigned int		max_initiator_depth;
 	unsigned int		max_responder_resources;
 	spinlock_t		spinlock;	/* protect the above */
-	atomic_t		refcount;
+	refcount_t		refcount;
 	struct work_struct	free_work;
 	int			*vector_load;
 };
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 977f698..9a3c54e 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -52,7 +52,7 @@ static struct rds_ib_device *rds_ib_get_device(__be32 ipaddr)
 	list_for_each_entry_rcu(rds_ibdev, &rds_ib_devices, list) {
 		list_for_each_entry_rcu(i_ipaddr, &rds_ibdev->ipaddr_list, list) {
 			if (i_ipaddr->ipaddr == ipaddr) {
-				atomic_inc(&rds_ibdev->refcount);
+				refcount_inc(&rds_ibdev->refcount);
 				rcu_read_unlock();
 				return rds_ibdev;
 			}
@@ -134,7 +134,7 @@ void rds_ib_add_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *con
 	spin_unlock_irq(&ib_nodev_conns_lock);
 
 	ic->rds_ibdev = rds_ibdev;
-	atomic_inc(&rds_ibdev->refcount);
+	refcount_inc(&rds_ibdev->refcount);
 }
 
 void rds_ib_remove_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn)
-- 
2.7.4

