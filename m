Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13939 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752742AbdJTJzt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 05:55:49 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 04/11] fs, nfs: convert nfs4_pnfs_ds.ds_count from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 12:53:31 +0300
Message-Id: <1508493218-27760-5-git-send-email-elena.reshetova@intel.com>
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

The variable nfs4_pnfs_ds.ds_count is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/nfs/pnfs.h     |  3 ++-
 fs/nfs/pnfs_nfs.c | 10 +++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 87f144f..cefa7da 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -30,6 +30,7 @@
 #ifndef FS_NFS_PNFS_H
 #define FS_NFS_PNFS_H
 
+#include <linux/refcount.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 #include <linux/workqueue.h>
@@ -54,7 +55,7 @@ struct nfs4_pnfs_ds {
 	char			*ds_remotestr;	/* comma sep list of addrs */
 	struct list_head	ds_addrs;
 	struct nfs_client	*ds_clp;
-	atomic_t		ds_count;
+	refcount_t		ds_count;
 	unsigned long		ds_state;
 #define NFS4DS_CONNECTING	0	/* ds is establishing connection */
 };
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 60da59b..03aaa60 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -338,7 +338,7 @@ print_ds(struct nfs4_pnfs_ds *ds)
 		"        client %p\n"
 		"        cl_exchange_flags %x\n",
 		ds->ds_remotestr,
-		atomic_read(&ds->ds_count), ds->ds_clp,
+		refcount_read(&ds->ds_count), ds->ds_clp,
 		ds->ds_clp ? ds->ds_clp->cl_exchange_flags : 0);
 }
 
@@ -451,7 +451,7 @@ static void destroy_ds(struct nfs4_pnfs_ds *ds)
 
 void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds)
 {
-	if (atomic_dec_and_lock(&ds->ds_count,
+	if (refcount_dec_and_lock(&ds->ds_count,
 				&nfs4_ds_cache_lock)) {
 		list_del_init(&ds->ds_node);
 		spin_unlock(&nfs4_ds_cache_lock);
@@ -537,7 +537,7 @@ nfs4_pnfs_ds_add(struct list_head *dsaddrs, gfp_t gfp_flags)
 		INIT_LIST_HEAD(&ds->ds_addrs);
 		list_splice_init(dsaddrs, &ds->ds_addrs);
 		ds->ds_remotestr = remotestr;
-		atomic_set(&ds->ds_count, 1);
+		refcount_set(&ds->ds_count, 1);
 		INIT_LIST_HEAD(&ds->ds_node);
 		ds->ds_clp = NULL;
 		list_add(&ds->ds_node, &nfs4_data_server_cache);
@@ -546,10 +546,10 @@ nfs4_pnfs_ds_add(struct list_head *dsaddrs, gfp_t gfp_flags)
 	} else {
 		kfree(remotestr);
 		kfree(ds);
-		atomic_inc(&tmp_ds->ds_count);
+		refcount_inc(&tmp_ds->ds_count);
 		dprintk("%s data server %s found, inc'ed ds_count to %d\n",
 			__func__, tmp_ds->ds_remotestr,
-			atomic_read(&tmp_ds->ds_count));
+			refcount_read(&tmp_ds->ds_count));
 		ds = tmp_ds;
 	}
 	spin_unlock(&nfs4_ds_cache_lock);
-- 
2.7.4

