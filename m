Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:61867 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbaHCRDV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:03:21 -0400
Received: by mail-qg0-f54.google.com with SMTP id z60so7686248qgd.41
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:03:20 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 05/11] lockd: Ensure that lockd_start_svc sets the server rq_task...
Date: Sun,  3 Aug 2014 13:03:07 -0400
Message-Id: <1407085393-3175-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/lockd/svc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 8f27c93f8d2e..b416b3355807 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -313,6 +313,8 @@ static int lockd_start_svc(struct svc_serv *serv)
 			"lockd_up: kthread_run failed, error=%d\n", error);
 		goto out_task;
 	}
+	nlmsvc_rqst->rq_task = nlmsvc_task;
+
 	dprintk("lockd_up: service started\n");
 	return 0;
 
-- 
1.9.3

