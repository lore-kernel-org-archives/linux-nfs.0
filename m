Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43703 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752686AbdGDMy5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:54:57 -0400
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
Subject: [PATCH 07/36] net, atm: convert lec_arp_table.usage from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:02 +0300
Message-Id: <1499172811-16271-8-git-send-email-elena.reshetova@intel.com>
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
 net/atm/lec.c      | 6 +++---
 net/atm/lec_arpc.h | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 7554571..093fe87 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -101,12 +101,12 @@ static void lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc);
 /* must be done under lec_arp_lock */
 static inline void lec_arp_hold(struct lec_arp_table *entry)
 {
-	atomic_inc(&entry->usage);
+	refcount_inc(&entry->usage);
 }
 
 static inline void lec_arp_put(struct lec_arp_table *entry)
 {
-	if (atomic_dec_and_test(&entry->usage))
+	if (refcount_dec_and_test(&entry->usage))
 		kfree(entry);
 }
 
@@ -1564,7 +1564,7 @@ static struct lec_arp_table *make_entry(struct lec_priv *priv,
 	to_return->last_used = jiffies;
 	to_return->priv = priv;
 	skb_queue_head_init(&to_return->tx_wait);
-	atomic_set(&to_return->usage, 1);
+	refcount_set(&to_return->usage, 1);
 	return to_return;
 }
 
diff --git a/net/atm/lec_arpc.h b/net/atm/lec_arpc.h
index ec67435..d923f53 100644
--- a/net/atm/lec_arpc.h
+++ b/net/atm/lec_arpc.h
@@ -47,7 +47,7 @@ struct lec_arp_table {
 					 * the length of the tlvs array
 					 */
 	struct sk_buff_head tx_wait;	/* wait queue for outgoing packets */
-	atomic_t usage;			/* usage count */
+	refcount_t usage;		/* usage count */
 };
 
 /*
-- 
2.7.4

