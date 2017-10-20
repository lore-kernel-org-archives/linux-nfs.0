Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13939 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752791AbdJTJz6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 05:55:58 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 07/11] fs, nfs: convert nfs4_ff_layout_mirror.ref from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 12:53:34 +0300
Message-Id: <1508493218-27760-8-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
References: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable nfs4_ff_layout_mirror.ref is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 8 ++++----
 fs/nfs/flexfilelayout/flexfilelayout.h | 3 ++-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index b0fa83a..ff55a0a 100644
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
 
@@ -2286,7 +2286,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 		if (!test_and_clear_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags))
 			continue;
 		/* mirror refcount put in cleanup_layoutstats */
-		if (!atomic_inc_not_zero(&mirror->ref))
+		if (!refcount_inc_not_zero(&mirror->ref))
 			continue;
 		dev = &mirror->mirror_ds->id_node; 
 		memcpy(&devinfo->dev_id, &dev->deviceid, NFS4_DEVICEID4_SIZE);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 98b34c9..ca35426 100644
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

