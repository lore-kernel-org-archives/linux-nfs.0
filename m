Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:21896 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758576Ab2DYNiC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 09:38:02 -0400
Subject: [PATCH 2/3] SUNRPC: check rpcbind clients usage counter before
 decrement
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 25 Apr 2012 17:37:49 +0400
Message-ID: <20120425133749.13800.24003.stgit@localhost6.localdomain6>
In-Reply-To: <20120425132314.13800.6813.stgit@localhost6.localdomain6>
References: <20120425132314.13800.6813.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Registering service with svc_bind() can fail. In this case service will be
destroyed and during destruction it will try to unregister itself from rpcbind.
In this case unregister have to be skipped.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpcb_clnt.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 78ac39f..4c38b33 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -180,14 +180,16 @@ void rpcb_put_local(struct net *net)
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	struct rpc_clnt *clnt = sn->rpcb_local_clnt;
 	struct rpc_clnt *clnt4 = sn->rpcb_local_clnt4;
-	int shutdown;
+	int shutdown = 0;
 
 	spin_lock(&sn->rpcb_clnt_lock);
-	if (--sn->rpcb_users == 0) {
-		sn->rpcb_local_clnt = NULL;
-		sn->rpcb_local_clnt4 = NULL;
+	if (sn->rpcb_users) {
+		if (--sn->rpcb_users == 0) {
+			sn->rpcb_local_clnt = NULL;
+			sn->rpcb_local_clnt4 = NULL;
+		}
+		shutdown = !sn->rpcb_users;
 	}
-	shutdown = !sn->rpcb_users;
 	spin_unlock(&sn->rpcb_clnt_lock);
 
 	if (shutdown) {

