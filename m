Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ve1eur01on0125.outbound.protection.outlook.com ([104.47.1.125]:45121
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932772AbeCMKt1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Mar 2018 06:49:27 -0400
Subject: [PATCH net-next nfs 1/6] net: Convert rpcsec_gss_net_ops
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: davem@davemloft.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@kernel.org, dhowells@redhat.com, ktkhai@virtuozzo.com,
        keescook@chromium.org, dwindsor@gmail.com, ishkamiel@gmail.com,
        elena.reshetova@intel.com, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org
Date: Tue, 13 Mar 2018 13:49:15 +0300
Message-ID: <152093815494.8636.6607369744413088370.stgit@localhost.localdomain>
In-Reply-To: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These pernet_operations initialize and destroy sunrpc_net_id
refered per-net items. Only used global list is cache_list,
and accesses already serialized.

sunrpc_destroy_cache_detail() check for list_empty() without
cache_list_lock, but when it's called from unregister_pernet_subsys(),
there can't be callers in parallel, so we won't miss list_empty()
in this case.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 net/sunrpc/auth_gss/auth_gss.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 9463af4b32e8..44f939cb6bc8 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -2063,6 +2063,7 @@ static __net_exit void rpcsec_gss_exit_net(struct net *net)
 static struct pernet_operations rpcsec_gss_net_ops = {
 	.init = rpcsec_gss_init_net,
 	.exit = rpcsec_gss_exit_net,
+	.async = true,
 };
 
 /*

