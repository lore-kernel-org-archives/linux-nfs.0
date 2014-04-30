Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:30707 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753647AbaD3CrT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 22:47:19 -0400
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <greg@kroah.com>, <lizefan@huawei.com>,
        <skinsbursky@parallels.com>, <h.huangqiang@huawei.com>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3.4 7/9] nfsd: pass proper net to nfsd_destroy() from NFSd kthreads
Date: Wed, 30 Apr 2014 10:43:42 +0800
Message-ID: <1398825824-6360-8-git-send-email-wengmeiling.weng@huawei.com>
In-Reply-To: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
References: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Stanislav Kinsbursky <skinsbursky@parallels.com>

commit 88c47666171989ed4c5b1a5687df09511e8c5e35 upstream.

Since NFSd service is per-net now, we have to pass proper network
context in nfsd_shutdown() from NFSd kthreads.

The simplest way I found is to get proper net from one of transports
with permanent sockets.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
[wengmeiling: backport to 3.4: adjust context]
Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 fs/nfsd/nfssvc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 0974818..5bc9380 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -483,6 +483,8 @@ static int
 nfsd(void *vrqstp)
 {
 	struct svc_rqst *rqstp = (struct svc_rqst *) vrqstp;
+	struct svc_xprt *perm_sock = list_entry(rqstp->rq_server->sv_permsocks.next, typeof(struct svc_xprt), xpt_list);
+	struct net *net = perm_sock->xpt_net;
 	int err, preverr = 0;
 
 	/* Lock module and set up kernel thread */
@@ -557,7 +559,7 @@ out:
 	/* Release the thread */
 	svc_exit_thread(rqstp);
 
-	nfsd_destroy(&init_net);
+	nfsd_destroy(net);
 
 	/* Release module */
 	mutex_unlock(&nfsd_mutex);
-- 
1.8.2.2


