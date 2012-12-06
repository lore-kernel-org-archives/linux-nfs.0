Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:29654 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423193Ab2LFLWz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 06:22:55 -0500
Subject: [PATCH 5/8] nfsd: introduce helpers for generic resources init and
	shutdown
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 14:23:29 +0300
Message-ID: <20121206112329.29559.66447.stgit@localhost.localdomain>
In-Reply-To: <20121206111903.29559.4853.stgit@localhost.localdomain>
References: <20121206111903.29559.4853.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSd have per-net resources and resources, used globally.
Let's move generic resources init and shutdown to separated functions since
they are going to be allocated on first NFSd service start and destroyed after
last NFSd service shutdown.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfssvc.c |   50 ++++++++++++++++++++++++++++++++++----------------
 1 files changed, 34 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 0e8622a..f9d147f 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -206,6 +206,37 @@ static int nfsd_init_socks(struct net *net)
 
 static bool nfsd_up = false;
 
+static int nfsd_startup_generic(int nrservs)
+{
+	int ret;
+
+	if (nfsd_up)
+		return 0;
+
+	/*
+	 * Readahead param cache - will no-op if it already exists.
+	 * (Note therefore results will be suboptimal if number of
+	 * threads is modified after nfsd start.)
+	 */
+	ret = nfsd_racache_init(2*nrservs);
+	if (ret)
+		return ret;
+	ret = nfs4_state_start();
+	if (ret)
+		goto out_racache;
+	return 0;
+
+out_racache:
+	nfsd_racache_shutdown();
+	return ret;
+}
+
+static void nfsd_shutdown_generic(void)
+{
+	nfs4_state_shutdown();
+	nfsd_racache_shutdown();
+}
+
 static int nfsd_startup_net(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
@@ -236,19 +267,9 @@ static int nfsd_startup(int nrservs, struct net *net)
 {
 	int ret;
 
-	if (nfsd_up)
-		return 0;
-	/*
-	 * Readahead param cache - will no-op if it already exists.
-	 * (Note therefore results will be suboptimal if number of
-	 * threads is modified after nfsd start.)
-	 */
-	ret = nfsd_racache_init(2*nrservs);
+	ret = nfsd_startup_generic(nrservs);
 	if (ret)
 		return ret;
-	ret = nfs4_state_start();
-	if (ret)
-		goto out_racache;
 	ret = nfsd_startup_net(net);
 	if (ret)
 		goto out_net;
@@ -257,9 +278,7 @@ static int nfsd_startup(int nrservs, struct net *net)
 	return 0;
 
 out_net:
-	nfs4_state_shutdown();
-out_racache:
-	nfsd_racache_shutdown();
+	nfsd_shutdown_generic();
 	return ret;
 }
 
@@ -286,8 +305,7 @@ static void nfsd_shutdown(struct net *net)
 	if (!nfsd_up)
 		return;
 	nfsd_shutdown_net(net);
-	nfs4_state_shutdown();
-	nfsd_racache_shutdown();
+	nfsd_shutdown_generic();
 	nfsd_up = false;
 }
 

