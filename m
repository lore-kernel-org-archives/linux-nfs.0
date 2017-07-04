Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60829 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752684AbdGDMyz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:54:55 -0400
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
Subject: [PATCH 08/36] net, atm: convert in_cache_entry.use from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:03 +0300
Message-Id: <1499172811-16271-9-git-send-email-elena.reshetova@intel.com>
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
 net/atm/mpoa_caches.c | 12 ++++++------
 net/atm/mpoa_caches.h |  3 ++-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index a89fdeb..05e89e9 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -40,7 +40,7 @@ static in_cache_entry *in_cache_get(__be32 dst_ip,
 	entry = client->in_cache;
 	while (entry != NULL) {
 		if (entry->ctrl_info.in_dst_ip == dst_ip) {
-			atomic_inc(&entry->use);
+			refcount_inc(&entry->use);
 			read_unlock_bh(&client->ingress_lock);
 			return entry;
 		}
@@ -61,7 +61,7 @@ static in_cache_entry *in_cache_get_with_mask(__be32 dst_ip,
 	entry = client->in_cache;
 	while (entry != NULL) {
 		if ((entry->ctrl_info.in_dst_ip & mask) == (dst_ip & mask)) {
-			atomic_inc(&entry->use);
+			refcount_inc(&entry->use);
 			read_unlock_bh(&client->ingress_lock);
 			return entry;
 		}
@@ -82,7 +82,7 @@ static in_cache_entry *in_cache_get_by_vcc(struct atm_vcc *vcc,
 	entry = client->in_cache;
 	while (entry != NULL) {
 		if (entry->shortcut == vcc) {
-			atomic_inc(&entry->use);
+			refcount_inc(&entry->use);
 			read_unlock_bh(&client->ingress_lock);
 			return entry;
 		}
@@ -105,7 +105,7 @@ static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 
 	dprintk("adding an ingress entry, ip = %pI4\n", &dst_ip);
 
-	atomic_set(&entry->use, 1);
+	refcount_set(&entry->use, 1);
 	dprintk("new_in_cache_entry: about to lock\n");
 	write_lock_bh(&client->ingress_lock);
 	entry->next = client->in_cache;
@@ -121,7 +121,7 @@ static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 	entry->count = 1;
 	entry->entry_state = INGRESS_INVALID;
 	entry->ctrl_info.holding_time = HOLDING_TIME_DEFAULT;
-	atomic_inc(&entry->use);
+	refcount_inc(&entry->use);
 
 	write_unlock_bh(&client->ingress_lock);
 	dprintk("new_in_cache_entry: unlocked\n");
@@ -178,7 +178,7 @@ static int cache_hit(in_cache_entry *entry, struct mpoa_client *mpc)
 
 static void in_cache_put(in_cache_entry *entry)
 {
-	if (atomic_dec_and_test(&entry->use)) {
+	if (refcount_dec_and_test(&entry->use)) {
 		memset(entry, 0, sizeof(in_cache_entry));
 		kfree(entry);
 	}
diff --git a/net/atm/mpoa_caches.h b/net/atm/mpoa_caches.h
index 8e5f78c..38a4e7e 100644
--- a/net/atm/mpoa_caches.h
+++ b/net/atm/mpoa_caches.h
@@ -6,6 +6,7 @@
 #include <linux/atm.h>
 #include <linux/atmdev.h>
 #include <linux/atmmpc.h>
+#include <linux/refcount.h>
 
 struct mpoa_client;
 
@@ -25,7 +26,7 @@ typedef struct in_cache_entry {
 	struct   atm_vcc *shortcut;
 	uint8_t  MPS_ctrl_ATM_addr[ATM_ESA_LEN];
 	struct   in_ctrl_info ctrl_info;
-	atomic_t use;
+	refcount_t use;
 } in_cache_entry;
 
 struct in_cache_ops{
-- 
2.7.4

