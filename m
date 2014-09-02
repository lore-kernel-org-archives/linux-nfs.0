Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:43491 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbaIBR7I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 13:59:08 -0400
Received: by mail-ie0-f178.google.com with SMTP id at1so8173924iec.37
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 10:59:07 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs: do not start the callback thread until we set rqstp->rq_task
Date: Tue,  2 Sep 2014 13:58:58 -0400
Message-Id: <1409680738-12491-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1409680738-12491-1-git-send-email-trond.myklebust@primarydata.com>
References: <1409680738-12491-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes an Oopsable race when starting up the callback server.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index e3dd1cd175d9..b8fb3a4ef649 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -235,7 +235,7 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
 
 	cb_info->serv = serv;
 	cb_info->rqst = rqstp;
-	cb_info->task = kthread_run(callback_svc, cb_info->rqst,
+	cb_info->task = kthread_create(callback_svc, cb_info->rqst,
 				    "nfsv4.%u-svc", minorversion);
 	if (IS_ERR(cb_info->task)) {
 		ret = PTR_ERR(cb_info->task);
@@ -245,6 +245,7 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
 		return ret;
 	}
 	rqstp->rq_task = cb_info->task;
+	wake_up_process(cb_info->task);
 	dprintk("nfs_callback_up: service started\n");
 	return 0;
 }
-- 
1.9.3

