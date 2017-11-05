Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7002 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750731AbdKEQwS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 5 Nov 2017 11:52:18 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v2 21/21] sunrpc: exit_net cleanup check added
To: netdev@vger.kernel.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <bafb347d-e36e-8b2b-7646-afc458a7a32a@virtuozzo.com>
Message-ID: <ccbaed5b-39dd-7889-8428-57a227b4a2a7@virtuozzo.com>
Date: Sun, 5 Nov 2017 19:52:05 +0300
MIME-Version: 1.0
In-Reply-To: <bafb347d-e36e-8b2b-7646-afc458a7a32a@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Be sure that all_clients list initialized in net_init hook was return
to initial state.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/sunrpc/sunrpc_syms.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index c73de18..4a25658 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -65,10 +65,14 @@ static __net_init int sunrpc_init_net(struct net *net)
 
 static __net_exit void sunrpc_exit_net(struct net *net)
 {
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+
 	rpc_pipefs_exit_net(net);
 	unix_gid_cache_destroy(net);
 	ip_map_cache_destroy(net);
 	rpc_proc_exit(net);
+	WARN(!list_empty(&sn->all_clients),
+	     "%s: all_clients list is not empty\n", __func__);
 }
 
 static struct pernet_operations sunrpc_net_ops = {
-- 
2.7.4

