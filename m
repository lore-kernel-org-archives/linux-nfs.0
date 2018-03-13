Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-he1eur01on0115.outbound.protection.outlook.com ([104.47.0.115]:45945
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932791AbeCMKuD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Mar 2018 06:50:03 -0400
Subject: [PATCH net-next nfs 5/6] net: Convert nfs4blocklayout_net_ops
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: davem@davemloft.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@kernel.org, dhowells@redhat.com, ktkhai@virtuozzo.com,
        keescook@chromium.org, dwindsor@gmail.com, ishkamiel@gmail.com,
        elena.reshetova@intel.com, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org
Date: Tue, 13 Mar 2018 13:49:58 +0300
Message-ID: <152093819834.8636.8992014016092587849.stgit@localhost.localdomain>
In-Reply-To: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These pernet_operations create and destroy per-net pipe
and dentry, and they seem safe to be marked as async.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/nfs/blocklayout/rpc_pipefs.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/blocklayout/rpc_pipefs.c b/fs/nfs/blocklayout/rpc_pipefs.c
index 9fb067a6f7e0..ef9fa111b009 100644
--- a/fs/nfs/blocklayout/rpc_pipefs.c
+++ b/fs/nfs/blocklayout/rpc_pipefs.c
@@ -261,6 +261,7 @@ static void nfs4blocklayout_net_exit(struct net *net)
 static struct pernet_operations nfs4blocklayout_net_ops = {
 	.init = nfs4blocklayout_net_init,
 	.exit = nfs4blocklayout_net_exit,
+	.async = true,
 };
 
 int __init bl_init_pipefs(void)

