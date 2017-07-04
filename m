Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60385 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752649AbdGDMym (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:54:42 -0400
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
Subject: [PATCH 06/36] net, atm: convert atm_dev.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:01 +0300
Message-Id: <1499172811-16271-7-git-send-email-elena.reshetova@intel.com>
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
 include/linux/atmdev.h | 7 ++++---
 net/atm/proc.c         | 2 +-
 net/atm/resources.c    | 2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 4d97a89..0ec9bdb 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -11,6 +11,7 @@
 #include <linux/uio.h>
 #include <net/sock.h>
 #include <linux/atomic.h>
+#include <linux/refcount.h>
 #include <uapi/linux/atmdev.h>
 
 #ifdef CONFIG_PROC_FS
@@ -158,7 +159,7 @@ struct atm_dev {
 	struct k_atm_dev_stats stats;	/* statistics */
 	char		signal;		/* signal status (ATM_PHY_SIG_*) */
 	int		link_rate;	/* link rate (default: OC3) */
-	atomic_t	refcnt;		/* reference count */
+	refcount_t	refcnt;		/* reference count */
 	spinlock_t	lock;		/* protect internal members */
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *proc_entry; /* proc entry */
@@ -261,13 +262,13 @@ static inline int atm_may_send(struct atm_vcc *vcc,unsigned int size)
 
 static inline void atm_dev_hold(struct atm_dev *dev)
 {
-	atomic_inc(&dev->refcnt);
+	refcount_inc(&dev->refcnt);
 }
 
 
 static inline void atm_dev_put(struct atm_dev *dev)
 {
-	if (atomic_dec_and_test(&dev->refcnt)) {
+	if (refcount_dec_and_test(&dev->refcnt)) {
 		BUG_ON(!test_bit(ATM_DF_REMOVED, &dev->flags));
 		if (dev->ops->dev_close)
 			dev->ops->dev_close(dev);
diff --git a/net/atm/proc.c b/net/atm/proc.c
index 27c9c01..4caca2a 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -61,7 +61,7 @@ static void atm_dev_info(struct seq_file *seq, const struct atm_dev *dev)
 	add_stats(seq, "0", &dev->stats.aal0);
 	seq_puts(seq, "  ");
 	add_stats(seq, "5", &dev->stats.aal5);
-	seq_printf(seq, "\t[%d]", atomic_read(&dev->refcnt));
+	seq_printf(seq, "\t[%d]", refcount_read(&dev->refcnt));
 	seq_putc(seq, '\n');
 }
 
diff --git a/net/atm/resources.c b/net/atm/resources.c
index 0447d5d..9182447 100644
--- a/net/atm/resources.c
+++ b/net/atm/resources.c
@@ -109,7 +109,7 @@ struct atm_dev *atm_dev_register(const char *type, struct device *parent,
 	else
 		memset(&dev->flags, 0, sizeof(dev->flags));
 	memset(&dev->stats, 0, sizeof(dev->stats));
-	atomic_set(&dev->refcnt, 1);
+	refcount_set(&dev->refcnt, 1);
 
 	if (atm_proc_dev_register(dev) < 0) {
 		pr_err("atm_proc_dev_register failed for dev %s\n", type);
-- 
2.7.4

