Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:16799 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965164Ab2LFPeJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 10:34:09 -0500
Subject: [PATCH 1/6] nfsd: pass proper net to nfsd_destroy() from NFSd kthreads
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 18:34:42 +0300
Message-ID: <20121206153442.30693.25959.stgit@localhost.localdomain>
In-Reply-To: <20121206153204.30693.11408.stgit@localhost.localdomain>
References: <20121206153204.30693.11408.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since NFSd service is per-net now, we have to pass proper network context in
nfsd_shutdown() from NFSd kthreads.
The simlies way I found is to get proper net from one of transports with
permanent sockets.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfssvc.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2cfd9c6..cee62ab 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -541,6 +541,8 @@ static int
 nfsd(void *vrqstp)
 {
 	struct svc_rqst *rqstp = (struct svc_rqst *) vrqstp;
+	struct svc_xprt *perm_sock = list_entry(rqstp->rq_server->sv_permsocks.next, typeof(struct svc_xprt), xpt_list);
+	struct net *net = perm_sock->xpt_net;
 	int err;
 
 	/* Lock module and set up kernel thread */
@@ -605,7 +607,7 @@ out:
 	/* Release the thread */
 	svc_exit_thread(rqstp);
 
-	nfsd_destroy(&init_net);
+	nfsd_destroy(net);
 
 	/* Release module */
 	mutex_unlock(&nfsd_mutex);

