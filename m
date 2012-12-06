Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:20237 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423191Ab2LFLXB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 06:23:01 -0500
Subject: [PATCH 6/8] nfsd: simplify NFSv4 state init and shutdown
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 14:23:34 +0300
Message-ID: <20121206112334.29559.58420.stgit@localhost.localdomain>
In-Reply-To: <20121206111903.29559.4853.stgit@localhost.localdomain>
References: <20121206111903.29559.4853.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch moves nfsd_startup_generic() and nfsd_shutdown_generic() calls to
nfsd_startup_net() and nfsd_shutdown_net() respectively, which allow to call
nfsd_startup_net() instead of nfsd_startup() and makes code looks clearer.
It alos modifies nfsd_svc() and nfsd_shutdown() to check for nn->nfsd_net_up
variable instead of global nfsd_up.
Last one is now used only generic resources shutdown and currently useless.
But it will replaced by NFSd users counter later in this series.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfssvc.c |   44 +++++++++++++++-----------------------------
 1 files changed, 15 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index f9d147f..0c87b4e 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -235,9 +235,10 @@ static void nfsd_shutdown_generic(void)
 {
 	nfs4_state_shutdown();
 	nfsd_racache_shutdown();
+	nfsd_up = false;
 }
 
-static int nfsd_startup_net(struct net *net)
+static int nfsd_startup_net(int nrservs, struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	int ret;
@@ -245,39 +246,26 @@ static int nfsd_startup_net(struct net *net)
 	if (nn->nfsd_net_up)
 		return 0;
 
-	ret = nfsd_init_socks(net);
+	ret = nfsd_startup_generic(nrservs);
 	if (ret)
 		return ret;
+	ret = nfsd_init_socks(net);
+	if (ret)
+		goto out_socks;
 	ret = lockd_up(net);
 	if (ret)
-		return ret;
+		goto out_socks;
 	ret = nfs4_state_start_net(net);
 	if (ret)
 		goto out_lockd;
 
 	nn->nfsd_net_up = true;
+	nfsd_up = true;
 	return 0;
 
 out_lockd:
 	lockd_down(net);
-	return ret;
-}
-
-static int nfsd_startup(int nrservs, struct net *net)
-{
-	int ret;
-
-	ret = nfsd_startup_generic(nrservs);
-	if (ret)
-		return ret;
-	ret = nfsd_startup_net(net);
-	if (ret)
-		goto out_net;
-
-	nfsd_up = true;
-	return 0;
-
-out_net:
+out_socks:
 	nfsd_shutdown_generic();
 	return ret;
 }
@@ -286,27 +274,25 @@ static void nfsd_shutdown_net(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	if (!nn->nfsd_net_up)
-		return;
-
 	nfs4_state_shutdown_net(net);
 	lockd_down(net);
 	nn->nfsd_net_up = false;
+	nfsd_shutdown_generic();
 }
 
 static void nfsd_shutdown(struct net *net)
 {
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
 	/*
 	 * write_ports can create the server without actually starting
 	 * any threads--if we get shut down before any threads are
 	 * started, then nfsd_last_thread will be run before any of this
 	 * other initialization has been done.
 	 */
-	if (!nfsd_up)
+	if (!nn->nfsd_net_up)
 		return;
 	nfsd_shutdown_net(net);
-	nfsd_shutdown_generic();
-	nfsd_up = false;
 }
 
 static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
@@ -528,9 +514,9 @@ nfsd_svc(int nrservs, struct net *net)
 	if (error)
 		goto out;
 
-	nfsd_up_before = nfsd_up;
+	nfsd_up_before = nn->nfsd_net_up;
 
-	error = nfsd_startup(nrservs, net);
+	error = nfsd_startup_net(nrservs, net);
 	if (error)
 		goto out_destroy;
 	error = svc_set_num_threads(nn->nfsd_serv, NULL, nrservs);

