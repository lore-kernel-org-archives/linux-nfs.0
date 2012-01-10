Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:27496 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932172Ab2AJNFE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jan 2012 08:05:04 -0500
Subject: [PATCH v2 5/5] SUNRPC: kernel PipeFS mount point creation routines
 removed
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 10 Jan 2012 17:04:48 +0400
Message-ID: <20120110130448.1672.9202.stgit@localhost6.localdomain6>
In-Reply-To: <20120110130323.1672.97025.stgit@localhost6.localdomain6>
References: <20120110130323.1672.97025.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch removes static rpc_mnt variable and its creation and destruction
routines, because they are not used anymore.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/rpc_pipe_fs.h |    2 --
 net/sunrpc/rpc_pipe.c              |   21 ---------------------
 2 files changed, 0 insertions(+), 23 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 7eb0160..a28d2de 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -90,8 +90,6 @@ void rpc_destroy_pipe_data(struct rpc_pipe *pipe);
 extern struct dentry *rpc_mkpipe_dentry(struct dentry *, const char *, void *,
 					struct rpc_pipe *);
 extern int rpc_unlink(struct dentry *);
-extern struct vfsmount *rpc_get_mount(void);
-extern void rpc_put_mount(void);
 extern int register_rpc_pipefs(void);
 extern void unregister_rpc_pipefs(void);
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index cd565d7..b53bb3b 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -18,7 +18,6 @@
 #include <linux/kernel.h>
 
 #include <asm/ioctls.h>
-#include <linux/fs.h>
 #include <linux/poll.h>
 #include <linux/wait.h>
 #include <linux/seq_file.h>
@@ -37,9 +36,6 @@
 
 #define NET_NAME(net)	((net == &init_net) ? " (init_net)" : "")
 
-static struct vfsmount *rpc_mnt __read_mostly;
-static int rpc_mount_count;
-
 static struct file_system_type rpc_pipe_fs_type;
 
 
@@ -450,23 +446,6 @@ struct rpc_filelist {
 	umode_t mode;
 };
 
-struct vfsmount *rpc_get_mount(void)
-{
-	int err;
-
-	err = simple_pin_fs(&rpc_pipe_fs_type, &rpc_mnt, &rpc_mount_count);
-	if (err != 0)
-		return ERR_PTR(err);
-	return rpc_mnt;
-}
-EXPORT_SYMBOL_GPL(rpc_get_mount);
-
-void rpc_put_mount(void)
-{
-	simple_release_fs(&rpc_mnt, &rpc_mount_count);
-}
-EXPORT_SYMBOL_GPL(rpc_put_mount);
-
 static int rpc_delete_dentry(const struct dentry *dentry)
 {
 	return 1;

