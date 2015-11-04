Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45132 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030368AbbKDPU3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 10:20:29 -0500
Subject: [PATCH 2/4] FS-Cache: Don't override netfs's primary_index if
 registering failed
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org
Date: Wed, 04 Nov 2015 15:20:24 +0000
Message-ID: <20151104152024.2987.22363.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151104152005.2987.46683.stgit@warthog.procyon.org.uk>
References: <20151104152005.2987.46683.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kinglong Mee <kinglongmee@gmail.com>

Only override netfs->primary_index when registering success.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/netfs.c |   35 +++++++++++++++++------------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/fs/fscache/netfs.c b/fs/fscache/netfs.c
index 458cc968d9a0..9b28649df3a1 100644
--- a/fs/fscache/netfs.c
+++ b/fs/fscache/netfs.c
@@ -22,6 +22,7 @@ static LIST_HEAD(fscache_netfs_list);
 int __fscache_register_netfs(struct fscache_netfs *netfs)
 {
 	struct fscache_netfs *ptr;
+	struct fscache_cookie *cookie;
 	int ret;
 
 	_enter("{%s}", netfs->name);
@@ -29,26 +30,25 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
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
 
-	spin_lock_init(&netfs->primary_index->lock);
-	INIT_HLIST_HEAD(&netfs->primary_index->backing_objects);
+	spin_lock_init(&cookie->lock);
+	INIT_HLIST_HEAD(&cookie->backing_objects);
 
 	/* check the netfs type is not already present */
 	down_write(&fscache_addremove_sem);
@@ -59,9 +59,10 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 			goto already_registered;
 	}
 
-	atomic_inc(&netfs->primary_index->parent->usage);
-	atomic_inc(&netfs->primary_index->parent->n_children);
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

