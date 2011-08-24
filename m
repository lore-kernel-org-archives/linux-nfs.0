Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39239 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753930Ab1HXSfB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Aug 2011 14:35:01 -0400
Subject: [PATCH 1/5] SUNRPC: introduce helpers for reference counted rpcbind
	clients
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Wed, 24 Aug 2011 22:33:44 +0400
Message-ID: <20110824183344.4924.33065.stgit@localhost6.localdomain6>
In-Reply-To: <20110824183304.4924.94670.stgit@localhost6.localdomain6>
References: <20110824183304.4924.94670.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This helpers will be used for dynamical creation and destruction of rpcbind
clients.
Variable rpcb_users is actually a counter of lauched RPC services. If rpcbind
client has been created already, then we just increase rpcb_users.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpcb_clnt.c |   51 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index e45d2fb..c84e6a3 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
 static struct rpc_clnt *	rpcb_local_clnt;
 static struct rpc_clnt *	rpcb_local_clnt4;
 
+DEFINE_SPINLOCK(rpcb_clnt_lock);
+unsigned int			rpcb_users;
+
 struct rpcbind_args {
 	struct rpc_xprt *	r_xprt;
 
@@ -161,6 +164,54 @@ static void rpcb_map_release(void *data)
 	kfree(map);
 }
 
+static int rpcb_get_local(void)
+{
+	spin_lock(&rpcb_clnt_lock);
+	if (rpcb_users)
+		rpcb_users++;
+	spin_unlock(&rpcb_clnt_lock);
+
+	return rpcb_users;
+}
+
+void rpcb_put_local(void)
+{
+	struct rpc_clnt *clnt = rpcb_local_clnt;
+	struct rpc_clnt *clnt4 = rpcb_local_clnt4;
+	int shutdown;
+
+	spin_lock(&rpcb_clnt_lock);
+	if (--rpcb_users == 0) {
+		rpcb_local_clnt = NULL;
+		rpcb_local_clnt4 = NULL;
+	}
+	shutdown = !rpcb_users;
+	spin_unlock(&rpcb_clnt_lock);
+
+	if (shutdown) {
+		/*
+		 * cleanup_rpcb_clnt - remove xprtsock's sysctls, unregister
+		 */
+		if (clnt4)
+			rpc_shutdown_client(clnt4);
+		if (clnt)
+			rpc_shutdown_client(clnt);
+	}
+	return;
+}
+
+static void rpcb_set_local(struct rpc_clnt *clnt, struct rpc_clnt *clnt4)
+{
+	/* Protected by rpcb_create_local_mutex */
+	rpcb_local_clnt = clnt;
+	rpcb_local_clnt4 = clnt4;
+	rpcb_users++;
+	dprintk("RPC:       created new rpcb local clients (rpcb_local_clnt: "
+			"0x%p, rpcb_local_clnt4: 0x%p)\n", rpcb_local_clnt,
+			rpcb_local_clnt4);
+
+}
+
 /*
  * Returns zero on success, otherwise a negative errno value
  * is returned.

