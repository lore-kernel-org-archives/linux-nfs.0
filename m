Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33013 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934287AbbDJNq3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Apr 2015 09:46:29 -0400
Message-ID: <5527D42A.800@gmail.com>
Date: Fri, 10 Apr 2015 21:46:18 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: David Howells <dhowells@redhat.com>
CC: linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH] fscache: Don't override netfs->primary_index if register
 failed
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Only override netfs->primary_index when registering success.

Note: this patch is made with,
"[PATCH] fscache: put reference of parent's usage and n_children"

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/fscache/netfs.c | 36 +++++++++++++++++-------------------
 1 file changed, 17 insertions(+), 19 deletions(-)

diff --git a/fs/fscache/netfs.c b/fs/fscache/netfs.c
index b16afba..b935250 100644
--- a/fs/fscache/netfs.c
+++ b/fs/fscache/netfs.c
@@ -22,6 +22,7 @@ static LIST_HEAD(fscache_netfs_list);
 int __fscache_register_netfs(struct fscache_netfs *netfs)
 {
 	struct fscache_netfs *ptr;
+	struct fscache_cookie *cookie;
 	int ret;
 
 	_enter("{%s}", netfs->name);
@@ -29,29 +30,28 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 	INIT_LIST_HEAD(&netfs->link);
 
 	/* allocate a cookie for the primary index */
-	netfs->primary_index =
-		kmem_cache_zalloc(fscache_cookie_jar, GFP_KERNEL);
+	cookie = kmem_cache_zalloc(fscache_cookie_jar, GFP_KERNEL);
 
-	if (!netfs->primary_index) {
+	if (!cookie) {
 		_leave(" = -ENOMEM");
 		return -ENOMEM;
 	}
 
 	/* initialise the primary index cookie */
-	atomic_set(&netfs->primary_index->usage, 1);
-	atomic_set(&netfs->primary_index->n_children, 0);
-	atomic_set(&netfs->primary_index->n_active, 1);
+	atomic_set(&cookie->usage, 1);
+	atomic_set(&cookie->n_children, 0);
+	atomic_set(&cookie->n_active, 1);
 
-	netfs->primary_index->def		= &fscache_fsdef_netfs_def;
-	netfs->primary_index->parent		= &fscache_fsdef_index;
-	netfs->primary_index->netfs_data	= netfs;
-	netfs->primary_index->flags		= 1 << FSCACHE_COOKIE_ENABLED;
+	cookie->def		= &fscache_fsdef_netfs_def;
+	cookie->parent		= &fscache_fsdef_index;
+	cookie->netfs_data	= netfs;
+	cookie->flags		= 1 << FSCACHE_COOKIE_ENABLED;
 
-	atomic_inc(&netfs->primary_index->parent->usage);
-	atomic_inc(&netfs->primary_index->parent->n_children);
+	atomic_inc(&cookie->parent->usage);
+	atomic_inc(&cookie->parent->n_children);
 
-	spin_lock_init(&netfs->primary_index->lock);
-	INIT_HLIST_HEAD(&netfs->primary_index->backing_objects);
+	spin_lock_init(&cookie->lock);
+	INIT_HLIST_HEAD(&cookie->backing_objects);
 
 	/* check the netfs type is not already present */
 	down_write(&fscache_addremove_sem);
@@ -62,6 +62,7 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 			goto already_registered;
 	}
 
+	netfs->primary_index = cookie;
 	list_add(&netfs->link, &fscache_netfs_list);
 	ret = 0;
 
@@ -69,11 +70,8 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 
 already_registered:
 	up_write(&fscache_addremove_sem);
-
-	if (ret < 0) {
-		fscache_relinquish_cookie(netfs->primary_index, 0);
-		netfs->primary_index = NULL;
-	}
+	if (ret < 0)
+		fscache_relinquish_cookie(cookie, 0);
 
 	_leave(" = %d", ret);
 	return ret;
-- 
2.3.5

