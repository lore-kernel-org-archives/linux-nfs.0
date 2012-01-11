Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:34716 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933472Ab2AKPSw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jan 2012 10:18:52 -0500
Subject: [PATCH v2 5/6] SUNRPC: remove RPC pipefs mount point manipulations
 from RPC clients code
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 11 Jan 2012 19:18:34 +0400
Message-ID: <20120111151834.5891.17329.stgit@localhost6.localdomain6>
In-Reply-To: <20120111151051.5891.1830.stgit@localhost6.localdomain6>
References: <20120111151051.5891.1830.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
1) Updated due to changes in the first patch of the series.

Now, with RPC pipefs mount notifications handling in RPC clients, we can remove
mount point creation and destruction. RPC clients dentries will be created on
PipeFS mount event and removed on umount event.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/clnt.c |   19 +++----------------
 1 files changed, 3 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c89ceb8..e3ced30 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -109,17 +109,12 @@ static void __rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
 static void rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
 {
 	struct super_block *pipefs_sb;
-	int put_mnt = 0;
 
 	pipefs_sb = rpc_get_sb_net(clnt->cl_xprt->xprt_net);
 	if (pipefs_sb) {
-		if (clnt->cl_path.dentry)
-			put_mnt = 1;
 		__rpc_clnt_remove_pipedir(clnt);
 		rpc_put_sb_net(clnt->cl_xprt->xprt_net);
 	}
-	if (put_mnt)
-		rpc_put_mount();
 }
 
 static struct dentry *rpc_setup_pipedir_sb(struct super_block *sb,
@@ -165,21 +160,13 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 	clnt->cl_path.dentry = NULL;
 	if (dir_name == NULL)
 		return 0;
-
-	path.mnt = rpc_get_mount();
-	if (IS_ERR(path.mnt))
-		return PTR_ERR(path.mnt);
 	pipefs_sb = rpc_get_sb_net(clnt->cl_xprt->xprt_net);
-	if (!pipefs_sb) {
-		rpc_put_mount();
-		return -ENOENT;
-	}
+	if (!pipefs_sb)
+		return 0;
 	path.dentry = rpc_setup_pipedir_sb(pipefs_sb, clnt, dir_name);
 	rpc_put_sb_net(clnt->cl_xprt->xprt_net);
-	if (IS_ERR(path.dentry)) {
-		rpc_put_mount();
+	if (IS_ERR(path.dentry))
 		return PTR_ERR(path.dentry);
-	}
 	clnt->cl_path = path;
 	return 0;
 }

