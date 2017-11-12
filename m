Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:13709 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753052AbdKLIsw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 12 Nov 2017 03:48:52 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v4 15/18] sunrpc: exit_net cleanup check added
To: netdev@vger.kernel.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
References: <9dfa013e-9098-e155-9c47-a73753338288@virtuozzo.com>
Message-ID: <62a56880-3a6d-481e-7aec-5cf7cd2968e0@virtuozzo.com>
Date: Sun, 12 Nov 2017 11:48:43 +0300
MIME-Version: 1.0
In-Reply-To: <9dfa013e-9098-e155-9c47-a73753338288@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Be sure that all_clients list initialized in net_init hook was return
to initial state.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/sunrpc/sunrpc_syms.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index c73de18..56f9eff 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -65,10 +65,13 @@ static __net_init int sunrpc_init_net(struct net *net)
 
 static __net_exit void sunrpc_exit_net(struct net *net)
 {
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+
 	rpc_pipefs_exit_net(net);
 	unix_gid_cache_destroy(net);
 	ip_map_cache_destroy(net);
 	rpc_proc_exit(net);
+	WARN_ON_ONCE(!list_empty(&sn->all_clients));
 }
 
 static struct pernet_operations sunrpc_net_ops = {
-- 
2.7.4

