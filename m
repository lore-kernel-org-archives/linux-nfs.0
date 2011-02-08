Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:48817 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755304Ab1BHSmJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 13:42:09 -0500
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Rob Landley <rlandley@parallels.com>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        containers@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kas@openvz.org>
Subject: [PATCH v3, RESEND 01/16] sunrpc: mount rpc_pipefs on initialization
Date: Tue,  8 Feb 2011 20:41:52 +0200
Message-Id: <1297190527-19925-2-git-send-email-kas@openvz.org>
In-Reply-To: <1297190527-19925-1-git-send-email-kas@openvz.org>
References: <1297190527-19925-1-git-send-email-kas@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Mount rpc_pipefs on register_rpc_pipefs() and replace
rpc_get_mount()/rpc_put_mount() implementation with mntget()/mntput().

This commit introduces temprorary regression: there is no way to
remove the module. It will be fixed at the end of the patchset.

Signed-off-by: Kirill A. Shutemov <kas@openvz.org>
Reviewed-by: Rob Landley <rlandley@parallels.com>
---
 net/sunrpc/rpc_pipe.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 72bc536..9ab9355 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -29,7 +29,6 @@
 #include <linux/sunrpc/cache.h>
 
 static struct vfsmount *rpc_mnt __read_mostly;
-static int rpc_mount_count;
 
 static struct file_system_type rpc_pipe_fs_type;
 
@@ -423,18 +422,13 @@ struct rpc_filelist {
 
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
 
@@ -1071,12 +1065,22 @@ int register_rpc_pipefs(void)
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
-- 
1.7.4

