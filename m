Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:15496 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932229Ab1J1Kwf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 06:52:35 -0400
Subject: [PATCH v7 4/7] SUNRPC: setup rpcbind clients if service requires it
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
Date: Fri, 28 Oct 2011 14:53:18 +0300
Message-ID: <20111028105307.24628.89889.stgit@localhost6.localdomain6>
In-Reply-To: <20111028104530.24628.23631.stgit@localhost6.localdomain6>
References: <20111028104530.24628.23631.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

New function ("svc_uses_rpcbind") will be used to detect, that new service will
send portmapper register calls. For such services we will create rpcbind
clients and remove all stale portmap registrations.
Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for such services
in case of this field wasn't initialized earlier. This will allow to destroy
rpcbind clients when no other users of them left.

Note: Currently, any creating service will be detected as portmap user.
Probably, this is wrong. But now it depends on program versions "vs_hidden"
flag.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/svc.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index d2d61bf..87a67b2 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -436,10 +436,8 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	serv->sv_pools =
 		kcalloc(serv->sv_nrpools, sizeof(struct svc_pool),
 			GFP_KERNEL);
-	if (!serv->sv_pools) {
-		kfree(serv);
-		return NULL;
-	}
+	if (!serv->sv_pools)
+		goto err_serv;
 
 	for (i = 0; i < serv->sv_nrpools; i++) {
 		struct svc_pool *pool = &serv->sv_pools[i];
@@ -454,10 +452,20 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		spin_lock_init(&pool->sp_lock);
 	}
 
-	/* Remove any stale portmap registrations */
-	svc_unregister(serv);
+	if (svc_uses_rpcbind(serv)) {
+	       	if (svc_rpcb_setup(serv) < 0)
+			goto err_rpcb;
+		if (!serv->sv_shutdown)
+			serv->sv_shutdown = svc_rpcb_cleanup;
+	}
 
 	return serv;
+
+err_rpcb:
+	kfree(serv->sv_pools);
+err_serv:
+	kfree(serv);
+	return NULL;
 }
 
 struct svc_serv *

