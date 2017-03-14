Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21290 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751100AbdCNHHu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:07:50 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 07/12] fs, nfs: convert nfs4_ff_layout_mirror.ref from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:15 +0200
Message-Id: <1489475240-6594-8-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
References: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
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
 fs/nfs/flexfilelayout/flexfilelayout.c | 8 ++++----
 fs/nfs/flexfilelayout/flexfilelayout.h | 3 ++-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index d6acc68..18d4c5a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -187,7 +187,7 @@ ff_layout_add_mirror(struct pnfs_layout_hdr *lo,
 			continue;
 		if (!ff_mirror_match_fh(mirror, pos))
 			continue;
-		if (atomic_inc_not_zero(&pos->ref)) {
+		if (refcount_inc_not_zero(&pos->ref)) {
 			spin_unlock(&inode->i_lock);
 			return pos;
 		}
@@ -218,7 +218,7 @@ static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(gfp_t gfp_flags)
 	mirror = kzalloc(sizeof(*mirror), gfp_flags);
 	if (mirror != NULL) {
 		spin_lock_init(&mirror->lock);
-		atomic_set(&mirror->ref, 1);
+		refcount_set(&mirror->ref, 1);
 		INIT_LIST_HEAD(&mirror->mirrors);
 	}
 	return mirror;
@@ -242,7 +242,7 @@ static void ff_layout_free_mirror(struct nfs4_ff_layout_mirror *mirror)
 
 static void ff_layout_put_mirror(struct nfs4_ff_layout_mirror *mirror)
 {
-	if (mirror != NULL && atomic_dec_and_test(&mirror->ref))
+	if (mirror != NULL && refcount_dec_and_test(&mirror->ref))
 		ff_layout_free_mirror(mirror);
 }
 
@@ -2325,7 +2325,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 		if (!test_and_clear_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags))
 			continue;
 		/* mirror refcount put in cleanup_layoutstats */
-		if (!atomic_inc_not_zero(&mirror->ref))
+		if (!refcount_inc_not_zero(&mirror->ref))
 			continue;
 		dev = &mirror->mirror_ds->id_node; 
 		memcpy(&devinfo->dev_id, &dev->deviceid, NFS4_DEVICEID4_SIZE);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index f4f39b0..1b5d60b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -13,6 +13,7 @@
 #define FF_FLAGS_NO_IO_THRU_MDS  2
 #define FF_FLAGS_NO_READ_IO      4
 
+#include <linux/refcount.h>
 #include "../pnfs.h"
 
 /* XXX: Let's filter out insanely large mirror count for now to avoid oom
@@ -81,7 +82,7 @@ struct nfs4_ff_layout_mirror {
 	nfs4_stateid			stateid;
 	struct rpc_cred	__rcu		*ro_cred;
 	struct rpc_cred	__rcu		*rw_cred;
-	atomic_t			ref;
+	refcount_t			ref;
 	spinlock_t			lock;
 	unsigned long			flags;
 	struct nfs4_ff_layoutstat	read_stat;
-- 
2.7.4

