Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37882 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755987Ab2BCUpp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 15:45:45 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: Fix comparison between DS address lists
Date: Fri,  3 Feb 2012 15:45:40 -0500
Message-Id: <1328301940-478-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

data_server_cache entries should only be treated as the same if the address
list hasn't changed.

A new entry will be made when an MDS changes an address list (as seen by
GETDEVINFO). The old entry will be freed once all references are gone.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |   71 +++++++++++++++-----------------------------
 1 files changed, 24 insertions(+), 47 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 6eb59b0..420e748 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -108,58 +108,40 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
 	return false;
 }
 
-/*
- * Lookup DS by addresses.  The first matching address returns true.
- * nfs4_ds_cache_lock is held
- */
-static struct nfs4_pnfs_ds *
-_data_server_lookup_locked(struct list_head *dsaddrs)
+bool
+_same_data_server_addrs_locked(const struct list_head *dsaddrs1,
+			       const struct list_head *dsaddrs2)
 {
-	struct nfs4_pnfs_ds *ds;
 	struct nfs4_pnfs_ds_addr *da1, *da2;
 
-	list_for_each_entry(da1, dsaddrs, da_node) {
-		list_for_each_entry(ds, &nfs4_data_server_cache, ds_node) {
-			list_for_each_entry(da2, &ds->ds_addrs, da_node) {
-				if (same_sockaddr(
-					(struct sockaddr *)&da1->da_addr,
-					(struct sockaddr *)&da2->da_addr))
-					return ds;
-			}
-		}
+	/* step through both lists, comparing as we go */
+	for (da1 = list_first_entry(dsaddrs1, typeof(*da1), da_node),
+	     da2 = list_first_entry(dsaddrs2, typeof(*da2), da_node);
+	     da1 != NULL && da2 != NULL;
+	     da1 = list_entry(da1->da_node.next, typeof(*da1), da_node),
+	     da2 = list_entry(da2->da_node.next, typeof(*da2), da_node)) {
+		if (!same_sockaddr((struct sockaddr *)&da1->da_addr,
+				   (struct sockaddr *)&da2->da_addr))
+			return false;
 	}
-	return NULL;
+	if (da1 == NULL && da2 == NULL)
+		return true;
+
+	return false;
 }
 
 /*
- * Compare two lists of addresses.
+ * Lookup DS by addresses.  nfs4_ds_cache_lock is held
  */
-static bool
-_data_server_match_all_addrs_locked(struct list_head *dsaddrs1,
-				    struct list_head *dsaddrs2)
+static struct nfs4_pnfs_ds *
+_data_server_lookup_locked(const struct list_head *dsaddrs)
 {
-	struct nfs4_pnfs_ds_addr *da1, *da2;
-	size_t count1 = 0,
-	       count2 = 0;
-
-	list_for_each_entry(da1, dsaddrs1, da_node)
-		count1++;
-
-	list_for_each_entry(da2, dsaddrs2, da_node) {
-		bool found = false;
-		count2++;
-		list_for_each_entry(da1, dsaddrs1, da_node) {
-			if (same_sockaddr((struct sockaddr *)&da1->da_addr,
-				(struct sockaddr *)&da2->da_addr)) {
-				found = true;
-				break;
-			}
-		}
-		if (!found)
-			return false;
-	}
+	struct nfs4_pnfs_ds *ds;
 
-	return (count1 == count2);
+	list_for_each_entry(ds, &nfs4_data_server_cache, ds_node)
+		if (_same_data_server_addrs_locked(&ds->ds_addrs, dsaddrs))
+			return ds;
+	return NULL;
 }
 
 /*
@@ -356,11 +338,6 @@ nfs4_pnfs_ds_add(struct list_head *dsaddrs, gfp_t gfp_flags)
 		dprintk("%s add new data server %s\n", __func__,
 			ds->ds_remotestr);
 	} else {
-		if (!_data_server_match_all_addrs_locked(&tmp_ds->ds_addrs,
-							 dsaddrs)) {
-			dprintk("%s:  multipath address mismatch: %s != %s",
-				__func__, tmp_ds->ds_remotestr, remotestr);
-		}
 		kfree(remotestr);
 		kfree(ds);
 		atomic_inc(&tmp_ds->ds_count);
-- 
1.7.4.4

