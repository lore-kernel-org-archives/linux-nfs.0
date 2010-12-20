Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:38432 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755489Ab0LTLyl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 06:54:41 -0500
From: "Kirill A. Shutsemov" <kirill@shutemov.name>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH 01/12] sunrpc: mount rpc_pipefs on initialization
Date: Mon, 20 Dec 2010 13:54:27 +0200
Message-Id: <1292846078-31793-2-git-send-email-kirill@shutemov.name>
In-Reply-To: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
References: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Kirill A. Shutemov <kirill@shutemov.name>

Mount rpc_pipefs on register_rpc_pipefs() and replace
rpc_get_mount()/rpc_put_mount() implementation with mntget()/mntput().

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 net/sunrpc/rpc_pipe.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 10a17a3..7f3fbdd 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -29,7 +29,6 @@
 #include <linux/sunrpc/cache.h>
 
 static struct vfsmount *rpc_mnt __read_mostly;
-static int rpc_mount_count;
 
 static struct file_system_type rpc_pipe_fs_type;
 
@@ -415,18 +414,13 @@ struct rpc_filelist {
 
 struct vfsmount *rpc_get_mount(void)
 {
-	int err;
-
-	err = simple_pin_fs(&rpc_pipe_fs_type, &rpc_mnt, &rpc_mount_count);
-	if (err != 0)
-		return ERR_PTR(err);
-	return rpc_mnt;
+	return mntget(rpc_mnt);
 }
 EXPORT_SYMBOL_GPL(rpc_get_mount);
 
 void rpc_put_mount(void)
 {
-	simple_release_fs(&rpc_mnt, &rpc_mount_count);
+	mntput(rpc_mnt);
 }
 EXPORT_SYMBOL_GPL(rpc_put_mount);
 
@@ -1063,16 +1057,27 @@ int register_rpc_pipefs(void)
 	if (!rpc_inode_cachep)
 		return -ENOMEM;
 	err = register_filesystem(&rpc_pipe_fs_type);
-	if (err) {
-		kmem_cache_destroy(rpc_inode_cachep);
-		return err;
+	if (err)
+		goto destroy_cache;
+
+	rpc_mnt = kern_mount(&rpc_pipe_fs_type);
+	if (IS_ERR(rpc_mnt)) {
+		err = PTR_ERR(rpc_mnt);
+		goto unregister_fs;
 	}
 
 	return 0;
+
+unregister_fs:
+	unregister_filesystem(&rpc_pipe_fs_type);
+destroy_cache:
+	kmem_cache_destroy(rpc_inode_cachep);
+	return err;
 }
 
 void unregister_rpc_pipefs(void)
 {
+	mntput(rpc_mnt);
 	kmem_cache_destroy(rpc_inode_cachep);
 	unregister_filesystem(&rpc_pipe_fs_type);
 }
-- 
1.7.3.4

