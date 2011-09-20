Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29889 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755638Ab1ITKO1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 06:14:27 -0400
Subject: [PATCH v4 4/8] SUNRPC: setup rpcbind clients if service requires it
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Tue, 20 Sep 2011 14:14:04 +0400
Message-ID: <20110920101404.9861.83097.stgit@localhost6.localdomain6>
In-Reply-To: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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
 net/sunrpc/svc.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index d2d61bf..918edc3 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -454,8 +454,15 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		spin_lock_init(&pool->sp_lock);
 	}
 
-	/* Remove any stale portmap registrations */
-	svc_unregister(serv);
+	if (svc_uses_rpcbind(serv)) {
+	       	if (svc_rpcb_setup(serv) < 0) {
+			kfree(serv->sv_pools);
+			kfree(serv);
+			return NULL;
+		}
+		if (!serv->sv_shutdown)
+			serv->sv_shutdown = svc_rpcb_cleanup;
+	}
 
 	return serv;
 }

