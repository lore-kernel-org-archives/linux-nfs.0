Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:38542 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753740Ab2LJJSe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2012 04:18:34 -0500
Subject: [PATCH 2/7] nfsd: pass net to nfsd_init_socks()
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 10 Dec 2012 12:19:09 +0300
Message-ID: <20121210091909.8855.89719.stgit@localhost.localdomain>
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
 fs/nfsd/nfssvc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 9beace6..9fd8496 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -182,18 +182,18 @@ int nfsd_nrthreads(void)
 	return rv;
 }
 
-static int nfsd_init_socks(void)
+static int nfsd_init_socks(struct net *net)
 {
 	int error;
 	if (!list_empty(&nfsd_serv->sv_permsocks))
 		return 0;
 
-	error = svc_create_xprt(nfsd_serv, "udp", &init_net, PF_INET, NFS_PORT,
+	error = svc_create_xprt(nfsd_serv, "udp", net, PF_INET, NFS_PORT,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
 
-	error = svc_create_xprt(nfsd_serv, "tcp", &init_net, PF_INET, NFS_PORT,
+	error = svc_create_xprt(nfsd_serv, "tcp", net, PF_INET, NFS_PORT,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
@@ -218,7 +218,7 @@ static int nfsd_startup(int nrservs)
 	ret = nfsd_racache_init(2*nrservs);
 	if (ret)
 		return ret;
-	ret = nfsd_init_socks();
+	ret = nfsd_init_socks(net);
 	if (ret)
 		goto out_racache;
 	ret = lockd_up(net);

