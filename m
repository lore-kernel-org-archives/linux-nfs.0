Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34609 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815AbbDMNBl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2015 09:01:41 -0400
Message-ID: <552BBE2E.5050903@gmail.com>
Date: Mon, 13 Apr 2015 21:01:34 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: David Howells <dhowells@redhat.com>
CC: linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH v2 1/2] FSCACHE: Increase reference of parent after registering
 netfs success
References: <552BB530.50405@gmail.com> <5527C9A0.6030502@gmail.com> <30571.1428924822@warthog.procyon.org.uk> <32264.1428929064@warthog.procyon.org.uk>
In-Reply-To: <32264.1428929064@warthog.procyon.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If netfs exist, fscache should not increase the reference of parent's
usage and n_children, otherwise, never be decreased.

v2: thanks David's suggest,
 move increasing reference of parent if success
 use kmem_cache_free() freeing primary_index directly

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/fscache/netfs.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/fscache/netfs.c b/fs/fscache/netfs.c
index 6d941f5..bea1f2e 100644
--- a/fs/fscache/netfs.c
+++ b/fs/fscache/netfs.c
@@ -43,13 +43,9 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 	atomic_set(&netfs->primary_index->n_active, 1);
 
 	netfs->primary_index->def		= &fscache_fsdef_netfs_def;
-	netfs->primary_index->parent		= &fscache_fsdef_index;
 	netfs->primary_index->netfs_data	= netfs;
 	netfs->primary_index->flags		= 1 << FSCACHE_COOKIE_ENABLED;
 
-	atomic_inc(&netfs->primary_index->parent->usage);
-	atomic_inc(&netfs->primary_index->parent->n_children);
-
 	spin_lock_init(&netfs->primary_index->lock);
 	INIT_HLIST_HEAD(&netfs->primary_index->backing_objects);
 
@@ -62,6 +58,10 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 			goto already_registered;
 	}
 
+	netfs->primary_index->parent = &fscache_fsdef_index;
+	atomic_inc(&netfs->primary_index->parent->usage);
+	atomic_inc(&netfs->primary_index->parent->n_children);
+
 	list_add(&netfs->link, &fscache_netfs_list);
 	ret = 0;
 
@@ -71,8 +71,7 @@ already_registered:
 	up_write(&fscache_addremove_sem);
 
 	if (ret < 0) {
-		netfs->primary_index->parent = NULL;
-		__fscache_cookie_put(netfs->primary_index);
+		kmem_cache_free(fscache_cookie_jar, netfs->primary_index);
 		netfs->primary_index = NULL;
 	}
 
-- 
2.3.5

