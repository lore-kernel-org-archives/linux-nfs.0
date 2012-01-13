Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:44077 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932097Ab2AMKDV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 05:03:21 -0500
Subject: [PATCH v2 3/4] SUNRPC: register service on creation in current
 network namespace
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 13 Jan 2012 14:02:56 +0400
Message-ID: <20120113100256.12259.43503.stgit@localhost6.localdomain6>
In-Reply-To: <20120113095121.12259.52250.stgit@localhost6.localdomain6>
References: <20120113095121.12259.52250.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Service, using rpcbind (Lockd, NFSd) are starting from userspace call and thus
we can use current network namespace.
There could be a problem with NFSd service, because it's creation can be called
through NFSd fs from different network namespace. But this is a part of "NFSd
per net ns" task and will be fixed in future.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/svc.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 03d2dfc..b2cc1b3 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -20,6 +20,7 @@
 #include <linux/module.h>
 #include <linux/kthread.h>
 #include <linux/slab.h>
+#include <linux/nsproxy.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
@@ -366,16 +367,16 @@ svc_pool_for_cpu(struct svc_serv *serv, int cpu)
 	return &serv->sv_pools[pidx % serv->sv_nrpools];
 }
 
-static int svc_rpcb_setup(struct svc_serv *serv)
+static int svc_rpcb_setup(struct svc_serv *serv, struct net *net)
 {
 	int err;
 
-	err = rpcb_create_local(&init_net);
+	err = rpcb_create_local(net);
 	if (err)
 		return err;
 
 	/* Remove any stale portmap registrations */
-	svc_unregister(serv, &init_net);
+	svc_unregister(serv, net);
 	return 0;
 }
 
@@ -468,7 +469,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	}
 
 	if (svc_uses_rpcbind(serv)) {
-	       	if (svc_rpcb_setup(serv) < 0) {
+	       	if (svc_rpcb_setup(serv, current->nsproxy->net_ns) < 0) {
 			kfree(serv->sv_pools);
 			kfree(serv);
 			return NULL;

