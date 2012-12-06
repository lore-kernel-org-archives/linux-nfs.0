Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:9768 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423191Ab2LFLXL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 06:23:11 -0500
Subject: [PATCH 8/8] nfsd: simplify service shutdown
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 14:23:44 +0300
Message-ID: <20121206112344.29559.87559.stgit@localhost.localdomain>
In-Reply-To: <20121206111903.29559.4853.stgit@localhost.localdomain>
References: <20121206111903.29559.4853.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Function nfsd_shutdown is called from two places: nfsd_last_thread (when last
kernel thread is exiting) and nfsd_svc (in case of kthreads starting error).
When calling from nfsd_svc(), we can be sure that per-net resources are
allocated, so we don't need to check per-net nfsd_net_up boolean flag.
This allows us to remove nfsd_shutdown function at all and move check for
per-net nfsd_net_up boolean flag to nfsd_last_thread.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfssvc.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 5bb4a33..2cfd9c6 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -281,7 +281,7 @@ static void nfsd_shutdown_net(struct net *net)
 	nfsd_shutdown_generic();
 }
 
-static void nfsd_shutdown(struct net *net)
+static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
@@ -294,11 +294,6 @@ static void nfsd_shutdown(struct net *net)
 	if (!nn->nfsd_net_up)
 		return;
 	nfsd_shutdown_net(net);
-}
-
-static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
-{
-	nfsd_shutdown(net);
 
 	svc_rpcb_cleanup(serv, net);
 
@@ -530,7 +525,7 @@ nfsd_svc(int nrservs, struct net *net)
 	error = nn->nfsd_serv->sv_nrthreads - 1;
 out_shutdown:
 	if (error < 0 && !nfsd_up_before)
-		nfsd_shutdown(net);
+		nfsd_shutdown_net(net);
 out_destroy:
 	nfsd_destroy(net);		/* Release server */
 out:

