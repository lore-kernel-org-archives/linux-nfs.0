Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:8462 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754685Ab1KWKxV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Nov 2011 05:53:21 -0500
Subject: [PATCH 5/6] SUNRPC: remove RPC pipefs mount point manipulations from
	RPC clients code
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, davem@davemloft.net, devel@openvz.org
Date: Wed, 23 Nov 2011 14:51:56 +0300
Message-ID: <20111123105156.11077.88391.stgit@localhost6.localdomain6>
In-Reply-To: <20111123104945.11077.10270.stgit@localhost6.localdomain6>
References: <20111123104945.11077.10270.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now, with RPC pipefs mount notifications handling in RPC clients, we can remove
mount point creation and destruction. RPC clients dentries will be created on
PipeFS mount event and removed on umount event.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/clnt.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 23776a4..eb2595f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -112,7 +112,6 @@ static void rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
 		__rpc_clnt_remove_pipedir(clnt);
 		rpc_put_sb_net(clnt->cl_xprt->xprt_net);
 	}
-	rpc_put_mount();
 }
 
 static struct dentry *rpc_setup_pipedir_sb(struct super_block *sb,
@@ -158,21 +157,13 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
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

