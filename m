Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4711 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753039AbdKFNY1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Nov 2017 08:24:27 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 07/21] nfs4blocklayout: exit_net cleanup check added
To: netdev@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
References: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
Message-ID: <87a33322-18a9-a451-e69a-505eddb99333@virtuozzo.com>
Date: Mon, 6 Nov 2017 16:24:14 +0300
MIME-Version: 1.0
In-Reply-To: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Be sure that bl_wq wait queue initialized in net_init hook
is not used anymore.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs/blocklayout/rpc_pipefs.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/blocklayout/rpc_pipefs.c b/fs/nfs/blocklayout/rpc_pipefs.c
index 9fb067a6..8c3941b 100644
--- a/fs/nfs/blocklayout/rpc_pipefs.c
+++ b/fs/nfs/blocklayout/rpc_pipefs.c
@@ -256,6 +256,9 @@ static void nfs4blocklayout_net_exit(struct net *net)
 	nfs4blocklayout_unregister_net(net, nn->bl_device_pipe);
 	rpc_destroy_pipe_data(nn->bl_device_pipe);
 	nn->bl_device_pipe = NULL;
+	WARN_ONCE(!list_empty(&nn->bl_wq.head),
+		  "net %x %s: bl_wq head is not empty\n",
+		  net->ns.inum, __func__);
 }
 
 static struct pernet_operations nfs4blocklayout_net_ops = {
-- 
2.7.4

