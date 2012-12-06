Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:38675 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751676Ab2LFLWl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 06:22:41 -0500
Subject: [PATCH 2/8] nfsd: per-net NFSd up flag introduced
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 14:23:14 +0300
Message-ID: <20121206112314.29559.48129.stgit@localhost.localdomain>
In-Reply-To: <20121206111903.29559.4853.stgit@localhost.localdomain>
References: <20121206111903.29559.4853.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch introduces introduces per-net "nfsd_net_up" boolean flag, which has
the same purpose as general "nfsd_up" flag - skip init or shutdown of per-net
resources in case of they are inited on shutted down respectively.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h  |    2 ++
 fs/nfsd/nfssvc.c |   12 ++++++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index bca789d..da8741b 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -92,6 +92,8 @@ struct nfsd_net {
 
 	time_t nfsd4_lease;
 	time_t nfsd4_grace;
+
+	bool nfsd_net_up;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 038348b..6e17efd 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -21,6 +21,7 @@
 #include "nfsd.h"
 #include "cache.h"
 #include "vfs.h"
+#include "netns.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
 
@@ -205,8 +206,12 @@ static bool nfsd_up = false;
 
 static int nfsd_startup_net(struct net *net)
 {
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	int ret;
 
+	if (nn->nfsd_net_up)
+		return 0;
+
 	ret = nfsd_init_socks(net);
 	if (ret)
 		return ret;
@@ -217,6 +222,7 @@ static int nfsd_startup_net(struct net *net)
 	if (ret)
 		goto out_lockd;
 
+	nn->nfsd_net_up = true;
 	return 0;
 
 out_lockd:
@@ -257,8 +263,14 @@ out_racache:
 
 static void nfsd_shutdown_net(struct net *net)
 {
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	if (!nn->nfsd_net_up)
+		return;
+
 	nfs4_state_shutdown_net(net);
 	lockd_down(net);
+	nn->nfsd_net_up = false;
 }
 
 static void nfsd_shutdown(struct net *net)

