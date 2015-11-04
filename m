Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55789 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965613AbbKDPUT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 10:20:19 -0500
Subject: [PATCH 1/4] FS-Cache: Increase reference of parent after
 registering, netfs success
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org
Date: Wed, 04 Nov 2015 15:20:15 +0000
Message-ID: <20151104152015.2987.68616.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151104152005.2987.46683.stgit@warthog.procyon.org.uk>
References: <20151104152005.2987.46683.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kinglong Mee <kinglongmee@gmail.com>

If netfs exist, fscache should not increase the reference of parent's
usage and n_children, otherwise, never be decreased.

v2: thanks David's suggest,
 move increasing reference of parent if success
 use kmem_cache_free() freeing primary_index directly

v3: don't move "netfs->primary_index->parent = &fscache_fsdef_index;"

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/netfs.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/fscache/netfs.c b/fs/fscache/netfs.c
index 6d941f56faf4..458cc968d9a0 100644
--- a/fs/fscache/netfs.c
+++ b/fs/fscache/netfs.c
@@ -47,9 +47,6 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 	netfs->primary_index->netfs_data	= netfs;
 	netfs->primary_index->flags		= 1 << FSCACHE_COOKIE_ENABLED;
 
-	atomic_inc(&netfs->primary_index->parent->usage);
-	atomic_inc(&netfs->primary_index->parent->n_children);
-
 	spin_lock_init(&netfs->primary_index->lock);
 	INIT_HLIST_HEAD(&netfs->primary_index->backing_objects);
 
@@ -62,6 +59,9 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 			goto already_registered;
 	}
 
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
 

