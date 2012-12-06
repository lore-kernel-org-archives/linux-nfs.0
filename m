Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:9866 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751676Ab2LFLWf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 06:22:35 -0500
Subject: [PATCH 1/8] nfsd: move per-net startup code to separated function
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 14:23:09 +0300
Message-ID: <20121206112309.29559.7502.stgit@localhost.localdomain>
In-Reply-To: <20121206111903.29559.4853.stgit@localhost.localdomain>
References: <20121206111903.29559.4853.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSd resources are partially per-net and partially globally used.
This patch splits resources init and shutdown and moves per-net code to
separated functions.
Generic and per-net init and shutdown are called sequentially for a while.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfssvc.c |   48 +++++++++++++++++++++++++++++++++---------------
 1 files changed, 33 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index b144658..038348b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -203,6 +203,27 @@ static int nfsd_init_socks(struct net *net)
 
 static bool nfsd_up = false;
 
+static int nfsd_startup_net(struct net *net)
+{
+	int ret;
+
+	ret = nfsd_init_socks(net);
+	if (ret)
+		return ret;
+	ret = lockd_up(net);
+	if (ret)
+		return ret;
+	ret = nfs4_state_start_net(net);
+	if (ret)
+		goto out_lockd;
+
+	return 0;
+
+out_lockd:
+	lockd_down(net);
+	return ret;
+}
+
 static int nfsd_startup(int nrservs, struct net *net)
 {
 	int ret;
@@ -217,31 +238,29 @@ static int nfsd_startup(int nrservs, struct net *net)
 	ret = nfsd_racache_init(2*nrservs);
 	if (ret)
 		return ret;
-	ret = nfsd_init_socks(net);
-	if (ret)
-		goto out_racache;
-	ret = lockd_up(net);
-	if (ret)
-		goto out_racache;
 	ret = nfs4_state_start();
 	if (ret)
-		goto out_lockd;
-
-	ret = nfs4_state_start_net(net);
+		goto out_racache;
+	ret = nfsd_startup_net(net);
 	if (ret)
-		goto out_net_state;
+		goto out_net;
 
 	nfsd_up = true;
 	return 0;
-out_net_state:
+
+out_net:
 	nfs4_state_shutdown();
-out_lockd:
-	lockd_down(net);
 out_racache:
 	nfsd_racache_shutdown();
 	return ret;
 }
 
+static void nfsd_shutdown_net(struct net *net)
+{
+	nfs4_state_shutdown_net(net);
+	lockd_down(net);
+}
+
 static void nfsd_shutdown(struct net *net)
 {
 	/*
@@ -252,9 +271,8 @@ static void nfsd_shutdown(struct net *net)
 	 */
 	if (!nfsd_up)
 		return;
-	nfs4_state_shutdown_net(net);
+	nfsd_shutdown_net(net);
 	nfs4_state_shutdown();
-	lockd_down(net);
 	nfsd_racache_shutdown();
 	nfsd_up = false;
 }

