Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:19583 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754751Ab2EVHhP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 03:37:15 -0400
Subject: [PATCH v2 11/12] Signed-off-by: Stanislav Kinsbursky
	<skinsbursky@parallels.com>
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 22 May 2012 11:37:09 +0400
Message-ID: <20120522073709.20602.33027.stgit@localhost.localdomain>
In-Reply-To: <20120522073320.20602.87130.stgit@localhost.localdomain>
References: <20120522073320.20602.87130.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: root (none) <root@sighted>


---
 fs/nfs/client.c |    4 +++-
 fs/nfs/idmap.c  |    5 ++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 44cd70f..ae29d4f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -176,8 +176,10 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 
 #ifdef CONFIG_NFS_V4
 	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
-	if (err)
+	if (err) {
+		put_net(clp->net);
 		goto error_cleanup;
+	}
 
 	spin_lock_init(&clp->cl_lock);
 	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index b7f348b..c9c3e1b 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -487,7 +487,7 @@ nfs_idmap_delete(struct nfs_client *clp)
 	kfree(idmap);
 }
 
-static int __rpc_pipefs_event(struct nfs_client *clp, unsigned long event,
+static noinline int __rpc_pipefs_event(struct nfs_client *clp, unsigned long event,
 			      struct super_block *sb)
 {
 	int err = 0;
@@ -533,8 +533,11 @@ static struct nfs_client *nfs_get_client_for_event(struct net *net, int event)
 
 	spin_lock(&nn->nfs_client_lock);
 	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
+		BUG_ON(atomic_read(&clp->cl_count) == 0);
 		if (clp->rpc_ops != &nfs_v4_clientops)
 			continue;
+		BUG_ON(clp->cl_idmap == NULL);
+		BUG_ON(clp->cl_idmap->idmap_pipe == NULL);
 		cl_dentry = clp->cl_idmap->idmap_pipe->dentry;
 		if (((event == RPC_PIPEFS_MOUNT) && cl_dentry) ||
 		    ((event == RPC_PIPEFS_UMOUNT) && !cl_dentry))

