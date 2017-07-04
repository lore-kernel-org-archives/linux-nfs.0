Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:58463 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752338AbdGDM5K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:57:10 -0400
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
Subject: [PATCH 23/36] net, rds: convert rds_message.m_refcount from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:18 +0300
Message-Id: <1499172811-16271-24-git-send-email-elena.reshetova@intel.com>
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
 net/rds/message.c | 12 ++++++------
 net/rds/rds.h     |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/rds/message.c b/net/rds/message.c
index 49bfb51..4318cc9 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -48,8 +48,8 @@ static unsigned int	rds_exthdr_size[__RDS_EXTHDR_MAX] = {
 
 void rds_message_addref(struct rds_message *rm)
 {
-	rdsdebug("addref rm %p ref %d\n", rm, atomic_read(&rm->m_refcount));
-	atomic_inc(&rm->m_refcount);
+	rdsdebug("addref rm %p ref %d\n", rm, refcount_read(&rm->m_refcount));
+	refcount_inc(&rm->m_refcount);
 }
 EXPORT_SYMBOL_GPL(rds_message_addref);
 
@@ -83,9 +83,9 @@ static void rds_message_purge(struct rds_message *rm)
 
 void rds_message_put(struct rds_message *rm)
 {
-	rdsdebug("put rm %p ref %d\n", rm, atomic_read(&rm->m_refcount));
-	WARN(!atomic_read(&rm->m_refcount), "danger refcount zero on %p\n", rm);
-	if (atomic_dec_and_test(&rm->m_refcount)) {
+	rdsdebug("put rm %p ref %d\n", rm, refcount_read(&rm->m_refcount));
+	WARN(!refcount_read(&rm->m_refcount), "danger refcount zero on %p\n", rm);
+	if (refcount_dec_and_test(&rm->m_refcount)) {
 		BUG_ON(!list_empty(&rm->m_sock_item));
 		BUG_ON(!list_empty(&rm->m_conn_item));
 		rds_message_purge(rm);
@@ -206,7 +206,7 @@ struct rds_message *rds_message_alloc(unsigned int extra_len, gfp_t gfp)
 	rm->m_used_sgs = 0;
 	rm->m_total_sgs = extra_len / sizeof(struct scatterlist);
 
-	atomic_set(&rm->m_refcount, 1);
+	refcount_set(&rm->m_refcount, 1);
 	INIT_LIST_HEAD(&rm->m_sock_item);
 	INIT_LIST_HEAD(&rm->m_conn_item);
 	spin_lock_init(&rm->m_rs_lock);
diff --git a/net/rds/rds.h b/net/rds/rds.h
index ea72d6e..516bcc8 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -356,7 +356,7 @@ static inline u32 rds_rdma_cookie_offset(rds_rdma_cookie_t cookie)
 #define RDS_MSG_FLUSH		8
 
 struct rds_message {
-	atomic_t		m_refcount;
+	refcount_t		m_refcount;
 	struct list_head	m_sock_item;
 	struct list_head	m_conn_item;
 	struct rds_incoming	m_inc;
-- 
2.7.4

