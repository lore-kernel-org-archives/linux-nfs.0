Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23580 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756199Ab1IMSOf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 14:14:35 -0400
Subject: [PATCH v3 07/11] NFS: avoid rpcbind clients creation during service
	creation
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Tue, 13 Sep 2011 22:14:14 +0400
Message-ID: <20110913181414.3961.88915.stgit@localhost6.localdomain6>
In-Reply-To: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
References: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFS callbacks doesn't communicate portmapper and thus doesn't need rpcbind
clients.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/callback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index e3d2942..2715c02 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -259,7 +259,7 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 		nfs_callback_bc_serv(minorversion, xprt, cb_info);
 		goto out;
 	}
-	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, NULL);
+	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, 0, NULL);
 	if (!serv) {
 		ret = -ENOMEM;
 		goto out_err;

