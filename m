Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-he1eur01on0109.outbound.protection.outlook.com ([104.47.0.109]:45655
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932791AbeCMKtz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Mar 2018 06:49:55 -0400
Subject: [PATCH net-next nfs 4/6] net: Convert nfs4_dns_resolver_ops
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: davem@davemloft.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@kernel.org, dhowells@redhat.com, ktkhai@virtuozzo.com,
        keescook@chromium.org, dwindsor@gmail.com, ishkamiel@gmail.com,
        elena.reshetova@intel.com, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org
Date: Tue, 13 Mar 2018 13:49:48 +0300
Message-ID: <152093818835.8636.5993458301872634002.stgit@localhost.localdomain>
In-Reply-To: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These pernet_operations look similar to rpcsec_gss_net_ops,
they just create and destroy another cache. Also they create
and destroy directory. So, they also look safe to be async.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/nfs/dns_resolve.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 060c658eab66..e90bd69ab653 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -410,6 +410,7 @@ static void nfs4_dns_net_exit(struct net *net)
 static struct pernet_operations nfs4_dns_resolver_ops = {
 	.init = nfs4_dns_net_init,
 	.exit = nfs4_dns_net_exit,
+	.async = true,
 };
 
 static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,

