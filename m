Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7580 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752671AbdKEJ7s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 5 Nov 2017 04:59:48 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 05/21] nfs4blocklayout: exit_net cleanup check added
To: netdev@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Message-ID: <0724b082-28f9-9bda-f656-d22b3a2e0912@virtuozzo.com>
Date: Sun, 5 Nov 2017 12:59:46 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Be sure that bl_wq wait queue initialized in net_init hook
is not used anymore.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs/blocklayout/rpc_pipefs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/blocklayout/rpc_pipefs.c b/fs/nfs/blocklayout/rpc_pipefs.c
index 9fb067a6..fb732cf 100644
--- a/fs/nfs/blocklayout/rpc_pipefs.c
+++ b/fs/nfs/blocklayout/rpc_pipefs.c
@@ -256,6 +256,8 @@ static void nfs4blocklayout_net_exit(struct net *net)
 	nfs4blocklayout_unregister_net(net, nn->bl_device_pipe);
 	rpc_destroy_pipe_data(nn->bl_device_pipe);
 	nn->bl_device_pipe = NULL;
+	WARN(!list_empty(&nn->bl_wq.head),
+	     "net %p exit: nfs bl_wq head is not empty\n", net);
 }
 
 static struct pernet_operations nfs4blocklayout_net_ops = {
-- 
2.7.4

