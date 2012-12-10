Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:41616 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753820Ab2LJJSj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2012 04:18:39 -0500
Subject: [PATCH 3/7] nfsd: pass net to nfsd_startup() and nfsd_shutdown()
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 10 Dec 2012 12:19:14 +0300
Message-ID: <20121210091914.8855.60002.stgit@localhost.localdomain>
In-Reply-To: <20121210091832.8855.26672.stgit@localhost.localdomain>
References: <20121210091832.8855.26672.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Precursor patch. Hard-coded "init_net" will be replaced by proper one in
future.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfssvc.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 9fd8496..21cba3d 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -203,10 +203,9 @@ static int nfsd_init_socks(struct net *net)
 
 static bool nfsd_up = false;
 
-static int nfsd_startup(int nrservs)
+static int nfsd_startup(int nrservs, struct net *net)
 {
 	int ret;
-	struct net *net = &init_net;
 
 	if (nfsd_up)
 		return 0;
@@ -237,16 +236,14 @@ static int nfsd_startup(int nrservs)
 out_net_state:
 	nfs4_state_shutdown();
 out_lockd:
-	lockd_down(&init_net);
+	lockd_down(net);
 out_racache:
 	nfsd_racache_shutdown();
 	return ret;
 }
 
-static void nfsd_shutdown(void)
+static void nfsd_shutdown(struct net *net)
 {
-	struct net *net = &init_net;
-
 	/*
 	 * write_ports can create the server without actually starting
 	 * any threads--if we get shut down before any threads are
@@ -264,7 +261,7 @@ static void nfsd_shutdown(void)
 
 static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 {
-	nfsd_shutdown();
+	nfsd_shutdown(net);
 
 	svc_rpcb_cleanup(serv, net);
 
@@ -468,7 +465,7 @@ nfsd_svc(int nrservs)
 
 	nfsd_up_before = nfsd_up;
 
-	error = nfsd_startup(nrservs);
+	error = nfsd_startup(nrservs, net);
 	if (error)
 		goto out_destroy;
 	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
@@ -481,7 +478,7 @@ nfsd_svc(int nrservs)
 	error = nfsd_serv->sv_nrthreads - 1;
 out_shutdown:
 	if (error < 0 && !nfsd_up_before)
-		nfsd_shutdown();
+		nfsd_shutdown(net);
 out_destroy:
 	nfsd_destroy(net);		/* Release server */
 out:

