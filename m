Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr00119.outbound.protection.outlook.com ([40.107.0.119]:41312
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932903AbeCMKtq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Mar 2018 06:49:46 -0400
Subject: [PATCH net-next nfs 3/6] net: Convert nfsd_net_ops
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: davem@davemloft.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@kernel.org, dhowells@redhat.com, ktkhai@virtuozzo.com,
        keescook@chromium.org, dwindsor@gmail.com, ishkamiel@gmail.com,
        elena.reshetova@intel.com, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org
Date: Tue, 13 Mar 2018 13:49:38 +0300
Message-ID: <152093817836.8636.15497529959872953849.stgit@localhost.localdomain>
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
 fs/nfsd/nfsctl.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d107b4426f7e..1e3824e6cce0 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1263,6 +1263,7 @@ static struct pernet_operations nfsd_net_ops = {
 	.exit = nfsd_exit_net,
 	.id   = &nfsd_net_id,
 	.size = sizeof(struct nfsd_net),
+	.async = true,
 };
 
 static int __init init_nfsd(void)

