Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ve1eur01on0100.outbound.protection.outlook.com ([104.47.1.100]:6748
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932885AbeCMKtg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Mar 2018 06:49:36 -0400
Subject: [PATCH net-next nfs 2/6] net: Convert sunrpc_net_ops
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: davem@davemloft.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@kernel.org, dhowells@redhat.com, ktkhai@virtuozzo.com,
        keescook@chromium.org, dwindsor@gmail.com, ishkamiel@gmail.com,
        elena.reshetova@intel.com, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org
Date: Tue, 13 Mar 2018 13:49:28 +0300
Message-ID: <152093816841.8636.4371549856827439735.stgit@localhost.localdomain>
In-Reply-To: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These pernet_operations look similar to rpcsec_gss_net_ops,
they just create and destroy another caches. So, they also
can be async.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 net/sunrpc/sunrpc_syms.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 56f9eff74150..68287e921847 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -79,6 +79,7 @@ static struct pernet_operations sunrpc_net_ops = {
 	.exit = sunrpc_exit_net,
 	.id = &sunrpc_net_id,
 	.size = sizeof(struct sunrpc_net),
+	.async = true,
 };
 
 static int __init

