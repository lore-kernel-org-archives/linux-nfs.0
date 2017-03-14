Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34832 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750849AbdCNHHr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:07:47 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 04/12] fs, nfs: convert nfs4_pnfs_ds.ds_count from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:12 +0200
Message-Id: <1489475240-6594-5-git-send-email-elena.reshetova@intel.com>
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
 fs/nfs/pnfs.h     |  3 ++-
 fs/nfs/pnfs_nfs.c | 10 +++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 63f77b4..0411bb0 100644
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
index 9414b49..13bd1fe 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -359,7 +359,7 @@ print_ds(struct nfs4_pnfs_ds *ds)
 		"        client %p\n"
 		"        cl_exchange_flags %x\n",
 		ds->ds_remotestr,
-		atomic_read(&ds->ds_count), ds->ds_clp,
+		refcount_read(&ds->ds_count), ds->ds_clp,
 		ds->ds_clp ? ds->ds_clp->cl_exchange_flags : 0);
 }
 
@@ -472,7 +472,7 @@ static void destroy_ds(struct nfs4_pnfs_ds *ds)
 
 void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds)
 {
-	if (atomic_dec_and_lock(&ds->ds_count,
+	if (refcount_dec_and_lock(&ds->ds_count,
 				&nfs4_ds_cache_lock)) {
 		list_del_init(&ds->ds_node);
 		spin_unlock(&nfs4_ds_cache_lock);
@@ -558,7 +558,7 @@ nfs4_pnfs_ds_add(struct list_head *dsaddrs, gfp_t gfp_flags)
 		INIT_LIST_HEAD(&ds->ds_addrs);
 		list_splice_init(dsaddrs, &ds->ds_addrs);
 		ds->ds_remotestr = remotestr;
-		atomic_set(&ds->ds_count, 1);
+		refcount_set(&ds->ds_count, 1);
 		INIT_LIST_HEAD(&ds->ds_node);
 		ds->ds_clp = NULL;
 		list_add(&ds->ds_node, &nfs4_data_server_cache);
@@ -567,10 +567,10 @@ nfs4_pnfs_ds_add(struct list_head *dsaddrs, gfp_t gfp_flags)
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

