Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38167 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753052AbdKLIsZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 12 Nov 2017 03:48:25 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v4 14/18] nfs client: exit_net cleanup check added
To: netdev@vger.kernel.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
References: <9dfa013e-9098-e155-9c47-a73753338288@virtuozzo.com>
Message-ID: <6b79f4c2-95de-9df2-7403-060b12ff2c03@virtuozzo.com>
Date: Sun, 12 Nov 2017 11:48:16 +0300
MIME-Version: 1.0
In-Reply-To: <9dfa013e-9098-e155-9c47-a73753338288@virtuozzo.com>
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

