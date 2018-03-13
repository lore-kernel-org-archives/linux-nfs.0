Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-he1eur01on0133.outbound.protection.outlook.com ([104.47.0.133]:7379
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932921AbeCMKuP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Mar 2018 06:50:15 -0400
Subject: [PATCH net-next nfs 6/6] net: Convert rxrpc_net_ops
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: davem@davemloft.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@kernel.org, dhowells@redhat.com, ktkhai@virtuozzo.com,
        keescook@chromium.org, dwindsor@gmail.com, ishkamiel@gmail.com,
        elena.reshetova@intel.com, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org
Date: Tue, 13 Mar 2018 13:50:06 +0300
Message-ID: <152093820653.8636.15794912193976988473.stgit@localhost.localdomain>
In-Reply-To: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These pernet_operations modifies rxrpc_net_id-pointed
per-net entities. There is external link to AF_RXRPC
in fs/afs/Kconfig, but it seems there is no other
pernet_operations interested in that per-net entities.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 net/rxrpc/net_ns.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/rxrpc/net_ns.c b/net/rxrpc/net_ns.c
index f18c9248e0d4..5fd939dabf41 100644
--- a/net/rxrpc/net_ns.c
+++ b/net/rxrpc/net_ns.c
@@ -106,4 +106,5 @@ struct pernet_operations rxrpc_net_ops = {
 	.exit	= rxrpc_exit_net,
 	.id	= &rxrpc_net_id,
 	.size	= sizeof(struct rxrpc_net),
+	.async	= true,
 };

