Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:54280 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbaIBR7H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 13:59:07 -0400
Received: by mail-ie0-f176.google.com with SMTP id x19so8149124ier.21
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 10:59:06 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] lockd: Do not start the lockd thread before we've set nlmsvc_rqst->rq_task
Date: Tue,  2 Sep 2014 13:58:57 -0400
Message-Id: <1409680738-12491-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes an Oopsable race when starting lockd.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/lockd/svc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 673668a9eec1..c35cd43a06e6 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -306,7 +306,7 @@ static int lockd_start_svc(struct svc_serv *serv)
 	svc_sock_update_bufs(serv);
 	serv->sv_maxconn = nlm_max_connections;
 
-	nlmsvc_task = kthread_run(lockd, nlmsvc_rqst, "%s", serv->sv_name);
+	nlmsvc_task = kthread_create(lockd, nlmsvc_rqst, "%s", serv->sv_name);
 	if (IS_ERR(nlmsvc_task)) {
 		error = PTR_ERR(nlmsvc_task);
 		printk(KERN_WARNING
@@ -314,6 +314,7 @@ static int lockd_start_svc(struct svc_serv *serv)
 		goto out_task;
 	}
 	nlmsvc_rqst->rq_task = nlmsvc_task;
+	wake_up_process(nlmsvc_task);
 
 	dprintk("lockd_up: service started\n");
 	return 0;
-- 
1.9.3

