Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3595 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752769AbdKFN0K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Nov 2017 08:26:10 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 21/21] sunrpc: exit_net cleanup check added
To: netdev@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
References: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
Message-ID: <050f4168-80da-70a6-3bc7-6b60b46ac2a7@virtuozzo.com>
Date: Mon, 6 Nov 2017 16:26:01 +0300
MIME-Version: 1.0
In-Reply-To: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Be sure that all_clients list initialized in net_init hook was return
to initial state.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/sunrpc/sunrpc_syms.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index c73de18..3ee6d8e 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -65,10 +65,15 @@ static __net_init int sunrpc_init_net(struct net *net)
 
 static __net_exit void sunrpc_exit_net(struct net *net)
 {
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+
 	rpc_pipefs_exit_net(net);
 	unix_gid_cache_destroy(net);
 	ip_map_cache_destroy(net);
 	rpc_proc_exit(net);
+	WARN_ONCE(!list_empty(&sn->all_clients),
+		  "net %x %s: all_clients list is not empty\n",
+		  net->ns.inum, __func__);
 }
 
 static struct pernet_operations sunrpc_net_ops = {
-- 
2.7.4

