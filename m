Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34755 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815AbbDMNBt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2015 09:01:49 -0400
Message-ID: <552BBE35.3050401@gmail.com>
Date: Mon, 13 Apr 2015 21:01:41 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: David Howells <dhowells@redhat.com>
CC: linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH v2 2/2] FSCACHE: Don't override netfs's primary_index if registering
 failed
References: <552BB530.50405@gmail.com> <5527C9A0.6030502@gmail.com> <30571.1428924822@warthog.procyon.org.uk> <32264.1428929064@warthog.procyon.org.uk>
In-Reply-To: <32264.1428929064@warthog.procyon.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Only override netfs->primary_index when registering success.

v2: according to the change of 1/2

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/fscache/netfs.c | 35 +++++++++++++++++------------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/fs/fscache/netfs.c b/fs/fscache/netfs.c
index bea1f2e..166fdc3 100644
--- a/fs/fscache/netfs.c
+++ b/fs/fscache/netfs.c
@@ -22,6 +22,7 @@ static LIST_HEAD(fscache_netfs_list);
 int __fscache_register_netfs(struct fscache_netfs *netfs)
 {
 	struct fscache_netfs *ptr;
+	struct fscache_cookie *cookie;
 	int ret;
 
 	_enter("{%s}", netfs->name);
@@ -29,25 +30,24 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
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
-	netfs->primary_index->netfs_data	= netfs;
-	netfs->primary_index->flags		= 1 << FSCACHE_COOKIE_ENABLED;
+	cookie->def		= &fscache_fsdef_netfs_def;
+	cookie->netfs_data	= netfs;
+	cookie->flags		= 1 << FSCACHE_COOKIE_ENABLED;
 
-	spin_lock_init(&netfs->primary_index->lock);
-	INIT_HLIST_HEAD(&netfs->primary_index->backing_objects);
+	spin_lock_init(&cookie->lock);
+	INIT_HLIST_HEAD(&cookie->backing_objects);
 
 	/* check the netfs type is not already present */
 	down_write(&fscache_addremove_sem);
@@ -58,10 +58,11 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 			goto already_registered;
 	}
 
-	netfs->primary_index->parent = &fscache_fsdef_index;
-	atomic_inc(&netfs->primary_index->parent->usage);
-	atomic_inc(&netfs->primary_index->parent->n_children);
+	cookie->parent = &fscache_fsdef_index;
+	atomic_inc(&cookie->parent->usage);
+	atomic_inc(&cookie->parent->n_children);
 
+	netfs->primary_index = cookie;
 	list_add(&netfs->link, &fscache_netfs_list);
 	ret = 0;
 
@@ -70,10 +71,8 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 already_registered:
 	up_write(&fscache_addremove_sem);
 
-	if (ret < 0) {
-		kmem_cache_free(fscache_cookie_jar, netfs->primary_index);
-		netfs->primary_index = NULL;
-	}
+	if (ret < 0)
+		kmem_cache_free(fscache_cookie_jar, cookie);
 
 	_leave(" = %d", ret);
 	return ret;
-- 
2.3.5

