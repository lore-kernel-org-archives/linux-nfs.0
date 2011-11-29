Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:14598 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753561Ab1K2JMg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Nov 2011 04:12:36 -0500
Subject: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference from
	blocklayout routines
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 29 Nov 2011 13:10:37 +0300
Message-ID: <20111129091037.20730.59391.stgit@localhost6.localdomain6>
In-Reply-To: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cleanup patch. We don't need this reference anymore, because
blocklayout pipes dentries now creates and destroys in per-net operations and
on PipeFS mount/umount notification.
Note that nfs4blocklayout_register_net() now returns 0 instead of -ENOENT in
case of PipeFS superblock absence. This is ok, because blocklayout pipe dentry
will be created on PipeFS mount event.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/blocklayout/blocklayout.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index acf7ac9..8211ffd 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1032,7 +1032,7 @@ static struct dentry *nfs4blocklayout_register_net(struct net *net,
 
 	pipefs_sb = rpc_get_sb_net(net);
 	if (!pipefs_sb)
-		return ERR_PTR(-ENOENT);
+		return 0;
 	dentry = nfs4blocklayout_register_sb(pipefs_sb, pipe);
 	rpc_put_sb_net(net);
 	return dentry;
@@ -1083,7 +1083,6 @@ static struct pernet_operations nfs4blocklayout_net_ops = {
 
 static int __init nfs4blocklayout_init(void)
 {
-	struct vfsmount *mnt;
 	int ret;
 
 	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
@@ -1093,12 +1092,6 @@ static int __init nfs4blocklayout_init(void)
 		goto out;
 
 	init_waitqueue_head(&bl_wq);
-
-	mnt = rpc_get_mount();
-	if (IS_ERR(mnt)) {
-		ret = PTR_ERR(mnt);
-		goto out_remove;
-	}
 	ret = rpc_pipefs_notifier_register(&nfs4blocklayout_block);
 	if (ret)
 		goto out_remove;

