Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:28605 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753710Ab2B0Pv3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 10:51:29 -0500
Subject: [PATCH v2 2/4] NFS: release per-net clients lock before calling
 PipeFS dentries creation
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Mon, 27 Feb 2012 19:51:04 +0400
Message-ID: <20120227155103.7941.17006.stgit@localhost6.localdomain6>
In-Reply-To: <20120227154713.7941.17963.stgit@localhost6.localdomain6>
References: <20120227154713.7941.17963.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lockdep is sad otherwise, because inode mutex is taken on PipeFS dentry
creation, which can be called on mount notification, where this per-net client
lock is taken on clients list walk.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/client.c |    2 +-
 fs/nfs/idmap.c  |    8 ++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8563585..6aeb6b3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -538,7 +538,7 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 	/* install a new client and return with it unready */
 install_client:
 	clp = new;
-	list_add(&clp->cl_share_link, &nn->nfs_client_list);
+	list_add_tail(&clp->cl_share_link, &nn->nfs_client_list);
 	spin_unlock(&nn->nfs_client_lock);
 
 	error = cl_init->rpc_ops->init_client(clp, timeparms, ip_addr,
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index b5c6d8e..8a9e7a4 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -558,16 +558,20 @@ static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
 {
 	struct super_block *sb = ptr;
 	struct nfs_net *nn = net_generic(sb->s_fs_info, nfs_net_id);
-	struct nfs_client *clp;
+	struct nfs_client *clp, *tmp;
 	int error = 0;
 
 	spin_lock(&nn->nfs_client_lock);
-	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
+	list_for_each_entry_safe(clp, tmp, &nn->nfs_client_list, cl_share_link) {
 		if (clp->rpc_ops != &nfs_v4_clientops)
 			continue;
+		atomic_inc(&clp->cl_count);
+		spin_unlock(&nn->nfs_client_lock);
 		error = __rpc_pipefs_event(clp, event, sb);
+		nfs_put_client(clp);
 		if (error)
 			break;
+		spin_lock(&nn->nfs_client_lock);
 	}
 	spin_unlock(&nn->nfs_client_lock);
 	return error;

