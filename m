Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:29923 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752040AbdGDMz0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:55:26 -0400
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
Subject: [PATCH 11/36] net, calipso: convert calipso_doi.refcount from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:06 +0300
Message-Id: <1499172811-16271-12-git-send-email-elena.reshetova@intel.com>
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
 include/net/calipso.h |  4 ++--
 net/ipv6/calipso.c    | 12 ++++++------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/calipso.h b/include/net/calipso.h
index b1b30cd..5f95b11 100644
--- a/include/net/calipso.h
+++ b/include/net/calipso.h
@@ -38,7 +38,7 @@
 #include <linux/skbuff.h>
 #include <net/netlabel.h>
 #include <net/request_sock.h>
-#include <linux/atomic.h>
+#include <linux/refcount.h>
 #include <asm/unaligned.h>
 
 /* known doi values */
@@ -57,7 +57,7 @@ struct calipso_doi {
 	u32 doi;
 	u32 type;
 
-	atomic_t refcount;
+	refcount_t refcount;
 	struct list_head list;
 	struct rcu_head rcu;
 };
diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index 4406752..1323b96 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -338,7 +338,7 @@ static struct calipso_doi *calipso_doi_search(u32 doi)
 	struct calipso_doi *iter;
 
 	list_for_each_entry_rcu(iter, &calipso_doi_list, list)
-		if (iter->doi == doi && atomic_read(&iter->refcount))
+		if (iter->doi == doi && refcount_read(&iter->refcount))
 			return iter;
 	return NULL;
 }
@@ -370,7 +370,7 @@ static int calipso_doi_add(struct calipso_doi *doi_def,
 	if (doi_def->doi == CALIPSO_DOI_UNKNOWN)
 		goto doi_add_return;
 
-	atomic_set(&doi_def->refcount, 1);
+	refcount_set(&doi_def->refcount, 1);
 
 	spin_lock(&calipso_doi_list_lock);
 	if (calipso_doi_search(doi_def->doi)) {
@@ -458,7 +458,7 @@ static int calipso_doi_remove(u32 doi, struct netlbl_audit *audit_info)
 		ret_val = -ENOENT;
 		goto doi_remove_return;
 	}
-	if (!atomic_dec_and_test(&doi_def->refcount)) {
+	if (!refcount_dec_and_test(&doi_def->refcount)) {
 		spin_unlock(&calipso_doi_list_lock);
 		ret_val = -EBUSY;
 		goto doi_remove_return;
@@ -499,7 +499,7 @@ static struct calipso_doi *calipso_doi_getdef(u32 doi)
 	doi_def = calipso_doi_search(doi);
 	if (!doi_def)
 		goto doi_getdef_return;
-	if (!atomic_inc_not_zero(&doi_def->refcount))
+	if (!refcount_inc_not_zero(&doi_def->refcount))
 		doi_def = NULL;
 
 doi_getdef_return:
@@ -520,7 +520,7 @@ static void calipso_doi_putdef(struct calipso_doi *doi_def)
 	if (!doi_def)
 		return;
 
-	if (!atomic_dec_and_test(&doi_def->refcount))
+	if (!refcount_dec_and_test(&doi_def->refcount))
 		return;
 	spin_lock(&calipso_doi_list_lock);
 	list_del_rcu(&doi_def->list);
@@ -553,7 +553,7 @@ static int calipso_doi_walk(u32 *skip_cnt,
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(iter_doi, &calipso_doi_list, list)
-		if (atomic_read(&iter_doi->refcount) > 0) {
+		if (refcount_read(&iter_doi->refcount) > 0) {
 			if (doi_cnt++ < *skip_cnt)
 				continue;
 			ret_val = callback(iter_doi, cb_arg);
-- 
2.7.4

