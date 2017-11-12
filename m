Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37156 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750800AbdKLTb3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 12 Nov 2017 14:31:29 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v5 09/13] nfs client: exit_net cleanup check added
To: netdev@vger.kernel.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
References: <cb06dace-88a8-fecf-92ad-02920920a0d3@virtuozzo.com>
Message-ID: <d3c76264-5fdb-be03-98fe-b4ce09247165@virtuozzo.com>
Date: Sun, 12 Nov 2017 22:31:20 +0300
MIME-Version: 1.0
In-Reply-To: <cb06dace-88a8-fecf-92ad-02920920a0d3@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Be sure that nfs_client_list and nfs_volume_list lists initialized
in net_init hook were return to initial state in net_exit hook.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs/inode.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 134d9f5..4ef515f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2084,8 +2084,12 @@ static int nfs_net_init(struct net *net)
 
 static void nfs_net_exit(struct net *net)
 {
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
+
 	nfs_fs_proc_net_exit(net);
 	nfs_cleanup_cb_ident_idr(net);
+	WARN_ON_ONCE(!list_empty(&nn->nfs_client_list));
+	WARN_ON_ONCE(!list_empty(&nn->nfs_volume_list));
 }
 
 static struct pernet_operations nfs_net_ops = {
-- 
2.7.4

